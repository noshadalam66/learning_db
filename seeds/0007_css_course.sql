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
  (id, slug, title, subtitle, overview, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000005',
   'css-from-basics-to-expert',
   'CSS: From Basics to Expert',
   'Four levels, twelve lessons, every example runnable in the browser',
   'CSS decides what a page looks like. HTML says a thing is a heading; CSS says that headings are 32 pixels, dark blue, and have space above them. The two are deliberately separate, which is why one stylesheet can restyle a thousand pages.

Most of the difficulty is not in the properties. There are a few hundred of them and you can look them up. The difficulty is in three questions that run underneath all of them: when two rules both apply, which one wins; how big is this box actually; and what decides where it sits on the page. Almost every afternoon lost to CSS is one of those three, and this course answers them in Level 1 before anything else.

Modern CSS has also quietly absorbed things that used to need JavaScript or a build step - theming, container-relative layout, cascade control. A good deal of what people still reach for a framework to do, the browser now does.',
   -- Plain text, like every other description. Only content_articles is
   -- rendered as Markdown; asterisks here would reach the page as asterisks.
   'A complete path through CSS in four levels. Level 1, Basic, covers the three things every rule depends on: how a selector wins, how a box is measured, and which unit to reach for. Level 2, Intermediate, is layout - Flexbox for one dimension, Grid for two, and how to build a page that adapts without a single media query. Level 3, Advanced, moves to custom properties and theming, the positioning and stacking rules that decide what covers what, and motion that respects the people who do not want it. Level 4, Expert, finishes with cascade layers, container queries, and the CSS that decides how fast a page paints.

You need to be able to write HTML to start this course; you do not need to have written any CSS. If you have, the honest test is Level 1: if you cannot say why one rule beats another, or what box-sizing actually changes, start there anyway - almost every CSS bug that takes an afternoon comes back to one of those two answers.

Each level is three lessons and a Level Check quiz, with an Expert Exam at the end. Every example is a complete HTML document with its CSS in a style block, so it renders the moment you open it - and the Try yourself button puts it in the playground, where you can change a value and watch the page redraw beside it.

Every lesson ships a complete, professional example: an HTML document with its CSS in a style block, so it renders the moment you open it. Press the "Try yourself!" button under any example and it opens in the playground, where you can edit it on the left and watch the result redraw on the right.

By the end you will be able to lay out a responsive page without a framework and without guessing: a grid that adapts with no media queries, a theme that switches with a single custom property, overlays that stack in the order you intended, and animation that respects somebody who has asked their system for less of it.',
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
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description),
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
   'The three questions every CSS rule depends on, answered before anything else. Which selector wins and why specificity is not a popularity contest; how a box is actually measured, and what box-sizing changes about that; and which unit to reach for, which is the difference between a layout that survives a larger font size and one that does not.', 1),
  ('d0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'Level 2 - Intermediate',
   'Layout, which is the part people most often fight. Flexbox handles one dimension at a time and is the right tool far more often than it is used; Grid handles rows and columns together; and the last lesson builds a page that adapts to its space without a single media query, using clamp, minmax and auto-fit.', 2),
  ('d0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'Level 3 - Advanced',
   'The CSS that decides what a page looks like, and what covers what. Custom properties make a theme a handful of values rather than a find-and-replace; positioning, stacking contexts and overflow explain the overlay that will not go on top; and the motion lesson covers transitions, keyframes and honouring prefers-reduced-motion.', 3),
  ('d0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'Level 4 - Expert',
   'The modern cascade, and the cost of what you write. Cascade layers let you control specificity deliberately instead of adding another selector; container queries let a component respond to its own space rather than the viewport; and the last lesson is about what makes a page expensive to paint, which is rarely the property you suspect.', 4)
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
   'Two rules set the same property on the same element and one of them wins. CSS is completely deterministic about which - it is only mysterious until you know the order the browser checks things in, and why !important is not the answer.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-00000000001e', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'the-box-model', 'The Box Model',
   'Set width: 300px on a box with padding and a border and it will not be 300 pixels wide. That surprises everyone once; this is why it happens, and the one line you should put at the top of every stylesheet you ever write.',
   'article', 'published', 2, 480, 1),
  ('e0000001-0000-4000-8000-00000000001f', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'colour-units-and-type', 'Colour, Units and Type',
   'Three small decisions - which unit, which colour notation, which type scale - shape more of how a site feels than any single layout choice. rem against px, oklch against hex, and the four properties that carry most of a design.',
   'article', 'published', 3, 600, 0),

  -- Level 2 - Intermediate
  ('e0000001-0000-4000-8000-000000000020', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'flexbox-in-one-dimension', 'Flexbox: One Dimension at a Time',
   'Flexbox lays things out along a single axis - a row or a column - and shares the leftover space between them. That is the whole model, and almost every problem people have with it comes from expecting it to handle two axes at once.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000021', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'grid-in-two-dimensions', 'Grid: Rows and Columns Together',
   'Grid is the only layout system on the web that works in two dimensions at once: you describe the tracks, then place things into them. With named areas you can draw the layout in the stylesheet and read it back a year later.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000022', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'responsive-without-breakpoints', 'Responsive Without Breakpoints',
   'A media query asks how wide the window is. Most of the time what you want to say is wrap when you run out of room - and auto-fit, minmax and clamp say it directly, without pixel values somebody picked off a phone released in 2016.',
   'article', 'published', 3, 660, 0),

  -- Level 3 - Advanced
  ('e0000001-0000-4000-8000-000000000023', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'custom-properties-and-theming', 'Custom Properties and Theming',
   'A custom property is a real value in the cascade, not a build-time find-and-replace: it inherits, it can be changed on one subtree, and JavaScript can set it at runtime. Which makes a theme a matter of redefining variables rather than duplicating components.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000024', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'positioning-and-stacking', 'Positioning, Stacking and Overflow',
   'Your dropdown is behind the header, you set z-index: 9999, and nothing happened. The reason is always one of two things - a stacking context you did not know you created, or an ancestor with overflow: hidden clipping it.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000025', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'transitions-and-animation', 'Transitions and Animation',
   'Two properties are cheap to animate; everything else makes the browser redo work on every frame, and at 60fps you have about 16 milliseconds to spend. Knowing which is which is most of smooth motion - plus the media query you owe your users.',
   'article', 'published', 3, 780, 0),

  -- Level 4 - Expert
  ('e0000001-0000-4000-8000-000000000026', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'cascade-layers-and-scope', 'Cascade Layers and Specificity Control',
   'Specificity wars end the same way every time: a selector, then another selector, then !important, and the file is unmaintainable. Cascade layers remove the argument by making stylesheet order something you write down deliberately.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-000000000027', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'container-queries', 'Container Queries',
   'A media query asks how wide the window is; a component cares how much room it has been given. The same card in a 20rem sidebar and in a 60rem main column wants two different layouts, and this is how it asks about its own space instead.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-000000000028', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'css-that-renders-fast', 'CSS That Renders Fast',
   'CSS is not usually the bottleneck, and when it is it is dramatic: 12fps scrolling, or 300ms of style recalculation before a single pixel appears. Style, layout, paint, composite - which declarations trigger which, and what each one costs.',
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

Two rules set the same property on the same element. One of them wins. CSS is completely deterministic about which - it is only mysterious until you know the order the browser checks things in.

This lesson is that order, and what to do instead of reaching for `!important`.

## The order, in full

When two declarations conflict, the browser works through these in sequence and stops at the first one that separates them.

1. **Origin and importance.** Your stylesheet beats the browser''s defaults. An `!important` declaration beats a normal one - but a user''s `!important` beats yours, which is deliberate: somebody who needs a 24-pixel minimum font size must be able to have one.
2. **Cascade layers.** Later layers win over earlier ones, regardless of specificity. Covered properly in the Level 4 lesson.
3. **Specificity.** The more specific selector wins.
4. **Source order.** The one written later wins.

Most day-to-day confusion is steps three and four, and most of it comes from misreading step three.

## Specificity is three numbers, not one

Count three things about a selector:

- **A** - how many id selectors it has
- **B** - how many class, attribute and pseudo-class selectors
- **C** - how many element and pseudo-element selectors

Write it as `A-B-C` and compare left to right. A higher A wins outright, whatever B and C are.

```css
a                             /* 0-0-1 */
.nav a                        /* 0-1-1 */
nav ul li a                   /* 0-0-4 */
.nav .list .item a            /* 0-3-1 */
#header a                     /* 1-0-1 */
```

The important consequence: `.nav a` at `0-1-1` beats `nav ul li a` at `0-0-4`, even though the second is four selectors long and looks more specific. **One class beats any number of elements.** This is the single most common misreading, and it is why adding more descendant selectors to "win" an argument usually does nothing.

Three things do not count at all:

```css
* { }                /* 0-0-0 - the universal selector is free */
:where(.a, .b) { }   /* 0-0-0 - :where always contributes nothing */
:is(.a, #b) { }      /* takes the HIGHEST of its arguments: 1-0-0 */
:not(.a) { }         /* takes its argument: 0-1-0 */
```

`:where()` is genuinely useful because of this. A reset written with it can be overridden by a single class without a fight:

```css
:where(h1, h2, h3) { margin-block: 0 .5em; }   /* 0-0-0 */
.card h2 { margin: 0; }                        /* wins easily */
```

## Inline styles and the one thing above them

```html
<p style="color: red">...</p>
```

An inline style sits above every selector - think of it as `1-0-0-0`. The only normal declaration that can beat it is... none. The only thing that can is `!important` in a stylesheet.

That is the honest reason `!important` exists, and it is why a codebase that uses inline styles ends up using `!important`, and then needs a second `!important` to beat the first.

## Source order, and why it matters more than people think

When specificity ties, the later rule wins. Simple, and it is the whole mechanism behind a utility class being overridden by one written after it, and behind the order of your `@import` statements mattering.

```css
.button { background: grey; }
.button { background: blue; }   /* this one */
```

This is also why a stylesheet''s order is architecture rather than housekeeping - which is exactly the problem cascade layers were introduced to solve.

## Inheritance is a different mechanism

Specificity decides between rules that **match** an element. Inheritance is what happens when **no** rule matches: some properties take their value from the parent.

```css
body { color: #333; font-family: Inter, sans-serif; }
/* every descendant gets both, with no selector at all */
```

Inherited by default: `color`, `font-*`, `line-height`, `text-align`, `visibility`, `cursor`, `list-style`.

Not inherited: `background`, `border`, `padding`, `margin`, `width`, `display`, `position`.

A directly matching rule of any specificity always beats an inherited value, however specific the parent''s selector was. An inherited value is not a competitor in the cascade; it is what happens in its absence.

Four keywords let you ask for it explicitly:

```css
.thing {
  color: inherit;    /* take the parent''s value */
  border: initial;   /* the property''s own default */
  padding: unset;    /* inherit if inheritable, initial if not */
  margin: revert;    /* back to the browser''s own stylesheet */
}
```

`inherit` on a form control is the most useful of these in practice - inputs and buttons do not inherit `font` by default, which is why they look like the operating system until you say otherwise:

```css
input, button, select, textarea { font: inherit; }
```

## The selectors worth knowing

```css
/* Combinators */
.card p        { }  /* any p inside .card, at any depth */
.card > p      { }  /* only a direct child */
h2 + p         { }  /* the p immediately after an h2 */
h2 ~ p         { }  /* every p after an h2, same parent */

/* Attributes */
[disabled]          { }
[type="email"]      { }
[href^="https://"]  { }  /* starts with */
[href$=".pdf"]      { }  /* ends with */
[class*="col-"]     { }  /* contains */

/* Structure */
li:first-child      { }
li:last-child       { }
li:nth-child(2n)    { }  /* even */
li:nth-child(3n+1)  { }  /* 1st, 4th, 7th */
li:only-child       { }
p:empty             { }

/* State */
a:hover, a:focus-visible { }
input:checked            { }
input:user-invalid       { }
details[open]            { }

/* Relational - the parent selector CSS lacked for twenty years */
.card:has(img)      { }  /* a card that contains an image */
label:has(input:checked) { }
```

`:has()` is worth dwelling on. It is the first selector that looks **down** the tree, which makes a whole category of problem solvable in CSS that previously needed JavaScript:

```css
/* A form field whose input is invalid */
.field:has(input:user-invalid) { border-color: var(--danger); }

/* A layout that changes when there is a sidebar */
.layout:has(> aside) { grid-template-columns: 1fr 18rem; }
```

## !important, and what to do instead

Reaching for `!important` is almost always a sign that the stylesheet''s order or structure is wrong. It wins the argument and makes the next one worse, because the only way to beat it is another `!important`.

The usual causes and their real fixes:

| Why you reached for it | What to do instead |
|---|---|
| A third-party stylesheet is winning | Put it in an earlier cascade layer |
| An inline style from a script | Remove the inline style; use a class |
| A selector elsewhere is too specific | Lower that selector, do not raise this one |
| You cannot find what is winning | Open devtools; it shows you, with the loser struck through |

There is one honest use: a utility class that must always win, in a system where that is the documented contract.

```css
.visually-hidden {
  position: absolute !important;
  width: 1px !important;
  height: 1px !important;
  overflow: hidden !important;
  clip-path: inset(50%) !important;
}
```

## Debugging, which takes thirty seconds

Open the element inspector. The Styles panel lists every rule that matched, in cascade order, with the losing declarations struck through, and the file and line each came from. The Computed tab shows the final value and lets you expand it to see which rule supplied it.

You never have to reason about specificity from first principles. You have to know that the order exists so that you know what you are looking at - and then the browser tells you the rest.

## What goes wrong

| Symptom | Cause |
|---|---|
| Adding more selectors changes nothing | One class beats any number of elements |
| A style works, then stops after a refactor | Source order changed |
| `!important` needed to override `!important` | Inline styles, or a specificity war |
| Buttons look like the operating system | Form controls do not inherit `font` |
| A reset is impossible to override | Written without `:where()` |
| A rule matches but has no effect | Another rule wins - devtools shows which |

## The habit

Keep specificity low and flat. One class per rule wherever you can, `:where()` for resets, layers for order, and devtools open whenever something surprises you. A stylesheet where every rule is `0-1-0` has no specificity problems at all, because source order is the only thing left to decide - and source order is something you control.
',
   'Two rules set the same property on the same element. One of them wins. CSS is completely deterministic about which - it is only mysterious until you know the order it checks things in.', 7, 1419,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-00000000001e',
   'The Box Model',
   'markdown',
   '# The Box Model

Set `width: 300px` on a box with padding and a border, and it will not be 300 pixels wide. That surprises everyone exactly once. There is a one-line fix you should put at the top of every stylesheet you ever write, and a handful of related behaviours that are worth understanding rather than working around.

## Four boxes, from the inside out

Every element is four nested rectangles:

```
+-------------------------- margin -------------------------+
|  +----------------------- border ----------------------+  |
|  |  +-------------------- padding -------------------+  |  |
|  |  |                                                |  |  |
|  |  |                   content                      |  |  |
|  |  |                                                |  |  |
|  |  +------------------------------------------------+  |  |
|  +------------------------------------------------------+  |
+------------------------------------------------------------+
```

- **content** - the text or the image.
- **padding** - space inside the border. Takes the background.
- **border** - the line itself.
- **margin** - space outside. Always transparent; the background does not reach it.

The question the box model answers is: when you say `width: 300px`, which of those rectangles is 300 pixels?

## The default answer is the unhelpful one

```css
.box {
  width: 300px;
  padding: 20px;
  border: 2px solid;
}
```

By default `width` sets the **content** box. The element therefore occupies:

```
300 + 20 + 20 + 2 + 2 = 344px
```

Now put that box in a 300-pixel column and it overflows. Add padding to make it breathe and it gets wider. Put two 50% boxes side by side with any padding at all and they wrap.

## The fix, and where to put it

```css
*, *::before, *::after {
  box-sizing: border-box;
}
```

`border-box` makes `width` set the **border** box - the content, the padding and the border together. Now `width: 300px` means the thing is 300 pixels wide, padding adjusts the content rather than the element, and two 50% columns fit.

Three details about that snippet:

- **The pseudo-elements matter.** Without `::before` and `::after` in the selector, generated content keeps the old behaviour and produces exactly the kind of bug nobody looks for.
- **It is not inherited**, which is why the universal selector is used rather than setting it on `html`.
- **It is three lines and it goes at the top**, before anything else. Every modern reset starts with it.

An alternative, if you need to interoperate with a third-party component that assumes the old model:

```css
html { box-sizing: border-box; }
*, *::before, *::after { box-sizing: inherit; }
```

Now a subtree can opt out by setting `box-sizing: content-box` on its root.

## Margins collapse, and only vertically

```html
<p style="margin-bottom: 30px">First</p>
<p style="margin-top: 20px">Second</p>
```

The gap between them is **30 pixels**, not 50. Adjacent vertical margins collapse to the larger of the two.

This is deliberate: it is what makes a document of paragraphs and headings space itself sensibly without every element knowing about its neighbours. It is also a steady source of confusion, because it happens in three different situations:

**Between siblings**, as above.

**Between a parent and its first or last child**, when nothing separates them:

```html
<div style="background: #eee">
  <p style="margin-top: 20px">Why is there space above the grey box?</p>
</div>
```

The child''s top margin escapes the parent and becomes the parent''s. The grey background starts below where you expected.

**On an empty element**, whose own top and bottom margins collapse together.

### Stopping it

Anything between the margins stops them meeting:

```css
.parent { padding-top: 1px; }         /* padding */
.parent { border-top: 1px solid; }    /* a border */
.parent { overflow: auto; }           /* a new block formatting context */
.parent { display: flow-root; }       /* the same, with no side effects */
```

`display: flow-root` is the one designed for this. `overflow: auto` works by accident and brings a scrollbar risk with it.

Margins never collapse in flex or grid containers, which is one reason modern layouts feel more predictable: once you are laying out with `gap`, the whole question goes away.

```css
.stack { display: flex; flex-direction: column; gap: 1.5rem; }
```

## Logical properties, for text that is not left to right

```css
/* physical */
margin-top: 1rem;
margin-left: 2rem;
padding-right: 1rem;

/* logical */
margin-block-start: 1rem;
margin-inline-start: 2rem;
padding-inline-end: 1rem;
```

Block is the direction text flows in blocks - downwards in English. Inline is the direction words run - left to right in English, right to left in Arabic.

Write `margin-inline-start` and the same stylesheet lays out correctly in both without a mirrored copy. There are shorthands for the common cases, and they are shorter than what they replace:

```css
margin-block: 1rem 2rem;    /* top and bottom */
margin-inline: auto;        /* left and right - this centres a block */
padding-inline: 1.25rem;
inset: 0;                   /* top, right, bottom, left */
```

## Sizing keywords beyond a number

```css
.box {
  width: min-content;   /* as narrow as the content allows */
  width: max-content;   /* as wide as the content wants, no wrapping */
  width: fit-content;   /* max-content, capped by the available space */
}

.container {
  width: min(100% - 2rem, 70ch);   /* the smaller of the two */
  width: clamp(20rem, 50%, 60rem); /* floor, preferred, ceiling */
}
```

`min()` with a percentage and a maximum is the modern centred container: it fills the width on a phone with a gutter, and stops at a readable measure on a desktop, with no media query.

```css
.wrap { width: min(100% - 2rem, 72rem); margin-inline: auto; }
```

## min-width, max-width and the one that catches people

```css
img { max-width: 100%; height: auto; }
```

That is the line that stops an image overflowing its container, and it is in every stylesheet for a reason.

The catch is a flex item: a flex item will not shrink below its content''s minimum size, because `min-width` defaults to `auto` in a flex container. A long word or a wide code block therefore blows the layout out, and the fix is not obvious:

```css
.flex-child { min-width: 0; }      /* now it may shrink */
```

The same applies to grid items with `min-height: 0`. If a flex or grid child is refusing to shrink and you cannot see why, this is almost always it.

## Overflow

```css
.box {
  overflow: visible;   /* default - content spills out */
  overflow: hidden;    /* clipped, no scrollbar */
  overflow: auto;      /* scrollbar only when needed */
  overflow: scroll;    /* always a scrollbar */
  overflow: clip;      /* clipped, and no scroll container created */
}
```

`overflow: hidden` creates a scroll container, which has consequences: it establishes a block formatting context (stopping margin collapse), it can be scrolled programmatically, and it clips `position: sticky` descendants - which is the usual reason a sticky header silently stops sticking.

`overflow: clip` clips without any of that, and is what you usually want when you only mean "do not spill".

## What goes wrong

| Symptom | Cause |
|---|---|
| Two 50% columns wrap | `content-box` plus padding |
| Unexpected gap above a box | A child''s margin collapsed out of its parent |
| Gap smaller than the sum of two margins | Collapsing, working as designed |
| A long word blows the layout out | Flex item with the default `min-width: auto` |
| Image wider than its container | No `max-width: 100%` |
| A sticky header stops sticking | An ancestor has `overflow: hidden` |
| Padding added and the box grew | `content-box` again |

## What to do

Three lines, in this order, at the top of every project:

```css
*, *::before, *::after { box-sizing: border-box; }
body { margin: 0; }
img, svg, video { display: block; max-width: 100%; }
```

Then lay out with flex or grid and `gap` rather than with margins, and most of this lesson stops applying - which is the point of knowing it. You learn the box model so that you recognise the handful of times it is still what bit you.
',
   'Set width: 300px on a box with padding and a border, and it will not be 300 pixels wide. That surprises everyone once, and there is a one-line fix.', 7, 1331,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-00000000001f',
   'Colour, Units and Type',
   'markdown',
   '# Colour, Units and Type

Three small decisions - which unit, which colour notation, which type scale - shape more of how a site feels than any single layout choice. They are also the decisions made earliest and changed least, which makes them worth a lesson of their own.

## Units: the only three you need most days

```css
font-size: 1rem;      /* relative to the ROOT font size */
padding: 1em;         /* relative to THIS element''s font size */
width: 50%;           /* relative to the containing block */
```

**`rem`** is the workhorse. One rem is the root font size, which is 16px by default and - importantly - is whatever the user set in their browser preferences. Someone who has set 24px because they cannot comfortably read 16 gets a site that scales with that choice.

**`px`** does not. A layout built in pixels ignores that preference entirely. This is the single strongest argument for `rem`, and it is an accessibility argument rather than an aesthetic one.

**`em`** compounds, which is occasionally what you want and often a trap:

```css
.card { font-size: 1.2em; }
.card .title { font-size: 1.2em; }   /* 1.44x the parent. Nested: 1.73x. */
```

Use `em` for things that should scale **with their own text** - the padding inside a button, the gap between an icon and its label - and `rem` for everything structural.

### Viewport units

```css
font-size: 4vw;      /* 4% of viewport width */
min-height: 100vh;   /* full viewport height */
min-height: 100dvh;  /* the dynamic one - excludes mobile browser chrome */
```

`100vh` on a phone is famously wrong: it includes the space under the address bar, so a "full height" section is taller than the screen and the bottom is cut off. `dvh` tracks the chrome as it hides and shows. `svh` and `lvh` are the smallest and largest states if you want one or the other explicitly.

Never set a font size in `vw` alone. It does not scale with the user''s preference and it has no floor, so at 320 pixels the text becomes unreadable. Clamp it:

```css
h1 { font-size: clamp(1.75rem, 1.2rem + 2.5vw, 3.5rem); }
```

Floor, a preferred value that grows with the viewport, ceiling. The `rem` in the middle term is what keeps the user''s preference in the calculation.

### ch and the measure

```css
.prose { max-width: 70ch; }
```

`1ch` is the width of the digit zero in the current font. It is the natural unit for line length, and 60 to 75 characters is the range typographers settle on: shorter and the eye jumps back too often, longer and it loses the next line''s start.

## Colour: the notations, and why the new ones matter

```css
color: #0f766e;
color: rgb(15 118 110);
color: rgb(15 118 110 / 0.8);     /* modern syntax, slash for alpha */
color: hsl(175 77% 26%);
color: oklch(48% 0.09 180);
```

Hex and `rgb()` describe a colour in terms of a screen''s primaries, which is precise and tells you nothing useful. You cannot look at `#0f766e` and say what will happen if you make it lighter.

`hsl()` is readable - hue, saturation, lightness - but its lightness is not perceptual. `hsl(60 100% 50%)` (yellow) and `hsl(240 100% 50%)` (blue) claim the same lightness and one of them is blinding while the other is nearly black.

**`oklch()`** fixes exactly that. Its lightness is perceptual, so two colours with the same L genuinely look equally light. This makes a palette derivable rather than hand-picked:

```css
:root {
  --accent-h: 175;
  --accent: oklch(48% 0.09 var(--accent-h));
  --accent-soft: oklch(94% 0.03 var(--accent-h));
  --accent-strong: oklch(38% 0.10 var(--accent-h));
}
```

Change one hue and the whole family moves together, with the contrast relationships intact. Doing that with hex means recalculating every value by hand.

### Contrast is a requirement, not a preference

The accessibility guidelines ask for a contrast ratio of at least **4.5:1** for body text against its background, and **3:1** for large text (roughly 24px, or 19px bold) and for the visual boundary of a control.

This is not a style opinion. Low-contrast grey-on-grey is unreadable in sunlight, on a cheap screen, and for the very large number of people with reduced contrast sensitivity - which includes most people over sixty.

Every browser''s devtools shows the ratio when you open a colour picker on a text element, with a tick or a cross. Check the ones you are unsure about; it takes seconds.

### Dark mode, done with tokens

```css
:root {
  --bg: oklch(99% 0.005 250);
  --text: oklch(25% 0.02 250);
  --surface: oklch(97% 0.008 250);
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: oklch(18% 0.02 250);
    --text: oklch(92% 0.01 250);
    --surface: oklch(23% 0.02 250);
  }
}

:root[data-theme="dark"] { /* the same block, for an explicit choice */ }
```

Define the colours once as tokens and redefine the tokens, not the components. A component that says `background: var(--surface)` needs no dark-mode rule of its own, ever.

Two things worth knowing about dark mode: pure black backgrounds with pure white text cause halation and are tiring to read, so use a very dark grey and a slightly-off white; and shadows mostly stop working, so lean on a lighter surface colour to raise something instead.

## Type: four properties carry a design

```css
body {
  font-family: Inter, system-ui, sans-serif;
  font-size: 1rem;
  line-height: 1.6;
  letter-spacing: 0;
}
```

**`font-family`** with a sensible fallback chain. `system-ui` is the operating system''s own interface font - it loads instantly because it is already there, and on most sites it is a legitimate choice rather than a compromise.

**`line-height`** unitless, always. `1.6` means 1.6 times each element''s own font size. Giving it a unit (`line-height: 24px`) makes every descendant inherit 24 pixels regardless of their size, which breaks headings.

Body text wants 1.5 to 1.7. Headings want less - 1.1 to 1.25 - because the lines are short and the type is large.

**`letter-spacing`** is normally left alone. Large display text often wants a touch of negative tracking (`-0.02em`), and all-caps text usually wants positive (`0.05em`) because capitals were not designed to sit together.

### A scale, rather than values picked one at a time

```css
:root {
  --step--1: 0.833rem;
  --step-0:  1rem;
  --step-1:  1.2rem;
  --step-2:  1.44rem;
  --step-3:  1.728rem;
  --step-4:  2.074rem;
}
```

Each step is the previous one times 1.2. Any consistent ratio works - 1.125, 1.25, the golden ratio - and the point is that there is one. Sizes chosen individually never quite relate to each other, and the result reads as noise even when no single value is wrong.

### Loading a web font without a flash

```css
@font-face {
  font-family: Inter;
  src: url(/fonts/inter-var.woff2) format("woff2-variations");
  font-weight: 100 900;        /* a variable font: one file, every weight */
  font-display: swap;
}
```

`font-display: swap` shows the fallback immediately and swaps when the web font arrives. The reader sees text at once; the cost is a visible reflow.

A variable font is one file covering every weight, which is usually smaller than the two or three static files it replaces, and it lets you use weights between the named ones.

## A page you can run

Everything above, in one document: a token palette in `oklch`, a type scale built from one ratio, `clamp()` for the heading, `ch` for the measure, and a dark palette that redefines the tokens rather than the components.

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
        /* Lightness, chroma, hue. Changing the hue alone keeps the
           perceived lightness, which hex notation cannot promise. */
        --surface:    oklch(99% 0.004 250);
        --surface-2:  oklch(96% 0.008 250);
        --ink:        oklch(25% 0.02 250);
        --ink-quiet:  oklch(50% 0.02 250);
        --accent:     oklch(55% 0.13 180);
        --line:       oklch(90% 0.01 250);

        /* One ratio, applied repeatedly. Nothing here was picked by eye. */
        --step-0: 1rem;
        --step-1: 1.25rem;
        --step-2: 1.563rem;
        --step-3: 1.953rem;
      }

      @media (prefers-color-scheme: dark) {
        :root {
          --surface:   oklch(20% 0.012 250);
          --surface-2: oklch(25% 0.015 250);
          --ink:       oklch(95% 0.008 250);
          --ink-quiet: oklch(72% 0.012 250);
          --accent:    oklch(72% 0.12 180);
          --line:      oklch(32% 0.015 250);
        }
      }

      body {
        margin: 0;
        padding: clamp(1rem, 4vw, 3rem);
        background: var(--surface);
        color: var(--ink);
        font-family: system-ui, sans-serif;
        font-size: var(--step-0);
        line-height: 1.6;
      }

      h1 {
        /* A rem term in the middle, so the user''s own font size still
           counts. Pure vw would ignore it. */
        font-size: clamp(var(--step-2), 1.2rem + 2.5vw, var(--step-3));
        line-height: 1.15;
        letter-spacing: -0.015em;
        text-wrap: balance;
        margin: 0 0 0.5rem;
      }

      h2 { font-size: var(--step-1); line-height: 1.3; margin: 2rem 0 0.5rem; }

      /* The measure: 60 to 75 characters is the comfortable range, and ch
         is the unit that says so directly. */
      .prose { max-width: 66ch; }
      .prose p { margin: 0 0 1rem; }

      .lede { color: var(--ink-quiet); font-size: var(--step-1); }

      .swatches {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(min(9rem, 100%), 1fr));
        gap: 0.75rem;
        margin: 1rem 0 0;
        padding: 0;
        list-style: none;
      }
      .swatches li {
        background: var(--surface-2);
        border: 1px solid var(--line);
        border-radius: 10px;
        padding: 0.75rem;
        font-size: 0.875rem;
        color: var(--ink-quiet);
      }
      .chip {
        display: block;
        height: 2.5rem;
        border-radius: 6px;
        margin-block-end: 0.5rem;
        background: var(--accent);
      }
      /* One token changed per chip. The relative syntax keeps the
         relationship explicit instead of hard-coding a second colour. */
      .chip.lighter { background: oklch(from var(--accent) calc(l + 0.15) c h); }
      .chip.duller  { background: oklch(from var(--accent) l calc(c * 0.4) h); }
      .chip.turned  { background: oklch(from var(--accent) l c calc(h + 120)); }

      a { color: var(--accent); }
    </style>
  </head>
  <body>
    <div class="prose">
      <h1>Three tokens, one ratio, no guessed values</h1>
      <p class="lede">
        Switch your operating system between light and dark. Nothing below
        changes except the six custom properties at the top of the stylesheet.
      </p>
      <p>
        The line length is set in <code>ch</code>, so it holds the same number
        of characters whatever the font size. The heading is clamped, so it
        grows with the window but stops before it looks silly. Try setting your
        browser default font size to 24px and reloading: everything scales,
        because every size is in <code>rem</code> rather than pixels.
      </p>

      <h2>One accent, varied by component</h2>
      <ul class="swatches">
        <li><span class="chip"></span>--accent</li>
        <li><span class="chip lighter"></span>lightness + 0.15</li>
        <li><span class="chip duller"></span>chroma x 0.4</li>
        <li><span class="chip turned"></span>hue + 120</li>
      </ul>
    </div>
  </body>
