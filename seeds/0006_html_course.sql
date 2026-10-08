-- ===========================================================================
-- Seed 06 : the HTML course, basics -> intermediate -> advanced -> expert
--
-- One course, four modules, one per level. The level lives in the module
-- rather than in four separate courses so a learner keeps a single enrolment
-- and a single progress percentage all the way from <!DOCTYPE html> to a
-- custom element.
--
-- Every lesson body is Markdown carrying at least one fenced ```html block.
-- That fence is the contract with the front end: the Content Service renders
-- it to <pre><code class="language-html">, and the website turns each of those
-- into a code box with a "Try yourself!" button that opens the playground.
-- Change the fence language and the button quietly disappears, so the tests
-- in learning_website/smoke.php assert it is still there.
-- ===========================================================================

-- Lena is seeded as a student in 0001; the HTML course needs her as its author.
INSERT INTO identity_user_roles (user_id, role_id)
SELECT u.id, r.id
  FROM identity_users u
  JOIN identity_roles r ON r.name = 'instructor'
 WHERE u.email = 'lena@learning.test'
ON DUPLICATE KEY UPDATE granted_at = identity_user_roles.granted_at;

INSERT INTO catalog_tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-000000000008', 'html',          'HTML'),
  ('bbbbbbb1-0000-4000-8000-000000000009', 'accessibility', 'Accessibility'),
  ('bbbbbbb1-0000-4000-8000-00000000000a', 'web-standards', 'Web Standards')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ---------------------------------------------------------------------------
-- The course
-- ---------------------------------------------------------------------------
INSERT INTO catalog_courses
  (id, slug, title, subtitle, overview, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000004',
   'html-from-basics-to-expert',
   'HTML: From Basics to Expert',
   'Four levels, twelve lessons, every example runnable in the browser',
   'HTML is the language every web page is written in. It is not a programming language: it does not calculate or decide anything. It says what the things on a page are - this is a heading, this is a link, this is a table of sales figures - and the browser, the search engine and the screen reader all work from that answer.

That is why it is worth more attention than it usually gets. CSS can make any element look like any other, so a page built from meaningless divs can be made to look perfect and still be unusable with a keyboard, unreadable aloud, and invisible to the thing that decides whether anyone finds it. The markup is the layer that carries meaning, and nothing above it can put the meaning back.

It is also the smallest useful thing you can learn in web development. By the end of Level 1 you can build a page that works. Nothing else on this site has that ratio.',
   -- catalog_courses.description is plain text, not Markdown. Only
   -- content_articles carries a format column, and only that body is rendered.
   -- Asterisks here would reach the page as literal asterisks.
   'A complete path through HTML in four levels. Level 1, Basic, gets a valid document on screen and teaches the elements you will use every day. Level 2, Intermediate, covers the two hard parts of real pages: tables that actually communicate data, and forms that validate themselves. Level 3, Advanced, moves to semantic layout, accessible components and the metadata that decides how your page looks when someone shares it. Level 4, Expert, finishes with templates, custom elements, loading performance and progressive enhancement.

This course assumes nothing. If you have never written a tag, Level 1 starts with the nine lines every page begins with and explains what each one is for. If you already write HTML every day, treat Level 1 as half an hour of revision and start properly at Level 3: most working developers have never read the rules on landmarks, labelling or what a screen reader does with a div, and that is where the hours here pay for themselves.

Every level has the same shape: three lessons, then a Level Check quiz drawn from them, and an Expert Exam after Level 4. A lesson is one sitting - a short explanation, a complete example, then the edge cases that bite in real pages. Nothing is a fragment; every example is a whole file you can save and open.

Every lesson ships a complete, professional code example. None of them are fragments: each one is a document you can paste into a file and open. Press the "Try yourself!" button under any example and it opens in the playground, where you can edit it on the left and watch the rendered result on the right.

By the end you will be able to build a page that is valid, accessible and fast without reaching for a framework: tables a screen reader can read aloud, forms that validate before a line of JavaScript runs, metadata that controls how a link previews, and a loading order that does not block the first paint.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '55555555-5555-4555-8555-555555555555',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/html-from-basics-to-expert.jpg', 0,
   JSON_ARRAY('Write a valid, accessible HTML5 document from memory',
              'Mark up tables and forms that work without a line of JavaScript',
              'Structure a page with landmarks a screen reader can navigate',
              'Control how a page is previewed, indexed and shared',
              'Build reusable markup with templates and custom elements',
              'Cut load time with preloads, lazy images and correct script attributes'),
   JSON_ARRAY('A text editor and a browser', 'No previous HTML required'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000008'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000009'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

-- ---------------------------------------------------------------------------
-- The four levels
-- ---------------------------------------------------------------------------
INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'Level 1 - Basic',
   'Where every page starts. You will write the document skeleton from memory, learn which text element means what - and why a heading is structure rather than a size - and cover the three things every page is made of: words, links and pictures. By the end of this level you can build a page that validates and reads well with no CSS and no JavaScript at all.', 1),
  ('d0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'Level 2 - Intermediate',
   'The two parts of HTML that most often go wrong in real projects, and the one that costs the most bandwidth. Tables first - headers, scope and captions, the markup that decides whether a screen reader reads data or noise - then forms, where the browser will validate for you if you let it, and finally images and media that fit the screen they land on.', 2),
  ('d0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'Level 3 - Advanced',
   'Markup that carries meaning rather than just shape. Landmarks and sectioning give a page a structure assistive technology can navigate; the components lesson covers the interactive patterns people most often rebuild badly by hand; head metadata decides how the page is indexed, and what it looks like when somebody shares the link.', 3),
  ('d0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'Level 4 - Expert',
   'The parts that separate a page which works from one which holds up. Templates and custom elements let you reuse markup with no build step; the performance lesson covers preloading, lazy images and the script attributes that stop the parser blocking; progressive enhancement is how all of it behaves when one piece fails to arrive.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

-- ---------------------------------------------------------------------------
-- Twelve lessons, three per level. All articles: this course is read-and-run,
-- not watch-and-forget, so there is no video metadata for any of them.
-- ---------------------------------------------------------------------------
INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Level 1 - Basic
  ('e0000001-0000-4000-8000-000000000011', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'the-document-skeleton', 'The Document Skeleton',
   'Every HTML page ever shipped starts from the same nine lines, and they are worth knowing by heart: a page that omits one still renders, because the browser repairs it silently, and then behaves strangely in a way nothing points at.',
   'article', 'published', 1, 420, 1),
  ('e0000001-0000-4000-8000-000000000012', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'text-headings-and-meaning', 'Text, Headings and Meaning',
   'Choosing the right text element is HTML; everything about how it looks belongs to CSS. The question to ask about a piece of text is not how it should look but what it is - and headings answer it as an outline, not as a font size.',
   'article', 'published', 2, 480, 1),
  ('e0000001-0000-4000-8000-000000000013', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'links-images-and-lists', 'Links, Images and Lists',
   'Three elements carry most of the web, and each has an attribute people leave off: a link that does not say where it goes, an image with no alt text, a list that is really a stack of divs. Each omission has a specific cost.',
   'article', 'published', 3, 540, 0),

  -- Level 2 - Intermediate
  ('e0000001-0000-4000-8000-000000000014', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'tables-that-communicate', 'Tables That Communicate Data',
   'A table is the right element for two-dimensional data and the wrong one for layout, and the difference is not aesthetic: a screen reader announces the shape and then reads each cell against its headers. Without a caption and scope it reads a grid of numbers.',
   'article', 'published', 1, 600, 0),
  ('e0000001-0000-4000-8000-000000000015', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'forms-and-native-validation', 'Forms and Native Validation',
   'The browser will label, validate, autofill and describe your form for free. Most of the JavaScript written for forms re-implements something that was already there and does it worse - without keyboard support, and without telling anyone what went wrong.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000016', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'responsive-images-and-media', 'Responsive Images and Media',
   'Sending a 2400-pixel photograph to a phone wastes the visitor data allowance and their battery, and fixing it is the easiest performance win on most sites. One image element, several files, and the browser picking the cheapest one that still looks right.',
   'article', 'published', 3, 660, 0),

  -- Level 3 - Advanced
  ('e0000001-0000-4000-8000-000000000017', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'semantic-layout-and-landmarks', 'Semantic Layout and Landmarks',
   'Six elements replace a page full of div class=header and give screen reader users something a sighted reader has always had: the ability to skim. Landmarks are that skimming interface, and this is where each one goes.',
   'article', 'published', 1, 660, 0),
  ('e0000001-0000-4000-8000-000000000018', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'accessible-components', 'Accessible Interactive Components',
   'The accessible version of most components is the one built on an element the browser already understands. Focus, keyboard handling, escape-to-close and the announcements are hard to get right - so disclosure, dialog and tabs, built on what is already there.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000019', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'head-metadata-and-sharing', 'Head Metadata and Sharing',
   'Nobody looks at the head, and it decides what the page is in a search result, in a shared link, on a phone home screen and in a browser tab. Per byte written it is the highest-leverage markup in the document.',
   'article', 'published', 3, 600, 0),

  -- Level 4 - Expert
  ('e0000001-0000-4000-8000-00000000001a', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'templates-and-custom-elements', 'Templates and Custom Elements',
   'The template element is markup the parser reads but does not render: no images fetched, no scripts run, no styles applied - a stencil you stamp out. A custom element is a tag you define yourself, with lifecycle callbacks the browser calls for you.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000001b', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-that-loads-fast', 'HTML That Loads Fast',
   'Most of a page loading behaviour is decided by attributes in the first few kilobytes of HTML, before any CSS or JavaScript has run. Getting them right costs nothing at runtime and is usually worth more than any amount of bundling.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-00000000001c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'progressive-enhancement', 'Progressive Enhancement in Practice',
   'Build the version that works with plain HTML, then add the version that feels instant. The order matters: the second is an enhancement of the first rather than a replacement, and the first is what is left when the script fails to load.',
   'article', 'published', 3, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
--
-- body_html is left NULL throughout. It is a render cache, and the Content
-- Service fills it from body on first read; seeding it here would mean
-- maintaining the same document twice and letting the two drift.
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000011',
   'The Document Skeleton',
   'markdown',
   '# The Document Skeleton

Every HTML page ever shipped starts from the same handful of lines. They are worth knowing by heart, and not because anybody will test you on them. They are worth knowing because a page that omits one of them still **renders** - the browser repairs it silently and shows you something - and then behaves strangely in a way that is very hard to trace back to the missing line weeks later.

This lesson is those lines, what each one actually does, and what specifically breaks when it is absent.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A page that does everything right</title>
  </head>
  <body>
    <h1>Hello</h1>
  </body>
</html>
```

Six lines of machinery around one line of content. Each of the six is load-bearing.

## The doctype is a switch, not a declaration

`<!DOCTYPE html>` looks like it announces a version. It does not. Modern HTML has no version to announce; this line exists to put the browser into **standards mode**.

Leave it out and the browser enters **quirks mode**, which is a deliberate emulation of how browsers behaved in 1999 so that pages written then still work. In quirks mode:

- `width` on an element includes its padding and border, rather than excluding them - the opposite of what every CSS written this century assumes.
- Vertical margins between some elements stop collapsing.
- An image inside a table cell gets a mysterious few pixels of space under it.
- Several CSS features simply do not apply.

