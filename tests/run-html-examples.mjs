#!/usr/bin/env node
/**
 * Loads every HTML example from the database in a real browser and checks that the browser built
 * the structure the example is written as.
 *
 * WHY THIS AND NOT A LINTER. A browser never rejects HTML. Hand it
 * `<p><div>x</div></p>` and it silently produces two paragraphs and a div
 * between them, because the parser's job is to always produce a document. The
 * example still renders, so a screenshot proves nothing, and the reader learns
 * a structure that was never built. Comparing the written skeleton with the
 * parsed one is the check that catches it.
 *
 * WHAT IT COMPARES. Tags only, nesting included, text and attributes dropped:
 *
 *   written   <ul><li></li><li></li></ul>
 *   parsed    <ul><li></li><li></li></ul>
 *
 * An example that omits a closing tag the parser then infers will differ, and
 * that is deliberate: the course itself says to close non-void elements, and
 * an example is the worst place not to practise what it preaches.
 *
 * THREE PLACES THE DOM IS LEGITIMATELY NOT THE MARKUP, each handled rather
 * than excused:
 *   - <template> holds its children in a DocumentFragment, not in .children;
 *   - <noscript> contents are parsed as TEXT when scripting is on, so the
 *     element really has no element children;
 *   - a fragment of rows, list items or head content has to be parsed inside
 *     the element that legally contains it, or the parser throws it away.
 *
 *   ./scripts/migrate.sh && ./scripts/seed.sh
 *   node tests/run-html-examples.mjs [course-slug]
 *
 * Reads the lesson bodies out of the database rather than out of the seed, so
 * what is checked is what a learner will actually be served - including
 * anything MySQL did to the text on the way in.
 *
 * Requires playwright and a seeded database.
 */
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const COURSE = process.argv[2] || 'html-from-basics-to-expert';

/** Every ```html fence in a course's lessons, straight out of the database. */
function examplesFor(courseSlug) {
  const sql =
    'SELECT l.slug, a.body FROM catalog_lessons l ' +
    'JOIN content_articles a ON a.lesson_id = l.id ' +
    'JOIN catalog_courses c ON c.id = l.course_id ' +
    `WHERE c.slug = '${courseSlug}' ORDER BY l.\`position\`\\G`;

  const out = execFileSync(path.join(ROOT, 'scripts/console.sh'),
    { input: sql, encoding: 'utf8', cwd: ROOT });

  const found = [];
  for (const chunk of out.split('*************************** ')) {
    const m = chunk.match(/slug: (\S+)\n\s*body: ([\s\S]*)/);
    if (!m) continue;
    const pattern = /```html\n([\s\S]*?)```/g;
    let hit;
    let index = 0;
    while ((hit = pattern.exec(m[2])) !== null) {
      index += 1;
      found.push({ lesson: m[1], index, code: hit[1] });
    }
  }
  return found;
}

const VOID = new Set([
  'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta',
  'param', 'source', 'track', 'wbr',
]);

/**
 * Elements whose children the parser does not put in the element tree.
 *
 * <noscript> is NOT in this set, and that is a consequence of the structural
 * pass running with JavaScript disabled. With scripting ON a browser parses
 * noscript's contents as text, so the element really has no element children;
 * with scripting OFF it parses them as markup, which is the whole point of the
 * element. Since the structural pass is the one with scripting off, its
 * children are real - and listing it here would report every noscript block as
 * a divergence.
 */
const OPAQUE = new Set(['script', 'style', 'textarea', 'title']);