</html>
```

Open it and resize the window, then change your system colour scheme. Two things are worth noticing. The components never mention a colour - they mention a token, which is why the dark palette is six lines rather than a second stylesheet. And the three varied chips are derived from the accent rather than written down, so changing `--accent` moves all four together.

## What goes wrong

| Symptom | Cause |
|---|---|
| Site ignores the user''s font-size setting | Sized in `px` |
| Nested text keeps growing | `em` compounding |
| Bottom of a full-height section cut off on a phone | `100vh` instead of `100dvh` |
| Headings have far too much leading | `line-height` with a unit |
| Palette looks uneven across hues | `hsl` lightness is not perceptual |
| Grey text unreadable in sunlight | Under 4.5:1 contrast |
| Text invisible for a second | No `font-display` |
| Heading sizes feel arbitrary | No scale |

## What to decide once

Set the root font size in `rem` and never use `px` for anything that holds text. Define your colours as `oklch` tokens and redefine the tokens for dark mode. Pick a type scale with a ratio and use only its steps. Set `line-height` unitless, and cap your prose at about `70ch`.

Those five decisions take an hour at the start of a project and remove most of the small arguments for the rest of it.
',
   'Three small decisions - which unit, which colour notation, which type scale - shape more of how a site feels than any single layout choice.', 10, 1936,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
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
  ('e0000001-0000-4000-8000-000000000020',
   'Flexbox: One Dimension at a Time',
   'markdown',
   '# Flexbox: One Dimension at a Time

Flexbox lays things out along a single axis - a row or a column - and shares the leftover space between them. That is the whole model. Almost every problem people have with it comes from expecting it to handle two axes at once, which is Grid''s job.

## The two axes, and why the names are abstract

```css
.row { display: flex; }                           /* main axis: horizontal */
.col { display: flex; flex-direction: column; }   /* main axis: vertical */
```

- The **main axis** is the one `flex-direction` names.
- The **cross axis** is the other one.

The names are abstract on purpose: set `flex-direction: column` and every property below swaps meaning without you rewriting any of them. `justify-content` always works along the main axis, whichever that currently is.

This is also why `justify-content` and `align-items` are so often mixed up. The fix is not to memorise which is horizontal - neither is. Learn them as "along the flow" and "across the flow".

## Properties on the container

```css
.container {
  display: flex;
  flex-direction: row;          /* row | row-reverse | column | column-reverse */
  flex-wrap: wrap;              /* nowrap (default) | wrap */
  gap: 1rem;                    /* space between items, both axes */

  justify-content: space-between;  /* along the main axis */
  align-items: center;             /* across the cross axis, per line */
  align-content: flex-start;       /* the lines themselves, when wrapped */
}
```

`justify-content` takes: `flex-start`, `flex-end`, `center`, `space-between`, `space-around`, `space-evenly`.

The three space values differ in where the gaps go:

```
space-between   |A      B      C|     no space at the ends
space-around    |  A    B    C  |     half-size space at the ends
space-evenly    |   A   B   C   |     equal space everywhere
```

`align-items` takes: `stretch` (the default - items fill the cross axis), `flex-start`, `flex-end`, `center`, `baseline`.

`baseline` is the underrated one: it lines up the text baselines of items with different font sizes, which is what you want for a heading next to a badge.

`gap` replaced the old approach of putting a margin on every item and removing it from the last. It applies between items only, never at the edges, and it works in grid too.

## Properties on the items

```css
.item {
  flex-grow: 0;      /* share of EXTRA space. 0 = do not grow */
  flex-shrink: 1;    /* share of the DEFICIT. 0 = do not shrink */
  flex-basis: auto;  /* starting size before growing or shrinking */

  flex: 0 1 auto;    /* the shorthand, in that order - and the default */

  align-self: center;  /* override align-items for one item */
  order: 2;            /* visual order only - see the warning below */
}
```

### The shorthand values worth knowing

```css
flex: 1;        /* = 1 1 0%   - share space equally, ignore content size */
flex: auto;     /* = 1 1 auto - share space, but start from content size */
flex: none;     /* = 0 0 auto - do not grow or shrink. Fixed. */
flex: 0 0 240px;/* exactly 240px, never flexing */
```

The difference between `flex: 1` and `flex: auto` is the one that matters and the one people miss.

With `flex: 1`, the basis is `0%`, so content size is ignored entirely and every item ends up the **same width** regardless of what is in it.

With `flex: auto`, the basis is the content size, so items start at their natural width and then share the leftover - an item with more text in it ends up wider.

```css
/* Three equal columns, whatever is in them */
.equal > * { flex: 1; }