The symptom is always the same and always baffling: your layout is close but every box is a few pixels wrong, and nothing in your stylesheet explains it. You can check in the browser console:

```javascript
document.compatMode
// "CSS1Compat"  -> standards mode, correct
// "BackCompat"  -> quirks mode, the doctype is missing
```

It must be the very first thing in the file. A comment, a blank line or a stray character before it is enough to lose it in some browsers.

## lang is read by machines, and they act on it

`<html lang="en">` tells the page what language it is in. Three things read it and change their behaviour.

**A screen reader** chooses its pronunciation rules from it. Without `lang`, a screen reader set up for a French user will read your English page with French phonetics, which is not slightly wrong - it is unintelligible. This is the single cheapest accessibility fix in HTML.

**The browser** chooses hyphenation and spell-check dictionaries from it, and decides whether to offer a translation.

**A search engine** uses it as one signal of who the page is for.

Use a language subtag - `en`, `fr`, `hi`, `ar` - optionally with a region when it genuinely matters, as in `en-GB` or `pt-BR`. If part of the page is in another language, say so on that part:

```html
<p>The French call it <span lang="fr">le shadow DOM</span>, which helps nobody.</p>
```

## The charset must be early, and utf-8

`<meta charset="utf-8">` tells the browser how the bytes in the file map to characters. Get it wrong and text that is not plain ASCII arrives mangled: an apostrophe becomes a small constellation of symbols, a name with an accent in it becomes unreadable, an emoji becomes a question mark in a box. The usual name for this is mojibake, and once it is stored in a database it is painful to undo.

Two details matter.

**It has to be utf-8.** Not because of politics but because every other encoding can represent only part of the world, and your users are not confined to that part. A learner called Grigoryev, a lesson about CSS content with a tick in it, a quiz option containing a mathematical symbol: all of them need it.

**It has to be in the first 1024 bytes of the document.** The browser begins parsing before it knows the encoding; it guesses, and when it reaches the charset declaration it starts again with the right one. If that declaration is further in than a kilobyte, the browser gives up waiting and keeps its guess. In practice this means: put it immediately after `<head>`, before the title, before any other meta, and certainly before any inline style or script.

## The viewport, or your site is unusable on a phone

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

Without this line, a mobile browser pretends to be a 980-pixel-wide desktop and then zooms the whole rendered page out to fit the screen. Your responsive CSS never fires, because as far as the browser is concerned the viewport really is 980 pixels wide. The page is not broken - it is a perfect miniature of the desktop layout, with 6-point text.

`width=device-width` says use the real width. `initial-scale=1` says do not zoom on load.

Two things people add here that they should not:

- `maximum-scale=1` or `user-scalable=no`. These stop a visitor pinching to zoom. For somebody with low vision that is the difference between a usable page and an unusable one, and browsers increasingly ignore it anyway. Do not.
- `shrink-to-fit=no`. A workaround for an iOS bug from 2016. It does nothing now.

## The title is the page, almost everywhere

`<title>` is one of the most-used strings you will write. It is the browser tab, the bookmark name, the blue line in a search result, the entry in the history, and the suggested text when somebody shares the link.

Write it for somebody who cannot see the page:

```html
<!-- weak -->
<title>Home</title>
<title>Untitled Document</title>

<!-- useful -->
<title>Semantic Layout and Landmarks - HTML - Omni Academy</title>
```

Most specific part first, because a tab shows the first 20 characters or so and that is all somebody scanning twelve tabs will read. Keep it under about 60 characters or a search result will truncate it - and it is better that you choose where it ends than that the engine does.

Every page needs its own. A site where every tab says the same thing is a site nobody can navigate with the keyboard.

## head and body do different jobs

Everything in `<head>` is **about** the document: its title, its encoding, its stylesheets, its description for a search engine. None of it is drawn.

Everything in `<body>` **is** the document. All of it is drawn.

You can omit both tags - the browser infers them - and you should not. The inference is based on what it meets first, so a stray text node at the top of your file silently closes `<head>` and starts `<body>`, and the stylesheet link that follows ends up in the body where it still works but no longer tells you anything true about the file.

## What actually goes wrong

| Symptom | Cause |
|---|---|
| Boxes a few pixels wrong everywhere, CSS looks right | No doctype: quirks mode |
| Accented characters are rubbish | Missing or late charset |
| Site is a tiny desktop page on a phone | Missing viewport meta |
| Every browser tab says the same thing | One title reused, or none |
| Screen reader pronounces the page wrongly | No lang attribute |
| A stylesheet in the body for no reason | Content before `<head>` closed it |

Each one of these is a different person losing an afternoon. None costs more than one line to prevent.

## Write it once, keep it

The skeleton does not vary from project to project. Put it in a snippet, a template, or your editor''s new-file content, and never type it again. What varies is the title, the language and what goes in the body; the rest is the same on every page you will ever write, and that is exactly why it is worth getting right once.
',
   'Every HTML page ever shipped starts from the same nine lines. They are worth knowing by heart, because a page that omits one still renders - the browser repairs it silently - and then behaves strangely.', 7, 1306,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000012',
   'Text, Headings and Meaning',
   'markdown',
   '# Text, Headings and Meaning

Choosing the right text element **is** HTML. Everything else - the layout, the colour, the spacing - belongs to CSS. The question to ask about every piece of text on a page is not "how should this look" but "what is this", and once you are asking the right question the markup usually writes itself.

This matters because the answer is read by more than one audience. A sighted reader sees your CSS. A screen reader user hears your elements. A search engine indexes your elements. A reader-mode view strips your CSS entirely and shows only your elements. Get the elements right and all four work; get them wrong and only the first one does.

## Headings are an outline, not a font size

The commonest mistake in HTML is picking a heading level because of how big it looks. `h1` is large, `h3` is smaller, so somebody who wants a smaller heading writes `h3`.

Headings are a document outline. `h1` is the title of the page, `h2` is a section of it, `h3` is a subsection of that `h2`. Nesting them correctly produces a table of contents that software can read.

```html
<h1>HTML</h1>
  <h2>Text elements</h2>
    <h3>Headings</h3>
    <h3>Paragraphs</h3>
  <h2>Forms</h2>
    <h3>Inputs</h3>
```

This is not a style preference. Screen reader users navigate long pages by jumping between headings - it is the single most-used navigation feature in a screen reader - and a page where the levels skip around gives them a contents list that makes no sense. Pressing "next heading" and landing somewhere unrelated is the equivalent of a broken link.

Three rules follow:

- **One `h1` per page**, naming what the page is.
- **Do not skip levels on the way down.** `h2` then `h4` leaves a gap in the outline. Going back up is fine - `h3` then `h2` just means a new section started.
- **Never choose a level for its size.** If an `h2` is too big, make it smaller in CSS. That is what CSS is for.

```css
/* The heading is an h2 because of where it sits in the document.
   It is this size because of how it should look. Two separate decisions. */
.card h2 { font-size: 1.1rem; }
```

## Paragraphs, and what is not a paragraph

`<p>` is a paragraph of prose. It is not a generic container for a line of text, and `<br>` is not a way to make paragraphs.

```html
<!-- wrong: one paragraph pretending to be three -->
<p>First thought.<br><br>Second thought.<br><br>Third.</p>

<!-- right -->
<p>First thought.</p>
<p>Second thought.</p>
<p>Third.</p>
```

The second version can be styled, counted, read one at a time by a screen reader and spaced consistently by one CSS rule. The first is a single run of text with gaps hammered into it.

`<br>` has one legitimate use: a line break that is part of the content rather than a visual separation. A postal address, a line of poetry, a verse. If removing it would change the meaning rather than the look, it belongs.

## Emphasis means something

There are two pairs of elements here, and the difference is real.

- `<em>` is **stress emphasis** - the word you would lean on when speaking the sentence. A screen reader changes its intonation. Renders italic.
- `<i>` is text that is set apart for some other reason: a technical term on first use, a thought, a word in another language, a taxonomic name. Also renders italic. No emphasis implied.
- `<strong>` is **importance** - a warning, a caveat, the part you must not miss. Renders bold.
- `<b>` is text drawn attention to without extra importance: a keyword in a summary, a product name in a review. Renders bold.

```html
<p>You <em>must</em> call this before the request starts.</p>
<p><strong>This deletes the row permanently.</strong> There is no undo.</p>
<p>The <i>cascade</i> is what decides which rule wins.</p>
```

If you are unsure, `<em>` and `<strong>` are the safer defaults - they carry meaning, and meaning degrades better than decoration.

## Quotations, code and small print

```html
<blockquote cite="https://example.com/spec">
  <p>Authors must not use the longdesc attribute.</p>
  <footer>- The HTML specification</footer>
</blockquote>

<p>Press <kbd>Ctrl</kbd> + <kbd>S</kbd> to save.</p>
<p>The function returns <code>null</code> when nothing matches.</p>
<p>The output was <samp>Permission denied</samp>.</p>
<p>Replace <var>name</var> with your own.</p>

<p><small>Prices exclude tax.</small></p>
```

`<q>` is for a short inline quotation and the browser supplies the quotation marks itself - which is why typing them as well gives you two sets.

`<code>` is for a fragment of code. For a block of code, wrap a `<code>` in a `<pre>`, because `<pre>` is what preserves the whitespace:

```html
<pre><code>function add(a, b) {
  return a + b;
}</code></pre>
```

Indenting that markup prettily would put the indentation into the output, which is the one place in HTML where your source formatting shows up on the page.

## Dates, abbreviations and edits

```html
<p>Published <time datetime="2026-10-07">7 October 2026</time>.</p>
<p>It uses <abbr title="Cascading Style Sheets">CSS</abbr> for layout.</p>
<p>The limit is <del>20</del> <ins>50</ins> requests a minute.</p>
```

`<time datetime="...">` gives a machine the unambiguous form while the reader sees the friendly one. "7 October 2026" is ambiguous to software and "2026-10-07" is ugly to a person; this element lets you have both.

`<abbr title="...">` expands an abbreviation on hover and for a screen reader. Use it on first appearance, not on every one.

## Lists are three different things

```html
<ul>  <!-- order does not matter -->
  <li>Eggs</li>
  <li>Milk</li>
</ul>

<ol>  <!-- order does matter -->
  <li>Install the dependencies</li>
  <li>Run the migrations</li>
  <li>Start the server</li>
</ol>

<dl>  <!-- name and value -->
  <dt>Doctype</dt>
  <dd>Puts the browser into standards mode.</dd>
  <dt>Viewport</dt>
  <dd>Tells a phone to use its real width.</dd>
</dl>
```

A screen reader announces "list, 2 items" before reading one, which tells a listener how much is coming. A stack of divs announces nothing.

Use `<ol>` whenever the sequence carries meaning - steps, rankings, a procedure - even if you then style the numbers away. Reversing an `<ol>` in CSS does not change what the markup says, which is the point.

## What goes wrong

**Headings chosen by size.** The outline becomes meaningless and screen reader navigation breaks. Fix in CSS, not in markup.

**Everything is a div.** A div has no meaning at all. It is the right element when there genuinely is no meaning - a wrapper that exists only to be positioned. Reach for it last, not first.

