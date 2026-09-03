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
INSERT INTO identity.user_roles (user_id, role_id)
SELECT u.id, r.id
  FROM identity.users u
  JOIN identity.roles r ON r.name = 'instructor'
 WHERE u.email = 'lena@learning.test'
ON DUPLICATE KEY UPDATE granted_at = identity.user_roles.granted_at;

INSERT INTO catalog.tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-000000000008', 'html',          'HTML'),
  ('bbbbbbb1-0000-4000-8000-000000000009', 'accessibility', 'Accessibility'),
  ('bbbbbbb1-0000-4000-8000-00000000000a', 'web-standards', 'Web Standards')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ---------------------------------------------------------------------------
-- The course
-- ---------------------------------------------------------------------------
INSERT INTO catalog.courses
  (id, slug, title, subtitle, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000004',
   'html-from-basics-to-expert',
   'HTML: From Basics to Expert',
   'Four levels, twelve lessons, every example runnable in the browser',
   -- catalog.courses.description is plain text, not Markdown. Only
   -- content.articles carries a format column, and only that body is rendered.
   -- Asterisks here would reach the page as literal asterisks.
   'A complete path through HTML in four levels. Level 1, Basic, gets a valid document on screen and teaches the elements you will use every day. Level 2, Intermediate, covers the two hard parts of real pages: tables that actually communicate data, and forms that validate themselves. Level 3, Advanced, moves to semantic layout, accessible components and the metadata that decides how your page looks when someone shares it. Level 4, Expert, finishes with templates, custom elements, loading performance and progressive enhancement.

Every lesson ships a complete, professional code example. None of them are fragments: each one is a document you can paste into a file and open. Press the "Try yourself!" button under any example and it opens in the playground, where you can edit it on the left and watch the rendered result on the right.',
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
  title = VALUES(title), subtitle = VALUES(subtitle), description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog.course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000008'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000009'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

-- ---------------------------------------------------------------------------
-- The four levels
-- ---------------------------------------------------------------------------
INSERT INTO catalog.modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'Level 1 - Basic',
   'A valid document, the text elements, and the three things every page is made of: words, links and pictures.', 1),
  ('d0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'Level 2 - Intermediate',
   'Tables and forms - the two areas where careless markup costs real users the most.', 2),
  ('d0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'Level 3 - Advanced',
   'Semantic layout, accessible components, and the metadata that lives in the head.', 3),
  ('d0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'Level 4 - Expert',
   'Templates, custom elements, loading performance and progressive enhancement.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

-- ---------------------------------------------------------------------------
-- Twelve lessons, three per level. All articles: this course is read-and-run,
-- not watch-and-forget, so there is no video metadata for any of them.
-- ---------------------------------------------------------------------------
INSERT INTO catalog.lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Level 1 - Basic
  ('e0000001-0000-4000-8000-000000000011', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'the-document-skeleton', 'The Document Skeleton',
   'Every page you will ever write starts with these nine lines. Here is what each one is for.',
   'article', 'published', 1, 420, 1),
  ('e0000001-0000-4000-8000-000000000012', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'text-headings-and-meaning', 'Text, Headings and Meaning',
   'Headings are an outline, not a font size. Choosing the right text element is most of what HTML is.',
   'article', 'published', 2, 480, 1),
  ('e0000001-0000-4000-8000-000000000013', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'links-images-and-lists', 'Links, Images and Lists',
   'Three elements carry most of the web. Each has one attribute people forget, and each omission has a cost.',
   'article', 'published', 3, 540, 0),

  -- Level 2 - Intermediate
  ('e0000001-0000-4000-8000-000000000014', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'tables-that-communicate', 'Tables That Communicate Data',
   'A table without a caption and scoped headers is a grid of numbers nobody can read out loud.',
   'article', 'published', 1, 600, 0),
  ('e0000001-0000-4000-8000-000000000015', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'forms-and-native-validation', 'Forms and Native Validation',
   'The browser will validate, autofill and describe your form for free, if you label it properly.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000016', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'responsive-images-and-media', 'Responsive Images and Media',
   'One image element, several files, and the browser picking the cheapest one that still looks right.',
   'article', 'published', 3, 660, 0),

  -- Level 3 - Advanced
  ('e0000001-0000-4000-8000-000000000017', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'semantic-layout-and-landmarks', 'Semantic Layout and Landmarks',
   'Six elements replace a page full of divs and give screen reader users a table of contents.',
   'article', 'published', 1, 660, 0),
  ('e0000001-0000-4000-8000-000000000018', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'accessible-components', 'Accessible Interactive Components',
   'Disclosure, dialog and tabs - built on elements the browser already makes accessible.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000019', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'head-metadata-and-sharing', 'Head Metadata and Sharing',
   'What search engines index, what a chat app previews, and what a browser tab shows.',
   'article', 'published', 3, 600, 0),

  -- Level 4 - Expert
  ('e0000001-0000-4000-8000-00000000001a', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'templates-and-custom-elements', 'Templates and Custom Elements',
   'Inert markup you can stamp out repeatedly, and a tag the browser lets you define yourself.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000001b', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-that-loads-fast', 'HTML That Loads Fast',
   'Attributes that move a page from three seconds to under one, without changing a single byte of the design.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-00000000001c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'progressive-enhancement', 'Progressive Enhancement in Practice',
   'Build the version that works with no JavaScript, then add the version that feels instant.',
   'article', 'published', 3, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
--
-- body_html is left NULL throughout. It is a render cache, and the Content
-- Service fills it from body on first read; seeding it here would mean
-- maintaining the same document twice and letting the two drift.
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000011',
   'The Document Skeleton',
   'markdown',
   '# The Document Skeleton

Every HTML page ever shipped starts from the same nine lines. They are worth
knowing by heart, because a page that omits one of them still *renders* - the
browser repairs it silently - and then behaves strangely in a way that is very
hard to trace back to the missing line.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Field Notes - Bird Survey 2026</title>
    <meta name="description" content="Counts and observations from the spring bird survey.">
    <link rel="stylesheet" href="/assets/site.css">
  </head>
  <body>
    <h1>Field Notes</h1>
    <p>Observations recorded between March and May 2026.</p>
  </body>
</html>
```

## Line by line

**`<!DOCTYPE html>`** is not a tag and it is not optional. It is the switch
between standards mode and quirks mode. Leave it out and the browser emulates
1999: box sizing changes, line heights change, and your layout is subtly wrong
everywhere at once.

**`lang="en"`** tells a screen reader which pronunciation rules to use and tells
the browser which dictionary to spell-check against. A German page read aloud
with English phonemes is unintelligible. One attribute, and it is the single
highest-value accessibility fix in this document.

**`<meta charset="utf-8">`** must appear in the first 1024 bytes, which is why
it goes first inside the head. Without it the browser guesses the encoding, and
its guess is what turns an apostrophe into three garbage characters.

**The viewport meta** is what makes a page respond to phone screens. Without
it, mobile browsers render at 980 pixels wide and then zoom out, so your careful
mobile layout is never used.

**`<title>`** is the browser tab, the bookmark name, and the blue link in search
results. Write it for someone with forty tabs open.

## What the browser adds for you

You never write `<head>` or `<body>` opening tags in the sense of *needing* to -
the parser inserts them if they are missing. Write them anyway. Implicit
structure is fine until the day something lands in the wrong one and you are
reading a DOM tree wondering how your stylesheet ended up in the body.',
   'Every HTML page ever shipped starts from the same nine lines. They are worth knowing by heart, because a page that omits one still renders - the browser repairs it silently - and then behaves strangely.',
   4, 330, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000012',
   'Text, Headings and Meaning',
   'markdown',
   '# Text, Headings and Meaning

Choosing the right text element *is* HTML. Everything else - layout, colour,
spacing - belongs to CSS. The question to ask about every piece of text is not
"how should this look" but "what is this".

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Release notes - Kestrel 4.2</title>
  </head>
  <body>
    <article>
      <h1>Kestrel 4.2</h1>
      <p>
        Released <time datetime="2026-03-14">14 March 2026</time> by the
        platform team.
      </p>

      <h2>Breaking changes</h2>
      <p>
        The <abbr title="Application Programming Interface">API</abbr> now
        rejects requests without an <code>Idempotency-Key</code> header.
        Retries that previously created duplicate orders will now
        <strong>fail loudly</strong> instead.
      </p>

      <h2>Deprecations</h2>
      <p>
        <code>POST /v1/orders/batch</code> is deprecated and will be removed in
        5.0. The replacement is <code>POST /v2/orders</code> with an array body.
      </p>

      <blockquote cite="https://example.com/rfc/idempotency">
        <p>
          A client that cannot safely retry a request cannot be made reliable by
          the server alone.
        </p>
        <footer>- Internal RFC 12, <cite>Idempotent Writes</cite></footer>
      </blockquote>

      <h2>Fixed</h2>
      <p>
        Order totals no longer drift by <del>0.01</del> <ins>0.00</ins> on
        multi-currency baskets.
      </p>
    </article>
  </body>
</html>
```

## Headings are an outline

`h1` through `h6` describe a document outline. Screen reader users navigate by
jumping between them, the way a sighted reader skims for bold text. Two rules
follow from that:

1. **Do not skip levels.** An `h4` directly under an `h2` reads as a missing
   section.
2. **Do not choose a level for its size.** If an `h2` is too big, that is three
   lines of CSS, not a reason to use `h4`.

## The pairs people confuse

| Looks the same | Means |
| --- | --- |
| `<strong>` vs `<b>` | importance vs stylistically offset |
| `<em>` vs `<i>` | stress emphasis vs alternate voice or term |
| `<del>` vs `<s>` | removed from the document vs no longer accurate |

A screen reader changes its tone for `strong` and `em`. It says nothing
different for `b` and `i`. Use the first pair unless you specifically mean the
second.

## Machine-readable dates

`<time datetime="2026-03-14">14 March 2026</time>` gives humans the readable
form and machines the parseable one. Write "next Tuesday" in the text if you
like; the attribute is what a calendar integration reads.',
   'Choosing the right text element is HTML. Everything else - layout, colour, spacing - belongs to CSS. The question to ask about every piece of text is not how should this look but what is this.',
   5, 400, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000013',
   'Links, Images and Lists',
   'markdown',
   '# Links, Images and Lists

Three elements carry most of the web. Each one has an attribute people leave
off, and each omission has a specific cost.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trail guide - Cairngorms</title>
  </head>
  <body>
    <h1>Lairig Ghru</h1>

    <figure>
      <img
        src="/img/lairig-ghru-1600.jpg"
        alt="A wide glacial pass between two granite ridges, snow on the summits"
        width="1600"
        height="900"
        loading="lazy"
        decoding="async">
      <figcaption>
        The pass seen from Rothiemurchus, looking south.
      </figcaption>
    </figure>

    <h2>Before you go</h2>
    <ul>
      <li>Check the <a href="/weather/cairngorms">mountain forecast</a>.</li>
      <li>Carry a paper map - there is no signal in the pass.</li>
      <li>
        Leave a route card with someone. The
        <a
          href="https://www.mountaineering.scot/safety"
          rel="noopener noreferrer"
          target="_blank">
          Mountaineering Scotland safety guidance
          <span aria-hidden="true">(opens in a new tab)</span>
        </a>
        explains what to include.
      </li>
    </ul>

    <h2>The route</h2>
    <ol>
      <li>Follow the Allt Druidh path south from Coylumbridge.</li>
      <li>Climb steadily to the Pools of Dee at the summit of the pass.</li>
      <li>Descend to the Corrour bothy and pick up the Dee-side track.</li>
    </ol>

    <h2>At a glance</h2>
    <dl>
      <dt>Distance</dt>
      <dd>31 km point to point</dd>

      <dt>Ascent</dt>
      <dd>760 m</dd>

      <dt>Grade</dt>
      <dd>Strenuous - remote, no escape routes for 14 km</dd>
    </dl>
  </body>
</html>
```

## `alt` is not a caption

`alt` replaces the image for someone who cannot see it. That means it describes
the image''s *function in this page*, not its contents in general.

- A photo illustrating the text: describe what matters about it.
- A decorative flourish: `alt=""`. Empty, present. That tells a screen reader to
  skip it. Omitting `alt` entirely makes it read the filename out loud instead.
- An image inside a link with no other text: the `alt` becomes the link text, so
  it must describe *the destination*, not the picture.

## `width` and `height` are a layout fix

They are not there to size the image - CSS does that. They give the browser the
aspect ratio before the file arrives, so it can reserve the right amount of
space. Leave them off and everything below the image jumps down when it loads.
That jump is the single most common cause of a poor Cumulative Layout Shift
score, and of a reader tapping the wrong link.

## `target="_blank"` needs company

Opening a new tab hands the new page a reference to yours through
`window.opener`, which it can use to navigate your tab elsewhere. `rel="noopener"`
severs that reference. Modern browsers imply it, but older ones do not, and it
costs eight characters. Add a visible or screen-reader-only hint too: a tab
opening unannounced is disorienting for everyone and especially so for someone
using a magnifier.

## Choosing a list

- **`ul`** - order does not matter.
- **`ol`** - order matters. Steps, rankings, anything you would number in prose.
- **`dl`** - name/value pairs. Specifications, glossaries, metadata blocks.

A screen reader announces "list, 3 items" before reading. That count is the
whole reason to use a list element instead of three paragraphs with dashes.',
   'Three elements carry most of the web. Each one has an attribute people leave off, and each omission has a specific cost.',
   6, 520, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 2 - Intermediate
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000014',
   'Tables That Communicate Data',
   'markdown',
   '# Tables That Communicate Data

A table is the right element whenever you have two-dimensional data. It is the
wrong element for page layout, and the difference is not aesthetic: a screen
reader announces "table, 4 columns, 6 rows" and then offers cell-by-cell
navigation, which is helpful for data and baffling for a layout.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quarterly revenue by region</title>
    <style>
      table { border-collapse: collapse; font: 16px/1.5 system-ui, sans-serif; }
      caption { text-align: left; font-weight: 600; padding-block: 0.5rem; }
      th, td { border: 1px solid #d0d5dd; padding: 0.5rem 0.75rem; }
      thead th { background: #f2f4f7; }
      td.numeric, th.numeric { text-align: right; font-variant-numeric: tabular-nums; }
      tfoot { font-weight: 600; }
    </style>
  </head>
  <body>
    <table>
      <caption>
        Revenue by region, financial year 2026
        <span>All figures in thousands of GBP, excluding VAT.</span>
      </caption>

      <colgroup>
        <col>
        <col span="4" class="quarters">
      </colgroup>

      <thead>
        <tr>
          <th scope="col">Region</th>
          <th scope="col" class="numeric">Q1</th>
          <th scope="col" class="numeric">Q2</th>
          <th scope="col" class="numeric">Q3</th>
          <th scope="col" class="numeric">Q4</th>
        </tr>
      </thead>

      <tbody>
        <tr>
          <th scope="row">North</th>
          <td class="numeric">412</td>
          <td class="numeric">455</td>
          <td class="numeric">501</td>
          <td class="numeric">548</td>
        </tr>
        <tr>
          <th scope="row">Midlands</th>
          <td class="numeric">308</td>
          <td class="numeric">331</td>
          <td class="numeric">327</td>
          <td class="numeric">390</td>
        </tr>
        <tr>
          <th scope="row">South</th>
          <td class="numeric">690</td>
          <td class="numeric">712</td>
          <td class="numeric">744</td>
          <td class="numeric">801</td>
        </tr>
      </tbody>

      <tfoot>
        <tr>
          <th scope="row">Total</th>
          <td class="numeric">1,410</td>
          <td class="numeric">1,498</td>
          <td class="numeric">1,572</td>
          <td class="numeric">1,739</td>
        </tr>
      </tfoot>
    </table>
  </body>
</html>
```

## The four things that make it readable

**`<caption>`** is the table''s accessible name, and it must be the first child
of `<table>`. A user listing the tables on a page hears the captions; a table
without one is announced as "table" and nothing else.

**`scope`** is the load-bearing attribute. `scope="col"` says this header
describes the column below it; `scope="row"` says it describes the row beside
it. With both in place, a screen reader reading the cell `744` announces
"South, Q3, 744". Without them it announces "744".

**Row headers are `<th>`, not `<td>`.** The first cell of each body row names
that row - it is a header, so it takes the header element.

**`<thead>` / `<tbody>` / `<tfoot>`** let the browser repeat the header when a
long table breaks across printed pages, and let you scroll the body under a
sticky header with two lines of CSS.

## Numbers deserve their own treatment

`font-variant-numeric: tabular-nums` makes every digit the same width, so the
columns line up on screen the way they would in a spreadsheet. Right-aligning
numeric columns is not decoration either: it puts the units, tens and hundreds
in vertical columns so the eye can compare magnitudes without reading.

## When the table is wider than the screen

Do not remove columns. Wrap the table in a scrolling container and make it
focusable so a keyboard user can reach the scroll:

```html
<div class="table-scroll" tabindex="0" role="region" aria-labelledby="rev-cap">
  <table aria-describedby="rev-note"> ... </table>
</div>
```

A `role="region"` with an accessible name is announced as a landmark, so the
table becomes something a user can jump to rather than something they scroll
past.',
   'A table is the right element whenever you have two-dimensional data, and the wrong element for page layout. The difference is not aesthetic.',
   6, 500, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000015',
   'Forms and Native Validation',
   'markdown',
   '# Forms and Native Validation

The browser will label, validate, autofill, and describe your form for free.
Most of the JavaScript written for forms is re-implementing something that was
already there and doing it worse - without keyboard support, without
translation, and without working when the script fails to load.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create your account</title>
  </head>
  <body>
    <h1>Create your account</h1>

    <form action="/register" method="post" novalidate>
      <fieldset>
        <legend>Your details</legend>

        <p>
          <label for="full-name">Full name</label>
          <input
            id="full-name"
            name="fullName"
            type="text"
            autocomplete="name"
            required
            maxlength="120"
            autocapitalize="words">
        </p>

        <p>
          <label for="email">Email address</label>
          <input
            id="email"
            name="email"
            type="email"
            autocomplete="email"
            inputmode="email"
            spellcheck="false"
            required
            aria-describedby="email-hint">
          <span id="email-hint">We use this to send your receipt. No marketing.</span>
        </p>

        <p>
          <label for="password">Password</label>
          <input
            id="password"
            name="password"
            type="password"
            autocomplete="new-password"
            required
            minlength="12"
            aria-describedby="password-rule">
          <span id="password-rule">At least 12 characters. Length beats symbols.</span>
        </p>
      </fieldset>

      <fieldset>
        <legend>How should we contact you?</legend>

        <p>
          <input id="contact-email" name="contact" type="radio" value="email" checked>
          <label for="contact-email">Email only</label>
        </p>
        <p>
          <input id="contact-none" name="contact" type="radio" value="none">
          <label for="contact-none">Do not contact me</label>
        </p>
      </fieldset>

      <p>
        <input id="terms" name="terms" type="checkbox" value="accepted" required>
        <label for="terms">
          I accept the <a href="/terms">terms of service</a>.
        </label>
      </p>

      <button type="submit">Create account</button>
    </form>
  </body>
</html>
```

## Every input needs a label, and `for` must match `id`

A placeholder is not a label. It disappears the moment someone types, it fails
contrast requirements in most designs, and screen readers treat it
inconsistently. A real `<label>` also gives you a bigger click target for free -
clicking the word focuses the field.

## `autocomplete` is worth more than it looks

The values are a specified vocabulary - `name`, `email`, `street-address`,
`cc-number`, `one-time-code`. Getting them right means the browser and the
password manager fill the form correctly on the first try. `autocomplete="new-password"`
in particular is the difference between a manager offering to *generate* a
password and offering to *fill in* the old one.

## `inputmode` versus `type`

`type` decides validation and the data model. `inputmode` decides which on-screen
keyboard appears. They are often the same choice but not always: a postcode
wants `type="text"` with `inputmode="text"`, while a one-time code wants
`type="text"` with `inputmode="numeric"` - because `type="number"` on a code
strips leading zeros and shows a spinner nobody wants.

## About that `novalidate`

The example sets it deliberately. Native validation messages cannot be styled or
translated per-page, and they appear one at a time. The professional pattern is:
keep every constraint attribute (`required`, `minlength`, `type="email"`) so the
*Constraint Validation API* knows the rules, add `novalidate` to suppress the
default bubbles, then render your own summary with JavaScript - and validate
everything again on the server, because a constraint attribute is a hint to a
cooperating browser, never a guarantee.',
   'The browser will label, validate, autofill and describe your form for free. Most form JavaScript re-implements something that was already there, and does it worse.',
   7, 610, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000016',
   'Responsive Images and Media',
   'markdown',
   '# Responsive Images and Media

Sending a 2400-pixel-wide photograph to a phone wastes the visitor''s data and
their battery, and it is the easiest performance win on most sites. HTML has
had the fix built in for a decade.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Responsive media</title>
  </head>
  <body>
    <h1>The reading room</h1>

    <!-- Same picture, several encodings and sizes.
         The browser picks one; it never downloads the rest. -->
    <picture>
      <source
        type="image/avif"
        srcset="/img/room-480.avif 480w,
                /img/room-960.avif 960w,
                /img/room-1920.avif 1920w"
        sizes="(min-width: 64rem) 60rem, 100vw">
      <source
        type="image/webp"
        srcset="/img/room-480.webp 480w,
                /img/room-960.webp 960w,
                /img/room-1920.webp 1920w"
        sizes="(min-width: 64rem) 60rem, 100vw">
      <img
        src="/img/room-960.jpg"
        alt="A long reading room with green lamps on every desk"
        width="1920"
        height="1080"
        loading="lazy"
        decoding="async">
    </picture>

    <!-- Art direction: a different crop on narrow screens,
         not merely a smaller version of the same one. -->
    <picture>
      <source media="(max-width: 40rem)" srcset="/img/portrait-crop.jpg">
      <img
        src="/img/wide-crop.jpg"
        alt="The librarian at the issue desk"
        width="1600"
        height="900">
    </picture>

    <figure>
      <video
        controls
        preload="metadata"
        poster="/video/tour-poster.jpg"
        width="1280"
        height="720"
        playsinline>
        <source src="/video/tour.webm" type="video/webm">
        <source src="/video/tour.mp4" type="video/mp4">
        <track
          kind="captions"
          src="/video/tour.en.vtt"
          srclang="en"
          label="English"
          default>
        <p>
          Your browser cannot play embedded video.
          <a href="/video/tour.mp4">Download the tour (24 MB)</a>.
        </p>
      </video>
      <figcaption>A three-minute tour of the building.</figcaption>
    </figure>
  </body>
</html>
```

## `srcset` and `sizes` are a pair

`srcset` lists the files and their real widths in pixels (`960w`). `sizes` tells
the browser how wide the image will be *laid out*, using CSS lengths and media
queries. The browser combines the two with the device pixel ratio and picks a
file - and it does this before any CSS or JavaScript has been parsed, which is
why `sizes` has to describe your layout rather than let the browser measure it.

Get `sizes` wrong and the mechanism still works, it just chooses badly. A common
mistake is leaving the default `100vw` on an image that is actually shown in a
narrow column, which downloads a file four times larger than needed.

## `srcset` versus `<picture>`

- **Same image, different sizes** - `srcset` on the `<img>`. Let the browser
  choose.
- **Different formats** - `<source type="...">`, best format first. The browser
  takes the first one it can decode.
- **Different crops** - `<source media="...">`. This is *art direction*, and it
  is the only case where you are making the decision rather than the browser.

The `<img>` is always the last child and always required. It is what actually
renders; the `<source>` elements only redirect it.

## `loading="lazy"` has one exception

Lazy-load everything below the fold. Never lazy-load the image at the top of the
page - it is almost always the Largest Contentful Paint element, and deferring
it delays the metric you were trying to improve. For that one image use
`fetchpriority="high"` instead.

## Captions are not optional

A `<track kind="captions">` serves people who are deaf or hard of hearing,
people in a noisy room, and people watching with the sound off - which is most
people on a phone. `default` marks the track to enable automatically.',
   'Sending a 2400-pixel photograph to a phone wastes the visitor''s data and battery, and it is the easiest performance win on most sites. HTML has had the fix built in for a decade.',
   6, 560, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 3 - Advanced
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000017',
   'Semantic Layout and Landmarks',
   'markdown',
   '# Semantic Layout and Landmarks

Six elements replace a page full of `<div class="header">` and give screen
reader users something a sighted reader has always had: the ability to skim.
Landmarks are the skimming interface.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Coastal Path Trust</title>
  </head>
  <body>
    <a class="skip-link" href="#main">Skip to content</a>

    <header class="site-header">
      <a class="brand" href="/">Coastal Path Trust</a>

      <nav aria-label="Main">
        <ul>
          <li><a href="/routes">Routes</a></li>
          <li><a href="/volunteer">Volunteer</a></li>
          <li><a href="/about" aria-current="page">About</a></li>
        </ul>
      </nav>

      <form class="site-search" action="/search" method="get" role="search">
        <label for="q">Search the site</label>
        <input id="q" name="q" type="search" autocomplete="off">
        <button type="submit">Search</button>
      </form>
    </header>

    <main id="main">
      <nav aria-label="Breadcrumb">
        <ol>
          <li><a href="/">Home</a></li>
          <li><a href="/about">About</a></li>
          <li><a href="/about/history" aria-current="page">History</a></li>
        </ol>
      </nav>

      <article>
        <header>
          <h1>Fifty years of the coastal path</h1>
          <p>
            By Aisha Rahman -
            <time datetime="2026-02-02">2 February 2026</time>
          </p>
        </header>

        <section aria-labelledby="beginnings">
          <h2 id="beginnings">Beginnings</h2>
          <p>The first eleven miles opened in the spring of 1976.</p>
        </section>

        <section aria-labelledby="today">
          <h2 id="today">The path today</h2>
          <p>It now runs unbroken for six hundred and thirty miles.</p>
        </section>

        <footer>
          <p>Filed under <a href="/tags/history" rel="tag">history</a>.</p>
        </footer>
      </article>

      <aside aria-labelledby="related">
        <h2 id="related">Related</h2>
        <ul>
          <li><a href="/routes/south-west">The south-west section</a></li>
          <li><a href="/volunteer/wardens">Become a warden</a></li>
        </ul>
      </aside>
    </main>

    <footer class="site-footer">
      <p>Registered charity 1042351.</p>
    </footer>
  </body>
</html>
```

## What each element maps to

| Element | Landmark role | How many |
| --- | --- | --- |
| `<header>` (page level) | `banner` | one per page |
| `<nav>` | `navigation` | as many as you need, each named |
| `<main>` | `main` | exactly one |
| `<aside>` | `complementary` | as many as you need |
| `<footer>` (page level) | `contentinfo` | one per page |
| `<form role="search">` | `search` | usually one |

`<header>` and `<footer>` only become `banner` and `contentinfo` when they are
direct children of `<body>`. Nested inside an `<article>`, as above, they are
ordinary grouping elements - which is exactly what you want for a byline and a
tag list.

## Name every landmark you have more than one of

Three unlabelled `<nav>` elements are announced as "navigation, navigation,
navigation". With `aria-label="Main"` and `aria-label="Breadcrumb"` they become
a usable menu. The rule is simple: if a landmark type appears more than once,
every instance of it needs a name.

Use `aria-labelledby` pointing at a real heading when one exists, as the
`<section>` and `<aside>` do above. A visible heading is better than an
invisible label, because sighted users get it too.

## The skip link

The first focusable element on the page should jump past the navigation. A
keyboard user who tabs into your site otherwise walks through forty menu links
on every single page. Three lines of CSS keep it off screen until it is focused:

```html
<style>
  .skip-link {
    position: absolute;
    left: -9999px;
  }
  .skip-link:focus {
    left: 1rem;
    top: 1rem;
  }
</style>
```

Never use `display: none` for this. A hidden element cannot receive focus, so
the link stops working entirely.

## `<section>` needs a name to count

A `<section>` without an accessible name is not exposed as a `region` landmark
at all - it is just a box. If it does not warrant a heading, it does not warrant
being a `<section>`; use a `<div>`.',
   'Six elements replace a page full of divs and give screen reader users something a sighted reader has always had: the ability to skim.',
   6, 560, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000018',
   'Accessible Interactive Components',
   'markdown',
   '# Accessible Interactive Components

The accessible version of most components is the one built on an element the
browser already understands. Focus management, keyboard handling, escape-to-close
and screen reader announcements are hard to write and free to inherit.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accessible components</title>
  </head>
  <body>
    <h1>Booking help</h1>

    <!-- 1. Disclosure. No JavaScript at all: the browser handles
            open/close, keyboard activation and the ARIA state. -->
    <details name="faq">
      <summary>Can I change my booking after paying?</summary>
      <p>
        Yes, up to 24 hours before departure. Changes made later are treated as
        a cancellation.
      </p>
    </details>

    <details name="faq">
      <summary>Do I need to print my ticket?</summary>
      <p>No. The barcode in the confirmation email is enough.</p>
    </details>

    <!-- 2. Modal dialog. showModal() gives you the backdrop,
            the focus trap, inert background content and Escape. -->
    <button type="button" id="open-refund">Request a refund</button>

    <dialog id="refund" aria-labelledby="refund-title">
      <form method="dialog">
        <h2 id="refund-title">Request a refund</h2>
        <p>
          <label for="reason">Why are you cancelling?</label>
          <textarea id="reason" name="reason" rows="4" required></textarea>
        </p>
        <button value="cancel" formnovalidate>Never mind</button>
        <button value="send">Send request</button>
      </form>
    </dialog>

    <!-- 3. A live region: announced when its text changes,
            without moving focus away from what the user is doing. -->
    <p id="status" role="status" aria-live="polite"></p>

    <script type="module">
      const dialog = document.getElementById("refund");
      const status = document.getElementById("status");

      document.getElementById("open-refund")
        .addEventListener("click", () => dialog.showModal());

      // close fires however the dialog was dismissed: button, Escape,
      // or a backdrop click if you wire one up.
      dialog.addEventListener("close", () => {
        status.textContent = dialog.returnValue === "send"
          ? "Refund request sent. We reply within two working days."
          : "No changes were made to your booking.";
      });
    </script>
  </body>
</html>
```

## `<details>` is the component you should reach for first

It is a complete disclosure widget: keyboard operable, correctly announced as
"expanded" or "collapsed", and it works with JavaScript disabled. The `name`
attribute groups several together into an accordion where opening one closes the
rest - which is the entire feature people used to write two hundred lines for.

`<summary>` is the button. Put the label there and nothing else that is
interactive; a link inside a summary is ambiguous to both mouse and keyboard.

## `<dialog>` and `showModal()`

Call `showModal()`, not `show()`. `showModal()` is the one that:

- renders the `::backdrop` pseudo-element,
- makes everything outside the dialog inert, so tab cannot leave it,
- moves focus into the dialog and restores it to the trigger on close,
- closes on Escape.

`show()` does none of that. It opens a non-modal box and leaves you to implement
the rest.

`<form method="dialog">` closes the dialog on submit without navigating, and
puts the pressed button''s `value` into `dialog.returnValue`. That is how the
example distinguishes "Send" from "Never mind" without a single event listener
on either button.

## Live regions announce without stealing focus

`role="status"` with `aria-live="polite"` means: when this text changes, read it
at the next natural pause. Use it for confirmations, result counts and
autosave indicators. Use `aria-live="assertive"` only for errors that stop the
user - it interrupts mid-word.

The region must be in the DOM *before* the text changes. Inserting a new element
that already contains the message is frequently not announced at all.

## When you do have to build it yourself

Tabs, comboboxes and tree views have no native element. Then, and only then,
reach for ARIA roles - and follow the APG keyboard patterns exactly, because a
component that says `role="tablist"` and does not respond to arrow keys is worse
than no ARIA at all. You have promised a behaviour the user now expects.',
   'The accessible version of most components is the one built on an element the browser already understands. Focus management and keyboard handling are hard to write and free to inherit.',
   7, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-000000000019',
   'Head Metadata and Sharing',
   'markdown',
   '# Head Metadata and Sharing

Nobody sees the `<head>`, and it decides what your page looks like in a search
result, in a shared link, on a phone home screen and in a browser tab. It is the
highest-leverage markup in the document per byte written.

```html
<!DOCTYPE html>
<html lang="en-GB">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Reading EXPLAIN Output - Learning Platform</title>
    <meta name="description"
          content="How to read a MySQL query plan: what rows, filtered and Extra actually mean, and which numbers are worth trusting.">

    <link rel="canonical" href="https://learn.example.com/courses/mysql/reading-explain">
    <link rel="alternate" hreflang="en-GB" href="https://learn.example.com/courses/mysql/reading-explain">
    <link rel="alternate" hreflang="de" href="https://learn.example.com/de/kurse/mysql/explain-lesen">

    <meta name="robots" content="index, follow, max-image-preview:large">
    <meta name="theme-color" content="#0b3d2c">
    <meta name="color-scheme" content="light dark">

    <!-- Open Graph: Facebook, LinkedIn, Slack, WhatsApp, Discord. -->
    <meta property="og:type" content="article">
    <meta property="og:site_name" content="Learning Platform">
    <meta property="og:title" content="Reading EXPLAIN Output">
    <meta property="og:description" content="What rows, filtered and Extra actually mean.">
    <meta property="og:url" content="https://learn.example.com/courses/mysql/reading-explain">
    <meta property="og:image" content="https://learn.example.com/og/reading-explain.png">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="A query plan with the scanned-rows column highlighted">
    <meta property="article:published_time" content="2026-02-18T09:00:00Z">

    <meta name="twitter:card" content="summary_large_image">

    <link rel="icon" href="/favicon.ico" sizes="32x32">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
    <link rel="manifest" href="/site.webmanifest">

    <link rel="preconnect" href="https://cdn.example.com" crossorigin>
  </head>
  <body>
    <h1>Reading EXPLAIN Output</h1>
    <p>A query plan is a tree. Read it from the leaves inward.</p>
  </body>
</html>
```

## `<title>` and `description` are the search result

The title is the blue link; the description is the grey text underneath. Search
engines rewrite descriptions they judge unhelpful, so write one that answers
"what will I get if I click this", in roughly 150 characters. Put the specific
part first - "Reading EXPLAIN Output - Learning Platform", not the other way
round, because the tail is what gets truncated.

`description` has no effect on ranking. It has a large effect on click-through,
which is not the same thing and is more useful.

## `canonical` prevents you competing with yourself

The same page reachable at `?utm_source=newsletter`, `?page=1` and with a
trailing slash is four URLs holding one page''s worth of value. A canonical link
tells the crawler which one is real. It must be an absolute URL, and it must be
self-referential on the canonical page itself.

## Open Graph is a separate vocabulary, and it needs absolute URLs

Note `property=` rather than `name=` - Open Graph uses RDFa attributes and a
scraper looking for `property` will not find `name`. Declare
`og:image:width` and `og:image:height` so the preview can be laid out before the
image downloads, and give the image an `alt`.

Relative URLs do not work here. The scraper is a different machine on a different
network with no notion of your page''s base URL.

## Structured data for rich results

Open Graph controls the preview. Schema.org JSON-LD controls whether you are
eligible for a rich result - a recipe card, a course listing, a breadcrumb trail
in the search result:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "MySQL for Application Developers",
  "description": "Schema design, indexing and the queries behind a real product.",
  "provider": {
    "@type": "Organization",
    "name": "Learning Platform",
    "sameAs": "https://learn.example.com"
  }
}
</script>
```

JSON-LD goes in a script tag the browser never executes - the type is not
`text/javascript`, so it is inert data. Keep it consistent with the visible page;
describing a paid course as free is a manual-action penalty, not a clever trick.',
   'Nobody sees the head, and it decides what your page looks like in a search result, in a shared link, on a home screen and in a browser tab.',
   6, 570, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 4 - Expert
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000001a',
   'Templates and Custom Elements',
   'markdown',
   '# Templates and Custom Elements

`<template>` is markup the parser reads but does not render: no images fetched,
no scripts run, no styles applied. It sits in the document as a stencil you
stamp out. A custom element is a tag you define yourself, which the browser then
upgrades wherever it appears - including in HTML that arrived after page load.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Star rating</title>
  </head>
  <body>
    <h1>Course reviews</h1>

    <star-rating value="4" count="128">
      <a href="/courses/html/reviews">4 out of 5 from 128 reviews</a>
    </star-rating>

    <star-rating value="5" count="12">
      <a href="/courses/css/reviews">5 out of 5 from 12 reviews</a>
    </star-rating>

    <template id="star-rating-template">
      <style>
        :host { display: inline-flex; align-items: center; gap: 0.4rem; }
        .stars { letter-spacing: 0.1em; color: #b7791f; }
        .count { color: #667085; font-size: 0.875em; }
      </style>
      <span class="stars" part="stars" aria-hidden="true"></span>
      <span class="count"><slot></slot></span>
    </template>

    <script type="module">
      class StarRating extends HTMLElement {
        // Changing one of these re-runs attributeChangedCallback.
        static observedAttributes = ["value", "count"];

        #stars;

        constructor() {
          super();
          const template = document.getElementById("star-rating-template");
          this.attachShadow({ mode: "open" })
              .append(template.content.cloneNode(true));
          this.#stars = this.shadowRoot.querySelector(".stars");
        }

        connectedCallback() {
          // The light-DOM link is the accessible name and the no-JS fallback,
          // so the shadow copy is decorative and hidden from assistive tech.
          this.#render();
        }

        attributeChangedCallback() {
          this.#render();
        }

        #render() {
          const value = Math.max(0, Math.min(5, Number(this.getAttribute("value")) || 0));
          this.#stars.textContent = "*".repeat(value).padEnd(5, ".");
        }
      }

      customElements.define("star-rating", StarRating);
    </script>
  </body>
</html>
```

## Why `<template>` and not a string of HTML

`template.content` is a `DocumentFragment` that was parsed once, by the real HTML
parser, at page load. Cloning it is a DOM copy - no re-parsing, no escaping
mistakes, and no chance of an injection because there is no string concatenation
anywhere in the path. Building markup with `innerHTML +=` in a loop does the
opposite of all four.

## The light DOM is your fallback

Look at what is between the `<star-rating>` tags: a plain link that says
"4 out of 5 from 128 reviews". If the script never loads, if it throws, or if
the visitor is on a browser without custom elements, that link is what renders.
The `<slot>` in the template is what pulls it into the shadow tree once the
element upgrades.

This is the whole discipline of custom elements: **the fallback content is the
real content**. The shadow DOM is presentation on top of it.

## Shadow DOM boundaries

`attachShadow({ mode: "open" })` scopes the styles inside the template to this
element - the `.stars` rule cannot leak out and a page-level `.stars` rule
cannot leak in. That isolation is the feature, and it is also the cost: you
expose deliberate hooks with `::part()` (note `part="stars"` above) and custom
properties, or the component becomes unstylable by its users.

`:host` styles the element itself. Give it a `display` - custom elements are
`display: inline` by default, which surprises everyone once.

## Lifecycle, in order

1. `constructor` - attach the shadow root. **Do not** read attributes or touch
   children here; the element may not have any yet.
2. `connectedCallback` - it is in the document. Read attributes, add listeners,
   render. This can fire more than once if the element is moved.
3. `attributeChangedCallback` - one of `observedAttributes` changed.
4. `disconnectedCallback` - remove listeners and observers here, or you have
   written a memory leak.

## Naming

A custom element name must contain a hyphen. That is not style guidance, it is
the rule that guarantees your tag can never collide with a future standard
element.',
   'A template is markup the parser reads but does not render: no images fetched, no scripts run. A custom element is a tag you define yourself, which the browser upgrades wherever it appears.',
   8, 690, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-00000000001b',
   'HTML That Loads Fast',
   'markdown',
   '# HTML That Loads Fast

Most of a page''s loading behaviour is decided by attributes in the first few
kilobytes of HTML, before any CSS or JavaScript has run. Getting them right
costs nothing at runtime and is usually worth more than any amount of bundler
configuration.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kestrel - order management</title>

    <!-- 1. Open the connection to the asset host now, in parallel with
            parsing, so the DNS + TLS handshake is not on the critical path. -->
    <link rel="preconnect" href="https://cdn.example.com" crossorigin>

    <!-- 2. The font the heading uses. Discovered late otherwise, because
            the browser only finds it after downloading and parsing CSS. -->
    <link
      rel="preload"
      href="/fonts/inter-var.woff2"
      as="font"
      type="font/woff2"
      crossorigin>

    <!-- 3. Render-blocking by design: this is the styling for what is
            visible immediately, and a flash of unstyled text is worse. -->
    <link rel="stylesheet" href="/css/critical.css">

    <!-- 4. Not render-blocking: everything below the fold. The media
            trick loads it at low priority, then applies it. -->
    <link
      rel="stylesheet"
      href="/css/rest.css"
      media="print"
      onload="this.media=''all''">

    <!-- 5. Deferred: parsed in order, executed after the document is
            ready, never blocking the parser. -->
    <script type="module" src="/js/app.js"></script>
    <script nomodule defer src="/js/legacy.js"></script>
  </head>

  <body>
    <header>
      <!-- 6. The LCP image. Eager, high priority, never lazy. -->
      <img
        src="/img/hero-1200.avif"
        alt=""
        width="1200"
        height="500"
        fetchpriority="high"
        decoding="async">
      <h1>Orders</h1>
    </header>

    <main>
      <!-- 7. Below the fold: deferred until it is close to the viewport. -->
      <img
        src="/img/chart-800.avif"
        alt="Orders per day for the last 30 days, rising steadily"
        width="800"
        height="400"
        loading="lazy"
        decoding="async">

      <!-- 8. A third-party embed, isolated and deferred. -->
      <iframe
        src="https://maps.example.com/embed?id=warehouse-3"
        title="Warehouse 3 location"
        width="600"
        height="400"
        loading="lazy"
        referrerpolicy="no-referrer"
        sandbox="allow-scripts allow-same-origin"></iframe>
    </main>
  </body>
</html>
```

## `defer` versus `async` versus `type="module"`

| | Blocks parsing | Execution order | Runs at |
| --- | --- | --- | --- |
| `<script>` | yes | document order | immediately |
| `async` | no | whenever it arrives | on arrival |
| `defer` | no | document order | after parsing |
| `type="module"` | no | document order | after parsing |

`type="module"` is deferred by default, which is why the example needs no
`defer` on it. Use `async` only for scripts with no dependencies and nothing
depending on them - analytics is the standard example. Anything else gets
`defer`, because "whenever it arrives" means the execution order changes between
runs and the bug only appears on a slow connection.

## `preload` is a promise, not a hint

`rel="preload"` says "I will definitely need this, fetch it at high priority
now". Preload something you do not use and the browser warns in the console -
you have spent bandwidth on the critical path for nothing. Two things to get
right:

- `as` is mandatory. It sets the priority and the Accept header. Without it the
  file is fetched twice.
- `crossorigin` is mandatory for fonts, even same-origin ones, because fonts are
  fetched in CORS mode. Omit it and you get two copies of the file.

Use `preconnect` for a host you will use, `dns-prefetch` for one you might, and
neither for more than a handful - each open connection has a cost.

## Reserve space for everything

`width` and `height` on every image and iframe, and explicit dimensions for ad
slots and embeds. The browser computes the aspect ratio and holds the space
before the resource arrives. This is the whole of Cumulative Layout Shift, and
it is a correctness issue rather than an aesthetic one: content that moves under
a finger causes mis-taps.

## Isolate third-party embeds

`sandbox` on an iframe removes capabilities and adds them back one at a time.
`referrerpolicy="no-referrer"` stops the embed learning which of your pages the
user is on. `loading="lazy"` keeps a map widget from competing with your own
content for bandwidth during the initial load.',
   'Most of a page''s loading behaviour is decided by attributes in the first few kilobytes of HTML, before any CSS or JavaScript has run.',
   7, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),

  ('e0000001-0000-4000-8000-00000000001c',
   'Progressive Enhancement in Practice',
   'markdown',
   '# Progressive Enhancement in Practice

Build the version that works with plain HTML. Then add the version that feels
instant. The order matters, because the second one is an enhancement of the
first rather than a replacement for it - and the first one is what runs when the
script fails, which happens more often than the analytics suggest.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Search the catalogue</title>
  </head>
  <body>
    <h1>Search the catalogue</h1>

    <!-- Works with no JavaScript: GET to a server-rendered results page.
         The action and method are the contract; the script below only
         intercepts them. -->
    <form id="search" action="/search" method="get" role="search">
      <label for="q">Search courses</label>
      <input id="q" name="q" type="search" autocomplete="off" required>

      <label for="level">Level</label>
      <select id="level" name="level">
        <option value="">Any level</option>
        <option value="beginner">Beginner</option>
        <option value="intermediate">Intermediate</option>
        <option value="advanced">Advanced</option>
      </select>

      <button type="submit">Search</button>
    </form>

    <p id="search-status" role="status" aria-live="polite"></p>

    <!-- Server-rendered on first load. Replaced in place after that. -->
    <ul id="results" aria-labelledby="results-heading">
      <li><a href="/courses/html-from-basics-to-expert">HTML: From Basics to Expert</a></li>
      <li><a href="/courses/mysql-for-applications">MySQL for Application Developers</a></li>
    </ul>

    <script type="module">
      const form = document.getElementById("search");
      const results = document.getElementById("results");
      const status = document.getElementById("search-status");

      let inFlight = null;

      form.addEventListener("submit", async (event) => {
        // Only now do we take over. Until this line runs, the form
        // is a plain HTML form and submitting it navigates.
        event.preventDefault();

        // A new search supersedes the one still running, so a slow
        // early response cannot overwrite a fast later one.
        inFlight?.abort();
        inFlight = new AbortController();

        const query = new URLSearchParams(new FormData(form));

        // Keep the URL honest: back, forward, reload and share all work.
        history.replaceState(null, "", `?${query}`);
        status.textContent = "Searching...";

        try {
          const response = await fetch(`/api/search?${query}`, {
            headers: { Accept: "application/json" },
            signal: inFlight.signal,
          });

          if (!response.ok) throw new Error(`HTTP ${response.status}`);

          const { items } = await response.json();

          results.replaceChildren(...items.map((item) => {
            const li = document.createElement("li");
            const a = document.createElement("a");
            a.href = item.url;
            // textContent, never innerHTML: this string came from a
            // network response and may contain anything.
            a.textContent = item.title;
            li.append(a);
            return li;
          }));

          status.textContent = items.length === 1
            ? "1 course found."
            : `${items.length} courses found.`;
        } catch (error) {
          if (error.name === "AbortError") return;

          // The fallback is not an error page - it is the form doing
          // what it would have done without any of this.
          status.textContent = "Search is unavailable. Loading the full page...";
          form.submit();
        }
      });
    </script>
  </body>
</html>
```

## The test

Disable JavaScript and use the feature. If it works, the enhancement is layered
correctly. If it does not, you have written a JavaScript application that happens
to be delivered as HTML - which is a legitimate choice, but make it deliberately
rather than by accident.

## What this buys you, concretely

- **The script fails to load.** A CDN blip, an aggressive corporate proxy, a
  content blocker with a broad rule. The page still works.
- **The script throws.** One unhandled error in an unrelated module does not
  take the search box down with it.
- **Slow devices.** The form is usable during the seconds before the module has
  parsed and executed.
- **Search engines and previews.** The first response already contains the
  results.

## Four details in that script

**`event.preventDefault()` is inside the handler, not around the form.** The
form is fully functional right up to the moment the listener attaches. There is
no window in which the button does nothing.

**`AbortController` cancels superseded requests.** Without it, type "html", then
"htm", and a slow first response can land after the second and show the wrong
results. This is a race the user sees.

**`history.replaceState` keeps the URL in sync.** The address bar is state.
Update it and reload, back, forward and copy-paste all keep working for free.

**`textContent`, never `innerHTML`.** The titles came off the network. Assigning
them to `innerHTML` is how a stored cross-site scripting bug reaches the browser.

## The fallback path in the catch block

`form.submit()` submits the form programmatically *without* firing the submit
event again, so it cannot loop. The user gets the server-rendered page they
would have got in the first place. That is the whole point: there is always a
version of this feature that works, and the enhancement can always fall back
to it.',
   'Build the version that works with plain HTML. Then add the version that feels instant. The order matters, because the first one is what runs when the script fails.',
   9, 800, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Refresh the denormalised counters and re-index for search.
-- ---------------------------------------------------------------------------
CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000004');
CALL `search`.reindex_all();