/* Columns proportional to their content, sharing what is left */
.natural > * { flex: auto; }
```

## Four layouts that cover most of what you need

### A bar with something pushed to the end

```css
.bar { display: flex; align-items: center; gap: 1rem; }
.bar .spacer { margin-inline-start: auto; }
```

`margin: auto` in a flex container absorbs all the free space on that side. One `margin-inline-start: auto` pushes that item and everything after it to the end - which is often clearer than restructuring to use `justify-content: space-between`.

### A sidebar that holds its width

```css
.layout { display: flex; gap: 2rem; }
.sidebar { flex: 0 0 18rem; }   /* fixed */
.main    { flex: 1; min-width: 0; }  /* takes the rest */
```

`min-width: 0` on the main column is not optional. A flex item''s `min-width` defaults to `auto`, which means it refuses to shrink below its content''s intrinsic minimum - so one long code block or one unbroken URL pushes the sidebar off the screen. This is the single most common flexbox bug and the fix is never obvious from the symptom.

### Cards that wrap and fill the last row

```css
.cards { display: flex; flex-wrap: wrap; gap: 1.5rem; }
.cards > * { flex: 1 1 18rem; }
```

Each card wants to be at least 18rem, grows to share the row, and wraps when there is not room. The one caveat is that items on a partly-filled last row stretch to fill it, which can look odd - and is the case where Grid''s `auto-fill` is the better tool.

### Vertical centring

```css
.centre { display: flex; align-items: center; justify-content: center; min-height: 100dvh; }
```

The problem that defined a decade of CSS, in three declarations.

### All four, in one page you can run

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Four flex layouts</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 0;
        padding: 1.5rem;
        background: #fbfbfd;
        color: #16181d;
      }
      h2 { font-size: 1rem; margin: 2rem 0 0.5rem; color: #5c626e; }
      .box {
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 0.75rem 1rem;
      }

      /* 1. A bar with something pushed to the end. margin-left: auto
         absorbs all the free space, so no spacer element is needed. */
      .bar {
        display: flex;
        align-items: center;
        gap: 1rem;
      }
      .bar .brand { font-weight: 600; }
      .bar nav { display: flex; gap: 1rem; }
      .bar .account { margin-inline-start: auto; }

      /* 2. A sidebar that holds its width while the main column takes
         the rest. flex: 0 0 14rem is "do not grow, do not shrink,
         start at 14rem"; min-width: 0 on the main column stops long
         content from forcing it wider than its share. */
      .with-sidebar { display: flex; gap: 1rem; flex-wrap: wrap; }
      .with-sidebar .side { flex: 0 0 14rem; }
      .with-sidebar .main { flex: 1 1 20rem; min-width: 0; }

      /* 3. Cards that wrap, where the last row fills rather than
         leaving a gap. flex-basis gives the preferred width; grow
         lets the survivors of a wrap share what is left. */
      .cards { display: flex; flex-wrap: wrap; gap: 0.75rem; }
      .cards > * { flex: 1 1 12rem; }

      /* 4. Vertical centring, which used to be the hard one. */
      .hero {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 9rem;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <h2>1 - a bar, with the account pushed to the end</h2>
    <div class="bar box">
      <span class="brand">Omni</span>
      <nav><a href="#">Courses</a><a href="#">Paths</a></nav>
      <span class="account">Signed in</span>
    </div>

    <h2>2 - a sidebar that does not move</h2>
    <div class="with-sidebar">
      <aside class="side box">Fixed at 14rem until the row runs out of room.</aside>
      <div class="main box">
        Takes everything left over. Drag the window narrow and the sidebar
        wraps above this column rather than squeezing it.
      </div>
    </div>

    <h2>3 - cards that fill the last row</h2>
    <div class="cards">
      <div class="box">One</div>
      <div class="box">Two</div>
      <div class="box">Three</div>
      <div class="box">Four</div>
      <div class="box">Five</div>
    </div>

    <h2>4 - centred both ways</h2>
    <div class="hero box">Centred, in two declarations.</div>
  </body>
</html>
```

Drag the window from wide to narrow and watch each one in turn. The bar keeps the account at the end without a spacer. The sidebar holds 14rem and then wraps rather than collapsing. The cards reflow and the last row spreads to fill. And the hero stays centred at every width.

## The accessibility warning about order

```css
.item { order: -1; }          /* moves it first, visually */
.row { flex-direction: row-reverse; }
```