**`<br>` used as spacing.** Produces one unstylable paragraph, and reads as a single run of text.

**Text with no element at all.** A bare string inside a div is a paragraph the browser cannot name, so no reader-mode, no screen-reader paragraph navigation, nothing to style.

**`<span>` carrying meaning via a class.** `<span class="important">` is invisible to anything that is not your stylesheet. `<strong>` is the same visual result and is understood by everything.

## The test

Turn the stylesheet off. Most browsers will do this from the developer tools in one click.

What you are left with should still be readable and still be structured: a title, sections with headings, paragraphs, lists that look like lists. If what you see is an undifferentiated wall of text, the meaning was in the CSS - which means it was never really in the page at all.
',
   'Choosing the right text element is HTML. Everything else - layout, colour, spacing - belongs to CSS. The question to ask about every piece of text is not how should this look but what is this.', 6, 1212,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000013',
   'Links, Images and Lists',
   'markdown',
   '# Links, Images and Lists

Three elements carry most of the web. Each one has an attribute people routinely leave off, and each omission has a specific, measurable cost - a page that cannot be navigated, a reader who learns nothing from your illustration, a layout that jumps under somebody''s finger as they go to tap.

## A link goes somewhere. Say where.

```html
<a href="/courses">Browse the courses</a>
```

The text between the tags is the only thing many people ever see of a link, because a screen reader can list every link on the page out of context. That list is useless if half of it says "click here" and the other half says "read more".

```html
<!-- useless out of context -->
<p>We wrote about the cascade. <a href="/css/cascade">Read more</a>.</p>

<!-- says where it goes -->
<p>We wrote about <a href="/css/cascade">how the cascade decides which rule wins</a>.</p>
```

The rule: the link text should make sense read on its own. If you genuinely cannot make it work, there is an escape hatch:

```html
<a href="/report.pdf">
  Download <span class="visually-hidden">the 2026 accessibility report as a</span> PDF
</a>
```

### Opening in a new tab

`target="_blank"` takes the decision away from the reader, who already has middle-click and a context menu. Use it sparingly - a help document opened from a half-finished form is a fair case - and when you do, say so and add `rel`:

```html
<a href="https://example.com" target="_blank" rel="noopener noreferrer">
  The specification
  <span class="visually-hidden">(opens in a new tab)</span>
</a>
```

`rel="noopener"` stops the new page getting a `window.opener` handle back to yours, which it could use to navigate your tab somewhere else. Modern browsers imply it for `_blank`, and writing it costs nothing and covers the ones that do not.

### Links versus buttons

This is the most common semantic mistake on the web.

- A **link** navigates. It changes the address. It can be opened in a new tab, bookmarked, copied.
- A **button** performs an action. Submits, opens a dialog, deletes a row, toggles something.

```html
<!-- wrong: a link that is not going anywhere -->
<a href="#" onclick="openDialog()">Settings</a>

<!-- right -->
<button type="button" onclick="openDialog()">Settings</button>
```

The `href="#"` version is reached by the keyboard but is announced as a link, so a screen reader user expects to be taken somewhere. It also does nothing without JavaScript, and scrolls the page to the top if the handler fails.

### Other protocols

```html
<a href="mailto:hello@example.com">Email us</a>
<a href="tel:+441234567890">Call us</a>
<a href="#section-two">Jump to section two</a>
<a href="/report.pdf" download>Download the report</a>
```

## An image needs alt. Which alt depends.

`alt` is not a caption and it is not optional. It is what the image **means** to somebody who cannot see it, and the right value depends entirely on the job the image is doing.

```html
<!-- informative: describe what matters about it -->
<img src="/chart.png"
     alt="Signups doubled between January and March, then flattened.">

<!-- decorative: say explicitly that there is nothing to say -->
<img src="/swoosh.svg" alt="">

<!-- functional: describe the action, not the picture -->
<a href="/"><img src="/logo.svg" alt="Omni Academy home"></a>
```

Three mistakes, each with a cost:

- **Omitting `alt` entirely.** A screen reader falls back to reading the file name, so a listener hears "i m g underscore 4 7 2 1 dot p n g". An empty `alt=""` is a statement - this image carries nothing - and is correct for decoration. A missing `alt` is an absence, and is never correct.
- **Describing the file instead of the meaning.** `alt="chart"` tells a listener there is a chart and nothing about what it shows.
- **"Image of" or "Picture of".** The element already says it is an image. Start with the content.

For something complex - a diagram, a data table rendered as a picture - the alt text should be a sentence that carries the conclusion, and the detail belongs in the page near it where everybody benefits from it.

### Size the box before the image arrives

```html
<img src="/cover.jpg" alt="..." width="800" height="450">
```

Those attributes are not the display size; CSS still controls that. They give the browser the **aspect ratio**, so it can reserve the right amount of space before the file has downloaded.

Without them, the page lays out with the image at zero height, then re-lays out when it arrives, and everything below jumps down. If the reader was about to tap a link, they now tap whatever moved into its place. This is the single largest cause of layout shift on most sites, and the fix is two attributes.

### Loading and decoding

```html
<img src="/hero.jpg" alt="..." width="1200" height="600" fetchpriority="high">
<img src="/below.jpg" alt="..." width="800" height="450" loading="lazy" decoding="async">
```

`loading="lazy"` tells the browser not to fetch an image until it is near the viewport. Put it on everything below the fold and on nothing above it - lazy-loading the hero image delays the thing the reader is waiting for.

## Lists say how many, and whether order matters

```html
<ul>
  <li>Validate the input</li>
  <li>Escape the output</li>
</ul>

<ol>
  <li>Clone the repository</li>
  <li>Install the dependencies</li>
  <li>Run the migrations</li>
</ol>
```

A screen reader announces "list, 3 items" and then "item 1 of 3" as it goes. That is navigation information a stack of divs cannot provide, and it is free.

Only `<li>` may be a direct child of `<ul>` or `<ol>`. A `<div>` in between breaks the list semantics in some assistive technology even though it looks identical.

Nesting goes **inside** an `<li>**, not between them:

```html
<ul>
  <li>Frontend
    <ul>
      <li>HTML</li>
      <li>CSS</li>
    </ul>
  </li>
  <li>Backend</li>
</ul>
```

Navigation is a list. It genuinely is a list of links, and marking it as one lets a screen reader tell somebody how many items are in the menu before they start through it:

```html
<nav aria-label="Main">
  <ul>
    <li><a href="/courses">Courses</a></li>
    <li><a href="/playground">Playground</a></li>
  </ul>
</nav>
```

## What goes wrong

| Symptom | Cause | Fix |
|---|---|---|
| Screen reader reads "i m g 4 7 2 1 dot j p g" | No `alt` attribute | Add one, empty if decorative |
| Page jumps as images load | No `width` and `height` | Add both, as the real pixel dimensions |
| A link list of "click here" and "read more" | Link text written for sighted context | Put the destination in the text |
| A link that does not navigate | `<a href="#">` with a click handler | Use `<button>` |
| Hero image loads last | `loading="lazy"` above the fold | Remove it there |
| Bulleted list with no list semantics | Divs with a bullet in CSS | Use `<ul>` and `<li>` |

## The habit worth forming

Three attributes, every time, without thinking about it: `alt` on every image, `width` and `height` on every image, and link text that says where it goes. None of them takes longer to write than to leave out, and between them they fix the majority of what an accessibility audit will find on an otherwise well-built page.
',
   'Three elements carry most of the web. Each one has an attribute people leave off, and each omission has a specific cost.', 6, 1169,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 2 - Intermediate
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000014',
   'Tables That Communicate Data',
   'markdown',
   '# Tables That Communicate Data

A table is the right element whenever you have two-dimensional data - rows of things, columns of facts about them. It is the wrong element for page layout, and the difference is not aesthetic.

When a screen reader meets a table it announces the shape - "table, 4 columns, 6 rows" - and then offers a different way of moving: cell by cell, with the headers announced each time. A listener in a well-marked table hears "Row 3, Product: Keyboard, Price: 45 pounds". In a badly marked one they hear "Keyboard. 45". The data is the same; one of them is usable.

## The parts, and what each one is for

```html
<table>
  <caption>Monthly signups, 2026</caption>
  <thead>
    <tr>
      <th scope="col">Month</th>
      <th scope="col">Signups</th>
      <th scope="col">Completed a course</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">January</th>
      <td>1,204</td>
      <td>318</td>
    </tr>
    <tr>
      <th scope="row">February</th>
      <td>1,655</td>
      <td>402</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <th scope="row">Total</th>
      <td>2,859</td>
      <td>720</td>
    </tr>
  </tfoot>
</table>
```

### caption

The table''s title, and it belongs **inside** the table rather than in a heading above it. That is what associates it, so a screen reader announces the caption as the listener enters the table - which is the moment they need to know what they are looking at. It must be the first child of `<table>`.

If you prefer it to look like a normal heading, style it. If you genuinely do not want it visible, keep it and hide it visually rather than deleting it.

### th and scope

A `<th>` is a header cell; a `<td>` is a data cell. `scope` says which cells the header governs.

- `scope="col"` - this header labels the column below it.
- `scope="row"` - this header labels the row across from it.

Without `scope`, a browser guesses, and it guesses from position. In a simple table it usually guesses right. In a table with row headers, a `<tfoot>`, or any irregularity, it does not - and a wrong guess is worse than no guess, because the listener is confidently told the wrong column name.

A first column of names, dates or labels is a column of **row headers**. Marking them `<th scope="row">` is what makes "Keyboard, Price: 45" possible instead of "45".

### thead, tbody, tfoot

These group the rows. They are not decoration:

- A browser can scroll `<tbody>` while keeping `<thead>` fixed.
- When the table is printed and breaks across pages, the `<thead>` repeats at the top of each one.
- `<tfoot>` is for summary rows - totals, averages - and may be written before or after `<tbody>` in the source; the browser puts it last either way.

## Cells that span

```html
<table>
  <caption>Opening hours</caption>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Morning</th>
      <th scope="col">Afternoon</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Weekdays</th>
      <td>9 to 12</td>
      <td>1 to 6</td>
    </tr>
    <tr>
      <th scope="row">Weekend</th>
      <td colspan="2">Closed</td>
    </tr>
  </tbody>
</table>
```

`colspan` and `rowspan` merge cells. They are legitimate and they make the table harder to read for software, so use them where the data genuinely is merged and not to achieve a visual effect.

When a table has two levels of header - a group header above column headers - `scope` is no longer enough, and you need `id` and `headers`:

```html
<tr>
  <th id="h-q1" colspan="2" scope="colgroup">Q1</th>
  <th id="h-q2" colspan="2" scope="colgroup">Q2</th>
</tr>
<tr>
  <th id="h-jan" headers="h-q1" scope="col">Jan</th>
  <th id="h-feb" headers="h-q1" scope="col">Feb</th>
  ...
</tr>
<tr>
  <td headers="h-q1 h-jan">1,204</td>
  ...
