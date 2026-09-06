-- ===========================================================================
-- Seed 07 : the CSS course, basics -> intermediate -> advanced -> expert
--
-- Same shape as the HTML course in 0006: one course, four modules, one per
-- level, twelve lessons. Same contract with the front end too - every lesson
-- body carries a fenced ```html block, because a CSS example is only
-- meaningful attached to markup. The example documents here are HTML with
-- their CSS in a <style> block, so pressing "Try yourself!" opens something
-- that renders rather than a stylesheet with nothing to style.
--
-- tests/verify.sql asserts the fence is still there for every lesson in both
-- courses.
-- ===========================================================================

INSERT INTO catalog_tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-00000000000b', 'css',    'CSS'),
  ('bbbbbbb1-0000-4000-8000-00000000000c', 'layout', 'Layout'),
  ('bbbbbbb1-0000-4000-8000-00000000000d', 'design', 'Design Systems')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ---------------------------------------------------------------------------
-- The course
-- ---------------------------------------------------------------------------
INSERT INTO catalog_courses
  (id, slug, title, subtitle, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000005',
   'css-from-basics-to-expert',
   'CSS: From Basics to Expert',
   'Four levels, twelve lessons, every example runnable in the browser',
   -- Plain text, like every other description. Only content_articles is
   -- rendered as Markdown; asterisks here would reach the page as asterisks.
   'A complete path through CSS in four levels. Level 1, Basic, covers the three things every rule depends on: how a selector wins, how a box is measured, and which unit to reach for. Level 2, Intermediate, is layout - Flexbox for one dimension, Grid for two, and how to build a page that adapts without a single media query. Level 3, Advanced, moves to custom properties and theming, the positioning and stacking rules that decide what covers what, and motion that respects the people who do not want it. Level 4, Expert, finishes with cascade layers, container queries, and the CSS that decides how fast a page paints.

Every lesson ships a complete, professional example: an HTML document with its CSS in a style block, so it renders the moment you open it. Press the "Try yourself!" button under any example and it opens in the playground, where you can edit it on the left and watch the result redraw on the right.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '55555555-5555-4555-8555-555555555555',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/css-from-basics-to-expert.jpg', 0,
   JSON_ARRAY('Predict which rule wins without opening devtools',
              'Build a page layout with Flexbox and Grid rather than with margins',
              'Make a design responsive without writing a media query',
              'Theme a whole site from one block of custom properties',
              'Animate without causing layout, and honour reduced-motion',
              'Use cascade layers and container queries the way frameworks now do'),
   JSON_ARRAY('You can write basic HTML', 'A text editor and a browser'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000005', 'bbbbbbb1-0000-4000-8000-00000000000b'),
  ('c0000001-0000-4000-8000-000000000005', 'bbbbbbb1-0000-4000-8000-00000000000c'),
  ('c0000001-0000-4000-8000-000000000005', 'bbbbbbb1-0000-4000-8000-00000000000d'),
  ('c0000001-0000-4000-8000-000000000005', 'bbbbbbb1-0000-4000-8000-000000000009')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

-- ---------------------------------------------------------------------------
-- The four levels
-- ---------------------------------------------------------------------------
INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'Level 1 - Basic',
   'Which rule wins, how a box is measured, and which unit to reach for.', 1),
  ('d0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'Level 2 - Intermediate',
   'Layout: Flexbox for one dimension, Grid for two, and responsive without breakpoints.', 2),
  ('d0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'Level 3 - Advanced',
   'Theming with custom properties, the stacking rules, and motion done responsibly.', 3),
  ('d0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'Level 4 - Expert',
   'Cascade layers, container queries, and the CSS that decides paint cost.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

-- ---------------------------------------------------------------------------
-- Twelve lessons, three per level.
-- ---------------------------------------------------------------------------
INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Level 1 - Basic
  ('e0000001-0000-4000-8000-00000000001d', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'selectors-and-the-cascade', 'Selectors and the Cascade',
   'Two rules set the same property. Here is exactly how the browser decides, and why !important is not the answer.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-00000000001e', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'the-box-model', 'The Box Model',
   'Why a width of 300px is almost never 300 pixels wide, and the one line that fixes it everywhere.',
   'article', 'published', 2, 480, 1),
  ('e0000001-0000-4000-8000-00000000001f', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'colour-units-and-type', 'Colour, Units and Type',
   'rem or px, oklch or hex, and the four properties that carry most of a design.',
   'article', 'published', 3, 600, 0),

  -- Level 2 - Intermediate
  ('e0000001-0000-4000-8000-000000000020', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'flexbox-in-one-dimension', 'Flexbox: One Dimension at a Time',
   'A row or a column, and the three properties on the child that do the real work.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000021', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'grid-in-two-dimensions', 'Grid: Rows and Columns Together',
   'Named areas, fractional units, and the layout you used to need a framework for.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000022', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'responsive-without-breakpoints', 'Responsive Without Breakpoints',
   'auto-fit, minmax and clamp do most of what a stack of media queries used to.',
   'article', 'published', 3, 660, 0),

  -- Level 3 - Advanced
  ('e0000001-0000-4000-8000-000000000023', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'custom-properties-and-theming', 'Custom Properties and Theming',
   'One block of variables, two themes, and no duplicated component styles.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000024', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'positioning-and-stacking', 'Positioning, Stacking and Overflow',
   'Why your dropdown is behind the header, and why z-index: 9999 did not help.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000025', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'transitions-and-animation', 'Transitions and Animation',
   'Two properties are cheap to animate and the rest cost a layout. Plus the media query you owe your users.',
   'article', 'published', 3, 780, 0),

  -- Level 4 - Expert
  ('e0000001-0000-4000-8000-000000000026', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'cascade-layers-and-scope', 'Cascade Layers and Specificity Control',
   'Order your stylesheet deliberately, and make specificity a choice instead of an accident.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-000000000027', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'container-queries', 'Container Queries',
   'A component that responds to the space it is in rather than to the size of the window.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000028', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'css-that-renders-fast', 'CSS That Renders Fast',
   'Style, layout, paint, composite - which of your declarations trigger which, and what it costs.',
   'article', 'published', 3, 840, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000001d',
   'Selectors and the Cascade',
   'markdown',
   '# Selectors and the Cascade

Two rules set the same property on the same element. One of them wins. CSS is
completely deterministic about which - it is only mysterious until you know the
order it checks things in.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Which rule wins?</title>
    <style>
      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 2rem;
        color: #16181d;
      }

      /* Specificity 0,0,1 - one element */
      a { color: #5c626e; }

      /* Specificity 0,1,0 - one class. Beats the rule above. */
      .link { color: #2f5bd7; }

      /* Specificity 0,2,1 - two classes and an element.
         Beats .link, wherever it appears in the file. */
      .card a.link { color: #1a7f4b; }

      /* Specificity 1,0,0 - an id. Beats everything above it.
         This is exactly why ids are a poor hook for styling. */
      #shout { color: #b3261e; }

      /* :where() has specificity ZERO, always. The rule applies, but it
         never wins an argument - which makes it the right tool for
         defaults that a component is expected to override. */
      :where(.card) p { color: #5c626e; }

      .card {
        border: 1px solid #e3e5ea;
        border-radius: 8px;
        padding: 1rem 1.25rem;
        max-width: 30rem;
      }
    </style>
  </head>
  <body>
    <h1>Which rule wins?</h1>

    <div class="card">
      <p>Each link below is styled by a different winner.</p>
      <p><a href="#">Plain anchor - grey, from the element selector</a></p>
      <p><a class="link" href="#">Class - blue, the class beats the element</a></p>
    </div>

    <p><a class="link" id="shout" href="#">Id - red, and nothing here can outrank it</a></p>
  </body>
</html>
```

