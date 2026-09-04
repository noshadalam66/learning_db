#!/usr/bin/env node
/**
 * Runs every fenced code example in the language courses, in the runtime a
 * learner actually gets.
 *
 * This exists because of a bug that nothing else caught. MySQL treats a
 * backslash inside a string literal as an escape, so a seed carrying a Python
 * example containing \n wrote a real newline into the body: the seed loaded
 * without complaint, the page rendered, tests/verify.sql passed, and the only
 * symptom was that the code a learner copied would not parse. The check that
 * finds that is the one that runs the code.
 *
 * It drives the site rather than a local interpreter on purpose. The runtime
 * in the browser is Python 3.14; a local python3 is whatever the machine has,
 * and judging 3.14 syntax with 3.11 produces failures that are not real.
 *
 *   cd ../learning_website && php serve.php      # in one terminal
 *   node tests/run-code-fences.mjs               # in another
 *
 * Requires playwright and a seeded database behind the site.
 */
import { chromium } from 'playwright';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SITE = (process.env.SITE_URL || 'http://localhost:8080').replace(/\/$/, '');

// Only the languages whose examples are meant to run standalone. The HTML and
// CSS courses render documents rather than printing, so "did it error" is not
// a question their fences answer.
const COURSES = [
  { id: 'c0000001-0000-4000-8000-000000000008', fence: 'python', example: 'py-basics' },
];

function fencesFor(courseId, fence) {
  const sql =
    `SELECT l.slug, a.body FROM catalog.lessons l ` +
    `JOIN content.articles a ON a.lesson_id = l.id ` +
    `WHERE l.course_id = '${courseId}' ORDER BY l.slug\\G`;
  // Resolved from the repository root, so the test runs from anywhere.
  const out = execFileSync(path.join(ROOT, 'scripts/console.sh'),
    { input: sql, encoding: 'utf8', cwd: ROOT });

  const blocks = [];
  for (const chunk of out.split('*************************** ')) {
    const m = chunk.match(/slug: (\S+)\n\s*body: ([\s\S]*)/);
    if (!m) continue;
    const pattern = new RegExp('```' + fence + '\\n([\\s\\S]*?)```', 'g');
    let hit, n = 0;
    while ((hit = pattern.exec(m[2])) !== null) {
      blocks.push({ slug: m[1], n: ++n, code: hit[1] });
    }
  }
  return blocks;
}

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const page = await (await browser.newContext()).newPage();
let failures = [];
let total = 0;

for (const course of COURSES) {
  const blocks = fencesFor(course.id, course.fence);
  console.log(`\n${course.fence}: ${blocks.length} fences`);

  await page.goto(`${SITE}/playground.php?example=${course.example}`);
  await page.frameLocator('[data-output]').locator('#out')
    .filter({ hasNotText: 'Starting Python' }).waitFor({ timeout: 180000 });

  for (const block of blocks) {
    total++;
    const result = await page.evaluate((code) => {
      const frame = document.querySelector('[data-output]');
      return new Promise((resolve) => {
        const onMessage = (event) => {
          if (event.source !== frame.contentWindow) return;
          if (event.data.kind !== 'python-done') return;
          window.removeEventListener('message', onMessage);
          resolve(event.data);
        };
        window.addEventListener('message', onMessage);
        // Generous stdin: an example that calls input() should be exercised,
        // not reported as a failure for having nothing to read.
        frame.contentWindow.postMessage(
          { kind: 'python-run', token: 1, code, stdin: 'Aisha\n1997\nx\ny\nz' }, '*');
      });
    }, block.code);

    if (result.errors) {
      const shown = (await page.frameLocator('[data-output]').locator('#out').textContent()).trim();
      failures.push({ ...block, output: shown.slice(-240) });
      console.log(`  FAIL ${block.slug} #${block.n}`);
    } else {
      console.log(`  ok   ${block.slug} #${block.n}`);
    }
  }
}

await browser.close();

console.log();
if (failures.length) {
  console.log(`${failures.length} of ${total} fences failed:\n`);
  for (const f of failures) {
    console.log(`  ${f.slug} #${f.n}`);
    console.log('      ' + f.output.replace(/\n/g, '\n      ') + '\n');
  }
  process.exit(1);
}
console.log(`all ${total} fences ran clean`);