</tr>
```

This is verbose, and that is a signal. A table that needs it is often two tables wearing one hat, and splitting it usually serves readers better than marking it up perfectly.

## Numbers want the right alignment

```css
td { text-align: left; }
.numeric { text-align: right; font-variant-numeric: tabular-nums; }
```

Right-aligning numbers lines up the decimal points, which is what lets an eye compare magnitudes down a column. `tabular-nums` makes every digit the same width, so the columns do not shift between 1,111 and 8,888. Both are one line and both make a table of figures readable at a glance.

## Tables on a small screen

A table of five columns does not fit on a phone, and the honest fixes are few.

**Let it scroll, in its own container.** The simplest approach and usually the best. Make the container focusable and labelled so a keyboard user can reach the scroll:

```html
<div class="table-scroll" tabindex="0" role="region" aria-label="Monthly signups">
  <table> ... </table>
</div>
```

```css
.table-scroll { overflow-x: auto; }
```

**Show fewer columns.** Hide the least important ones below a breakpoint. Honest, as long as what is hidden is genuinely secondary.

**Restack each row as a card.** Each row becomes a block with the header repeated as a label. Works for a handful of rows and falls apart for many; it also loses the comparability that was the reason for a table.

What not to do is rebuild the table out of divs so it reflows. That throws away every one of the semantics above to solve a layout problem that `overflow-x` solves in one line.

## Never for layout

Before CSS could lay out a page, tables were how it was done. The cost was that every page announced itself as a data table, and a screen reader offered cell-by-cell navigation through a document that had no cells.

If you find yourself using a table for layout, you want CSS Grid or Flexbox. If you want a layout that behaves like a table - equal columns, cells that size to content - CSS has that too:

```css
.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
```

## What goes wrong

| Symptom | Cause |
|---|---|
| Listener hears numbers with no labels | `<td>` where `<th scope="row">` belongs |
| Wrong column announced for a cell | No `scope`, browser guessed |
| Listener does not know what the table is | Caption in an `<h3>` above instead of inside |
| Headers do not repeat when printed | No `<thead>` |
| Columns of figures impossible to compare | Left-aligned, proportional digits |
| Table overflows the screen on a phone | No scroll container |

## The check

Ask somebody to read you the value in the third column of the fifth row, without looking at the headings.

If they can, your table is marked up. If they have to count across the top row first, it is not - and that counting is exactly what you are asking a screen reader user to do every single time.
',
   'A table is the right element whenever you have two-dimensional data, and the wrong element for page layout. The difference is not aesthetic.', 5, 1081,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000015',
   'Forms and Native Validation',
   'markdown',
   '# Forms and Native Validation

The browser will label, validate, autofill and describe your form for free. Most of the JavaScript written for forms re-implements something that was already there and does it worse - without keyboard support, without telling a screen reader what went wrong, and without working at all if the script fails to load.

This lesson is what you get for nothing, and the small number of places where you do have to help.

## A label is not optional and it is not decoration

```html
<label for="email">Email address</label>
<input type="email" id="email" name="email">
```

The `for` attribute must match the input''s `id`. That association does three things:

- A screen reader announces the label when focus reaches the field. Without it, a listener hears "edit, blank" and has to guess.
- Clicking the label focuses the field, which makes a checkbox or a radio far easier to hit - particularly on a touchscreen, where the box itself is a 16-pixel target.
- The browser can use the label when offering autofill.

Wrapping works too, and needs no ids:

```html
<label>
  Email address
  <input type="email" name="email">
</label>
```

What does **not** work is a placeholder as a label:

```html
<!-- not a label -->
<input type="email" placeholder="Email address">
```

A placeholder disappears the moment somebody types. They then cannot check what the field was for without clearing it. It is also low-contrast grey by default, and several screen readers do not announce it at all. A placeholder is for an example of the format - `name@example.com` - alongside a real label, or it is not needed.

## The input type does a surprising amount

```html
<input type="email">     <!-- validates a shape, mobile keyboard with @ -->
<input type="url">
<input type="tel">       <!-- numeric keypad, no validation - numbers vary -->
<input type="number">    <!-- spinner, min, max, step -->
<input type="date">      <!-- native date picker -->
<input type="password">  <!-- masked, offers the password manager -->
<input type="search">    <!-- a clear button, and the right keyboard -->
```

On a phone, the type chooses the keyboard. `type="email"` puts the at sign on the main layout; `type="tel"` gives a numeric keypad. That one attribute removes several taps from every form on a touchscreen, and costs nothing.

`type="number"` deserves a caveat: it is for quantities you would do arithmetic on. It is wrong for a card number, a postcode or a phone number, where the spinner is meaningless and the browser may strip leading zeros. Use `type="text"` with `inputmode="numeric"` for those.

## Validation the browser already does

```html
<form>
  <label for="name">Your name</label>
  <input type="text" id="name" name="name" required
         minlength="2" maxlength="80" autocomplete="name">

  <label for="age">Age</label>
  <input type="number" id="age" name="age" min="13" max="120">

  <label for="code">Invite code</label>
  <input type="text" id="code" name="code"
         pattern="[A-Z]{3}-[0-9]{4}"
         title="Three letters, a hyphen, four digits">

  <button type="submit">Create account</button>
</form>
```

`required`, `minlength`, `maxlength`, `min`, `max`, `step` and `pattern` are all enforced by the browser before the form submits, in the user''s own language, with the field focused.

`title` on a `pattern` is what the browser shows when the pattern fails. Without it the message is "Please match the requested format", which tells nobody anything.

### Styling the states

```css
input:invalid { border-color: var(--danger); }
input:valid   { border-color: var(--success); }
```

That is a trap as written. A `required` field is invalid before it has been touched, so an untouched form lights up red on arrival. Use `:user-invalid`, which only applies after the user has interacted with the field:

```css
input:user-invalid { border-color: var(--danger); }
input:user-invalid + .field-error { display: block; }
```

### Taking over the messages

When you want your own wording rather than the browser''s, `novalidate` turns off the built-in bubbles and leaves the validity API intact:

```html
<form novalidate>
```

```javascript
form.addEventListener(''submit'', (event) => {
  if (!form.checkValidity()) {
    event.preventDefault();
    for (const field of form.elements) {
      if (!field.validity.valid) {
        showError(field, message(field.validity));
        break;                      // focus the first problem, not the last
      }
    }
  }
});

function message(validity) {
  if (validity.valueMissing) return ''This one is needed.'';
  if (validity.typeMismatch) return ''That does not look like an email address.'';
  if (validity.tooShort)    return ''A little longer, please.'';
  return ''That is not quite right.'';
}
```

The constraint stays in the HTML. The JavaScript only changes how it is presented - so if the script fails, the form still validates.

## Errors a screen reader will hear

A red border is invisible to a listener and to anybody who cannot distinguish the colour.

```html
<label for="email">Email address</label>
<input type="email" id="email" name="email"
       aria-describedby="email-error" aria-invalid="true">
<p class="field-error" id="email-error">That does not look like an email address.</p>
```

`aria-invalid="true"` announces the state. `aria-describedby` ties the message to the field, so it is read out after the label. Both go on when the error appears and come off when it clears.

For a summary at the top of a long form, make it a live region so it is announced when it appears:

```html
<div role="alert">
  <h2>There are 2 problems with this form</h2>
  <ul>
    <li><a href="#email">Email address is not valid</a></li>
    <li><a href="#password">Password is too short</a></li>
  </ul>
</div>
```

Links to the fields, so somebody can jump straight to each one.

## autocomplete is worth more than it looks

```html
<input autocomplete="name">
<input autocomplete="email">
<input autocomplete="street-address">
<input autocomplete="postal-code">
<input autocomplete="cc-number">
<input autocomplete="new-password">
<input autocomplete="current-password">
```

These are not arbitrary strings; they are a fixed vocabulary in the HTML specification. Get them right and the browser fills a checkout form in one tap, and a password manager knows which field is which.

The distinction between `new-password` and `current-password` is the one worth knowing: it tells a password manager whether to offer to generate one or to fill the saved one.

For somebody with a motor impairment, autofill is the difference between a form that takes ten seconds and one that takes five minutes.

## Grouping, and the one exception to everything above

Radios and checkboxes need a group label, and this is the one place `<fieldset>` and `<legend>` genuinely belong:

```html
<fieldset>
  <legend>How did you hear about us?</legend>
  <label><input type="radio" name="source" value="search"> A search engine</label>
  <label><input type="radio" name="source" value="friend"> A friend</label>
</fieldset>
```

Without the fieldset, a screen reader announces "A search engine, radio button, 1 of 2" with no indication of what the question was.

Be aware that a `<legend>` is rendered by the browser on the fieldset''s border rather than inside its padding, which makes it awkward to style as an ordinary heading. Where the grouping is the only thing you need, `role="group"` with `aria-labelledby` gives the same semantics without that behaviour.

## What goes wrong

| Symptom | Cause |
|---|---|
| Listener hears "edit, blank" | No label, or `for` does not match `id` |
| Form turns red before anybody types | `:invalid` instead of `:user-invalid` |
| Error message read as unrelated text | No `aria-describedby` |
| Autofill never offers anything | Missing or invented `autocomplete` values |
| "Please match the requested format" | `pattern` with no `title` |
| Nothing submits when JavaScript fails | Validation only in the script |
| Leading zeros vanish from a postcode | `type="number"` on something that is not a number |

## The test

Turn JavaScript off and submit the form with a field empty.

If the browser stops you, focuses the field and tells you why, the form is built on what the platform already does. If it submits happily and the server has to catch it, every piece of help above was left on the table.
',
   'The browser will label, validate, autofill and describe your form for free. Most form JavaScript re-implements something that was already there, and does it worse.', 6, 1237,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000016',
   'Responsive Images and Media',
   'markdown',
   '# Responsive Images and Media

Sending a 2400-pixel-wide photograph to a phone wastes the visitor''s data allowance and their battery, and makes your page slower for the person least able to afford it. It is the easiest performance win on most sites, and HTML has had the fix built in for over a decade.

## The problem, stated in numbers

A hero photograph at 2400 by 1350 is perhaps 600 kilobytes as a JPEG. On a phone with a 390-pixel-wide screen, every pixel of that beyond about 1170 (390 at three times the device pixel ratio) is downloaded, decoded and then thrown away.

Decoding is the part people forget. A large image costs memory and main-thread time to decode even when it ends up drawn small - which on a cheap phone is measured in hundreds of milliseconds, during which nothing else happens.

## srcset and sizes: let the browser choose

```html
<img src="/photo-800.jpg"
     srcset="/photo-400.jpg   400w,
             /photo-800.jpg   800w,
             /photo-1600.jpg 1600w"
     sizes="(max-width: 700px) 100vw, 800px"
     alt="A reading room with high windows"
     width="800" height="450">