## The order the browser checks

1. **Origin and importance.** Author styles beat browser defaults. An
   `!important` author rule beats a normal author rule.
2. **Cascade layers.** A rule in a later `@layer` beats one in an earlier layer,
   *regardless of specificity*. This is the level-four lesson, and it is the
   modern way out of specificity wars.
3. **Specificity.** Counted as three numbers: ids, then classes (which includes
   attribute selectors and pseudo-classes), then elements. Compare left to
   right; the first difference decides it. `0,2,1` beats `0,1,9` because two
   classes beat one, and the element count never gets consulted.
4. **Source order.** Only when everything above ties does the later rule win.

Most confusion is people reaching for step 4 when they are actually losing at
step 3.

## Specificity is not a single number

`0,1,0` versus `0,0,11`: eleven element selectors still lose to one class. The
columns do not carry. Once you internalise that, the fix for a rule that will
not apply is almost never "add another descendant selector" - it is to look at
what is actually beating it.

## `:is()`, `:where()` and `:not()`

- `:is(h1, h2, h3)` takes the specificity of its *most specific* argument.
- `:where(h1, h2, h3)` always has **zero** specificity. Same matching, no weight.
- `:not(.foo)` takes the specificity of its argument, so it is not free.

`:where()` is the one worth building a habit around. Reset and base styles
written inside it apply everywhere and lose every argument, which is exactly
what you want from a default.

## About `!important`

It works, and it is the reason the next person cannot fix the bug without also
using it. The only defensible uses are overriding a third-party stylesheet you
cannot edit, and utility classes that are *meant* to be final. Everything else
is a specificity problem with a sticking plaster on it.',
   'Two rules set the same property on the same element. One of them wins. CSS is completely deterministic about which - it is only mysterious until you know the order it checks things in.',
   6, 540, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-00000000001e',
   'The Box Model',
   'markdown',
   '# The Box Model

Set `width: 300px` on a box with padding and a border, and it will not be 300
pixels wide. That surprises everyone once, and there is a one-line fix you
should put at the top of every stylesheet you ever write.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>The box model</title>
    <style>
      /* The line. Every box now measures width and height including its
         own padding and border, which is what everyone assumed all along. */
      *, *::before, *::after {
        box-sizing: border-box;
      }

      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 2rem;
        color: #16181d;
      }

      .box {
        width: 300px;
        padding: 1rem;
        border: 4px solid #2f5bd7;
        background: #eaefff;
        margin-block-end: 1.5rem;
      }

      /* The old default, shown for comparison. Same declarations,
         308 pixels wider on screen. */
      .box-content {
        box-sizing: content-box;
        border-color: #b3261e;
        background: #fdecea;
      }

      .note {
        border-inline-start: 3px solid #2f5bd7;
        padding-inline-start: 1rem;
        color: #5c626e;
      }
    </style>
  </head>
  <body>
    <h1>The box model</h1>

    <div class="box">
      <strong>border-box</strong> - this box is exactly 300px wide on screen.
      The padding and border are measured inside the 300.
    </div>

    <div class="box box-content">
      <strong>content-box</strong> - identical CSS apart from box-sizing, and
      this one occupies 308px: 300 of content, plus 2rem of padding, plus 8px
      of border.
    </div>

    <p class="note">
      Resize the window. Neither box moves, because both are fixed-width -
      which is its own argument for using max-width instead.
    </p>
  </body>
</html>
```

## Four boxes, from the inside out

**Content** &rarr; **padding** &rarr; **border** &rarr; **margin**. The
background paints under the content, padding *and* border. The margin is always
transparent - it is space, not surface, which is why you cannot give a margin a
background colour.

## `box-sizing: border-box`, everywhere

Applying it to `*` and both pseudo-element selectors is deliberate. Pseudo-
elements are not covered by `*`, and a `::before` that measures differently
from its parent is a genuinely nasty bug to track down.

## Margins collapse. Padding does not.

Two adjacent vertical margins of 20px and 30px produce 30px of space, not 50.
This applies only vertically, only between block-level siblings, and not inside
a flex or grid container. It is the reason a heading with `margin-block-start`
sometimes pushes its *parent* down instead of moving itself.

Two ways out, both better than fighting it: lay siblings out with `gap` in a
flex or grid container, which never collapses; or use the "owl" rule and give
spacing to one side only:

```html
<style>
  .flow > * + * { margin-block-start: 1.5rem; }
</style>
```

## Logical properties

`margin-block-end` rather than `margin-bottom`; `padding-inline-start` rather
than `padding-left`. Same result in English, and correct without changes when
the same component is rendered in Arabic or Hebrew, where "start" is the right
edge. It costs nothing to write them this way from the beginning.

## `width` versus `max-width`

`width: 300px` is 300 pixels even inside a 200-pixel phone. `max-width: 300px`
is "up to 300, and narrower if it has to be". For anything that has to survive
a small screen, the second one is nearly always what you meant.',
   'Set width: 300px on a box with padding and a border, and it will not be 300 pixels wide. That surprises everyone once, and there is a one-line fix.',
   6, 560, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-00000000001f',
   'Colour, Units and Type',
   'markdown',
   '# Colour, Units and Type

Three small decisions - which unit, which colour notation, which type scale -
shape more of how a site feels than any single layout choice.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Colour, units and type</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }

      :root {
        /* oklch is lightness, chroma, hue. Hold the last two, change the
           first, and you get a tonal ramp that stays the same colour -
           which hex and hsl both fail to do. */
        --brand-900: oklch(0.32 0.11 258);
        --brand-600: oklch(0.52 0.16 258);
        --brand-100: oklch(0.94 0.03 258);

        --ink: oklch(0.24 0.01 258);
        --muted: oklch(0.52 0.01 258);
        --paper: oklch(0.99 0.002 258);

        /* One ratio, applied repeatedly. A scale you can name is a scale
           you will actually stay on. */
        --step-0: 1rem;
        --step-1: 1.25rem;
        --step-2: 1.563rem;
        --step-3: 1.953rem;

        /* clamp(minimum, preferred, maximum): fluid between two screen
           sizes and pinned outside them. No media query involved. */
        --display: clamp(2rem, 1.2rem + 4vw, 3.5rem);
      }

      body {
        margin: 0;
        padding: 2rem 1.5rem;
        background: var(--paper);
        color: var(--ink);
        font-family: system-ui, sans-serif;
        font-size: var(--step-0);
        line-height: 1.6;
      }

      h1 {
        font-size: var(--display);
        line-height: 1.1;
        letter-spacing: -0.02em;
        text-wrap: balance;
        color: var(--brand-900);
        margin: 0 0 0.5rem;
      }

      h2 { font-size: var(--step-2); margin-block: 2rem 0.5rem; }

      /* A measure. Anything past about 75 characters and the eye starts
         losing its place on the return sweep. */
      p { max-width: 65ch; margin-block: 0 1rem; }

      .lede { font-size: var(--step-1); color: var(--muted); }

      .swatches { display: flex; gap: 0.75rem; flex-wrap: wrap; padding: 0; list-style: none; }
      .swatches li {
        width: 6rem; height: 4rem;
        border-radius: 6px;
        display: grid; place-items: end start;
        padding: 0.4rem;
        font: 500 0.7rem/1 ui-monospace, monospace;
      }
      .s900 { background: var(--brand-900); color: #fff; }
      .s600 { background: var(--brand-600); color: #fff; }
      .s100 { background: var(--brand-100); color: var(--brand-900); }
    </style>
  </head>
  <body>
    <h1>Colour, units and type</h1>
    <p class="lede">
      Resize the window: the heading scales smoothly between 2rem and 3.5rem
      and stops at both ends. No breakpoints were harmed.
    </p>

    <h2>One hue, three lightnesses</h2>
    <ul class="swatches">
      <li class="s900">900</li>
      <li class="s600">600</li>
      <li class="s100">100</li>
    </ul>

    <h2>The measure</h2>
    <p>
      This paragraph is capped at 65 characters. It is the single easiest
      typographic improvement available, and it costs one declaration.
    </p>
  </body>
</html>
```