Both change the **visual** order only. The DOM order is unchanged, so:

- The tab order still follows the source. A keyboard user tabs from the visually-last item to the visually-first, which looks like a bug.
- A screen reader reads the source order, so the page is narrated in a different order from the one it is read in.

Use these for genuinely cosmetic reordering at a breakpoint, and fix the source order when the order carries meaning. If reordering the DOM is awkward, that is usually a signal the markup is structured around the layout rather than the content.

## Flex or Grid

The honest rule:

- **Flex** when the content decides the layout - a row of buttons, a navigation bar, a card''s internals, anything that should wrap naturally.
- **Grid** when the layout decides where content goes - a page skeleton, a form of label-and-field pairs, anything where things must line up across rows as well as along them.

"One dimension versus two" is the usual phrasing and it is slightly misleading, because flex items do wrap onto several lines. The sharper distinction is **alignment across lines**: in flex, each line is laid out independently, so items in the second row do not line up with items in the first. In grid they do, because the tracks are defined up front.

## What goes wrong

| Symptom | Cause | Fix |
|---|---|---|
| A long word pushes everything out | Flex item `min-width: auto` | `min-width: 0` |
| Items are all the same width despite different content | `flex: 1` zeroes the basis | `flex: auto` |
| `align-items: center` does nothing | Only one line and the container has no extra cross-axis size | Give the container a height |
| Second row does not line up with the first | Flex lines are independent | Use Grid |
| Tab order jumps around | `order` or `row-reverse` | Fix the source order |
| The gap appears at the edges too | Margins instead of `gap` | Use `gap` |
| An item will not shrink | `flex-shrink: 0`, or an image with no `min-width: 0` | |

## The mental model to keep

A flex container has a main axis. Items are placed along it in order. If there is space left over, `flex-grow` says who takes it; if there is not enough, `flex-shrink` says who gives it up; `justify-content` positions whatever is left; `align-items` handles the other direction.

Everything else in this lesson follows from those five sentences.
',
   'Flexbox lays things out along a single axis and shares the leftover space. That is the whole model. Almost every problem comes from expecting it to handle two axes at once.', 9, 1786,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000021',
   'Grid: Rows and Columns Together',
   'markdown',
   '# Grid: Rows and Columns Together

Grid is the only layout system on the web that works in two dimensions at once. You describe the tracks, then place things into them - and with named areas you can draw the layout in the stylesheet and read it back a year later.

## Defining the tracks

```css
.grid {
  display: grid;
  grid-template-columns: 200px 1fr 200px;
  grid-template-rows: auto 1fr auto;
  gap: 1rem;
}
```

Three columns and three rows. Any length works, and so do three things that are specific to grid.

### fr, which is the unit that makes grid worth using

`1fr` is one share of the **leftover** space, after fixed tracks and gaps are subtracted.

```css
grid-template-columns: 200px 1fr 1fr;   /* 200px, then the rest split evenly */
grid-template-columns: 2fr 1fr;         /* two thirds, one third */
```

This is not the same as a percentage. `50%` is half the container including the gap, so `50% 50%` with a gap overflows. `1fr 1fr` accounts for the gap automatically, which is why `fr` is almost always the right choice.

### repeat, minmax and the responsive grid with no media query

```css
grid-template-columns: repeat(3, 1fr);
grid-template-columns: repeat(auto-fill, minmax(16rem, 1fr));
grid-template-columns: repeat(auto-fit,  minmax(16rem, 1fr));
```

That second line is the most useful declaration in modern CSS. Read it as: *fit as many columns as you can, each at least 16rem, sharing the leftover space equally.*

On a 1200-pixel screen that is four columns. On a phone it is one. There is no breakpoint, nothing to maintain, and it adapts to the container rather than the viewport.

The difference between `auto-fill` and `auto-fit` only shows when there are fewer items than fit:

- **`auto-fill`** keeps the empty tracks. Three cards in a four-column grid stay card-sized, with a gap on the right.
- **`auto-fit`** collapses the empty tracks, so three cards stretch to fill the whole row.

Neither is right in general. `auto-fit` for a gallery that should always look full; `auto-fill` when a consistent card width matters more.

## Placing items

### By line number

Grid lines are numbered from 1, and negative numbers count from the end.

```css
.item {
  grid-column: 1 / 3;     /* from line 1 to line 3: two columns */
  grid-row: 2 / 4;
  grid-column: 1 / -1;    /* full width, however many columns there are */
  grid-column: span 2;    /* two tracks, wherever it lands */
}
```

`grid-column: 1 / -1` is the one to remember: it means full width without you having to know the column count.

### By named area, which is the readable way

```css
.page {
  display: grid;
  grid-template-columns: 16rem 1fr;
  grid-template-rows: auto 1fr auto;
  grid-template-areas:
    "sidebar header"
    "sidebar main"
    "sidebar footer";
  min-height: 100dvh;
  gap: 1rem;
}

.page > header  { grid-area: header; }
.page > aside   { grid-area: sidebar; }
.page > main    { grid-area: main; }
.page > footer  { grid-area: footer; }
```

The template is a picture of the layout. Somebody reading this file six months later can see the page shape without opening the browser, which is not true of any other layout technique.

Rearranging for a phone is then one block:

```css
@media (max-width: 48rem) {
  .page {
    grid-template-columns: 1fr;
    grid-template-areas:
      "header"
      "main"
      "sidebar"
      "footer";
  }
}
```

No element moved. No element''s own CSS changed. A dot is an empty cell:

```css
grid-template-areas:
  "header header"
  "main   ."
  "footer footer";
```

## Alignment in both directions

Grid has the same alignment vocabulary as flexbox, and here both axes are available at once:

```css
.grid {
  justify-items: center;    /* each item, along the inline (row) axis */
  align-items: center;      /* each item, along the block (column) axis */
  place-items: center;      /* both, in one line */

  justify-content: center;  /* the whole grid, when it is narrower than its container */
  align-content: center;
  place-content: center;
}

.item {
  justify-self: end;        /* one item, overriding the above */
  align-self: start;
  place-self: center;
}
```

`place-items: center` on a grid container is the shortest true centring in CSS:

```css
.hero { display: grid; place-items: center; min-height: 100dvh; }
```

## Implicit tracks

Place more items than you defined tracks for and grid creates more. `grid-auto-rows` says how big those are:

```css
.feed {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
  grid-auto-rows: minmax(12rem, auto);
  gap: 1rem;
}
```

`grid-auto-flow: dense` lets grid backfill holes left by items that span several tracks. It does so by taking items out of order visually, which creates the same tab-order mismatch as flexbox `order` - so use it for a gallery of equivalent things, not for anything sequential.

## subgrid, for lining up across cards

A long-standing frustration: three cards in a row, each with a title, body and footer of different lengths, and the footers do not line up because each card is its own formatting context.

```css
.cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }

.card {
  display: grid;
  grid-row: span 3;
  grid-template-rows: subgrid;   /* adopt the parent''s rows */
}
```

Each card now uses the parent grid''s row tracks rather than its own, so every title row is the height of the tallest title and every footer starts at the same line. This genuinely was not possible before subgrid without JavaScript measuring things.

## A page you can run