```

Four parts, and each has a job.

**`src`** is the fallback for a browser that does not understand the rest. There are very few of those now, and it costs one attribute.

**`srcset`** lists the files you have with the **real width in pixels of each one**, using the `w` descriptor. This is a statement of fact, not a request - you are telling the browser what you have, not what to use.

**`sizes`** tells the browser **how wide the image will be laid out** at a given viewport width. Read the example as: below 700 pixels of viewport the image fills the width; above that it is 800 pixels wide.

**`width` and `height`** give the aspect ratio so the browser can reserve the space before anything downloads.

The browser then does the arithmetic: it knows the viewport, so from `sizes` it knows the layout width; it multiplies by the device pixel ratio; it picks the smallest entry in `srcset` that is at least that big. It may also take the network into account, and it is allowed to use a larger file it has already cached.

### Why sizes is the part people get wrong

`sizes` is needed because the browser begins fetching images **before** the CSS has been parsed and the layout computed. At that moment it does not know how wide the image will be. `sizes` is you telling it in advance.

Get it wrong and the browser picks wrongly. A common error:

```html
<!-- wrong: claims full width at every viewport -->
<img srcset="..." sizes="100vw">
```

on an image that is actually 400 pixels wide in a sidebar. On a 1440-pixel desktop the browser downloads the 1600-wide file for a 400-pixel slot.

If you genuinely do not know, `sizes="auto"` combined with `loading="lazy"` lets the browser work it out from the real layout - lazy loading means the image is not fetched until layout is known.

### The simpler case: same image, different densities

When an image is a fixed size in CSS pixels and you only want a sharper version on a high-density screen, the `x` descriptor is shorter and needs no `sizes`:

```html
<img src="/avatar.png" srcset="/avatar.png 1x, /avatar@2x.png 2x" alt="" width="48" height="48">
```

## picture: when you need to change the image itself

`srcset` is for the same image at different sizes. `<picture>` is for a **different image** - a different format, or a different crop.

### Different formats

```html
<picture>
  <source srcset="/photo.avif" type="image/avif">
  <source srcset="/photo.webp" type="image/webp">
  <img src="/photo.jpg" alt="A reading room with high windows"
       width="800" height="450">
</picture>
```

The browser takes the first `<source>` whose `type` it supports and ignores the rest. AVIF is typically 50% smaller than JPEG at the same quality and WebP about 30%, so the order matters: best first, with JPEG as the floor.

The `<img>` is required and is not a fallback you can omit - it carries the `alt`, the dimensions and the actual rendering.

### Art direction

```html
<picture>
  <source media="(min-width: 800px)" srcset="/hero-wide.jpg">
  <img src="/hero-square.jpg" alt="..." width="600" height="600">
</picture>
```

A wide crop on a desktop, a square crop on a phone where a 21:9 letterbox would be forty pixels tall. This is a different decision from resolution: here you are choosing a different photograph because the shape of the space changed.

## Lazy loading, and where not to

```html
<img src="/below-the-fold.jpg" alt="..." width="800" height="450"
     loading="lazy" decoding="async">
```

`loading="lazy"` tells the browser not to fetch until the image is near the viewport. It is one attribute and it can halve the bytes on a long page.

**Do not put it on anything visible on arrival.** Lazy-loading the hero image delays the one thing the reader is waiting for - the browser defers it, then discovers it is in view, then starts the fetch late. For the hero, do the opposite:

```html
<img src="/hero.jpg" alt="..." width="1200" height="600" fetchpriority="high">
```

## Video and audio

```html
<video controls preload="metadata" poster="/thumb.jpg"
       width="800" height="450" playsinline>
  <source src="/clip.webm" type="video/webm">
  <source src="/clip.mp4" type="video/mp4">
  <track kind="captions" src="/clip.en.vtt" srclang="en" label="English" default>
  <p>Your browser cannot play this. <a href="/clip.mp4">Download it instead.</a></p>
</video>
```

- `controls` gives the native player, which is keyboard accessible and translated.
- `preload="metadata"` fetches only enough for duration and the first frame. `preload="auto"` on several videos will download megabytes nobody asked for.
- `poster` is what shows before play, and prevents a black rectangle.
- `playsinline` stops iOS taking over the whole screen on play.
- `<track kind="captions">` is not optional if the video carries information. Captions serve deaf viewers, anybody in a noisy place, anybody watching with the sound off - which is most people on a phone - and they make the content searchable.

Autoplay deserves its own warning. Browsers block autoplay with sound, and they are right to. If you must, it has to be `muted`, and it should respect the reader:

```css
@media (prefers-reduced-motion: reduce) {
  video { animation: none; }
}
```

## What goes wrong

| Symptom | Cause |
|---|---|
| Phone downloads the desktop image | `srcset` with no `sizes`, or a wrong one |
| Page jumps as images arrive | No `width` and `height` |
| Hero image loads last | `loading="lazy"` above the fold |
| AVIF never served | `<source>` order, or the wrong `type` |
| Letterboxed hero on a phone | One crop for every viewport |
| Video eats the data allowance on load | `preload="auto"` |
| Video taken over by the iOS player | No `playsinline` |

## What to actually do

For most images on most sites: export three widths, write `srcset` with `w` descriptors, write an honest `sizes`, always set `width` and `height`, and put `loading="lazy"` on everything below the fold.

That is five attributes and it is the whole of responsive images for the common case. `<picture>` is there when you need a format or a crop to change, and most pages need it in one or two places rather than everywhere.
',
   'Sending a 2400-pixel photograph to a phone wastes the visitor''s data and battery, and it is the easiest performance win on most sites. HTML has had the fix built in for a decade.', 6, 1162,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 3 - Advanced
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000017',
   'Semantic Layout and Landmarks',
   'markdown',
   '# Semantic Layout and Landmarks

Six elements replace a page full of `<div class="header">` and give screen reader users something a sighted reader has always had: the ability to skim.

A sighted reader never reads a page top to bottom first. Their eye jumps to the masthead, the navigation, the main column, the sidebar - locating the shape of the page before reading a word of it. Landmarks are that skimming interface, expressed in markup, and without them a screen reader user has only one option: read everything in order, every time, on every page.

## The six, and what each one means

```html
<body>
  <header>
    <a href="/">Omni Academy</a>
    <nav aria-label="Main">
      <ul>
        <li><a href="/courses">Courses</a></li>
        <li><a href="/playground">Playground</a></li>
      </ul>
    </nav>
  </header>

  <main>
    <h1>Semantic Layout and Landmarks</h1>
    <article>
      <p>...</p>
    </article>
  </main>

  <aside aria-label="Related">
    <h2>Related lessons</h2>
  </aside>

  <footer>
    <p>Copyright 2026</p>
  </footer>
</body>
```

**`<header>`** is introductory content. At the top level of the page that is the masthead; inside an `<article>` it is that article''s own heading block, and it is a landmark only in the first case.

**`<nav>`** is a major block of navigation links. Not every group of links - a paragraph with three links in it is not navigation. The main menu, a breadcrumb trail, a table of contents, pagination.

**`<main>`** is the content unique to this page. Exactly one per page, and it must not be nested inside any of the others. This is the one that matters most: it is what "skip to content" skips to.

**`<aside>`** is tangentially related content - a related-links box, a pull quote, an advertisement. If removing it would not harm the main content, it is an aside.

**`<footer>`** is closing information. At page level that is the copyright, the site map, the legal links.

**`<section>`** is a thematic grouping, and it needs a heading. A `<section>` without one is a `<div>` with extra steps.

## The one that does the most work

If you add only one of these, add `<main>`.

It is what makes a skip link work, and a skip link is the single most useful accessibility feature on a content site:

```html
<body>
  <a class="skip-link" href="#main">Skip to content</a>
  <header>...</header>
  <main id="main" tabindex="-1">...</main>
</body>
```

```css
.skip-link {
  position: absolute; left: -9999px;
}
.skip-link:focus {
  left: 1rem; top: 1rem; z-index: 100;
  padding: .6rem 1rem; background: #fff; border: 2px solid currentColor;
}
```

A keyboard user pressing Tab on arrival meets forty navigation links before reaching the article. On every page. The skip link is the first thing they reach and it takes them past all of it. `tabindex="-1"` on the target is what lets focus actually land there rather than only scrolling.

## Name a landmark when there is more than one

A screen reader lists landmarks by role: "navigation", "navigation", "navigation". Which one is the menu?

```html
<nav aria-label="Main">...</nav>
<nav aria-label="Breadcrumb">...</nav>
<nav aria-label="Course curriculum">...</nav>
```

Now the list reads "Main navigation", "Breadcrumb navigation", "Course curriculum navigation". The rule is: label a landmark when the page has more than one of that type. Do not write "navigation" in the label - the role already says it, and "Main navigation navigation" is what a listener hears if you do.

If a visible heading already names the region, point at it instead of repeating yourself:

```html
<aside aria-labelledby="related-head">
  <h2 id="related-head">Related lessons</h2>
</aside>
```

## article versus section versus div

This is the distinction people find hardest, and there is a usable test.

**`<article>`** is content that would still make sense somewhere else, on its own: a blog post, a news story, a comment, a product card, a forum reply. The test is "would this be complete in a feed reader".

**`<section>`** is a thematic part of something larger, and it takes a heading. The chapters of a document, the parts of a dashboard.

**`<div>`** is for grouping with no meaning at all - a wrapper you need in order to position two things together. It is the right element when there genuinely is no meaning, and it should be the one you reach for last rather than first.

```html
<main>
  <h1>Courses</h1>

  <section aria-labelledby="frontend">
    <h2 id="frontend">Frontend</h2>

    <article class="course-card">
      <h3>CSS: From Basics to Expert</h3>
      <p>Four levels, twelve lessons.</p>
    </article>
  </section>
</main>
```

Each card is an `<article>` because it would make sense on its own. The group is a `<section>` because it is part of this page. Any `<div>` inside a card is there for layout and says nothing.

## What makes a landmark, and what quietly does not

A landmark role is implied by the element, but three of them have a condition:

- `<header>` and `<footer>` are landmarks **only** when they are not inside `<article>`, `<aside>`, `<main>`, `<nav>` or `<section>`. Inside one of those they are just the heading or closing block of that thing.
- `<section>` is a landmark **only** when it has an accessible name - `aria-label` or `aria-labelledby`. Without one it is announced as nothing at all, which surprises people who have carefully divided a page into sections and find none of them in the landmark list.
- `<aside>` and `<nav>` are always landmarks.

## The usual mistakes

**Several `<main>` elements.** One page, one main. If you have two, one of them is a `<section>`.

**`<main>` inside `<header>`.** Main must be a top-level region. Nesting it inside anything else removes the thing it is for.

**`<nav>` round every list of links.** The footer''s four legal links do not need one, and a page with six navigation landmarks has none - the list is as long as reading the page.

**`<section>` used as a styling wrapper.** If it has no heading it is a `<div>`. Using `<section>` does not make a page semantic; using it correctly does.

**Divs with ARIA roles instead of the elements.** `<div role="navigation">` is exactly `<nav>`, in more characters, with no browser behaviour attached. The first rule of ARIA is not to use ARIA when an element already does the job.

## How to check it in two minutes

Open the accessibility tree in your browser''s developer tools - Firefox and Chrome both show it - and look at the landmark list for your page. You should see something like:

```
banner            (header)
navigation        Main
main
complementary     Related
contentinfo       (footer)
```

If you see a flat list of generic groups, or six unnamed navigations, or no main at all, that is what a screen reader user is working with. Fixing it is usually a matter of renaming six divs, and it is the highest-value half hour you will spend on a page.
',
   'Six elements replace a page full of divs and give screen reader users something a sighted reader has always had: the ability to skim.', 5, 1085,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000018',
   'Accessible Interactive Components',
   'markdown',
   '# Accessible Interactive Components

The accessible version of most components is the one built on an element the browser already understands. Focus management, keyboard handling, escape-to-close and the screen reader announcements are hard to write and easy to get subtly wrong, and the platform has already done all four.

This lesson builds three components the right way round, and names what you take on when you build them the other way.

## The first rule of ARIA

The specification for ARIA opens with a rule that is worth memorising: **do not use ARIA if a native element will do**.

```html
<!-- 40 lines of JavaScript to re-implement a button -->
<div role="button" tabindex="0"
     onclick="save()" onkeydown="if (event.key === ''Enter'' || event.key === '' '') save()">
  Save