## Which unit

| Unit | Use it for |
| --- | --- |
| `rem` | Type, spacing, radii - anything that should scale with the user''s font setting |
| `px` | Borders, and hairlines that must not grow |
| `%` / `fr` | Sharing space inside a container |
| `ch` | Line length. `65ch` is a measure, `40rem` is a guess |
| `vw` / `vh` | Viewport-relative sizing, usually inside `clamp()` |

**Never set a `px` font size on `html` or `body`.** A user who has raised their
browser''s default font size has done so because they need to; `rem` respects
that and `px` overrides it.

## Why `oklch()`

`#2f5bd7` tells you nothing about what a lighter version would be. `oklch()`
separates perceived lightness from chroma and hue, so a ramp built by changing
only the first number stays recognisably one colour. Two lightness values
40 points apart are reliably readable against each other, which is not true of
`hsl()`.

Keep `#rrggbb` for one-off values you copied from a design; use `oklch()` when
you are building a system.

## `clamp()` replaces most type breakpoints

`clamp(2rem, 1.2rem + 4vw, 3.5rem)` reads: never below 2rem, never above
3.5rem, and in between it grows with the viewport. The `rem` part of the middle
term matters - a preferred size of pure `vw` cannot be zoomed, which is a real
accessibility failure.

## Four properties carry a design

`font-family`, `font-size`, `line-height`, `letter-spacing`. Big type wants
tighter line-height and slightly negative tracking; small type wants the
reverse. Set them deliberately once and most of the "this looks unfinished"
feeling goes away.',
   'Three small decisions - which unit, which colour notation, which type scale - shape more of how a site feels than any single layout choice.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 2 - Intermediate
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000020',
   'Flexbox: One Dimension at a Time',
   'markdown',
   '# Flexbox: One Dimension at a Time