/** The skeleton of a written example: tag names and nesting, nothing else. */
function writtenSkeleton(source) {
  const out = [];
  const text = source.replace(/<!--[\s\S]*?-->/g, '').replace(/<!doctype[^>]*>/gi, '');

  const tag = /<\s*(\/?)([a-zA-Z][a-zA-Z0-9-]*)((?:"[^"]*"|'[^']*'|[^>"'])*?)(\/?)>/g;
  let match;
  let opaqueDepth = 0;
  let opaqueName = '';

  while ((match = tag.exec(text)) !== null) {
    const [, closing, rawName, , selfClosing] = match;
    const name = rawName.toLowerCase();

    // Inside <noscript> or <script> the parser sees text, so neither does this.
    if (opaqueDepth) {
      if (closing && name === opaqueName) {
        opaqueDepth = 0;
        out.push(`</${name}>`);
      }
      continue;
    }

    if (closing) {
      out.push(`</${name}>`);
      continue;
    }

    out.push(`<${name}>`);
    if (VOID.has(name)) continue;
    if (selfClosing) { out.push(`</${name}>`); continue; }
    if (OPAQUE.has(name)) { opaqueDepth = 1; opaqueName = name; }
  }
  return out.join('');
}

/**
 * The same skeleton, read back out of the DOM the browser actually built.
 * Serialised in the page, so what is walked is the real tree.
 */
const PARSED_SKELETON = (rootSelector) => {
  const voidTags = new Set([
    'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta',
    'param', 'source', 'track', 'wbr',
  ]);
  const root = rootSelector === ':root-document'
    ? document.documentElement
    : document.querySelector(rootSelector);
  if (!root) return '(no such root)';

  const walk = (node) => {
    let out = '';
    // A <template>'s children live in its content fragment, not in .children.
    const children = node.tagName && node.tagName.toLowerCase() === 'template'
      ? node.content.children
      : node.children;

    for (const child of children) {
      const name = child.tagName.toLowerCase();
      out += `<${name}>`;
      if (!voidTags.has(name)) out += walk(child) + `</${name}>`;
    }
    return out;
  };
  return walk(root);
};

/**
 * Where an example has to be parsed for the parser to keep it.
 *
 * A bare <tr> outside a table is "foster parented" - moved out and its cells
 * dropped - so parsing it at the top level would report a failure that is an
 * artefact of the harness rather than of the example.
 */
function hostFor(code) {
  const head = code.trim().slice(0, 400).toLowerCase();

  if (/^<!doctype/.test(head)) return { wrap: (c) => c, root: ':root-document', strip: /^<html>|<\/html>$/g };
  if (/^<html[\s>]/.test(head)) return { wrap: (c) => `<!doctype html>${c}`, root: ':root-document', strip: /^<html>|<\/html>$/g };
  // A <body>-only or <head>-only fragment is compared against that element
  // alone: the parser supplies the other one, and counting an implied
  // <head></head> as a divergence would fail every such example.
  if (/^<body[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html>${c}</html>`, root: 'body', strip: /^<body>|<\/body>$/g };
  // Head and body written side by side without the <html> around them: the
  // parser supplies only the root, so both halves are still compared.
  if (/^<head[\s>]/.test(head) && /<body[\s>]/.test(code.toLowerCase())) {
    return { wrap: (c) => `<!doctype html><html>${c}</html>`, root: ':root-document', strip: null };
  }
  if (/^<head[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html>${c}<body></body></html>`, root: 'head', strip: /^<head>|<\/head>$/g };
  if (/^<(meta|title|link|base)[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html><head>${c}</head><body></body></html>`, root: 'head', strip: null };
  if (/^<(tr|td|th|tbody|thead|tfoot|caption|colgroup|col)[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html><body><table>${c}</table></body></html>`, root: 'table', strip: null };
  if (/^<(li|dt|dd)[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html><body><ul>${c}</ul></body></html>`, root: 'ul', strip: null };
  if (/^<(option|optgroup)[\s>]/.test(head)) return { wrap: (c) => `<!doctype html><html><body><select>${c}</select></body></html>`, root: 'select', strip: null };

  return { wrap: (c) => `<!doctype html><html><body>${c}</body></html>`, root: 'body', strip: null };
}

const examples = examplesFor(COURSE);
if (examples.length === 0) {
  console.error(`no html examples found for ${COURSE} - is the database seeded?`);
  process.exit(1);
}
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });

/*
 * TWO CONTEXTS, because there are two questions and running them together
 * answers neither.
 *
 * The structural question is "did the PARSER build what was written". An
 * example whose script appends list items answers that wrongly in a page
 * where the script has run: the DOM legitimately contains elements the
 * markup does not, and the example is correct. So the skeleton is compared
 * with JavaScript switched off, where the DOM is exactly what the parser
 * produced and nothing else.
 *
 * The runtime question is "does anything throw", and that obviously needs
 * JavaScript switched on. It gets its own pass.
 */
const parsing = await browser.newContext({ javaScriptEnabled: false });
const running = await browser.newContext();

let checked = 0;
const failures = [];

for (const example of examples) {
  const host = hostFor(example.code);

  // Pass one: structure, with no script able to change it.
  const page = await parsing.newPage();
  await page.setContent(host.wrap(example.code), { waitUntil: 'load' });
  const parsed = await page.evaluate(PARSED_SKELETON, host.root);
  await page.close();

  let written = writtenSkeleton(example.code);
  if (host.strip) written = written.replace(host.strip, '');

  checked += 1;

  if (written !== parsed) {
    failures.push({
      ...example,
      reason: 'the browser built a different structure',
      diverges: firstDivergence(written, parsed),
    });
    continue;
  }

  // Pass two: does it throw? Only worth asking of an example with script in it.
  if (!/<script[\s>]/i.test(example.code) && !/\son[a-z]+\s*=/i.test(example.code)) continue;

  const live = await running.newPage();
  const consoleErrors = [];
  live.on('console', (m) => { if (m.type() === 'error') consoleErrors.push(m.text()); });
  live.on('pageerror', (e) => consoleErrors.push(String(e)));

  await live.setContent(host.wrap(example.code), { waitUntil: 'load' });
  await live.waitForTimeout(80);
  await live.close();

  if (consoleErrors.length) {
    failures.push({ ...example, reason: 'console error', detail: consoleErrors.join(' | ') });
  }
}

function firstDivergence(a, b) {
  let i = 0;
  while (i < a.length && i < b.length && a[i] === b[i]) i += 1;
  return `written ...${a.slice(Math.max(0, i - 50), i + 50)}\n            parsed  ...${b.slice(Math.max(0, i - 50), i + 50)}`;
}

await browser.close();

for (const failure of failures) {
  console.log(`FAIL ${failure.lesson} example ${failure.index}: ${failure.reason}`);
  if (failure.detail) console.log(`  ${failure.detail}`);
  if (failure.diverges) console.log(`  ${failure.diverges}`);
  console.log('  ' + failure.code.split('\n').slice(0, 14).join('\n  '));
  console.log();
}

console.log(`${checked} example(s) checked, ${failures.length} failing`);
process.exit(failures.length ? 1 : 0);