</div>

<!-- a button -->
<button type="button" onclick="save()">Save</button>
```

The second one is focusable, activates on Enter and Space, is announced as a button, appears in a screen reader''s list of buttons, respects the user''s focus-visible preference, shows a focus ring styled by the platform, and works in forms. The first does some of that if you wrote it carefully.

A role is a promise. `role="button"` tells assistive technology "this behaves like a button" - and nothing enforces it. Every behaviour a real button has, you now owe.

## Disclosure: show and hide

The simplest interactive component, and the browser has one:

```html
<details>
  <summary>What is a landmark?</summary>
  <p>A region of the page a screen reader can jump to.</p>
</details>
```

Keyboard accessible, announced as expandable, toggles on Enter and Space, works with no JavaScript at all, and is searchable by the browser''s find-in-page in modern browsers.

When you need more control over the animation or the markup, the pattern is a button and a region, tied together:

```html
<button type="button" aria-expanded="false" aria-controls="answer-1" id="q-1">
  What is a landmark?
</button>
<div id="answer-1" role="region" aria-labelledby="q-1" hidden>
  <p>A region of the page a screen reader can jump to.</p>
</div>
```

```javascript
button.addEventListener(''click'', () => {
  const open = button.getAttribute(''aria-expanded'') === ''true'';
  button.setAttribute(''aria-expanded'', String(!open));
  panel.hidden = open;
});
```

Three things make this correct:

- **`aria-expanded` on the button**, not on the panel. It describes the control''s state, and a screen reader announces "collapsed" or "expanded" as part of the button.
- **The `hidden` attribute**, not `display: none` in a class. `hidden` takes the content out of the accessibility tree and out of the tab order, which a visually-hidden class does not.
- **`aria-controls` and `aria-labelledby`** pointing at each other, so the relationship is explicit.

## Dialog: the one with the most to get wrong

A modal dialog is where hand-built components fail most often, because a modal has obligations that are not obvious:

- Focus must move into it when it opens.
- Focus must not escape it while it is open - Tab from the last control goes to the first.
- Escape must close it.
- Everything behind it must be inert: not focusable, not read by a screen reader.
- Focus must return to whatever opened it when it closes.

That is a lot of code, it is subtle, and the browser now does all of it:

```html
<button type="button" id="open">Delete this course</button>

<dialog id="confirm" aria-labelledby="confirm-title">
  <h2 id="confirm-title">Delete this course?</h2>
  <p>This cannot be undone.</p>
  <form method="dialog">
    <button value="cancel">Cancel</button>
    <button value="delete" class="btn-danger">Delete</button>
  </form>
</dialog>
```

```javascript
open.addEventListener(''click'', () => confirm.showModal());

confirm.addEventListener(''close'', () => {
  if (confirm.returnValue === ''delete'') deleteCourse();
});
```

`showModal()` - not `show()` - is what gives you the focus trap, the inert background, the Escape handling and the backdrop. `<form method="dialog">` closes the dialog on submit and puts the button''s `value` into `returnValue`, with no event handler at all.

Style the backdrop with the pseudo-element:

```css
dialog::backdrop { background: rgb(0 0 0 / .5); }
```

## Tabs: when there is no native element

Some patterns genuinely have no HTML element, and tabs are one. Here the roles are doing real work rather than re-describing something that exists.

```html
<div class="tabs">
  <div role="tablist" aria-label="Course sections">
    <button role="tab" id="tab-overview" aria-controls="panel-overview"
            aria-selected="true" tabindex="0">Overview</button>
    <button role="tab" id="tab-curriculum" aria-controls="panel-curriculum"
            aria-selected="false" tabindex="-1">Curriculum</button>
  </div>

  <div role="tabpanel" id="panel-overview" aria-labelledby="tab-overview" tabindex="0">
    ...
  </div>
  <div role="tabpanel" id="panel-curriculum" aria-labelledby="tab-curriculum" tabindex="0" hidden>
    ...
  </div>
</div>
```

The keyboard behaviour is specified, and it is not what people expect: **Tab enters the tab list once and then leaves it**. Arrow keys move between tabs. This is why only the selected tab has `tabindex="0"` and the rest have `tabindex="-1"` - the group is one tab stop.

```javascript
tablist.addEventListener(''keydown'', (event) => {
  const tabs = [...tablist.querySelectorAll(''[role="tab"]'')];
  const current = tabs.indexOf(document.activeElement);
  let next = current;

  if (event.key === ''ArrowRight'') next = (current + 1) % tabs.length;
  else if (event.key === ''ArrowLeft'') next = (current - 1 + tabs.length) % tabs.length;
  else if (event.key === ''Home'') next = 0;
  else if (event.key === ''End'') next = tabs.length - 1;
  else return;

  event.preventDefault();
  select(tabs[next]);
  tabs[next].focus();
});
```

Before building this, ask whether you need tabs at all. On a narrow screen they usually become an accordion, and headings with content under them are simpler, linkable, printable and findable by find-in-page. Tabs hide content, and hidden content is content people do not read.

## Focus must be visible

```css
/* Never do this */
:focus { outline: none; }

/* Do this */
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
```

Removing the focus ring makes a site unusable by keyboard - you cannot see where you are. The reason people remove it is that it appears on mouse clicks too, and `:focus-visible` is exactly the fix: the browser shows the ring for keyboard focus and not for a mouse click.

If you replace the outline with a border or a shadow, check it in Windows High Contrast Mode, where backgrounds and shadows are discarded and only the outline survives. `outline: 2px solid transparent` as a companion is the usual trick.

## Hiding things, three different ways

```css
/* Gone for everybody - not focusable, not announced */
.hidden { display: none; }

/* Visible to a screen reader, invisible on screen */
.visually-hidden {
  position: absolute; width: 1px; height: 1px;
  margin: -1px; padding: 0; overflow: hidden;
  clip-path: inset(50%); white-space: nowrap;
}

/* Visible on screen, ignored by a screen reader */
<span aria-hidden="true">&rarr;</span>
```

These are three different intentions and they are not interchangeable. The commonest mistake is `aria-hidden="true"` on something focusable, which produces a control a keyboard can reach and a screen reader cannot describe - the worst of both.

## Live regions, for things that change

When content appears without a page load, a screen reader does not notice unless you say so:

```html
<div role="status" aria-live="polite">3 courses match your filters</div>
<div role="alert">Your session expired. Please sign in again.</div>
```

`polite` waits for a pause; `assertive` interrupts, and is for errors only. The element must exist in the DOM **before** the text changes - adding the element and its content at the same moment often announces nothing, because there was no region to observe.

## What goes wrong

| Symptom | Cause |
|---|---|
| Keyboard reaches a control, Enter does nothing | `<div role="button">` with only a click handler |
| Tab escapes an open modal | `show()` instead of `showModal()`, or a hand-built dialog |
| Cannot see where the keyboard is | `outline: none` |
| Arrow keys do nothing in a tab list | Roles without the keyboard implementation |
| Screen reader reads hidden panel content | `visibility` or opacity instead of `hidden` |
| A filter result change is never announced | No live region |

## The test that takes two minutes

Put the mouse away. Reach every control with Tab, activate each with Enter or Space, close every dialog with Escape, and watch where the focus ring goes.

If you can operate the page, it works. If you lose the ring, get stuck inside something, or find a control you cannot reach, you have found exactly what a keyboard user finds - and almost always the fix is to delete a hand-built component and use the element that was there all along.
',
   'The accessible version of most components is the one built on an element the browser already understands. Focus management and keyboard handling are hard to write and free to inherit.', 7, 1344,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000019',
   'Head Metadata and Sharing',
   'markdown',
   '# Head Metadata and Sharing

Nobody looks at the `<head>`, and it decides what your page is in a search result, in a shared link, on a phone home screen and in a browser tab. Per byte written it is the highest-leverage markup in the document.

## The two that matter most

```html
<title>Semantic Layout and Landmarks - HTML - Omni Academy</title>
<meta name="description" content="Six elements replace a page full of divs and give screen reader users the ability to skim. What each landmark means, when to name one, and how to check the result.">
```

**The title** is the blue line in a search result, the browser tab, the bookmark name and the suggested text when somebody shares the link. Most specific part first, because a tab shows about twenty characters. Under sixty characters or a search result truncates it - and it is better that you choose where it ends.

**The description** is the grey text under the title in a result. Search engines do not use it for ranking and they do use it for the snippet, which is what decides whether anybody clicks. Around 155 characters; write it as a sentence that would make somebody want to read the page, not as a list of keywords.

Both must be different on every page. A site where fifty pages share one description is a site where forty-nine of them look identical in a result.

## The canonical, and why it is not optional

```html
<link rel="canonical" href="https://example.com/html/landmarks">
```

The same page is usually reachable at several addresses: with and without `www`, with and without a trailing slash, with `?utm_source=newsletter` on the end, over http and https. To a search engine those are different URLs with identical content, and the ranking signal is split between them.

The canonical says: whatever address you arrived at, this is the real one.

Two rules:

- **Build it from your configured origin, never from the request.** The `Host` header is supplied by the client. A canonical built from it lets anybody who can reach your server emit canonicals pointing at a domain they control, which is a real way to hand somebody your rankings.
- **Leave the query string out** unless it changes the content. That is the whole point: `?utm_source=newsletter` should not be a separate page.

## Telling crawlers what to do

```html
<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large">
```

`index, follow` is the default and writing it is harmless. The two that earn their place are `max-snippet:-1`, which lets an engine show as much of your text as it wants rather than a truncated line, and `max-image-preview:large`, which allows a full-size thumbnail.

For a page that should not be in results at all:

```html
<meta name="robots" content="noindex, nofollow">
```

This and `robots.txt` do different jobs and you often want both. `robots.txt` stops the crawl; the meta tag stops the indexing. A page linked from somewhere else can be indexed without ever being crawled - so the tag is what actually keeps it out.

## Open Graph: what a shared link looks like

```html
<meta property="og:type" content="article">
<meta property="og:title" content="Semantic Layout and Landmarks">
<meta property="og:description" content="Six elements replace a page full of divs...">
<meta property="og:url" content="https://example.com/html/landmarks">
<meta property="og:site_name" content="Omni Academy">
<meta property="og:image" content="https://example.com/og/landmarks.png">
<meta property="og:image:alt" content="Six landmark elements laid out on a page">
<meta property="og:locale" content="en_GB">
```

Two details that cost people hours.

**It is `property`, not `name`.** Open Graph uses RDFa, so a scraper looking for `property="og:title"` will not find `name="og:title"`. Everything is silently ignored if you get this wrong, and nothing warns you.

**`og:image` must be an absolute URL.** The scraper is a different machine with no notion of your page''s base URL. A relative path produces a link preview with no image and no error.

Around 1200 by 630 pixels is the size that works everywhere. Under about 300 by 200 and most platforms ignore it.

```html
<meta name="twitter:card" content="summary_large_image">
```

One line, and it is the difference between a thumbnail and a banner. With no `og:image`, use `summary` instead - `summary_large_image` with no image is an empty box.

## Structured data: the part machines read

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Course",
      "name": "HTML: From Basics to Expert",
      "description": "Four levels, twelve lessons.",
      "provider": { "@type": "Organization", "name": "Omni Academy" }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Courses", "item": "https://example.com/courses" }
      ]
    }
  ]
}
</script>
```