Flexbox lays things out along a single axis - a row or a column - and shares
the leftover space between them. That is the whole model. Almost every problem
people have with it comes from expecting it to handle two axes at once, which
is Grid''s job.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A toolbar and a media object</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; color: #16181d; background: #fbfbfd; }

      /* --- The classic toolbar ------------------------------------------
         Brand on the left, actions on the right, everything vertically
         centred, and it survives any number of buttons. */
      .toolbar {
        display: flex;
        align-items: center;   /* centre on the cross axis */
        gap: 0.75rem;          /* never margins between flex children */
        padding: 0.75rem 1.25rem;
        background: #fff;
        border-block-end: 1px solid #e3e5ea;
        flex-wrap: wrap;       /* wrap rather than overflow on a narrow screen */
      }

      .brand { font-weight: 700; margin-inline-end: 0.5rem; }

      /* One property, and everything after it is pushed to the far end.
         An auto margin absorbs all the free space on that side. */
      .spacer { margin-inline-start: auto; }

      .btn {
        font: inherit;
        padding: 0.45rem 0.9rem;
        border: 1px solid #cfd3db;
        border-radius: 6px;
        background: #fff;
        cursor: pointer;
      }
      .btn-primary { background: #2f5bd7; border-color: #2f5bd7; color: #fff; }

      /* --- The media object ---------------------------------------------
         A fixed-size thing beside a flexible thing. The oldest layout
         problem on the web, and three declarations solve it. */
      .media {
        display: flex;
        gap: 1rem;
        align-items: flex-start;
        max-width: 40rem;
        margin: 2rem 1.25rem;
        padding: 1rem;
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
      }

      .avatar {
        /* grow 0, shrink 0, basis 56px - do not stretch, do not squash. */
        flex: 0 0 56px;
        aspect-ratio: 1;
        border-radius: 50%;
        background: #2f5bd7;
        color: #fff;
        display: grid;
        place-items: center;
        font-weight: 700;
      }

      .media-body {
        /* grow 1, shrink 1, basis 0 - take all the remaining space.
           min-width: 0 is the fix for long words overflowing a flex child:
           flex items default to min-width: auto, which refuses to shrink
           below their content. */
        flex: 1 1 0;
        min-width: 0;
      }

      .media-body p { margin: 0.25rem 0 0; color: #5c626e; }
    </style>
  </head>
  <body>
    <header class="toolbar">
      <span class="brand">Kestrel</span>
      <button class="btn" type="button">Orders</button>
      <button class="btn" type="button">Stock</button>
      <span class="spacer"></span>
      <button class="btn" type="button">Help</button>
      <button class="btn btn-primary" type="button">New order</button>
    </header>

    <article class="media">
      <div class="avatar" aria-hidden="true">AR</div>
      <div class="media-body">
        <strong>Aisha Rahman</strong>
        <p>
          Wrote a comment long enough to prove the body column takes the
          remaining width and wraps instead of pushing the avatar off screen.
        </p>
      </div>
    </article>
  </body>
</html>
```

## The two axes

`flex-direction` sets the **main** axis. The **cross** axis is the other one.
Everything else follows from that pair:

- `justify-content` distributes space along the **main** axis.
- `align-items` positions children on the **cross** axis.

Swap `row` for `column` and those two swap meaning. That is the single most
common source of "why is it centred the wrong way".

## The `flex` shorthand

`flex: <grow> <shrink> <basis>`. Three values worth memorising:

- `flex: 0 0 auto` - the default. Size to content, do not grow or shrink.
- `flex: 1 1 0` (or just `flex: 1`) - share the leftover space equally,
  ignoring content width.
- `flex: 1 1 auto` - share the leftover space *proportionally to content*.

`flex: 1` and `flex: auto` are genuinely different, and mixing them up is why a
row of "equal" columns comes out unequal.

## `min-width: 0`

A flex item defaults to `min-width: auto`, which means it will not shrink
smaller than its content - so one long URL blows out the whole row. `min-width: 0`
on the flexible child fixes it, and it is the single most useful line in this
lesson.

## Use `gap`, not margins

`gap` puts space *between* children and never on the outside edges, so there is
no last-child margin to strip off. It works in Flexbox, Grid and multi-column.

## When to reach for Grid instead

If you find yourself nesting flex containers to line things up in both
directions, or setting widths on children to make columns match across rows,
you have a two-dimensional problem. That is the next lesson.',
   'Flexbox lays things out along a single axis and shares the leftover space. That is the whole model. Almost every problem comes from expecting it to handle two axes at once.',
   8, 700, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000021',
   'Grid: Rows and Columns Together',
   'markdown',
   '# Grid: Rows and Columns Together

Grid is the only layout system on the web that works in two dimensions at once.
You describe the tracks, then place things into them - and with named areas you
can draw the layout in the stylesheet and read it back later.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A page layout in nine lines</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; color: #16181d; }

      /* --- The page ------------------------------------------------------
         The template is a picture of the layout. Anyone can read it. */
      .page {
        display: grid;
        grid-template-areas:
          "header header"
          "sidebar main"
          "footer footer";
        /* A fixed rail and a flexible column. minmax(0, 1fr) rather than
           1fr: a bare 1fr track has an automatic minimum size, so wide
           content inside it makes the whole grid overflow. */
        grid-template-columns: 14rem minmax(0, 1fr);
        /* auto rows top and bottom, and the middle takes the rest. */
        grid-template-rows: auto minmax(0, 1fr) auto;
        min-height: 100vh;
        gap: 1px;
        background: #e3e5ea;   /* shows through the gaps as hairlines */
      }

      .page > * { background: #fff; padding: 1.25rem; }

      .page-header { grid-area: header; }
      .page-sidebar { grid-area: sidebar; }
      .page-main   { grid-area: main; }
      .page-footer { grid-area: footer; }

      /* --- A card grid inside it -----------------------------------------
         No media queries. auto-fit collapses empty tracks, so the number
         of columns follows the available width. */
      .cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
        gap: 1rem;
        margin: 0;
        padding: 0;
        list-style: none;
      }

      .card {
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 1rem;
        /* Equal-height cards with the meta line pinned to the bottom,
           regardless of how much text is above it. */
        display: grid;
        grid-template-rows: auto 1fr auto;
        gap: 0.4rem;
      }

      .card h3 { margin: 0; font-size: 1rem; }
      .card p { margin: 0; color: #5c626e; font-size: 0.925rem; }
      .card .meta { color: #868c99; font-size: 0.8rem; }

      /* One breakpoint, and it only rewrites the template. Nothing else
         in the stylesheet needs to know the layout changed. */
      @media (max-width: 45rem) {
        .page {
          grid-template-areas:
            "header"
            "main"
            "sidebar"
            "footer";
          grid-template-columns: minmax(0, 1fr);
        }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <header class="page-header"><strong>Kestrel</strong> - warehouse</header>

      <nav class="page-sidebar">
        <p>Orders</p>
        <p>Stock</p>
        <p>Suppliers</p>
      </nav>

      <main class="page-main">
        <h1>Open orders</h1>
        <ul class="cards">
          <li class="card">
            <h3>#4821</h3>
            <p>Two pallets, awaiting pick.</p>
            <span class="meta">Due Thursday</span>
          </li>
          <li class="card">
            <h3>#4822</h3>
            <p>Short by one line. The supplier has been emailed and has not replied.</p>
            <span class="meta">Overdue</span>
          </li>
          <li class="card">
            <h3>#4823</h3>
            <p>Packed.</p>
            <span class="meta">Ships today</span>
          </li>
        </ul>
      </main>

      <footer class="page-footer">Three orders open.</footer>
    </div>
  </body>
</html>
```

## `fr` is not a percentage

`1fr` means "one share of what is left after fixed tracks and gaps are
subtracted". Three `1fr` columns with a `1rem` gap divide the *remaining* width
evenly - percentages would not, because they do not know about the gap.

## `minmax(0, 1fr)` versus `1fr`

`1fr` is shorthand for `minmax(auto, 1fr)`, and that `auto` minimum means the
track will not shrink below its content. One long word, one wide table, and the
grid overflows its container. `minmax(0, 1fr)` says the track may shrink to
nothing, so the content scrolls or wraps instead of the layout breaking. Use it
for any track holding content you did not author.

## `auto-fit` versus `auto-fill`

`repeat(auto-fit, minmax(13rem, 1fr))` is a responsive card grid in one line.
The browser fits as many 13rem-minimum columns as it can and stretches them to
fill.

The difference: with three cards in a wide container, `auto-fit` collapses the
empty tracks and the three cards stretch to fill the row; `auto-fill` keeps the
empty tracks, so the cards stay 13rem and leave a gap. Neither is wrong -
`auto-fit` for a filled row, `auto-fill` when items should keep a consistent
size.

## Named areas are documentation

`grid-template-areas` puts a diagram of the layout in the stylesheet. Changing
the layout at a breakpoint then means redrawing that diagram, not reassigning
column numbers on six different children. A dot (`.`) leaves a cell empty.

## Grid on the child, too

`.card` is itself a grid with `auto 1fr auto` rows. That is how the meta line
sits at the bottom of every card no matter how much text is above it, without
absolute positioning and without fixed heights.',
   'Grid is the only layout system on the web that works in two dimensions at once. Describe the tracks, then place things into them.',
   8, 740, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000022',
   'Responsive Without Breakpoints',
   'markdown',
   '# Responsive Without Breakpoints

A media query asks how wide the *window* is. Most of the time what you actually
want to say is "wrap when you run out of room" - and CSS can express that
directly, without you picking arbitrary pixel values that some future phone
will not match.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Responsive with no media queries</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }

      body {
        font: 16px/1.6 system-ui, sans-serif;
        color: #16181d;
        background: #fbfbfd;
        margin: 0;
        /* Padding that grows with the viewport but never disappears
           and never becomes absurd. */
        padding: clamp(1rem, 4vw, 3rem);
      }

      h1 {
        font-size: clamp(1.75rem, 1.1rem + 3vw, 2.75rem);
        line-height: 1.15;
        text-wrap: balance;
        margin: 0 0 1.5rem;
      }

      /* A card grid that reflows on its own. */
      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(min(15rem, 100%), 1fr));
        gap: clamp(0.75rem, 2vw, 1.5rem);
      }

      /* The switcher: side by side while there is room, stacked when
         there is not - and the threshold is a real measurement, not a
         guessed screen width.

         flex-basis of (30rem - 100%) * 999 is either a huge positive
         number or a huge negative one. Positive forces a wrap; negative
         clamps to zero and the children share the row. */
      .switcher {
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        margin-block-start: 1.5rem;
      }
      .switcher > * {
        flex-grow: 1;
        flex-basis: calc((30rem - 100%) * 999);
      }

      .panel {
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 1.25rem;
      }
      .panel h2 { margin: 0 0 .5rem; font-size: 1.05rem; }
      .panel p { margin: 0; color: #5c626e; }

      /* Text that never gets too wide to read, at any window size. */
      .prose { max-width: 65ch; }
    </style>
  </head>
  <body>
    <h1>Nothing here is a breakpoint</h1>

    <p class="prose">
      Drag the window edge. The heading scales, the padding scales, the cards
      reflow, and the two panels below switch from side-by-side to stacked -
      and there is not one media query in this document.
    </p>

    <div class="grid">
      <div class="panel"><h2>auto-fit</h2><p>Fits as many columns as will hold 15rem.</p></div>
      <div class="panel"><h2>minmax</h2><p>Each column is at least 15rem, at most one fair share.</p></div>
      <div class="panel"><h2>min()</h2><p>...unless the container itself is narrower than 15rem.</p></div>
      <div class="panel"><h2>clamp()</h2><p>Gaps and type scale between two sensible bounds.</p></div>
    </div>

    <div class="switcher">
      <div class="panel">
        <h2>Side by side</h2>
        <p>While the row is wider than 30rem.</p>
      </div>
      <div class="panel">
        <h2>Then stacked</h2>
        <p>Below it, without anyone naming a device.</p>
      </div>
    </div>
  </body>
</html>
```

## The three functions worth knowing

- **`min(a, b)`** - takes the smaller. `width: min(60rem, 100%)` is "60rem, but
  never wider than the container".
- **`max(a, b)`** - takes the larger. Useful as a floor: `max(1rem, 2vw)`.
- **`clamp(low, ideal, high)`** - `max(low, min(ideal, high))`, written the way
  you think about it.

## Why `minmax(min(15rem, 100%), 1fr)`

`minmax(15rem, 1fr)` breaks in a container narrower than 15rem: the track
refuses to shrink and the grid overflows. Wrapping the minimum in
`min(15rem, 100%)` says "15rem, or the whole container if that is smaller". It
is the difference between a card grid that works in a sidebar and one that does
not.

## Where media queries still earn their place

Not everything is a width question, and these have no equivalent:

```html
<style>
  @media (prefers-reduced-motion: reduce) { /* honour it. Always. */ }
  @media (prefers-color-scheme: dark) { /* the other palette */ }
  @media (prefers-contrast: more) { /* stronger borders */ }
  @media print { /* drop the navigation */ }
  @media (hover: none) { /* no hover on a touch screen */ }
</style>
```

Use a width media query when the *layout structure* genuinely changes - a
sidebar moving below the content, say, as in the Grid lesson. Use intrinsic
sizing for everything that is really just "wrap when you run out of room".

## And when the question is about the component, not the window

A card in a 20rem sidebar and the same card in a 60rem main column want
different layouts, and the viewport width cannot tell them apart. That is what
container queries are for, and they are waiting in level four.',
   'A media query asks how wide the window is. Most of the time what you want to say is wrap when you run out of room - and CSS can express that directly.',
   7, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 3 - Advanced
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000023',
   'Custom Properties and Theming',
   'markdown',
   '# Custom Properties and Theming

A custom property is a real value in the cascade, not a build-time
find-and-replace. It inherits, it can be changed on one subtree, and JavaScript
can set it at runtime. That is what makes theming a matter of redefining a
dozen values rather than duplicating every component rule.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>One palette, three themes</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }

      /* Every token gets its value here, in the light palette. A token
         whose only definition lives inside a media query does not exist
         for anyone outside that query - the classic unreadable-theme bug. */
      :root {
        --bg: #f7f8fb;
        --surface: #ffffff;
        --border: #dde1e9;
        --text: #14161b;
        --muted: #5b6270;
        --accent: #2f5bd7;
        --accent-text: #ffffff;
        --radius: 10px;
        --pad: 1.25rem;
      }

      /* Only the tokens are redefined - never a component rule.
         :not([data-theme="light"]) so an explicit light choice still
         beats a dark operating system. */
      @media (prefers-color-scheme: dark) {
        :root:not([data-theme="light"]) {
          --bg: #0e1015;
          --surface: #171a21;
          --border: #2a2f3a;
          --text: #e9ebf0;
          --muted: #a2a9b8;
          --accent: #7d9dff;
          --accent-text: #0e1015;
        }
      }

      /* And again for the explicit toggle, so it wins in both directions. */
      :root[data-theme="dark"] {
        --bg: #0e1015;
        --surface: #171a21;
        --border: #2a2f3a;
        --text: #e9ebf0;
        --muted: #a2a9b8;
        --accent: #7d9dff;
        --accent-text: #0e1015;
      }

      body {
        margin: 0;
        padding: 2rem;
        background: var(--bg);
        color: var(--text);
        font: 16px/1.6 system-ui, sans-serif;
      }

      /* Not one colour literal below this line. */
      .card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        padding: var(--pad);
        max-width: 26rem;
      }
      .card h2 { margin: 0 0 .25rem; font-size: 1.1rem; }
      .card p { margin: 0 0 1rem; color: var(--muted); }

      .btn {
        font: inherit;
        border: 1px solid transparent;
        border-radius: 6px;
        padding: .5rem 1rem;
        cursor: pointer;
        background: var(--accent);
        color: var(--accent-text);
      }

      /* A component-local override. The token is redefined on this
         subtree only, and every rule above picks it up unchanged. */
      .card-danger {
        --accent: #b3261e;
        --border: #f3c8c5;
      }

      /* A fallback, for a token that may not be set. */
      .card { box-shadow: var(--card-shadow, 0 1px 2px rgb(0 0 0 / .06)); }

      .row { display: flex; gap: 1rem; flex-wrap: wrap; }
    </style>
  </head>
  <body>
    <div class="row">
      <div class="card">
        <h2>Default</h2>
        <p>Reads its colours from :root.</p>
        <button class="btn" type="button">Confirm</button>
      </div>

      <div class="card card-danger">
        <h2>Danger</h2>
        <p>Same rules. Two tokens redefined on this element.</p>
        <button class="btn" type="button">Delete</button>
      </div>
    </div>

    <p>
      <button class="btn" type="button"
              onclick="document.documentElement.dataset.theme =
                       document.documentElement.dataset.theme === ''dark'' ? ''light'' : ''dark''">
        Toggle theme
      </button>
    </p>
  </body>
</html>
```

## Custom properties inherit; Sass variables do not

`--accent` set on `.card-danger` applies to that element and everything inside
it. Nothing else in the document changes, and no component rule was touched.
A preprocessor variable cannot do this at all - it is resolved before the
browser ever sees the file.

## The theming rule that matters

**Redefine tokens, never components.** The moment a `.card` rule appears inside
`@media (prefers-color-scheme: dark)`, you have two copies of that component to
keep in step, and one of them will drift. Everything the second theme needs
should be expressible as a different set of values.

Three token blocks, in this order:

1. `:root` - the complete light palette. Every token gets its value here.
2. `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) }`
3. `:root[data-theme="dark"]`

Two and three redefine only the tokens that differ. A token defined *only*
inside two or three is undefined for the majority of visitors, who have no
explicit setting and are on a light system - which renders as one theme''s text
on the other theme''s background.

## Fallbacks

`var(--card-shadow, 0 1px 2px rgb(0 0 0 / .06))` uses the second argument when
the property is unset. Everything after the first comma is the fallback, commas
included, so `var(--pad, 1rem 2rem)` works.

## Setting them from script

```html
<script>
  document.documentElement.style.setProperty(''--accent'', ''#1a7f4b'');
</script>
```

One line, and every rule that reads `--accent` updates. This is how a theme
picker or a user-chosen accent colour is built without regenerating any CSS.

## `@property`, when you need it animated

A plain custom property is a string as far as the browser is concerned, so it
cannot be interpolated. Registering it gives it a type, and then it animates:

```html
<style>
  @property --glow {
    syntax: "<color>";
    inherits: false;
    initial-value: #2f5bd7;
  }
</style>
```',
   'A custom property is a real value in the cascade, not a build-time find-and-replace. It inherits, it can be changed on one subtree, and script can set it at runtime.',
   7, 660, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000024',
   'Positioning, Stacking and Overflow',
   'markdown',
   '# Positioning, Stacking and Overflow

Your dropdown is behind the header. You set `z-index: 9999` and nothing
happened. The reason is always one of two things: a stacking context you did
not know you created, or an ancestor with `overflow: hidden` clipping the menu.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Stacking contexts</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; color: #16181d; }

      /* z-index only applies to a positioned element (or a flex/grid
         child). On a static element it is silently ignored. */
      .header {
        position: sticky;
        top: 0;
        z-index: 20;
        display: flex;
        gap: 1rem;
        align-items: center;
        padding: .85rem 1.25rem;
        background: #fff;
        border-block-end: 1px solid #e3e5ea;
      }

      .content { padding: 1.25rem; }

      /* The menu anchor. position: relative on the parent is what makes
         the absolutely positioned child measure from here rather than
         from the page. */
      .menu { position: relative; display: inline-block; }

      .menu-panel {
        position: absolute;
        inset-block-start: calc(100% + .35rem);
        inset-inline-start: 0;
        min-width: 12rem;
        padding: .4rem;
        background: #fff;
        border: 1px solid #cfd3db;
        border-radius: 8px;
        box-shadow: 0 8px 24px rgb(16 18 24 / .12);
        z-index: 1;
      }

      .menu-panel a { display: block; padding: .4rem .6rem; color: #16181d; text-decoration: none; border-radius: 4px; }
      .menu-panel a:hover { background: #eaefff; }

      /* --- The trap ------------------------------------------------------
         opacity below 1 creates a stacking context. So do transform,
         filter, will-change, isolation, contain, and a positioned element
         with a z-index. Every child is then trapped inside it: this
         panel''s z-index of 1 competes with its siblings here, and the
         whole box sits below the header at 20 whatever number you use. */
      .trapped { opacity: .999; }

      .note {
        margin: 1.5rem 0 0;
        border-inline-start: 3px solid #2f5bd7;
        padding-inline-start: 1rem;
        color: #5c626e;
        max-width: 44rem;
      }

      /* overflow: hidden on an ancestor clips absolutely positioned
         descendants too - unless they are position: fixed, or the
         ancestor is not their containing block. */
      .clipper { overflow: hidden; border: 1px dashed #cfd3db; border-radius: 8px; padding: 1rem; margin-block-start: 1.5rem; }

      .spacer { height: 60vh; }
    </style>
  </head>
  <body>
    <header class="header">
      <strong>Kestrel</strong>
      <span>z-index: 20</span>
    </header>

    <div class="content">
      <div class="menu">
        <button type="button">Actions</button>
        <div class="menu-panel">
          <a href="#">Duplicate</a>
          <a href="#">Archive</a>
          <a href="#">Delete</a>
        </div>
      </div>

      <p class="note">
        The panel above escapes upward over the page. Scroll down and it goes
        under the sticky header - correctly, because 1 is less than 20 and
        both are in the root stacking context.
      </p>

      <div class="trapped">
        <div class="menu">
          <button type="button">Trapped actions</button>
          <div class="menu-panel" style="z-index: 9999">
            <a href="#">z-index: 9999</a>
            <a href="#">and it still loses</a>
          </div>
        </div>
      </div>

      <div class="clipper">
        <div class="menu">
          <button type="button">Clipped actions</button>
          <div class="menu-panel">
            <a href="#">This panel is cut off</a>
            <a href="#">by overflow: hidden</a>
          </div>
        </div>
      </div>

      <div class="spacer"></div>
    </div>
  </body>
</html>
```

## The five positioning values

| Value | Measures from | In normal flow? |
| --- | --- | --- |
| `static` | nothing - `top`/`left` ignored | yes |
| `relative` | its own normal position | yes, keeps its space |
| `absolute` | nearest positioned ancestor | no |
| `fixed` | the viewport | no |
| `sticky` | scroll position, within its parent | yes |

`position: sticky` needs a threshold - `top`, `bottom`, `inset-block-start` -
or it does nothing at all. And it sticks within its **parent**: once the parent
scrolls past, so does the sticky child. A parent with `overflow: hidden` or
`overflow: auto` breaks it entirely.

## What creates a stacking context

More things than people expect. Any of these on an element makes its children
sort among themselves and the whole group sort as one unit:

- `position` other than `static`, **with** a `z-index` that is not `auto`
- `opacity` less than `1`
- `transform`, `filter`, `backdrop-filter`, `perspective`, `mask`
- `will-change` naming any of the above
- `isolation: isolate`, `contain: paint`, `mix-blend-mode`
- a flex or grid **child** with a `z-index` that is not `auto`

`opacity: .999` in the example is a real trick used to force one - and a real
bug when someone adds it for a fade animation and a menu disappears three
components away.

## The two fixes

**For stacking:** raise the *context*, not the element. Find the ancestor that
created it and give that a higher `z-index`. If the component genuinely has to
escape everything, take it out of the tree - a top-layer element like
`<dialog>` with `showModal()`, or the `popover` attribute, both render above
every stacking context by definition.

**For clipping:** `overflow: hidden` on an ancestor clips absolutely positioned
descendants. `position: fixed` escapes it, unless an ancestor has a `transform`
or `filter` - which makes that ancestor the containing block for fixed children
too, and the escape stops working. This is the second-most surprising rule in
CSS after margin collapsing.

## `isolation: isolate`

One declaration, no other effect, creates a stacking context deliberately. Put
it on a component root and every `z-index` inside is scoped to that component -
so no child needs to know about the page''s numbers, and no page number needs
to be raised to beat a child.',
   'Your dropdown is behind the header and z-index: 9999 did not help. The reason is always a stacking context you did not know you created, or an ancestor clipping it.',
   8, 720, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000025',
   'Transitions and Animation',
   'markdown',
   '# Transitions and Animation

Two properties are cheap to animate. Everything else makes the browser redo
work on every single frame, and at 60fps you have about 16 milliseconds to
spend. Knowing which is which is most of what separates smooth motion from
motion that stutters on a mid-range phone.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Motion that behaves</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; padding: 2rem; color: #16181d; background: #fbfbfd; }

      .row { display: flex; gap: 1rem; flex-wrap: wrap; align-items: flex-start; }

      .card {
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 1.25rem;
        width: 15rem;

        /* Name the properties. transition: all also animates things you
           did not mean - including layout properties a future edit adds,
           which is how a smooth component quietly becomes a janky one. */
        transition:
          transform 180ms cubic-bezier(.2, 0, .2, 1),
          box-shadow 180ms ease-out;
      }

      .card:hover,
      .card:focus-within {
        /* transform and opacity only. The compositor handles both without
           re-running layout or paint. */
        transform: translateY(-3px);
        box-shadow: 0 8px 24px rgb(16 18 24 / .10);
      }

      /* A spinner, composited. Rotating is free; animating width is not. */
      .spinner {
        width: 2rem;
        aspect-ratio: 1;
        border: 3px solid #dde1e9;
        border-block-start-color: #2f5bd7;
        border-radius: 50%;
        animation: spin 700ms linear infinite;
      }

      @keyframes spin {
        to { transform: rotate(1turn); }
      }

      /* Entrance animation. It starts from a VISIBLE resting state on the
         last frame, and it is short - a long entrance is a delay wearing
         a costume. */
      .toast {
        animation: rise 240ms cubic-bezier(.2, 0, .2, 1) both;
        background: #16181d;
        color: #fff;
        border-radius: 8px;
        padding: .7rem 1rem;
      }

      @keyframes rise {
        from { opacity: 0; transform: translateY(6px); }
        to   { opacity: 1; transform: none; }
      }

      /* The one media query you owe your users. Vestibular disorders are
         common, and for some people a parallax scroll causes actual
         nausea. Reduce, do not necessarily remove: a 1ms transition still
         fires transitionend, so scripts waiting on it do not hang. */
      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after {
          animation-duration: 1ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 1ms !important;
          scroll-behavior: auto !important;
        }
      }
    </style>
  </head>
  <body>
    <h1>Motion that behaves</h1>

    <div class="row">
      <div class="card" tabindex="0">
        <strong>Hover or focus me</strong>
        <p>transform and box-shadow, 180ms, named explicitly.</p>
      </div>

      <div class="card">
        <strong>Composited spin</strong>
        <p><span class="spinner" role="img" aria-label="Loading"></span></p>
      </div>

      <div class="card">
        <div class="toast">Saved</div>
      </div>
    </div>
  </body>
</html>
```

## The pipeline, and where each property lands

Every frame the browser can run up to four stages: **style** &rarr; **layout**
&rarr; **paint** &rarr; **composite**. What you animate decides how many of
them it has to redo.

| Animating | Triggers | Cost |
| --- | --- | --- |
| `transform` | composite | cheapest - often off the main thread |
| `opacity` | composite | cheapest |
| `color`, `background-color`, `box-shadow` | paint + composite | moderate |
| `width`, `height`, `top`, `margin`, `padding` | layout + paint + composite | worst |

Animating `left` moves an element by making the browser re-lay-out the page
sixty times a second. `transform: translateX()` moves the same element by
handing the compositor a matrix. They look identical and cost completely
different amounts.

## Never `transition: all`

It animates every property that changes, including ones added later by someone
who has no idea a transition was watching. Name what you mean. It is also
measurably cheaper, because the browser is not diffing every computed value.

## Duration and easing

- **100-200ms** for hovers and small state changes.
- **200-300ms** for panels, drawers and modals.
- Over 400ms starts to feel like waiting.

`ease-out` (fast start, gentle stop) for things entering; `ease-in` for things
leaving. `linear` only for continuous motion like a spinner, where an eased
rotation looks broken.

## `prefers-reduced-motion` is not optional

For some people, large-scale motion causes genuine nausea and dizziness. The
system setting exists; honour it. Reducing to 1ms rather than removing the
animation keeps `transitionend` and `animationend` firing, so any script that
waits for them still works.

## Animating to and from `auto`

Height `auto` has no numeric value to interpolate. Three modern ways out:

- `grid-template-rows: 0fr` &rarr; `1fr` on a wrapper, which does animate.
- `interpolate-size: allow-keywords` on `:root`, where supported.
- `calc-size()`, the newest option.

`max-height` with a guessed large number is the old workaround, and the guess
is always wrong for someone.',
   'Two properties are cheap to animate. Everything else makes the browser redo work on every frame, and at 60fps you have about 16 milliseconds to spend.',
   8, 700, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 4 - Expert
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000026',
   'Cascade Layers and Specificity Control',
   'markdown',
   '# Cascade Layers and Specificity Control

Specificity wars end the same way every time: someone adds a selector, then
someone adds another, then someone writes `!important` and the file is now
unmaintainable. Cascade layers remove the argument entirely, because layer
order beats specificity outright.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cascade layers</title>
    <style>
      /* Declare the order once, at the top, before any layer has content.
         This single line is the architecture of the stylesheet: anything
         in components beats anything in base, whatever the selectors say. */
      @layer reset, base, components, utilities;

      @layer reset {
        *, *::before, *::after { box-sizing: border-box; }
        body { margin: 0; }
        h1, h2, p { margin: 0; }
      }

      @layer base {
        body {
          font: 16px/1.6 system-ui, sans-serif;
          color: #16181d;
          background: #fbfbfd;
          padding: 2rem;
        }

        /* :where() has zero specificity, so a component can restyle links
           with a single class and win without a fight. */
        :where(a) { color: #2f5bd7; }
      }

      @layer components {
        .card {
          background: #fff;
          border: 1px solid #e3e5ea;
          border-radius: 10px;
          padding: 1.25rem;
          max-width: 26rem;
        }

        /* One class. It beats the id rule below, because components is a
           later layer than base - and specificity is only consulted
           within a layer. */
        .card-title { color: #1a7f4b; font-size: 1.1rem; }
      }

      @layer utilities {
        /* Utilities win over components by layer order, so they need no
           !important and no repeated-class hacks. */
        .text-muted { color: #5c626e; }
        .mt-0 { margin-block-start: 0; }
      }

      /* UNLAYERED. Anything outside a layer beats every layer, always.
         That is deliberate: it gives you an escape hatch, and it is also
         why a stray rule at the bottom of a file can quietly overrule an
         entire design system. */
      .debug-outline { outline: 2px dashed #b3261e; }
    </style>
  </head>
  <body>
    <div class="card">
      <h2 class="card-title">A class beats an id here</h2>
      <p class="text-muted mt-0">
        The heading is green from <code>.card-title</code> in the components
        layer, even though the base layer is written first and even if an id
        rule targeted it there.
      </p>
      <p><a href="#">A link, styled at zero specificity</a></p>
    </div>
  </body>
</html>
```

## The order rules

1. Layers apply in the order they were **first declared**, not the order they
   are filled in. Declaring `@layer reset, base, components, utilities;` at the
   top settles it, and later `@layer components { ... }` blocks append.
2. **Unlayered styles beat every layer.** Backwards from what most people
   guess, and intentional: existing stylesheets keep working when a layered
   design system is introduced underneath them.
3. `!important` **inverts** layer order. An `!important` declaration in the
   *earliest* layer beats an `!important` in the last one. This makes a reset
   layer able to enforce something absolutely - and it is also why sprinkling
   `!important` into a layered stylesheet produces results nobody predicts.

## Importing a third party into a layer

```html
<style>
  @import url("vendor.css") layer(vendor);
</style>
```

Every rule in that file now sits in `vendor`, and one line in your layer order
puts it wherever you want relative to your own code. Overriding a framework
stops being a specificity exercise.

## The three tools for specificity itself

- **`:where(...)`** - always zero. Base styles and resets belong in it, so a
  component never has to fight them.
- **`:is(...)`** - takes its most specific argument. Use it to shorten selector
  lists without changing weight: `:is(h1, h2, h3) + p`.
- **`&` nesting** - native now, and it compounds specificity exactly like the
  selectors it expands to. Nesting four levels deep produces the same
  unmaintainable weight it always did in a preprocessor.

## A layer order worth stealing

```html
<style>
  @layer reset, tokens, base, layout, components, utilities, overrides;
</style>
```

Every new rule has an obvious home, and the file order inside each layer stops
mattering. That is the actual win: you can append to `components` without
reading the rest of the file to work out where it has to go.',
   'Specificity wars end the same way every time, with someone writing !important. Cascade layers remove the argument entirely, because layer order beats specificity outright.',
   8, 700, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000027',
   'Container Queries',
   'markdown',
   '# Container Queries

A media query asks how wide the window is. A component does not care about the
window - it cares how much room *it* has been given. The same card in a 20rem
sidebar and in a 60rem main column wants two different layouts, and the
viewport width cannot tell those apart.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>One component, two contexts</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; padding: 2rem; color: #16181d; background: #fbfbfd; }

      .page {
        display: grid;
        grid-template-columns: 18rem minmax(0, 1fr);
        gap: 1.5rem;
        align-items: start;
      }

      /* Naming the container is what a query targets. inline-size means
         "watch the width only" - the cheapest option, and the one that
         avoids the circularity of a height query changing the height. */
      .col {
        container-type: inline-size;
        container-name: panel;
      }

      /* The default: stacked. This is what the component looks like in a
         narrow container, and it is written first so narrow is never a
         special case. */
      .story {
        display: grid;
        gap: .75rem;
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 1rem;
      }

      .story img,
      .story .thumb {
        aspect-ratio: 16 / 9;
        border-radius: 6px;
        background: linear-gradient(135deg, #2f5bd7, #7d9dff);
      }

      .story h3 { margin: 0; font-size: 1rem; }
      .story p  { margin: 0; color: #5b6270; font-size: .925rem; }
      .story .meta { color: #868c99; font-size: .8rem; }

      /* When the CONTAINER is at least 30rem wide - not the window -
         switch to a side-by-side layout. Drag the window: the left column
         is fixed at 18rem, so the card in it never changes, while the one
         on the right does. */
      @container panel (min-width: 30rem) {
        .story {
          grid-template-columns: 12rem minmax(0, 1fr);
          align-items: start;
        }
        .story .thumb { grid-row: span 3; }
        .story h3 { font-size: 1.2rem; }
      }

      /* cqi is 1% of the container''s inline size - a viewport unit for
         components. The heading scales with its column, not the window. */
      @container panel (min-width: 24rem) {
        .story h3 { font-size: clamp(1rem, 4cqi, 1.5rem); }
      }

      @media (max-width: 48rem) {
        .page { grid-template-columns: minmax(0, 1fr); }
      }
    </style>
  </head>
  <body>
    <h1>One component, two contexts</h1>

    <div class="page">
      <div class="col">
        <article class="story">
          <div class="thumb"></div>
          <h3>Narrow container</h3>
          <p>Stacked, because this column is 18rem wide.</p>
          <span class="meta">2 min read</span>
        </article>
      </div>

      <div class="col">
        <article class="story">
          <div class="thumb"></div>
          <h3>Wide container</h3>
          <p>
            Identical markup and identical classes. Side by side, because the
            container it landed in is wider than 30rem.
          </p>
          <span class="meta">2 min read</span>
        </article>
      </div>
    </div>
  </body>
</html>
```

## `container-type`

- **`inline-size`** - queries width only. What you want almost every time.
- **`size`** - width and height. Requires the container to have a defined
  height, because otherwise the query result would change the height that the
  query depends on.
- **`normal`** - not a size container, but still a container for style queries.

A size container gets `contain: layout` and `contain: style` implicitly, which
means it establishes a new containing block and its children can no longer
affect its own size. That is the whole mechanism, and it is also why you query
a *wrapper* rather than the component itself: an element cannot respond to its
own width.

## Query the wrapper, not the component

This is the one structural rule. `.col` is the container; `.story` is what
responds. Putting `container-type` on `.story` and then querying it would ask
the element to change size based on its own size - and the browser refuses.

## Container units

`cqw`, `cqh`, `cqi`, `cqb`, `cqmin`, `cqmax` are to a container what `vw` and
`vh` are to the viewport. `clamp(1rem, 4cqi, 1.5rem)` is fluid type that
follows the component''s column rather than the browser window - so the same
card looks right in a sidebar, in a main column, and in a modal, with one
declaration.

## Style queries

```html
<style>
  @container style(--tone: warning) {
    .badge { background: #fdf3e0; color: #8a5a00; }
  }
</style>
```

Query a custom property''s value rather than a size. Set `--tone: warning` on a
parent and every descendant restyles, with no extra class threaded through the
markup.

## What this changes

A component styled with container queries has no idea what page it is on. Drop
it in a sidebar, a grid cell, a modal or a full-width row and it lays itself out
correctly in all four - which is the thing component libraries have wanted since
the day they were invented.',
   'A media query asks how wide the window is. A component cares how much room it has been given. The same card in a sidebar and in a main column wants two different layouts.',
   8, 700, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000028',
   'CSS That Renders Fast',
   'markdown',
   '# CSS That Renders Fast

CSS is not usually the bottleneck, and when it is, it is dramatic: a page that
scrolls at 12fps, or one that spends 300ms in style recalculation before a
single pixel appears. Every one of those has a cause you can name.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CSS that renders fast</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }

      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 0;
        padding: 2rem;
        color: #16181d;
        background: #fbfbfd;
      }

      /* --- 1. Contain the damage ----------------------------------------
         contain tells the browser this subtree cannot affect anything
         outside it, so a change inside re-lays-out only this box rather
         than the document. On a long list of independent rows that is the
         difference between a scroll that stutters and one that does not. */
      .row {
        contain: layout style;
        display: grid;
        grid-template-columns: 3rem minmax(0, 1fr) auto;
        gap: .75rem;
        align-items: center;
        padding: .75rem 1rem;
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 8px;
        margin-block-end: .5rem;
      }

      /* --- 2. Skip work for what is off screen ---------------------------
         content-visibility: auto lets the browser skip layout and paint
         for a subtree that is not near the viewport. contain-intrinsic-size
         is the placeholder height it uses meanwhile - without it the
         scrollbar jumps as things come into view. */
      .deferred {
        content-visibility: auto;
        contain-intrinsic-size: auto 4.5rem;
      }

      /* --- 3. Animate only the two cheap properties ---------------------- */
      .row .badge {
        transition: transform 150ms ease-out, opacity 150ms ease-out;
      }
      .row:hover .badge { transform: translateX(2px); }

      /* --- 4. will-change is a loan, not a gift --------------------------
         It promotes the element to its own compositor layer. Applied to
         many elements, or left on permanently, it costs GPU memory and
         makes things slower. Set it just before the animation and remove
         it after - or attach it to the hover intent, as here. */
      .promote:hover { will-change: transform; }
      .promote { will-change: auto; }

      .avatar {
        aspect-ratio: 1;
        border-radius: 50%;
        background: #2f5bd7;
        color: #fff;
        display: grid;
        place-items: center;
        font-weight: 700;
        font-size: .8rem;
      }

      .badge {
        font: 500 .75rem/1 ui-monospace, monospace;
        background: #eaefff;
        color: #2f5bd7;
        border-radius: 999px;
        padding: .25rem .55rem;
      }

      .name { min-width: 0; overflow-wrap: anywhere; }

      @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after { transition-duration: 1ms !important; }
      }
    </style>
  </head>
  <body>
    <h1>A list that stays smooth</h1>

    <div class="rows">
      <div class="row promote"><div class="avatar">AR</div><span class="name">Aisha Rahman</span><span class="badge">picked</span></div>
      <div class="row promote"><div class="avatar">KW</div><span class="name">Kenji Watanabe</span><span class="badge">packed</span></div>
      <div class="row promote deferred"><div class="avatar">LN</div><span class="name">Lena Novak</span><span class="badge">shipped</span></div>
      <div class="row promote deferred"><div class="avatar">SO</div><span class="name">Sam Okafor</span><span class="badge">queued</span></div>
    </div>
  </body>
</html>
```

## The four stages, again

**Style** &rarr; **layout** &rarr; **paint** &rarr; **composite**. Each stage
only runs if something invalidated it, and each one you skip is time back.
`contain` and `content-visibility` both work by letting the browser prove it
can skip work.

## `contain`

| Value | Promise |
| --- | --- |
| `layout` | nothing inside affects layout outside |
| `paint` | nothing inside paints outside the box |
| `style` | counters and quotes inside do not escape |
| `size` | the box''s size does not depend on its children |
| `content` | shorthand for `layout paint style` |

Put `contain: layout style` on repeating list rows, cards and widgets. The
browser can then treat each as an isolated subtree, and a change in one stops
invalidating the whole document.

`contain: paint` and `contain: layout` both create a stacking context and a
containing block - so a `position: fixed` child inside will now measure from the
contained element instead of the viewport. Worth knowing before you add it to a
component that has a fixed-position tooltip.

## `content-visibility: auto`

The largest single win available for long pages: the browser skips layout and
paint entirely for subtrees near-but-outside the viewport. **Always pair it
with `contain-intrinsic-size`**, or the element measures zero until it is
rendered, the scrollbar jumps around, and in-page anchors land in the wrong
place.

It also hides the content from find-in-page in some engines, so it is wrong for
a long article and right for a long list of cards.

## `will-change` is a loan

It promotes an element to its own compositor layer *in advance*. Every promoted
layer costs GPU memory, and a page that promotes fifty elements is slower than
one that promotes none. Add it immediately before an animation and remove it
after. Left on permanently, it is a pessimisation that looks like an
optimisation.

## Selector cost is mostly a myth now

Browsers match selectors right to left and index by the rightmost key, so the
old advice about avoiding descendant selectors has not mattered for years. What
*does* still cost:

- **Very large stylesheets** - style recalculation is proportional to rules
  times elements. Ship the CSS for the page, not for the whole site.
- **`@import` chains** - each one is a serial round trip discovered only after
  the previous file parses.
- **Layout thrashing from script** - reading `offsetHeight` after a write
  forces a synchronous layout. Batch all reads, then all writes.

## Inline the critical, defer the rest

The CSS needed for what is visible first goes inline in the `<head>`;
everything else loads without blocking:

```html
<link rel="stylesheet" href="/css/rest.css" media="print" onload="this.media=''all''">
```

That is the same trick from the HTML course''s performance lesson, and it is
still the highest-value change on most sites.',
   'CSS is not usually the bottleneck, and when it is, it is dramatic. Every stuttering scroll and every 300ms style recalculation has a cause you can name.',
   9, 780, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Refresh the denormalised counters and re-index for search.
-- ---------------------------------------------------------------------------
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000005');
CALL search_reindex_all();