A whole page layout by named area, with a card grid inside it that reflows on its own.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A page in two dimensions</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 0;
        background: #fbfbfd;
        color: #16181d;
      }

      /* The layout, drawn. Every area is named once in the template and
         once on the element, and the shape of the page is readable from
         the stylesheet without running it. */
      .page {
        display: grid;
        min-height: 100vh;
        gap: 1rem;
        padding: 1rem;
        grid-template-columns: minmax(0, 14rem) minmax(0, 1fr);
        grid-template-rows: auto 1fr auto;
        grid-template-areas:
          "header  header"
          "sidebar main"
          "footer  footer";
      }

      /* The one place a breakpoint earns its keep: the structure
         genuinely changes, rather than just wrapping. */
      @media (width < 48rem) {
        .page {
          grid-template-columns: minmax(0, 1fr);
          grid-template-areas:
            "header"
            "main"
            "sidebar"
            "footer";
        }
      }

      .page > header  { grid-area: header; }
      .page > nav     { grid-area: sidebar; }
      .page > main    { grid-area: main; }
      .page > footer  { grid-area: footer; }

      header, nav, main, footer {
        background: #fff;
        border: 1px solid #e3e5ea;
        border-radius: 10px;
        padding: 1rem 1.25rem;
      }
      nav ul { margin: 0; padding: 0; list-style: none; display: grid; gap: 0.5rem; }

      /* The inner grid: as many columns as fit, each at least 14rem,
         and min() so it survives a container narrower than that. */
      .cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(min(14rem, 100%), 1fr));
        gap: 1rem;
      }
      .card {
        border: 1px solid #e3e5ea;
        border-radius: 8px;
        padding: 1rem;
        /* Each card is its own little grid, so the button lines up
           across the row however long the text is. */
        display: grid;
        grid-template-rows: auto 1fr auto;
        gap: 0.5rem;
      }
      .card h3 { margin: 0; font-size: 1rem; }
      .card p { margin: 0; color: #5c626e; font-size: 0.9375rem; }
      .card button { font: inherit; padding: 0.4rem 0.75rem; border-radius: 6px;
                     border: 1px solid #0f766e; background: #0f766e; color: #fff; }
    </style>
  </head>
  <body>
    <div class="page">
      <header><strong>Omni Academy</strong></header>

      <nav>
        <ul>
          <li><a href="#">Courses</a></li>
          <li><a href="#">Paths</a></li>
          <li><a href="#">Account</a></li>
        </ul>
      </nav>

      <main>
        <h1>Named areas</h1>
        <p>Drag the window below 48rem and the sidebar moves under the content.</p>

        <div class="cards">
          <article class="card">
            <h3>Short</h3>
            <p>One line.</p>
            <button type="button">Open</button>
          </article>
          <article class="card">
            <h3>Longer</h3>
            <p>Several lines of description, enough to make this card taller than its neighbour if the rows were not stretching together.</p>
            <button type="button">Open</button>
          </article>
          <article class="card">
            <h3>Middling</h3>
            <p>Two lines or so of text here.</p>
            <button type="button">Open</button>
          </article>
        </div>
      </main>

      <footer>One grid, three areas, no positioning.</footer>
    </div>
  </body>
</html>
```

Two separate grids are at work and it is worth separating them in your head. The outer one is a page skeleton: fixed areas, named, with one media query where the structure genuinely changes. The inner one is content-driven: nobody said how many columns, only how narrow a column may get.

Look at the buttons across the card row. They line up even though the descriptions differ in length, because each card is a three-row grid whose middle row takes the slack. That is the cheap version of the trick - `subgrid`, below, is the thorough one.

## Grid or Flex

- **Grid** when the layout is a shape you can draw: a page skeleton, a card gallery, a form of labels and fields, a dashboard. Use it when things must line up in both directions.
- **Flex** when the content decides: a row of buttons, a toolbar, the inside of a card, anything that should wrap naturally.

They compose. A grid for the page, flex inside each region, is the normal arrangement rather than a compromise.

## What goes wrong

| Symptom | Cause | Fix |
|---|---|---|
| Columns overflow the container | `50% 50%` plus a gap | Use `1fr 1fr` |
| A long word stretches a track | Grid item `min-width: auto` | `minmax(0, 1fr)` |
| Cards do not fill the last row | `auto-fill` | `auto-fit` |
| Named areas do nothing | The template is not rectangular | Every row must have the same number of columns |
| An item ignores its placement | A typo in the area name - CSS fails silently | Check the template against the `grid-area` values |
| Nothing lines up between cards | Each card is its own grid | `subgrid` |

`minmax(0, 1fr)` deserves the same emphasis as `min-width: 0` in flexbox: `1fr` means `minmax(auto, 1fr)`, and that `auto` minimum is what lets content push a track wider than its share. If a grid column is refusing to shrink, this is why.

## Use the inspector

Both Firefox and Chrome draw the grid over the page - every line, numbered, with the area names and the track sizes labelled. Turn it on from the Layout panel the first time a grid does something you did not expect; it answers in seconds what reading the CSS answers in twenty minutes.
',
   'Grid is the only layout system on the web that works in two dimensions at once. Describe the tracks, then place things into them.', 8, 1692,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000022',
   'Responsive Without Breakpoints',
   'markdown',
   '# Responsive Without Breakpoints

A media query asks how wide the *window* is. That is almost never the question you meant to ask. What you meant was "wrap when you run out of room", and CSS can say that directly - without you picking a pixel value that some future device will land exactly between.

## Why the pixel values were always wrong

The breakpoint habit came from a world of three screen sizes. You wrote `768px` for tablets and `1024px` for laptops, and for a while that described the market. It stopped describing it around the time phones got wider than early tablets and laptops got narrower than desktops.

But the deeper problem is not that the numbers aged. It is that a width media query asks about the wrong thing. Consider a card grid. What you want is: as many columns as will fit, each at least wide enough to read. The viewport width is a poor proxy for that, because the grid might be in a sidebar, inside a modal, or in a main column next to a navigation panel. One number cannot be right in all three places.

Intrinsic sizing lets the layout answer the question itself, from the space it actually has.

## The three functions everything is built from

- **`min(a, b)`** takes the smaller. `width: min(60rem, 100%)` means "60rem, but never wider than the container". It replaces the old `width: 60rem; max-width: 100%` pair with one declaration.
- **`max(a, b)`** takes the larger. Useful as a floor: `padding: max(1rem, 2vw)` never drops below 1rem on a narrow phone.
- **`clamp(low, ideal, high)`** is `max(low, min(ideal, high))`, written the way you think about it. The middle value is usually a viewport unit so it scales; the outer two stop it scaling into absurdity.

All three take full expressions - `calc()` is implied inside them, so `clamp(1rem, 0.5rem + 2vw, 2rem)` is valid as written.

## A complete page with no media query in it

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Responsive with no breakpoints</title>
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
         there is not - and the threshold is a real measurement of the
         row, not a guessed screen width. */
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

Four techniques are doing the work. Each is worth understanding on its own, because each solves a different shape of problem.

## Walking through the four

**`clamp()` on padding and type.** `clamp(1rem, 4vw, 3rem)` has a floor, a slope and a ceiling. On a 320px phone, 4vw is about 13px, so the floor of 1rem wins. On a 1920px monitor, 4vw is 77px, so the ceiling of 3rem wins. Between roughly 400px and 1200px the viewport unit is in charge and the padding grows smoothly. No step, no jump, no device named.

For type, prefer `clamp(1.75rem, 1.1rem + 3vw, 2.75rem)` over `clamp(1.75rem, 5vw, 2.75rem)`. Adding a `rem` term to the middle value means the text still responds to the user''s browser font-size setting. A pure `vw` value ignores it, which breaks zoom for anyone who has turned their default size up - and that is an accessibility failure, not a styling preference.

**`auto-fit` with `minmax`.** `repeat(auto-fit, minmax(15rem, 1fr))` means: make as many 15rem-or-wider columns as fit, then let them share the leftover space equally. Four cards become four columns on a wide screen, two on a tablet, one on a phone, and the browser decides where each change happens by measuring.

**`min()` inside the minimum.** This is the part people miss. `minmax(15rem, 1fr)` breaks in a container narrower than 15rem: the track refuses to shrink below its minimum and the grid overflows its parent, producing a horizontal scrollbar. Wrapping it as `min(15rem, 100%)` says "15rem, or the whole container if that is smaller". It is the difference between a card grid that works in a 12rem sidebar and one that does not. Write it this way by default; the cost is nothing and the bug it prevents is a real one.

**The switcher.** `flex-basis: calc((30rem - 100%) * 999)` is a trick, and it is worth knowing why it works. The `100%` resolves against the flex container''s width. If the row is narrower than 30rem, the subtraction is positive, multiplying by 999 makes it enormous, and each child demands more than the full row - so they wrap and stack. If the row is wider than 30rem, the result is hugely negative, flex-basis clamps negative values to zero, and `flex-grow: 1` has the children share the row equally. One declaration, a real threshold, and the threshold is about the row rather than the window.

## Where media queries still earn their place

Not everything is a width question, and these have no intrinsic equivalent:

```html
<style>
  @media (prefers-reduced-motion: reduce) { /* honour it. Always. */ }
  @media (prefers-color-scheme: dark) { /* the other palette */ }
  @media (prefers-contrast: more) { /* stronger borders */ }
  @media print { /* drop the navigation */ }
  @media (hover: none) { /* no hover on a touch screen */ }
</style>
```

These ask about the user and the device, not about available space, and that is exactly what a media query is good at. Keep using them.

Use a width media query when the *structure* genuinely changes - a sidebar moving below the content, a horizontal navigation becoming a menu button. Use intrinsic sizing for everything that is really just "wrap when you run out of room", which is most of it.

## When the question is about the component, not the window

A card in a 20rem sidebar and the same card in a 60rem main column want different layouts, and the viewport width cannot tell them apart. That is what container queries are for, and they are waiting in level four.

## When it goes wrong

| Symptom | Cause |
|---|---|
| Horizontal scrollbar on a narrow screen | `minmax(15rem, ...)` without `min(15rem, 100%)` |
| Text will not zoom for a user who enlarged it | The middle of `clamp()` is pure `vw`, with no `rem` term |
| `clamp()` seems to do nothing | The low and high bounds are too close to leave the slope any room |
| The switcher never stacks | `flex-wrap: wrap` missing, so there is nowhere to wrap to |
| Columns are all equal but too narrow | `auto-fill` where you wanted `auto-fit` - empty tracks are being kept |
| `vw` units cause a scrollbar | `100vw` includes the scrollbar width; use `100%` or `100dvw` |

## A check you can run

Open the page above and drag the window from as narrow as it will go to as wide as your screen allows. Watch for a *jump* - a moment where something changes size in one step rather than growing smoothly. Every jump is a decision being made at a threshold, and you should be able to name which rule made it. In this page there are exactly two: the grid changing column count, and the switcher stacking. If you find a third, something is sized in a way you did not intend.

Then set your browser''s default font size to 24px and reload. The headings should still grow, the body text should still be comfortable, and nothing should overlap. A layout built on viewport units alone fails this test; one built on `rem` plus viewport units passes it.
',
   'A media query asks how wide the window is. Most of the time what you want to say is wrap when you run out of room - and CSS can express that directly.', 8, 1512,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
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
  ('e0000001-0000-4000-8000-000000000023',
   'Custom Properties and Theming',
   'markdown',
   '# Custom Properties and Theming

A custom property is a real value in the cascade, not a build-time find-and-replace. It inherits, it can be changed on one subtree, and JavaScript can set it at runtime. That is what makes theming a matter of redefining variables rather than duplicating components.

## They are not variables in the preprocessor sense

```css
:root {
  --accent: #0f766e;
  --gap: 1rem;
}

.button { background: var(--accent); padding: var(--gap); }
```

That looks like Sass. The difference is everything:

- **A Sass variable is resolved when the file is compiled.** After that it does not exist. You cannot change it at runtime, you cannot change it for one subtree, and the browser has never heard of it.
- **A custom property lives in the cascade.** It inherits down the tree, it can be overridden by any selector that matches, and reading or writing it from JavaScript works.

```javascript
getComputedStyle(el).getPropertyValue(''--accent'');
el.style.setProperty(''--accent'', ''#b91c1c'');
```

## Inheritance is the feature

```css
:root { --card-bg: white; }

.card { background: var(--card-bg); }

.panel-dark { --card-bg: #1f2937; }   /* every .card inside now dark */
```

The `.card` rule was not touched. Setting the property on an ancestor changes every descendant that reads it, which is how a component can be re-skinned by its container without knowing anything about the container.

This is the single idea the rest of the lesson builds on.

## Fallbacks

```css
color: var(--text, #333);
padding: var(--gap, var(--space-md, 1rem));   /* nested fallbacks */
```

The second argument is used when the property is not defined at all. It is not used when the property is defined but invalid - that case is different and worth knowing.

### Invalid at computed-value time

```css
.thing {
  --size: potato;
  width: var(--size);     /* not ''invalid'' - the property becomes ''unset'' */
}
```

The browser cannot reject `var(--size)` while parsing, because it does not yet know what `--size` holds. By the time it does, it is too late to fall back to the previous declaration. The property is treated as `unset` instead - inheriting if it is an inheritable property, and taking its initial value if not.

The practical consequence: a typo in a custom property does not show up as a struck-through declaration in devtools. It shows up as a property that inherited something unexpected, which is much harder to spot.

`@property` fixes this by giving the browser a type up front:

```css
@property --size {
  syntax: "<length>";
  inherits: false;
  initial-value: 1rem;
}
```

Now an invalid value falls back to `1rem` rather than to nothing, and `--size` can be animated - which an untyped custom property cannot be, because the browser does not know how to interpolate between two unknown strings.

## A token system, which is the point of all this

```css
:root {
  /* 1. Primitives - raw values, named for what they are */
  --blue-500: oklch(48% 0.09 250);
  --grey-50:  oklch(98% 0.005 250);
  --grey-900: oklch(22% 0.02 250);
  --space-1: 0.25rem;
  --space-4: 1rem;

  /* 2. Semantic - named for what they mean */
  --bg: var(--grey-50);
  --text: var(--grey-900);
  --accent: var(--blue-500);
  --surface: white;
  --border: oklch(90% 0.005 250);

  /* 3. Component - named for where they are used */
  --button-bg: var(--accent);
  --card-padding: var(--space-4);
}
```

Three layers, and the middle one is what makes dark mode a six-line change:

```css
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: var(--grey-900);
    --text: var(--grey-50);
    --surface: oklch(26% 0.02 250);
    --border: oklch(34% 0.02 250);
  }
}

:root[data-theme="dark"] {
  /* the same block again, for an explicit choice */
}
```

No component has a dark-mode rule. A card that says `background: var(--surface)` is correct in both themes and will be correct in the next one.

## Respecting the system and allowing a choice

The pattern above has three states and the order matters:

1. **No preference expressed** - follow the operating system, via the media query.
2. **The user chose dark** - `[data-theme="dark"]`, which applies regardless of the system.
3. **The user chose light** - `[data-theme="light"]`, which is why the media query is written as `:root:not([data-theme="light"])`. Without that `:not`, a user who explicitly chose light would still get dark from the media query at night.

Set the attribute before first paint, or the page flashes the wrong theme:

```html
<script>
  // Inline, in the head, before any stylesheet. Deliberately blocking.
  try {
    const saved = localStorage.getItem(''theme'');
    if (saved) document.documentElement.dataset.theme = saved;
  } catch {}
</script>
```

This is one of the few places a blocking inline script is correct: deferring it means the page paints in the wrong theme and then corrects itself, which is worse than a millisecond of delay.

## Scoping without a preprocessor

```css
.button {
  --bg: var(--accent);
  --fg: white;

  background: var(--bg);
  color: var(--fg);
}

.button.is-danger { --bg: var(--danger); }
.button.is-ghost  { --bg: transparent; --fg: var(--accent); }
```

The variant classes set properties rather than redeclaring `background` and `color`. One place reads them, so a new variant is two lines and cannot forget to set one of the pair.

## Deriving values, and the gotchas

```css
.thing {
  padding: calc(var(--space-4) * 2);
  width: calc(100% - var(--sidebar-width));
}
```

Two rules about `calc` with custom properties:

**A property holding a bare number cannot be a length on its own.** `--gap: 16` then `padding: var(--gap)` is invalid; `padding: calc(var(--gap) * 1px)` works. Store the unit in the value unless you specifically need the number.

**Whitespace in a custom property is preserved exactly.** `--x: 10px ;` with a space before the semicolon holds `10px ` including the space, which is fine on its own and breaks inside some `calc` expressions.

## Runtime values from JavaScript

```javascript
// A progress bar without writing width to the style attribute
bar.style.setProperty(''--progress'', percent + ''%'');
```

```css
.bar::after { width: var(--progress, 0%); }
```

The component still owns its CSS; the script supplies one number. The same pattern handles a mouse-follow highlight, a measured header height for `scroll-margin-top`, or a container width you cannot know in advance.

## What goes wrong

| Symptom | Cause |
|---|---|
| A typo produces an inherited value, not an error | Invalid at computed-value time |
| Custom property will not animate | Untyped - needs `@property` |
| Dark theme flashes on load | The theme attribute set after first paint |
| An explicit light choice is overridden at night | The media query missing `:not([data-theme="light"])` |
| `calc` fails with a custom property | A bare number with no unit |
| A component ignores a theme | It hard-codes a colour instead of reading a token |
| Variables not available in a media query condition | Custom properties cannot be used in `@media` conditions |

That last one catches people: `@media (min-width: var(--bp))` is not valid. Breakpoints have to be literal values, which is one of the few places you still need a preprocessor or a repeated constant.

## What to set up once

Three layers of tokens, defined on `:root`, with semantic names in the middle layer. Dark mode as a redefinition of the semantic layer and nothing else. The theme attribute set by a blocking inline script. Components that read tokens and never name a colour directly.

That is an afternoon at the start of a project, and after it every theme change, every rebrand and every new variant is an edit in one file.
',
   'A custom property is a real value in the cascade, not a build-time find-and-replace. It inherits, it can be changed on one subtree, and script can set it at runtime.', 6, 1216,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000024',
   'Positioning, Stacking and Overflow',
   'markdown',
   '# Positioning, Stacking and Overflow

Your dropdown is behind the header. You set `z-index: 9999` and nothing happened. The reason is always one of two things - a stacking context you did not know you created, or an ancestor with `overflow: hidden` clipping it - and both are invisible in the CSS of the element that is wrong.

## The five positioning values

```css
.a { position: static; }    /* the default. top/left do nothing. */
.b { position: relative; }  /* offset from where it would have been */
.c { position: absolute; }  /* removed from flow, placed in its containing block */
.d { position: fixed; }     /* removed from flow, placed in the viewport */
.e { position: sticky; }    /* in flow, until it reaches a threshold */
```

### relative

The element stays in the flow - the space it occupied is still reserved - and is drawn offset from there.

Its real job is usually not the offset at all but to become a **containing block** for an absolutely positioned child:

```css
.card { position: relative; }
.card .badge { position: absolute; top: .5rem; right: .5rem; }
```

### absolute

Removed from the flow entirely; nothing reserves space for it. It is positioned relative to its **nearest positioned ancestor** - the nearest ancestor with a `position` other than `static`.

If there is none, it falls back to the initial containing block, which is roughly the page - and a badge that was meant to sit on a card ends up in the top-right of the document. That is nearly always the bug: a missing `position: relative` on the parent.

```css
.overlay { position: absolute; inset: 0; }   /* top/right/bottom/left all 0 */
```

### fixed

Positioned relative to the viewport, so it does not move when the page scrolls.

With one large exception: if any ancestor has a `transform`, `filter`, `backdrop-filter`, `perspective`, `will-change` or `contain: paint`, that ancestor becomes the containing block instead, and `fixed` behaves like `absolute` within it. A fixed header inside a container with a transform on it scrolls away, and nothing in either rule suggests why.

### sticky

In the flow, scrolling normally, until it reaches the offset you gave it - then it stops and stays there while its parent scrolls past.

```css
.section-head { position: sticky; top: 0; }
```

Three things make sticky fail, and they account for essentially every report of "sticky does not work":

- **No offset.** `position: sticky` with no `top`, `bottom`, `left` or `right` never sticks. There is no threshold to reach.
- **An ancestor with `overflow: hidden`, `auto` or `scroll`.** The element sticks within that scroll container, which has usually already scrolled past.
- **The parent is not tall enough.** Sticky works within the parent''s box. If the parent is exactly the height of the sticky element, there is nowhere to stick.

## Stacking, which is where z-index goes wrong

Without any `z-index`, elements paint in a defined order: backgrounds, then non-positioned blocks, then floats, then inline content, then positioned elements in source order. Later in the source paints on top.

`z-index` changes that - but only **within a stacking context**.

### What creates a stacking context

A stacking context is a self-contained painting layer. Its children are painted entirely within it; one of them cannot be lifted out past a sibling of its parent, whatever its `z-index` is.

Common creators:

- `position` other than `static` **with** a `z-index` that is not `auto`
- `opacity` less than 1
- `transform`, `filter`, `backdrop-filter`, `perspective`
- `will-change` naming any of the above
- `isolation: isolate`
- `mix-blend-mode` other than `normal`
- a flex or grid **item** with a `z-index`
- `contain: paint` or `content`

That list is the whole explanation for `z-index: 9999` failing. Your dropdown has 9999 inside a card with `opacity: .99`; the card has no `z-index` and sits below the header; the dropdown cannot escape the card. 9999 is being compared against its siblings inside the card, where it already won.

### Reading the problem

```html
<header style="position: relative; z-index: 10">...</header>

<main style="transform: translateZ(0)">          <!-- creates a context -->
  <div class="dropdown" style="z-index: 9999">   <!-- trapped in it -->
```

`main` has no `z-index`, so it paints in source order - after the header, but as a single unit. Everything inside it, including the 9999, paints with it.

The fix is at the level of the context, not the element: give `main` a `z-index`, or remove the transform, or move the dropdown out of `main` - which is what a `<dialog>` or the top layer does for you.

### Keeping it manageable

```css
:root {
  --z-base: 0;
  --z-dropdown: 100;
  --z-sticky: 200;
  --z-overlay: 300;
  --z-modal: 400;
  --z-toast: 500;
}
```

Named steps, spaced apart, all in one place. The point is not the numbers but that they are comparable - and that nobody has to invent one.

`isolation: isolate` is the deliberate version: it creates a stacking context with no other side effect, so a component''s internal `z-index` values cannot leak out or be invaded.

```css
.card { isolation: isolate; }
```

### The top layer

```html
<dialog id="d">...</dialog>
```

```javascript
d.showModal();
```

A dialog opened with `showModal()` is painted in the **top layer**, above everything on the page, regardless of stacking contexts and z-index entirely. Popovers do the same. This is the genuine solution to the whole class of problem, and it is why modals should be dialogs rather than hand-built divs.

## Overflow, and what it quietly does

```css
.box {
  overflow: visible;  /* default - content spills */
  overflow: hidden;   /* clipped, no scrollbar */
  overflow: auto;     /* scrollbar only if needed */
  overflow: clip;     /* clipped, no scroll container */
  overflow-x: hidden; overflow-y: auto;   /* per axis */
}
```

Three consequences of `hidden`, `auto` and `scroll` that are not obvious:

- They create a **block formatting context**, which stops margins collapsing through.
- They create a **scroll container**, which is what breaks `position: sticky` on descendants.
- They clip absolutely positioned descendants, even ones positioned relative to something outside.

`overflow: clip` was added to give you the clipping without the scroll container, which is usually what "do not spill" actually means.

One asymmetry worth knowing: setting `overflow-x: hidden` and leaving `overflow-y: visible` does not work. The specification makes a `visible` value compute to `auto` when the other axis is not `visible`, so you get a vertical scrollbar you did not ask for. If you want horizontal clipping only, `overflow-x: clip` is the one that behaves.

## What goes wrong

| Symptom | Cause |
|---|---|
| Badge appears at the top of the page | Parent has no `position: relative` |
| `z-index: 9999` does nothing | Trapped in a stacking context |
| Fixed header scrolls away | An ancestor has a `transform` |
| Sticky element never sticks | No offset, or an ancestor scroll container |
| Dropdown clipped by its card | `overflow: hidden` on the card |
| Unwanted vertical scrollbar | `overflow-x: hidden` promoting the other axis |
| Modal behind the page content | A hand-built div instead of a `<dialog>` |

## How to find it in a minute

When something is behind something else: select it in the inspector and walk **up** the ancestors, looking for `opacity`, `transform`, `filter`, `will-change` or a `z-index`. The first ancestor with any of those is the context your element is trapped in, and that ancestor is where the fix goes.

When something is clipped: walk up looking for `overflow`. Same method, same answer - the problem is never in the CSS of the element that looks wrong.
',
   'Your dropdown is behind the header and z-index: 9999 did not help. The reason is always a stacking context you did not know you created, or an ancestor clipping it.', 6, 1275,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000025',
   'Transitions and Animation',
   'markdown',
   '# Transitions and Animation

Motion in an interface has one job: to explain what just happened. A panel that slides out from the button you pressed tells you where it came from. A row that fades as it is removed tells you it is gone rather than hidden. Motion that does not explain anything is decoration, and decoration costs frames.

CSS gives you two tools. A transition animates a change you made. An animation runs a sequence you declared. Knowing which one a problem wants is most of the skill.

## A transition animates a change

A transition does nothing on its own. It waits for a property to change, and then interpolates instead of jumping.

```css
.button {
  background: #0f766e;
  transform: translateY(0);
  transition: background 150ms ease, transform 150ms ease;
}
.button:hover { background: #115e59; }
.button:active { transform: translateY(1px); }
```

Four things make up a transition, and the shorthand takes them in this order: property, duration, timing function, delay. `transition: transform 200ms ease-out 50ms`.

Two rules about where to write it. Put the transition on the **base state**, not on `:hover` - otherwise the move in animates and the move out snaps back, because the rule carrying the transition no longer matches once the cursor leaves. And **name the properties** rather than writing `transition: all`. `all` means the browser watches every animatable property, which is both slower and a source of surprises when a later rule changes something you did not expect to move.

## An animation runs a sequence

When the motion is not a change between two states - a spinner, a pulse, a three-step entrance - you declare the sequence as keyframes.

```css
@keyframes pulse {
  from { opacity: 1; }
  50%  { opacity: 0.4; }
  to   { opacity: 1; }
}

.saving {
  animation: pulse 1.2s ease-in-out infinite;
}
```

`animation` takes name, duration, timing function, delay, iteration count, direction, fill mode and play state. In practice you write the first three or four and reach for the rest when you need them:

- **`animation-fill-mode: forwards`** keeps the final keyframe''s values after the animation ends. Without it the element snaps back to its unanimated state, which is almost never what an entrance animation wants.
- **`animation-direction: alternate`** runs every other iteration backwards, so a two-keyframe animation becomes a smooth there-and-back without you writing the return trip.
- **`animation-delay`** accepts negative values, which start the animation partway through. That is how you stagger a row of dots without three separate keyframe blocks.

## A complete worked example

A notification that slides in, can be dismissed, and respects the user''s motion preference.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Motion that explains</title>
    <style>
      *, *::before, *::after { box-sizing: border-box; }
      body {
        font: 16px/1.6 system-ui, sans-serif;
        margin: 0;
        padding: 2rem;
        background: #fbfbfd;
        color: #16181d;
      }

      @keyframes slide-in {
        from { opacity: 0; transform: translateX(1.5rem); }
        to   { opacity: 1; transform: translateX(0); }
      }

      .toast {
        display: flex;
        align-items: center;
        gap: 1rem;
        max-width: 26rem;
        padding: 1rem 1.25rem;
        margin-block-end: 0.75rem;
        background: #fff;
        border: 1px solid #e3e5ea;
        border-left: 3px solid #0f766e;
        border-radius: 8px;
        /* The entrance. forwards holds the end state. */
        animation: slide-in 220ms cubic-bezier(0.2, 0, 0, 1) forwards;
      }

      .toast p { margin: 0; flex: 1; }

      /* The exit is a state change, so it is a transition. The class
         is added by script, the element is removed on transitionend. */
      .toast.leaving {
        opacity: 0;
        transform: translateX(1.5rem);
        transition: opacity 180ms ease-in, transform 180ms ease-in;
      }

      .dismiss {
        border: 0;
        background: transparent;
        font: inherit;
        color: #5c626e;
        cursor: pointer;
        padding: 0.25rem 0.5rem;
        border-radius: 6px;
        transition: background 120ms ease, color 120ms ease;
      }
      .dismiss:hover { background: #f1f2f5; color: #16181d; }
      .dismiss:focus-visible { outline: 2px solid #0f766e; outline-offset: 2px; }

      /* Not optional. Some people get motion sickness from this. */
      @media (prefers-reduced-motion: reduce) {
        .toast, .toast.leaving, .dismiss {
          animation: none;
          transition: none;
        }
      }
    </style>
  </head>
  <body>
    <h1>Toasts</h1>
    <button id="add">Add a toast</button>

    <div id="stack" role="status" aria-live="polite"></div>

    <script>
      const stack = document.getElementById(''stack'');
      let n = 0;

      document.getElementById(''add'').addEventListener(''click'', () => {
        const toast = document.createElement(''div'');
        toast.className = ''toast'';
        toast.innerHTML = ''<p>Saved change number '' + (++n) + ''.</p>'' +
                          ''<button class="dismiss">Dismiss</button>'';
        stack.append(toast);
      });

      stack.addEventListener(''click'', (event) => {
        if (!event.target.closest(''.dismiss'')) return;
        const toast = event.target.closest(''.toast'');
        toast.classList.add(''leaving'');
        toast.addEventListener(''transitionend'', () => toast.remove(), { once: true });
      });
    </script>
  </body>
</html>
```

Notice the division of labour. The entrance is an animation, because there is no prior state to transition from - the element did not exist a moment ago. The exit is a transition, because it is a change from one state to another, and because `transitionend` gives us a reliable moment to remove the element from the document. Using an animation for the exit would mean listening for `animationend` and remembering `forwards`, which works but reads worse.

## The two properties that are cheap, and why

A browser renders in stages: it computes styles, works out geometry (layout), paints pixels, and composites the painted layers onto the screen. Animating a property determines how far back in that pipeline it has to start again, every frame.

- **`opacity` and `transform` are composited.** The layer is already painted; the compositor just draws it somewhere else or with different alpha. This can happen off the main thread, which is why these keep animating smoothly even while JavaScript is busy.
- **`width`, `height`, `top`, `left`, `margin` and `padding` force layout.** Changing one means recalculating the position of everything that depends on it, then repainting, then compositing - 60 times a second, on the main thread.

So `transform: translateX(20px)` and `left: 20px` look identical and cost nothing alike. Prefer the transform. For a position, animate `transform: translate()` rather than offsets; for a size, `transform: scale()` rather than width and height - accepting that scale stretches the content, which is fine for a backdrop and wrong for text.

The honest exception: `height` from 0 to `auto` has no transform equivalent. Modern CSS gives you `interpolate-size: allow-keywords` and `calc-size()` for this, and `grid-template-rows` from `0fr` to `1fr` works today in a grid wrapper. Both animate layout, so use them on one element at a time rather than on a list of thirty.

## Timing functions say what kind of thing moved

The default `ease` is fine and slightly characterless. The choice that matters is direction:

- **`ease-out`** starts fast and settles. Right for anything *entering* - it arrives promptly and comes to rest.
- **`ease-in`** starts slow and accelerates away. Right for anything *leaving*.
- **`linear`** has no acceleration. Right for a spinner or a progress bar, wrong for anything representing a physical object.
- **`cubic-bezier(0.2, 0, 0, 1)`** is a sharper ease-out: it moves decisively and lands softly. This is what most design systems mean by their standard easing.

Duration matters more than curve. Under 100ms reads as instant and the motion is wasted. Over about 400ms the interface feels slow and people start clicking again. Most interface motion belongs between 150ms and 250ms; a large element crossing a large distance can justify 300ms.

## Reduced motion is a requirement

`prefers-reduced-motion` is set by people for whom animation causes nausea or vertigo - a vestibular disorder is not a preference about taste. Honour it on every page, every time.

The right response is usually not "no feedback at all" but "no movement": keep an opacity fade, drop the slide and the scale. A `transition: none` block, as in the example above, is the blunt version and is always acceptable. What is not acceptable is leaving it out.

## When it goes wrong

| Symptom | Cause |
|---|---|
| It animates in but snaps out | The transition is on `:hover`, not on the base state |
| Nothing animates at all | The property is not animatable, or both ends are `auto` |
| An entrance animation reverts when it ends | `animation-fill-mode: forwards` is missing |
| Motion stutters while the page is busy | Animating layout properties instead of `transform` and `opacity` |
| `transitionend` fires several times | Several properties are transitioning; check `event.propertyName` |
| `transitionend` never fires | The value did not actually change, or the element was removed first |
| A `display: none` element will not fade in | It has no starting value to transition from; use `@starting-style` or a frame''s delay |
| It is smooth on your laptop and awful on a phone | Too many animated elements, or a layout property on a long list |

## A check you can run

Open DevTools, find the rendering panel, and turn on "Paint flashing" and the frame-rate meter. Then trigger your animation.

A transform or opacity animation should flash green once at the start and then stay quiet, holding a steady frame rate. A width or top animation repaints a region every single frame - you will see it flashing continuously, and on a mid-range phone you will see the frame rate fall with it. That difference, visible in a few seconds, is the whole argument for the two cheap properties.

Then set your operating system to reduce motion and reload. If anything still slides, you have a bug that affects real people.
',
   'Two properties are cheap to animate. Everything else makes the browser redo work on every frame, and at 60fps you have about 16 milliseconds to spend.', 8, 1530,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
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
  ('e0000001-0000-4000-8000-000000000026',
   'Cascade Layers and Specificity Control',
   'markdown',
   '# Cascade Layers and Specificity Control

Specificity wars end the same way every time: somebody adds a selector, then somebody adds another, then somebody writes `!important` and the file is now unmaintainable. Cascade layers remove the argument by making stylesheet order something you declare rather than something that emerges from the order files happen to load in.

## The problem, precisely

```css
/* components.css - written carefully */
.button { background: blue; }

/* some-library.css - loaded after, and you do not control it */
.lib .btn.btn-primary { background: red; }
```

Your rule is `0-1-0`. Theirs is `0-3-0`. Theirs wins, and your options are all bad: raise your specificity to match, add `!important`, or wrap everything in an extra class and raise it everywhere.

Each of those makes the next conflict worse, because you have raised the floor.

## Layers decide before specificity does

```css
@layer reset, base, components, utilities;

@layer components {
  .button { background: blue; }         /* 0-1-0 */
}

@layer base {
  .lib .btn.btn-primary { background: red; }   /* 0-3-0 */
}
```

The blue wins. `components` is declared after `base`, and **layer order beats specificity entirely**.

That first line is the important one: it declares the order up front, before any of the layers have content. After that it does not matter what order the files load in, which is what makes this robust - a build step that reorders imports, or a third-party stylesheet that arrives late, no longer changes anything.

## The full cascade order, revised

With layers, the order a browser works through is:

1. Origin and importance
2. **Layer order** - later layers win
3. Specificity
4. Source order

And one rule that catches everybody: **unlayered styles beat every layer.**

```css
@layer everything {
  .button { background: blue; }   /* 0-1-0, in a layer */
}

.button { background: red; }      /* 0-1-0, not in a layer - wins */
```

This is deliberate. It means you can adopt layers incrementally: put the library in a layer, leave your own styles unlayered, and yours win without any specificity changes at all. It also means a stray unlayered rule will quietly override a carefully ordered system, so a codebase that uses layers should use them for everything.

### Importance inverts the order

```css
@layer a, b;
@layer a { .x { color: red !important; } }
@layer b { .x { color: blue !important; } }
```

Red wins. For `!important` declarations the layer order is **reversed** - the earliest layer wins. The reasoning is that a reset layer''s emergency override should not be beatable by a utility layer''s emergency override, and the same inversion is what lets a user stylesheet beat an author one.

The practical advice is unchanged: in a layered system you should almost never need `!important`.

## A layer order that works

```css
@layer reset, base, layout, components, utilities, overrides;
```

- **reset** - normalisation. Lowest, so anything can beat it.
- **base** - element defaults: typography, links, form controls.
- **layout** - page-level structure.
- **components** - buttons, cards, the rail.
- **utilities** - single-purpose classes. Above components deliberately, so `.mt-0` wins against a component''s margin without `!important`.
- **overrides** - page-specific exceptions, rare and visible.

A third-party stylesheet goes near the bottom:

```css
@layer reset, vendor, base, components, utilities;

@import url("bootstrap.css") layer(vendor);
```

`@import` with `layer()` puts a file you do not control into a layer you do, and now your components beat it regardless of how its selectors are written. This one line replaces an entire category of workaround.

## Anonymous and nested layers

```css
@layer {                        /* anonymous - cannot be added to later */
  .one-off { color: red; }
}

@layer components {
  @layer buttons, cards;        /* nested, ordered within components */

  @layer buttons { .button { } }
  @layer cards   { .card { } }
}
```

Nested layers are addressed as `components.buttons`. Useful in a large system; unnecessary in a small one.

## :where() and :is(), the other half of specificity control

```css
:where(.a, .b) { }    /* always 0-0-0 */
:is(.a, #b) { }       /* takes the HIGHEST of its arguments: 1-0-0 */
```

`:where()` contributes **nothing** to specificity, which makes it the right tool for anything that should be easy to override:

```css
/* A reset that loses every argument, by design */
:where(h1, h2, h3, h4) { margin-block: 0 0.5em; }
:where(ul, ol) { padding-inline-start: 1.5em; }
:where(a) { color: var(--accent); }
```

A single class beats any of those, with no layer involved.

`:is()` is for grouping without repetition, and its specificity surprises people:

```css
/* 1-0-0 - the #sidebar lifts the whole thing */
:is(#sidebar, .main) a { }

/* 0-1-0 - :where neutralises it */
:where(#sidebar, .main) a { }
```

Both also change how a selector list fails. In a plain comma list, one unsupported selector invalidates the **whole rule**; inside `:is()` or `:where()`, an unknown selector is simply ignored and the rest still match. That makes them useful for forward compatibility.

## @scope, for styles that stop

```css
@scope (.card) to (.card-body) {
  p { color: grey; }     /* paragraphs in the card, but not in the body */
}
```

`@scope` sets a root and an optional lower boundary. Styles apply between them. The lower boundary is the genuinely new part - a "donut" of styles that stops at a nested region, which previously needed either `:not()` gymnastics or a different class on everything.

It also changes how proximity is resolved: when two scoped rules match, the one whose scope root is **closer** to the element wins, before specificity is considered. That is what makes nested components behave the way people expect:

```css
@scope (.theme-dark) { a { color: white; } }
@scope (.theme-light) { a { color: black; } }
```

A link inside a light panel inside a dark page gets black, because `.theme-light` is nearer. No specificity arithmetic involved.

Support is newer than layers, so treat it as an enhancement for now rather than the foundation.

## Putting it together

```css
@layer reset, base, components, utilities;

@layer reset {
  :where(*, *::before, *::after) { box-sizing: border-box; }
  :where(body) { margin: 0; }
  :where(img, svg, video) { display: block; max-width: 100%; }
}

@layer base {
  :where(h1, h2, h3) { line-height: 1.2; text-wrap: balance; }
  :where(p) { max-width: 70ch; }
}

@layer components {
  .button { background: var(--accent); padding: .6rem 1rem; }
  .card { background: var(--surface); border-radius: .5rem; }
}

@layer utilities {
  .mt-0 { margin-block-start: 0; }
  .visually-hidden { position: absolute; width: 1px; height: 1px; overflow: hidden; }
}
```

Every selector is one class or less. There is no `!important` anywhere. A utility beats a component because of where it sits, not because of how it is written. And a new rule cannot start an escalation, because there is nothing to escalate against.

## A page you can run

Four layers, a utility that wins without `!important`, and a third-party widget quarantined underneath everything.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Layers, in order</title>
    <style>
      /* The order is declared once, before anything is written into the
         layers. After this line the order is fixed, and where each rule
         is physically written stops mattering. */
      @layer reset, vendor, base, components, utilities;

      @layer reset {
        *, *::before, *::after { box-sizing: border-box; margin: 0; }
      }

      @layer vendor {
        /* Pretend this came from a widget''s own stylesheet. It is as
           specific as a vendor stylesheet usually is - and it loses
           anyway, because its layer is early. */
        #widget .widget-button.widget-button-primary {
          background: #7c3aed;
          border-radius: 0;
          font-family: Georgia, serif;
        }
      }

      @layer base {
        body {
          font: 16px/1.6 system-ui, sans-serif;
          padding: 2rem;
          background: #fbfbfd;
          color: #16181d;
        }
        h1 { font-size: 1.5rem; margin-block-end: 1rem; }
        p { margin-block-end: 1rem; max-width: 60ch; }
      }

      @layer components {
        /* One class. No ID, no !important, no chain of parents - the
           layer is doing the work that specificity used to be asked to
           do. */
        .button {
          font: inherit;
          padding: 0.5rem 0.9rem;
          border: 1px solid #0f766e;
          border-radius: 8px;
          background: #0f766e;
          color: #fff;
          cursor: pointer;
        }
        .button:focus-visible { outline: 2px solid #16181d; outline-offset: 2px; }

        /* :where() takes the specificity to zero, so a card can set
           its own heading size without a fight. */
        .card :where(h2) { font-size: 1.05rem; margin-block-end: 0.25rem; }

        .card {
          background: #fff;
          border: 1px solid #e3e5ea;
          border-radius: 10px;
          padding: 1rem 1.25rem;
          margin-block-end: 1rem;
          max-width: 30rem;
        }
      }

      @layer utilities {
        /* Last layer, so it wins over components - which is exactly
           what a utility is for, and the reason none of these need
           !important. */
        .mt-0 { margin-block-start: 0; }
        .quiet { color: #5c626e; }
        .full { width: 100%; }
      }

      /* Outside every layer. Unlayered styles beat all layers, which is
         the right place for a one-off page override - and the wrong
         place for anything you intend to reuse. */
      .page-note { border-inline-start: 3px solid #0f766e; padding-inline-start: 0.75rem; }
    </style>
  </head>
  <body>
    <h1>The order is the stylesheet</h1>

    <p class="page-note">
      The vendor rule below uses an ID and two classes. The component rule
      uses one class. The component rule wins, because its layer comes later -
      specificity is only consulted within a layer.
    </p>

    <div class="card" id="widget">
      <h2>A quarantined widget</h2>
      <p class="quiet">
        Teal, square-cornered, and in the page font - none of which the
        vendor stylesheet asked for.
      </p>
      <button type="button" class="button widget-button widget-button-primary full">
        Still ours
      </button>
    </div>

    <div class="card">
      <h2>A plain card</h2>
      <p class="quiet mt-0">The utility class wins over the component margin.</p>
      <button type="button" class="button">Also ours</button>
    </div>
  </body>
</html>
```

Open DevTools and inspect the button inside the widget card. You will see the vendor declarations struck through under the component ones, with the layer names shown beside them. That is the whole argument: an ID selector lost to a single class, predictably, and nobody wrote `!important` to make it happen.

Then move the `@layer` declaration line so `vendor` comes last, and reload. The button turns purple and square. The order of that one line is now the contract your stylesheet runs on - which is why it belongs at the top, written once, where a reviewer can see it.

## What goes wrong

| Symptom | Cause |
|---|---|
| A layered rule loses to a plain one | Unlayered styles beat every layer |
| Layer order seems ignored | The order was never declared, so it followed first appearance |
| `!important` in an early layer beats a later one | Importance inverts the order - working as designed |
| `:is()` raised the specificity unexpectedly | It takes the highest of its arguments |
| A whole rule stopped matching | One unsupported selector in a plain comma list |
| Scoped styles leak into a nested component | No lower boundary on `@scope` |

## The habit

Declare the layer order in one line, at the top, in one file. Write resets with `:where()`. Import third-party CSS into a low layer. Keep every selector to one class.

Do that and specificity stops being something you think about - which is the actual goal. The best outcome of this lesson is never needing most of it.
',
   'Specificity wars end the same way every time, with someone writing !important. Cascade layers remove the argument entirely, because layer order beats specificity outright.', 9, 1869,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000027',
   'Container Queries',
   'markdown',
   '# Container Queries

A media query asks how wide the window is. A component does not care about the window - it cares how much room **it** has been given. The same card in a 20rem sidebar and in a 60rem main column wants two different layouts, and until container queries there was no way for it to ask.

## The problem media queries cannot solve

```css
.card { display: block; }

@media (min-width: 60rem) {
  .card { display: grid; grid-template-columns: 8rem 1fr; }
}
```

This says: on a wide **screen**, lay cards out horizontally. But on that wide screen the same card might be in a narrow sidebar, where the horizontal layout is cramped and wrong.

The usual workaround was a modifier class - `.card--compact` - set by whoever placed the card. That works and it means the component is no longer self-contained: every place that uses it has to know which variant to ask for, and a layout change means revisiting all of them.

## Asking about the container instead

```css
.sidebar, .main {
  container-type: inline-size;
}

.card { display: block; }

@container (min-width: 30rem) {
  .card { display: grid; grid-template-columns: 8rem 1fr; gap: 1rem; }
}
```

Now the card asks about its own container. Put it in a 20rem sidebar and it stacks; put the identical markup in a 60rem column and it goes horizontal. Nothing outside the component knows anything.

Two parts:

**`container-type` on the ancestor** declares it as something that can be queried. `inline-size` means "query the width" and is what you want almost always. `size` means width and height, and requires the container to have a fixed size in both directions. `normal` is the default - queryable for style queries only.

**`@container` on the descendant** is the query itself.

## Naming containers

With several nested containers, the query matches the **nearest** ancestor that is a container. Naming lets you be explicit:

```css
.layout { container-type: inline-size; container-name: layout; }
.card   { container-type: inline-size; container-name: card; }

@container card (min-width: 30rem) { .card-title { font-size: 1.4rem; } }
@container layout (min-width: 60rem) { .card { grid-column: span 2; } }
```

The shorthand sets both:

```css
.sidebar { container: sidebar / inline-size; }
```

## Container query units

Inside a container query you get units relative to the container rather than the viewport:

| Unit | Meaning |
|---|---|
| `cqw` | 1% of the container''s width |
| `cqh` | 1% of its height |
| `cqi` | 1% of its inline size |
| `cqb` | 1% of its block size |
| `cqmin` | the smaller of `cqi` and `cqb` |
| `cqmax` | the larger |

```css
.card-title {
  font-size: clamp(1rem, 4cqi, 1.75rem);
}
```

That heading scales with the card, not the window - so one component is legible at every size it is ever placed in, with one declaration and no breakpoints.

## The containment cost

`container-type: inline-size` applies **size containment in the inline direction**, which means the container''s width no longer depends on its contents. That is what makes the query possible - the browser must know the container''s size before laying out its children, or it would be circular.

Two consequences:

- **A container cannot be sized by its content in that axis.** A `container-type: inline-size` element with `width: fit-content` will not do what you expect.
- **`container-type: size`** applies containment in both directions, so the element collapses to zero height unless you give it one. This is the reason most people reach for `size`, get a collapsed layout, and conclude container queries are broken.

Use `inline-size` unless you have a specific reason not to, which is almost never.

## Style queries

```css
.panel { container-name: panel; }

@container panel style(--tone: warning) {
  .icon { color: var(--warning); }
}
```

A style query matches on a custom property''s value rather than a size. It lets a parent set a mode as a property and descendants respond, without a class on each one.

Support is newer than size queries and currently limited to custom properties, so treat it as an enhancement.

## A worked example

```html
<article class="card">
  <img src="..." alt="" width="320" height="180">
  <div class="card-body">
    <h3>Grid: Rows and Columns Together</h3>
    <p>Named areas, fractional units, and the layout you used to need a framework for.</p>
    <a href="...">Read the lesson</a>
  </div>
</article>
```

```css
/* Any of these may hold a card. Each is a container. */
.sidebar, .main, .grid > * { container-type: inline-size; }

/* The default: narrow. Stacked. */
.card { display: grid; gap: .75rem; }
.card img { width: 100%; border-radius: .5rem; }
.card h3 { font-size: 1.05rem; }

/* Roomier: image beside the text. */
@container (min-width: 26rem) {
  .card { grid-template-columns: 10rem 1fr; align-items: start; }
  .card h3 { font-size: 1.2rem; }
}

/* Roomier still: a bigger image and a looser rhythm. */
@container (min-width: 44rem) {
  .card { grid-template-columns: 16rem 1fr; gap: 1.5rem; }
  .card h3 { font-size: 1.5rem; }
  .card p { font-size: 1.05rem; }
}
```

One component, three layouts, and the page it sits on does not know about any of them. Drop it in a sidebar, a two-column grid or a full-width section and it is right in each.

## When a media query is still correct

Container queries do not replace media queries. They answer a different question.

**Media queries** are for the page and for the device: the overall page skeleton, the number of columns in the main grid, whether the navigation is a bar or a drawer, print styles, `prefers-reduced-motion`, `prefers-color-scheme`.

**Container queries** are for components: how a card, a form field, a media object or a table arranges itself in the space it was given.

The usual architecture is a media query deciding the page layout, and container queries inside every component.

## Progressive enhancement

```css
.card { display: grid; gap: .75rem; }    /* works everywhere */

@supports (container-type: inline-size) {
  .wrapper { container-type: inline-size; }

  @container (min-width: 26rem) {
    .card { grid-template-columns: 10rem 1fr; }
  }
}
```

The stacked layout is the base and is never wrong. Browsers that support containers get the enhancement. Writing it this way round means an old browser gets a simple correct layout rather than a broken clever one.

## What goes wrong

| Symptom | Cause |
|---|---|
| The query never matches | No ancestor has `container-type` |
| An element collapses to nothing | `container-type: size` with no height |
| A container ignores `fit-content` | Size containment - that is the trade |
| The wrong container matched | Nearest ancestor wins - use `container-name` |
| An element cannot query itself | A container queries its descendants, not itself |

That last one is the commonest misunderstanding. `container-type` on `.card` does not let `.card` respond to its own width - it lets `.card`''s children respond to it. The card needs a wrapper, or the parent needs to be the container.

## Why this matters more than it sounds

Before container queries, a component''s appearance depended on something it could not see. That is the definition of a leaky abstraction, and it is why design systems accumulated variant classes that nobody could keep track of.

With them, a component is genuinely self-contained: it takes the space it is given and arranges itself. You can move it anywhere without touching it, and that is the thing that has been missing from CSS since components became the way people build.
',
   'A media query asks how wide the window is. A component cares how much room it has been given. The same card in a sidebar and in a main column wants two different layouts.', 6, 1247,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY)),

  ('e0000001-0000-4000-8000-000000000028',
   'CSS That Renders Fast',
   'markdown',
   '# CSS That Renders Fast

CSS performance is not about writing shorter selectors. Selector matching has been fast for a decade. What costs real time is the amount of *work a change forces the browser to redo*, and how much of the page that work touches.

Understanding the pipeline is the whole lesson. Everything else follows from it.

## The pipeline, stage by stage

When something changes, the browser runs some suffix of this sequence:

1. **Style** - work out which declarations apply to which elements and compute the final value of every property.
2. **Layout** - work out the size and position of every box. Also called reflow.
3. **Paint** - fill in pixels: text, colours, borders, shadows, images. Into layers, not directly to the screen.
4. **Composite** - assemble the painted layers into the final frame.

The further back a change starts, the cheaper it is. Change `color` and you skip layout: style, paint, composite. Change `transform` and you skip layout *and* paint: the layer already exists, so only compositing runs - and compositing can happen on a separate thread, which is why transforms stay smooth while JavaScript is blocking.

Change `width` and all four stages run, for the element and for everything whose position depends on it. That is the expensive case, and in a deep document "everything that depends on it" can be the rest of the page.

```css
/* composite only - cheapest */
.a { transform: translateX(10px); }
.b { opacity: 0.5; }

/* paint and composite */
.c { background: #eee; }
.d { box-shadow: 0 2px 8px rgb(0 0 0 / 0.2); }

/* style, layout, paint and composite - most expensive */
.e { width: 300px; }
.f { padding: 2rem; }
.g { font-size: 1.25rem; }
```

This does not mean never change a width. It means know that you did, and do not do it sixty times a second.

## Layout thrashing: the bug this knowledge prevents

The commonest real performance bug in a web application is not slow CSS. It is JavaScript interleaving reads and writes of layout.

```javascript
// Bad: forces a synchronous layout on every iteration.
for (const card of cards) {
  card.style.height = card.offsetHeight + 10 + ''px'';
}
```

Reading `offsetHeight` requires an up-to-date layout. Writing `style.height` invalidates it. Alternating the two means the browser must recompute layout on every pass through the loop, synchronously, blocking everything. With 200 cards that is 200 layouts where one would have done.

The fix is to batch: read everything, then write everything.

```javascript
// Good: one layout for all the reads, one for all the writes.
const heights = cards.map((card) => card.offsetHeight);
cards.forEach((card, i) => {
  card.style.height = heights[i] + 10 + ''px'';
});
```

The properties that force a synchronous layout when read are worth recognising: `offsetTop`, `offsetLeft`, `offsetWidth`, `offsetHeight`, `scrollTop`, `scrollWidth`, `clientWidth`, `clientHeight`, `getComputedStyle()` and `getBoundingClientRect()`. Reading any of them after a write is the pattern to look for.

## Containment: telling the browser what cannot escape

`contain` is a promise you make about an element, and the browser spends the promise on doing less work.

```css
.card {
  contain: layout paint;
}
```

- **`contain: layout`** promises that nothing inside affects the layout of anything outside. The browser can then lay out the card''s contents without reconsidering the rest of the page.
- **`contain: paint`** promises that nothing inside paints outside the element''s bounds. Descendants are clipped, and an off-screen card need not be painted at all.
- **`contain: size`** promises that the element''s size does not depend on its contents - which means you must give it a size, or it collapses. This is the one that bites.
- **`contain: content`** is shorthand for `layout paint style`. A good default for a repeated, self-contained component.

The payoff is largest exactly where it matters: a long list of cards, a feed, a table of rows. Without containment, a change inside row 400 may invalidate layout for the whole list. With it, the invalidation stops at the row''s boundary.

```css
/* A feed of hundreds of items. */
.feed-item {
  contain: content;
  /* Skip rendering work entirely while off screen, but keep the
     scrollbar honest by telling the browser roughly how big it is. */
  content-visibility: auto;
  contain-intrinsic-size: auto 8rem;
}
```

`content-visibility: auto` is containment taken to its conclusion: an off-screen element is not styled, laid out or painted at all until it approaches the viewport. On a long page this can turn a one-second first render into a fast one. `contain-intrinsic-size` supplies a placeholder size so the scrollbar does not jump as items render - leave it out and scrolling becomes unpleasant.

## A worked measurement

Here is a page that makes the difference visible rather than theoretical.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Measuring layout cost</title>
    <style>
      body { font: 16px/1.6 system-ui, sans-serif; margin: 0; padding: 2rem; }
      .feed { display: grid; gap: 0.5rem; max-width: 40rem; }
      .item {
        padding: 1rem;
        border: 1px solid #e3e5ea;
        border-radius: 8px;
        background: #fff;
      }
      /* Toggle this class on the feed to see the difference. */
      .contained .item {
        contain: content;
        content-visibility: auto;
        contain-intrinsic-size: auto 5rem;
      }
      output { display: block; margin-block: 1rem; font-variant-numeric: tabular-nums; }
    </style>
  </head>
  <body>
    <h1>Layout cost, measured</h1>
    <button id="thrash">Read and write alternately</button>
    <button id="batch">Read all, then write all</button>
    <button id="toggle">Toggle containment</button>
    <output id="result">Press a button.</output>

    <div class="feed" id="feed"></div>

    <script>
      const feed = document.getElementById(''feed'');
      const result = document.getElementById(''result'');

      for (let i = 0; i < 500; i++) {
        const item = document.createElement(''div'');
        item.className = ''item'';
        item.textContent = ''Item '' + (i + 1) + '' - some text to give it height.'';
        feed.append(item);
      }

      const items = [...feed.children];

      function time(label, work) {
        const start = performance.now();
        work();
        result.textContent = label + '': '' + (performance.now() - start).toFixed(1) + ''ms'';
      }

      document.getElementById(''thrash'').addEventListener(''click'', () => {
        time(''interleaved'', () => {
          for (const item of items) {
            item.style.minHeight = item.offsetHeight + 1 + ''px'';
          }
        });
      });

      document.getElementById(''batch'').addEventListener(''click'', () => {
        time(''batched'', () => {
          const heights = items.map((item) => item.offsetHeight);
          items.forEach((item, i) => { item.style.minHeight = heights[i] + 1 + ''px''; });
        });
      });

      document.getElementById(''toggle'').addEventListener(''click'', () => {
        feed.classList.toggle(''contained'');
        result.textContent = ''containment '' +
          (feed.classList.contains(''contained'') ? ''on'' : ''off'');
      });
    </script>
  </body>
</html>
```

Press the two buttons in turn. On a typical laptop the interleaved version takes tens of milliseconds and the batched version takes a few - the same work, one or two orders of magnitude apart. Then turn containment on and press them again.

## What actually makes a stylesheet slow to load

Rendering cost is one half. The other is getting the CSS to the browser at all, because **CSS blocks rendering by design**: the browser will not paint until it knows what things look like, to avoid showing you unstyled content.

- **Keep the critical stylesheet small.** Everything in it delays first paint. One hundred kilobytes of CSS of which the home page uses four is four kilobytes of value and a hundred of delay.
- **`@import` inside CSS is the worst case.** The browser must download and parse the first file before it discovers the second. Two round trips in series. Use several `<link>` elements, which fetch in parallel, or bundle at build time.
- **Media-qualify what is conditional.** `<link rel="stylesheet" href="print.css" media="print">` is downloaded but does not block rendering.
- **Watch web fonts.** `font-display: swap` shows text in a fallback immediately rather than leaving a blank space; `size-adjust` on the fallback reduces how much the page shifts when the real font arrives.
- **Reserve space for images.** `width` and `height` attributes, or `aspect-ratio`, stop the content below jumping once the image loads. Layout shift is a performance problem people can feel, even when the numbers look fine.

## The selectors that are worth thinking about

Selector performance is mostly a non-issue, with two exceptions worth knowing.

The first is **descendant selectors on frequently-invalidated subtrees**. A browser matches selectors right to left, so `.sidebar div p span` starts from every span on the page and walks up. That is still fast in isolation, but it is re-evaluated whenever the subtree changes.

The second is **the universal selector in a descendant position**, as in `.wrapper * { ... }`, which does genuinely more work than a class.

Neither will be your bottleneck. Measure before you refactor selectors; measure again before you believe the refactor helped.

## When it goes wrong

| Symptom | Cause |
|---|---|
| Scrolling janks on a long list | No containment, or shadows and filters repainting per frame |
| An interaction takes 300ms with no network call | Interleaved layout reads and writes in script |
| Animation is smooth in isolation, awful in the page | Animating layout properties while the main thread is busy |
| An element with `contain: size` has collapsed | Size containment with no explicit size given |
| The scrollbar jumps while scrolling | `content-visibility: auto` with no `contain-intrinsic-size` |
| First paint is late on a fast connection | `@import` chains, or one large blocking stylesheet |
| Content jumps as the page loads | Images with no dimensions, or a web font with no `size-adjust` |
| DevTools shows long purple bars | Style and layout recalculation - look at what invalidated them |

## A check you can run

Open DevTools, go to the Performance panel, start recording, interact with your page, and stop. Then read the flame chart for one frame.

You are looking for three things. **Purple** is style and layout; a lot of it means something is invalidating geometry. **Green** is paint and composite; a lot of it means something expensive is being repainted. And the **frame boundaries**: at 60Hz you have 16.7ms per frame, and anything longer is a dropped frame the user may feel.

Record the same interaction with CPU throttling set to 4x slower. That approximates a mid-range phone, which is what most of your users have. A page that holds 60fps throttled is genuinely fast; one that only holds it on your laptop has not been tested yet.
',
   'CSS is not usually the bottleneck, and when it is, it is dramatic. Every stuttering scroll and every 300ms style recalculation has a cause you can name.', 8, 1688,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY))
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
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000005');
CALL search_reindex_all_quiet();