JSON-LD rather than microdata, because it sits in one block rather than being scattered through the markup as attributes, which means it can be generated in one place and validated as one thing.

Two warnings worth taking seriously.

**Encode it so a `</script>` in your data cannot escape.** A course title containing that string ends the script element early and everything after it is parsed as markup. In PHP that is `JSON_HEX_TAG`; in JavaScript, replace the sequence. This is the one XSS hole structured data reliably opens.

**Never describe something the page does not show.** A rating nobody left, a price that is not real, an FAQ whose answers are not on the page - these are manual-action penalties rather than clever tricks, and the penalty is applied to the whole site.

## Icons and the phone home screen

```html
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="icon" href="/icon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0f766e">
```

An SVG icon scales to every size from one file, and can carry a dark-mode variant inside it with a media query. The `.ico` remains for older browsers; `apple-touch-icon` is a 180-pixel PNG for an iOS home screen.

`theme-color` tints the browser chrome on mobile, which is a small thing that makes a site look considered.

## Performance hints

```html
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>
```

`preconnect` opens the TCP and TLS connection to a third-party origin early, which saves a round trip when the request eventually goes out. Use it for two or three origins at most - each one costs a connection.

`preload` fetches something the parser has not reached yet. Fonts are the classic case, because they are discovered only after the CSS is parsed. The `crossorigin` attribute is required on fonts even from your own origin, and omitting it causes the file to be downloaded twice.

Both are easy to overdo. Preloading everything is the same as preloading nothing, because the browser''s own priority ordering is what you have overridden.

## What goes wrong

| Symptom | Cause |
|---|---|
| Shared link shows no image | Relative `og:image`, or `name` instead of `property` |
| Same description on every result | One description reused |
| Two URLs competing in search | No canonical, or one built from `Host` |
| Rich result never appears | Invalid JSON-LD, or it describes what the page does not show |
| Font loads twice | `preload` without `crossorigin` |
| Page title truncated oddly | Over 60 characters, site name first |

## The check

Paste your URL into a link-preview debugger, and your markup into a structured-data validator. Both are free, both take seconds, and both tell you exactly what a machine sees - which is the only opinion that matters for everything on this page.
',
   'Nobody sees the head, and it decides what your page looks like in a search result, in a shared link, on a home screen and in a browser tab.', 6, 1213,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 4 - Expert
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000001a',
   'Templates and Custom Elements',
   'markdown',
   '# Templates and Custom Elements

Two features that let the browser do work you would otherwise do with a library. One is a stencil for markup you stamp out repeatedly; the other is a tag you define yourself, with a lifecycle the browser calls for you.

## template: markup the parser reads and does not run

```html
<template id="course-card">
  <article class="course-card">
    <h3 class="title"></h3>
    <p class="summary"></p>
    <a class="link">Explore now</a>
  </article>
</template>
```

The parser reads that and produces real DOM nodes - but **inert** ones. Inside a template:

- No image is fetched.
- No script runs.
- No stylesheet applies.
- Nothing is rendered.
- `document.querySelector(''.title'')` does not find it.

It sits in the document as a stencil. This is the difference between `<template>` and a hidden `<div>`: a hidden div''s images still download and its scripts still run.

### Stamping one out

```javascript
const template = document.getElementById(''course-card'');

function renderCourse(course) {
  // true: deep clone, so the children come too
  const card = template.content.cloneNode(true);

  card.querySelector(''.title'').textContent = course.title;
  card.querySelector(''.summary'').textContent = course.summary;
  card.querySelector(''.link'').href = ''/course?slug='' + encodeURIComponent(course.slug);

  return card;
}

const list = document.querySelector(''#courses'');
const batch = document.createDocumentFragment();
for (const course of courses) {
  batch.append(renderCourse(course));
}
list.append(batch);          // one insertion, one layout
```

Three things worth noticing.

**`template.content`** is a DocumentFragment, not the template element. Clone the content, not the template.

**`textContent`, not `innerHTML`.** Every value above came from somewhere else, and `textContent` cannot execute anything. Using `innerHTML` with a course title that contains a script tag is how a catalogue page becomes an XSS hole.

**The fragment.** Appending each card to the live list triggers layout each time. Building them in a fragment and appending once triggers it once. For twenty cards that is invisible; for two thousand rows it is the difference between instant and a frozen tab.

### When a template earns its place

When the same shape is produced many times from data, and the alternative is building strings of HTML in JavaScript. The template keeps the markup in the HTML file where you can see it, read it and have your editor highlight it - and it removes the whole category of bug where a quote in a value breaks the string you were concatenating.

## Custom elements: a tag you define

```html
<char-count for="bio" max="200"></char-count>
```

```javascript
class CharCount extends HTMLElement {
  connectedCallback() {
    this.field = document.getElementById(this.getAttribute(''for''));
    this.max = Number(this.getAttribute(''max'')) || 100;

    this.setAttribute(''role'', ''status'');
    this.setAttribute(''aria-live'', ''polite'');

    this.onInput = () => this.update();
    this.field.addEventListener(''input'', this.onInput);
    this.update();
  }

  // Called when the element leaves the document. Removing the listener here is
  // what stops a long-lived page leaking one per render.
  disconnectedCallback() {
    this.field.removeEventListener(''input'', this.onInput);
  }

  update() {
    const left = this.max - this.field.value.length;
    this.textContent = left + '' characters left'';
    this.classList.toggle(''is-over'', left < 0);
  }
}

customElements.define(''char-count'', CharCount);
```

### The rules

**The name must contain a hyphen.** `<charcount>` is not allowed; `<char-count>` is. The hyphen is what guarantees your element can never collide with a future HTML element, because no standard element will ever have one.

**It must extend `HTMLElement`** (or a specific element class).

**It must be defined with `customElements.define`.** Until then the browser treats it as an unknown element - which it renders as an inline box and otherwise ignores, so a page with the script not yet loaded shows whatever is between the tags.

### The four lifecycle callbacks

```javascript
class Thing extends HTMLElement {
  static observedAttributes = [''value''];

  constructor() {
    super();
    // Attributes and children are NOT available here. Set up internal state
    // only. Touching the DOM in a constructor is the commonest mistake.
  }

  connectedCallback() {
    // In the document. Read attributes, add listeners, render.
    // May run more than once if the element is moved.
  }

  disconnectedCallback() {
    // Removed. Clean up listeners, timers, observers.
  }

  attributeChangedCallback(name, oldValue, newValue) {
    // Only for attributes named in observedAttributes.
  }
}
```

The constructor restriction catches everyone once. The element may be created by the parser before its attributes have been parsed, so reading one in the constructor returns null.

## Progressive enhancement, which is the point

A custom element that wraps existing markup degrades gracefully. One that generates all its own content does not.

```html
<!-- Good: works without the script, better with it -->
<sortable-table>
  <table>
    <thead><tr><th>Name</th><th>Lessons</th></tr></thead>
    <tbody>...</tbody>
  </table>
</sortable-table>

<!-- Fragile: an empty element if the script fails -->
<sortable-table src="/api/courses"></sortable-table>
```

The first renders a perfectly good table with no JavaScript, and gains sortable headers when the script arrives. The second renders nothing at all - and "the script failed" is not rare: a flaky connection, an ad blocker, a syntax error in an unrelated bundle.

## The shadow DOM, and when to skip it

```javascript
connectedCallback() {
  const shadow = this.attachShadow({ mode: ''open'' });
  shadow.innerHTML = `
    <style>
      p { color: rebeccapurple; }   /* cannot leak out */
    </style>
    <p><slot></slot></p>
  `;
}
```

A shadow root gives you real style encapsulation: your `p` rule cannot escape, and the page''s `p` rule cannot get in. `<slot>` is where the element''s own children are projected.

That isolation is the feature and also the cost. Your design system''s CSS does not reach inside either, so you have to pass values in deliberately - custom properties cross the boundary, ordinary rules do not. Forms are awkward: a control inside a shadow root does not automatically participate in the enclosing form.

For a component inside one application, where the styles are yours and the page is yours, the shadow DOM is usually solving a problem you do not have. For a widget embedded in somebody else''s page, it is exactly right.

## What goes wrong

| Symptom | Cause |
|---|---|
| `querySelector` finds nothing in a template | Searching the document instead of `template.content` |
| The same card repeated with identical data | Cloning without `true`, or reusing the node |
| A script tag in a title executes | `innerHTML` where `textContent` belonged |
| Attribute is null in the constructor | Read it in `connectedCallback` instead |
| Listeners pile up over a long session | No `disconnectedCallback` |
| Element renders as plain inline text | `customElements.define` never ran |
| Styles do not reach a component | A shadow root is doing its job |

## When to reach for these

A `<template>` is worth it as soon as you are building markup from data more than once - which is nearly always.

A custom element is worth it when a behaviour needs to attach to many places in a page and clean itself up: a character counter, a relative timestamp, a copy-to-clipboard button, a table that sorts. It is a lot of ceremony for something used once.

Neither is a framework, and that is the point. They are two small pieces of the platform that remove a dependency, and they will still work in ten years.
',
   'A template is markup the parser reads but does not render: no images fetched, no scripts run. A custom element is a tag you define yourself, which the browser upgrades wherever it appears.', 6, 1141,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-00000000001b',
   'HTML That Loads Fast',
   'markdown',
   '# HTML That Loads Fast

Most of a page''s loading behaviour is decided by attributes in the first few kilobytes of HTML, before any CSS or JavaScript has run. Getting them right costs nothing at runtime and is usually worth more than any amount of bundling.

## What the browser is doing while it reads your HTML

The parser reads top to bottom, building the DOM. When it meets a resource it decides, from the markup alone, whether to fetch it now, fetch it later, or stop and wait.

That last one is the whole story. Three things block rendering:

- **A stylesheet in the head.** The browser will not paint until CSS has arrived, because painting first would show unstyled text and then reflow it.
- **A synchronous script.** `<script src="...">` with no attribute stops the parser dead: it fetches, executes, and only then continues. Everything below it is not even parsed yet.
- **A font, briefly**, depending on `font-display`.

Everything else - images, video, scripts marked `defer` or `async` - is fetched alongside the parse.

## The script attributes

```html
<!-- Blocks the parser. Avoid. -->
<script src="/app.js"></script>

<!-- Fetched in parallel, run after the document is parsed, in order. -->
<script src="/app.js" defer></script>

<!-- Fetched in parallel, run as soon as it arrives, in no particular order. -->
<script src="/analytics.js" async></script>

<!-- A module. Deferred by default. -->
<script type="module" src="/app.js"></script>
```

`defer` is the right default for application code. The scripts run in the order you wrote them, after the DOM exists, so there is no need for a DOMContentLoaded wrapper and no chance of a script running before the element it is looking for.

`async` is for genuinely independent things with no dependencies and no dependents - an analytics beacon. Using it on application code means two scripts can run in either order, which is a bug that appears once a month on a slow connection.

An inline script blocks too, and worse: it blocks on the CSS above it, because it might read a computed style. A small inline script high in the head stops the page for as long as the stylesheet takes.

## Loading CSS without blocking on all of it

The stylesheet for what the reader can see has to block - that is the right trade, because the alternative is a flash of unstyled text. Everything else does not:

```html
<link rel="stylesheet" href="/critical.css">

<link rel="stylesheet" href="/print.css" media="print">
<link rel="stylesheet" href="/wide.css" media="(min-width: 60rem)">
```

A stylesheet with a `media` attribute that does not match is still downloaded, at low priority, and does not block rendering. This is the simplest way to split a stylesheet and needs no JavaScript.

## Fonts, which are the usual culprit

A web font is discovered only after the CSS is parsed, which is late. Then, by default, text using it is invisible until it arrives.

```html
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>
```

```css
@font-face {
  font-family: Inter;
  src: url(/fonts/inter.woff2) format("woff2");
  font-display: swap;
}
```

`preload` starts the fetch immediately rather than after the CSS. **`crossorigin` is required on a font preload even from your own origin** - fonts are fetched in CORS mode, and without it the browser downloads the file twice, which is worse than not preloading at all.

`font-display: swap` shows the fallback font immediately and swaps when the web font arrives. The reader sees text at once. The cost is a visible reflow; `optional` avoids that by not swapping at all on a slow connection, at the cost of the first visit sometimes not using your font.

## Images: the biggest single win

```html
<img src="/hero.jpg" alt="..." width="1200" height="600" fetchpriority="high">
<img src="/below.jpg" alt="..." width="800" height="450" loading="lazy" decoding="async">
```

Four attributes, and each one does something measurable:

- **`width` and `height`** reserve the space, which removes the layout shift as images arrive. This is the commonest cause of a page jumping under somebody''s finger.
- **`loading="lazy"`** on everything below the fold. Can halve the bytes on a long page.
- **`fetchpriority="high"`** on the one image that is the point of the page. The browser''s own guess is conservative.
- **`decoding="async"`** lets the decode happen off the main thread.

## Connection hints, used sparingly

```html
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="dns-prefetch" href="https://cdn.example.com">
```

`preconnect` does the DNS lookup, the TCP handshake and the TLS negotiation before the request goes out, which on a mobile connection saves perhaps 300 milliseconds.

It costs a connection each, so two or three at most - and only for origins you are definitely going to use, early. Preconnecting to six third parties makes the page slower, not faster.

## The order of the head

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>...</title>

  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>

  <link rel="stylesheet" href="/styles.css">

  <script src="/app.js" defer></script>

  <meta name="description" content="...">
  <link rel="canonical" href="...">
</head>
```

The order is deliberate: charset first so the parser never has to restart; viewport next; then the hints that start network activity; then the blocking stylesheet; then the deferred script; then the metadata, which no machine needs early.

## Measuring, rather than guessing

Three numbers describe how a page feels, and each maps to something in this lesson.

**Largest Contentful Paint** - when the biggest thing above the fold appears. Usually the hero image or the headline. Fixed by not lazy-loading it, by `fetchpriority`, and by not blocking on fonts.

**Cumulative Layout Shift** - how much the page moves after it starts drawing. Fixed almost entirely by `width` and `height` on images, and by reserving space for anything injected later.

**Interaction to Next Paint** - how long the page takes to respond to a tap. This is a JavaScript problem rather than an HTML one, but `defer` and splitting work into smaller tasks are where it starts.

Open the Performance panel, throttle to a slow connection and a slow CPU, and reload. The waterfall shows you what blocked what, which is a different and more useful question than how big anything was.

## What goes wrong

| Symptom | Cause |
|---|---|
| Blank page for a second, then everything | A synchronous script in the head |
| Text invisible until the font loads | No `font-display` |
| Font downloaded twice | `preload` without `crossorigin` |
| Page jumps as it loads | Images with no `width` and `height` |
| Hero image arrives last | `loading="lazy"` above the fold |
| Slower after adding preconnects | Too many, or to origins used late |

## The point

None of this is optimisation in the sense of making code faster. It is telling the browser what you already know - which image matters, which script can wait, which stylesheet is for printing - so that it does not have to guess conservatively.

Every item here is an attribute. There is no build step, no dependency and no runtime cost, and together they are usually worth more than anything you can do further down the stack.
',
   'Most of a page''s loading behaviour is decided by attributes in the first few kilobytes of HTML, before any CSS or JavaScript has run.', 6, 1165,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-00000000001c',
   'Progressive Enhancement in Practice',
   'markdown',
   '# Progressive Enhancement in Practice

Build the version that works with plain HTML. Then add the version that feels instant. The order matters, because the second is an enhancement of the first rather than a replacement for it - and the first is what is left when the script does not arrive.

## "The script does not arrive" is not a thought experiment

People dismiss this as a hypothetical about users who disable JavaScript. Almost nobody disables JavaScript. The script fails for other reasons, and they are ordinary:

- A connection drops mid-download. The HTML arrived; the bundle did not.
- A corporate proxy or an ad blocker matches a filename pattern and blocks the file.
- A syntax error in one module takes out everything bundled with it.
- A browser version does not support a feature used without a guard, and the whole file fails to parse.
- The CDN is having a bad ten minutes.
- The page is being read by something that is not a browser at all.

In each case the HTML works perfectly and the JavaScript does not. What the reader sees then is a design decision you have already made, whether or not you made it deliberately.

## The shape of it

Three layers, each usable alone:

1. **HTML** - the content and the ability to act on it. A form that posts. Links that navigate.
2. **CSS** - the presentation. Readable without it; better with it.
3. **JavaScript** - the enhancement. Faster, smoother, fewer page loads.

## A worked example: filtering a list

The usual implementation fetches on every keystroke and renders the results with JavaScript. With no script, there is an input that does nothing.

Here it is built the other way round.

### Layer one: it works

```html
<form method="get" action="/courses">
  <label for="q">Search courses</label>
  <input type="search" id="q" name="q" value="<?= e($query) ?>">

  <label for="level">Level</label>
  <select id="level" name="level">
    <option value="">Any level</option>
    <option value="beginner">Beginner</option>
    <option value="advanced">Advanced</option>
  </select>

  <button type="submit">Apply</button>
</form>

<ul id="results">
  <!-- rendered by the server -->
</ul>
```

A full page load per filter. Entirely usable. Bookmarkable, shareable, works in every browser, appears in search results, and the back button does the right thing without anybody writing code for it.

### Layer three: it feels instant

```javascript
const form = document.querySelector(''form'');
const results = document.getElementById(''results'');

// Only now is the submit button unnecessary - so only now is it hidden.
form.querySelector(''button[type="submit"]'').hidden = true;

let timer;
form.addEventListener(''input'', () => {
  clearTimeout(timer);
  timer = setTimeout(() => update(), 250);
});

async function update() {
  const params = new URLSearchParams(new FormData(form));

  // The address bar keeps up, so the back button and a copied link still work.
  history.replaceState(null, '''', ''?'' + params);

  const response = await fetch(''/courses?'' + params, {
    headers: { ''X-Requested-With'': ''fetch'' },
  });
  results.innerHTML = await response.text();
  status.textContent = results.children.length + '' courses match'';
}
```

Three details that are easy to miss:

**The submit button is hidden by the script, not by CSS.** If the script never runs, the button is still there and the form still works. Hiding it in the stylesheet would break the page precisely when JavaScript failed.

**`history.replaceState` keeps the URL honest.** Without it, filtering changes what is on screen but not the address, so a copied link gives somebody something else and the back button leaves the page entirely.

**A live region announces the count.** Content that changes without a page load is invisible to a screen reader otherwise.

## Feature detection, not browser detection

```javascript
// Does the thing exist?
if (''IntersectionObserver'' in window) {
  observeImages();
} else {
  loadAllImages();
}

// In CSS
@supports (container-type: inline-size) {
  .card { container-type: inline-size; }
}
```

Never test for a browser name. The user agent string lies - by design, because sites used to use it to lock people out - and a new browser that supports the feature will be caught by your blocklist for years.

## Where the line actually is

Progressive enhancement is not a rule that everything must work without JavaScript. Some things genuinely cannot:

- A code playground that runs Python in the browser.
- A collaborative editor.
- A canvas drawing tool.
- A live video call.

For those, the no-script experience is an honest message rather than a broken page:

```html
<noscript>
  <p>The playground needs JavaScript to run code in your browser.
     The lessons themselves do not - <a href="/courses">browse them here</a>.</p>
</noscript>
```

That is the real test: **is the core content reachable?** A tool can require JavaScript. An article cannot.

## Forms deserve particular care

A form is the one place where failure costs the user their work.

```html
<form method="post" action="/contact">
  <!-- fields -->
  <button type="submit">Send message</button>
</form>
```

```javascript
form.addEventListener(''submit'', async (event) => {
  event.preventDefault();
  const button = form.querySelector(''button'');
  button.disabled = true;

  try {
    const response = await fetch(form.action, {
      method: ''POST'',
      body: new FormData(form),
    });
    if (!response.ok) throw new Error(''rejected'');
    showSuccess();
  } catch {
    // Put it back the way it was and let the browser do it properly.
    button.disabled = false;
    form.submit();
  }
});
```

The `catch` is the part that matters. When the fetch fails, the handler stands down and the browser submits the form normally. The user''s typing is not lost and they do not see a spinner that never stops.

## Server-rendered first, enhanced after

The pattern that makes all of this natural is to render on the server and have the same endpoint able to return a fragment:

```php
// One template, two callers.
if (is_fetch_request()) {
    partial(''course_list'', [''courses'' => $courses]);   // just the list
    exit;
}
render(''courses'', [''courses'' => $courses]);            // the whole page
```

One template, one source of truth. The first page load is HTML the browser can paint immediately; subsequent filters swap a fragment. No duplicated rendering logic between a server template and a client one, which is where the two quietly drift apart.

## What goes wrong

| Symptom | Cause |
|---|---|
| Blank page when a script 404s | Content rendered only by JavaScript |
| A form loses everything on a flaky connection | `preventDefault` with no fallback |
| Back button leaves the page entirely | State changed without `history` |
| Copied link shows something different | The URL never updated |
| Screen reader never hears the new results | No live region |
| Submit button missing with no script | Hidden in CSS instead of by the script |

## The test

Open the Network panel, block your own JavaScript file, and reload.

What you see is what a measurable fraction of your visitors see on any given day - not because they chose to, but because something between you and them failed. If the page is still usable, you have built it in the right order.
',
   'Build the version that works with plain HTML. Then add the version that feels instant. The order matters, because the first one is what runs when the script fails.', 6, 1132,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Refresh the denormalised counters and re-index for search.
-- ---------------------------------------------------------------------------
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000004');
CALL search_reindex_all_quiet();
