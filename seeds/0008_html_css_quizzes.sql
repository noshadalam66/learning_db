-- ===========================================================================
-- Seed 08 : quizzes for the HTML and CSS courses
--
-- One quiz per level, eight in total, each attached to a lesson of kind
-- 'quiz' sitting at position 4 - the end of its module. That placement is
-- what makes the quiz appear in the curriculum on the course page rather
-- than only as a link from somewhere.
--
-- Question prompts quote real markup and real declarations. The front end
-- escapes every prompt on output, so a prompt containing <div> reaches the
-- page as the four characters a learner needs to read rather than as an
-- element - and the quiz page carries its own scratchpad compiler, so the
-- answer can be tested rather than guessed.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- The eight quiz lessons, one at the end of each level.
-- ---------------------------------------------------------------------------
INSERT INTO catalog.lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- HTML course
  ('e0000001-0000-4000-8000-000000000029', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-level-1-check', 'Level 1 Check: The Basics',
   'Five questions on the document skeleton, text elements, links and images.',
   'quiz', 'published', 4, 420, 1),
  ('e0000001-0000-4000-8000-00000000002a', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'html-level-2-check', 'Level 2 Check: Tables, Forms and Media',
   'Five questions on scoped headers, native validation and responsive images.',
   'quiz', 'published', 4, 480, 0),
  ('e0000001-0000-4000-8000-00000000002b', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-level-3-check', 'Level 3 Check: Semantics and Accessibility',
   'Five questions on landmarks, accessible components and head metadata.',
   'quiz', 'published', 4, 480, 0),
  ('e0000001-0000-4000-8000-00000000002c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-expert-exam', 'Expert Exam: HTML',
   'Templates, custom elements, loading performance and progressive enhancement.',
   'quiz', 'published', 4, 900, 0),

  -- CSS course
  ('e0000001-0000-4000-8000-00000000002d', 'd0000001-0000-4000-8000-00000000000c', 'c0000001-0000-4000-8000-000000000005',
   'css-level-1-check', 'Level 1 Check: Cascade, Box and Units',
   'Five questions on specificity, box-sizing and choosing a unit.',
   'quiz', 'published', 4, 420, 1),
  ('e0000001-0000-4000-8000-00000000002e', 'd0000001-0000-4000-8000-00000000000d', 'c0000001-0000-4000-8000-000000000005',
   'css-level-2-check', 'Level 2 Check: Flexbox and Grid',
   'Five questions on flex shorthand, track sizing and intrinsic responsiveness.',
   'quiz', 'published', 4, 480, 0),
  ('e0000001-0000-4000-8000-00000000002f', 'd0000001-0000-4000-8000-00000000000e', 'c0000001-0000-4000-8000-000000000005',
   'css-level-3-check', 'Level 3 Check: Theming, Stacking and Motion',
   'Five questions on custom properties, stacking contexts and animation cost.',
   'quiz', 'published', 4, 540, 0),
  ('e0000001-0000-4000-8000-000000000030', 'd0000001-0000-4000-8000-00000000000f', 'c0000001-0000-4000-8000-000000000005',
   'css-expert-exam', 'Expert Exam: CSS',
   'Cascade layers, container queries and the render pipeline.',
   'quiz', 'published', 4, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

-- ---------------------------------------------------------------------------
-- The quizzes.
--
-- show_answers is on for every one: the explanation is where the learning
-- happens, and hiding it turns a wrong answer into a dead end.
-- ---------------------------------------------------------------------------
INSERT INTO assessment.quizzes
  (id, course_id, lesson_id, title, description, pass_percent, time_limit_seconds,
   max_attempts, shuffle_questions, shuffle_options, show_answers, status)
VALUES
  ('f0000001-0000-4000-8000-000000000004',
   'c0000001-0000-4000-8000-000000000004', 'e0000001-0000-4000-8000-000000000029',
   'Level 1 Check: The Basics',
   'Five questions on the document skeleton, the text elements and the three attributes people leave off. Use the scratchpad below the questions to try anything you are unsure of.',
   60, 600, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000005',
   'c0000001-0000-4000-8000-000000000004', 'e0000001-0000-4000-8000-00000000002a',
   'Level 2 Check: Tables, Forms and Media',
   'Scoped table headers, native form validation, and picking the right image element. Every answer here is something you can verify in the scratchpad.',
   60, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000006',
   'c0000001-0000-4000-8000-000000000004', 'e0000001-0000-4000-8000-00000000002b',
   'Level 3 Check: Semantics and Accessibility',
   'Landmarks, accessible components built on native elements, and the metadata that decides how a page is shared.',
   70, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000007',
   'c0000001-0000-4000-8000-000000000004', 'e0000001-0000-4000-8000-00000000002c',
   'Expert Exam: HTML',
   'Templates and custom elements, loading attributes, and building a feature that still works when the script does not.',
   70, 1500, 3, 1, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000008',
   'c0000001-0000-4000-8000-000000000005', 'e0000001-0000-4000-8000-00000000002d',
   'Level 1 Check: Cascade, Box and Units',
   'Which rule wins, how a box is measured, and which unit to reach for. The scratchpad is the fastest way to settle a specificity argument.',
   60, 600, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000009',
   'c0000001-0000-4000-8000-000000000005', 'e0000001-0000-4000-8000-00000000002e',
   'Level 2 Check: Flexbox and Grid',
   'The flex shorthand, track sizing, and the functions that replace a stack of media queries.',
   60, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-00000000000a',
   'c0000001-0000-4000-8000-000000000005', 'e0000001-0000-4000-8000-00000000002f',
   'Level 3 Check: Theming, Stacking and Motion',
   'Custom properties, the things that create a stacking context, and which properties are cheap to animate.',
   70, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-00000000000b',
   'c0000001-0000-4000-8000-000000000005', 'e0000001-0000-4000-8000-000000000030',
   'Expert Exam: CSS',
   'Cascade layers, container queries and the four stages of the render pipeline.',
   70, 1500, 3, 1, 1, 1, 'published')
ON DUPLICATE KEY UPDATE
  title = VALUES(title), description = VALUES(description),
  pass_percent = VALUES(pass_percent), status = VALUES(status);

-- ---------------------------------------------------------------------------
-- Questions: HTML course
-- ---------------------------------------------------------------------------
INSERT INTO assessment.questions
  (id, quiz_id, kind, prompt, explanation, points, `position`, correct_text)
VALUES
  -- HTML Level 1
  ('a1000001-0000-4000-8000-000000000101', 'f0000001-0000-4000-8000-000000000004', 'single_choice',
   'What does omitting <!DOCTYPE html> from a page actually do?',
   'It switches the browser into quirks mode, which emulates pre-standards behaviour: box sizing and line heights change, so the layout is subtly wrong everywhere at once. The page still renders, which is exactly why the cause is hard to find.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000102', 'f0000001-0000-4000-8000-000000000004', 'single_choice',
   'Why must <meta charset="utf-8"> appear near the top of the head?',
   'The browser only scans the first 1024 bytes for an encoding declaration. Miss that window and it guesses, and a wrong guess is what turns an apostrophe into three garbage characters.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000103', 'f0000001-0000-4000-8000-000000000004', 'multiple_choice',
   'An image is purely decorative. Which of these are correct? Select all that apply.',
   'alt="" - empty but present - tells a screen reader to skip the image. Omitting alt entirely makes it read the filename aloud instead. width and height are still worth setting on a decorative image, because they reserve the space and stop the page jumping when it loads.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000104', 'f0000001-0000-4000-8000-000000000004', 'true_false',
   'You should pick a heading level based on how large you want the text to appear.',
   'No. h1 to h6 are a document outline that screen reader users navigate by, the way a sighted reader skims for bold text. If an h2 is too big, that is a line of CSS, not a reason to use an h4.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-000000000105', 'f0000001-0000-4000-8000-000000000004', 'short_text',
   'Which attribute on an anchor with target="_blank" closes the reverse-tabnabbing hole? Give the attribute name only, in lower case.',
   'rel. Specifically rel="noopener", which severs the window.opener reference the new page would otherwise use to navigate your tab elsewhere. Modern browsers imply it, older ones do not, and it costs eight characters.',
   2, 5, 'rel'),

  -- HTML Level 2
  ('a1000001-0000-4000-8000-000000000111', 'f0000001-0000-4000-8000-000000000005', 'single_choice',
   'A screen reader reads the cell containing 744 and announces only "744". Which attribute is missing?',
   'scope. With scope="col" on the column headers and scope="row" on the row headers, the same cell is announced as "South, Q3, 744". Without them a data table is a grid of numbers with no labels attached.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000112', 'f0000001-0000-4000-8000-000000000005', 'single_choice',
   'Where must <caption> appear inside a <table>?',
   'As the first child of the table. It is the table''s accessible name: a user listing the tables on a page hears the captions, and a table without one is announced as "table" and nothing more.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000113', 'f0000001-0000-4000-8000-000000000005', 'true_false',
   'A placeholder attribute is an acceptable substitute for a <label> element.',
   'It is not. A placeholder disappears the moment someone types, usually fails contrast requirements, and is treated inconsistently by screen readers. A real label also gives you a larger click target, because clicking the words focuses the field.',
   1, 3, NULL),

  ('a1000001-0000-4000-8000-000000000114', 'f0000001-0000-4000-8000-000000000005', 'multiple_choice',
   'You are marking up a one-time code field. Which of these are the right choices? Select all that apply.',
   'type="text" with inputmode="numeric" gives a numeric keypad without the damage type="number" does - it would strip leading zeros and add a spinner. autocomplete="one-time-code" lets the browser or the OS offer the code it just received by SMS.',
   3, 4, NULL),

  ('a1000001-0000-4000-8000-000000000115', 'f0000001-0000-4000-8000-000000000005', 'single_choice',
   'Which image is the one you must never give loading="lazy"?',
   'The one at the top of the page. It is almost always the Largest Contentful Paint element, so deferring it delays the exact metric you were trying to improve. Use fetchpriority="high" on that one and lazy-load everything below the fold.',
   2, 5, NULL),

  -- HTML Level 3
  ('a1000001-0000-4000-8000-000000000121', 'f0000001-0000-4000-8000-000000000006', 'single_choice',
   'A page has three <nav> elements and none of them has a name. What does a screen reader announce?',
   'Three landmarks all called "navigation", which is useless for choosing one. Any landmark type that appears more than once needs a name on every instance - aria-label="Main", aria-label="Breadcrumb" - and then the landmark list becomes a usable menu.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000122', 'f0000001-0000-4000-8000-000000000006', 'single_choice',
   'When does a <header> element become the page banner landmark?',
   'Only when it is a direct child of <body>. Nested inside an <article>, the same element is an ordinary grouping element - which is exactly what you want for a byline.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000123', 'f0000001-0000-4000-8000-000000000006', 'single_choice',
   'Why must a skip link be hidden with off-screen positioning rather than display: none?',
   'A display: none element cannot receive focus, so the link stops working entirely. Position it off screen and bring it back on :focus, and a keyboard user gets a way past forty navigation links on every page.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000124', 'f0000001-0000-4000-8000-000000000006', 'multiple_choice',
   'What does dialog.showModal() give you that dialog.show() does not? Select all that apply.',
   'showModal renders the ::backdrop, makes everything outside the dialog inert so tab cannot leave it, moves focus in and restores it on close, and closes on Escape. show() opens a non-modal box and leaves all of that to you.',
   3, 4, NULL),

  ('a1000001-0000-4000-8000-000000000125', 'f0000001-0000-4000-8000-000000000006', 'true_false',
   'Open Graph tags work correctly with relative image URLs.',
   'They do not. The scraper is a different machine on a different network with no notion of your page''s base URL, so og:image must be an absolute URL. Note also that Open Graph uses property= rather than name=.',
   1, 5, NULL),

  -- HTML Level 4
  ('a1000001-0000-4000-8000-000000000131', 'f0000001-0000-4000-8000-000000000007', 'single_choice',
   'What is the main advantage of cloning a <template> over building markup with innerHTML in a loop?',
   'The template was parsed once, by the real HTML parser, at page load. Cloning it is a DOM copy - no re-parsing, no escaping mistakes, and no string concatenation anywhere in the path, so no injection is possible.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000132', 'f0000001-0000-4000-8000-000000000007', 'single_choice',
   'In a custom element, why should you not read attributes or touch children in the constructor?',
   'The element may not have any yet - it can be constructed before it is parsed or upgraded. Attach the shadow root in the constructor and do the reading in connectedCallback, which runs once the element is in the document.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000133', 'f0000001-0000-4000-8000-000000000007', 'multiple_choice',
   'Which script loading attributes leave the HTML parser unblocked? Select all that apply.',
   'defer, async and type="module" all avoid blocking the parser. A module is deferred by default. Plain <script> with no attribute blocks parsing until it has downloaded and executed.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000134', 'f0000001-0000-4000-8000-000000000007', 'single_choice',
   'Why is crossorigin mandatory on <link rel="preload" as="font">, even for a same-origin font?',
   'Fonts are always fetched in CORS mode. Omit crossorigin and the preload is treated as a different request from the one the stylesheet makes, so the file downloads twice and the preload has cost you bandwidth for nothing.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-000000000135', 'f0000001-0000-4000-8000-000000000007', 'short_text',
   'In a progressively enhanced search form, which method call inside the submit handler is what makes the JavaScript version take over? Give the method name only, without parentheses.',
   'preventDefault. Until that line runs the form is a plain HTML form that navigates on submit, which is why there is no window in which the button does nothing. Everything after it is the enhancement.',
   2, 5, 'preventDefault')
ON DUPLICATE KEY UPDATE
  prompt = VALUES(prompt), explanation = VALUES(explanation),
  points = VALUES(points), correct_text = VALUES(correct_text);

-- ---------------------------------------------------------------------------
-- Questions: CSS course
-- ---------------------------------------------------------------------------
INSERT INTO assessment.questions
  (id, quiz_id, kind, prompt, explanation, points, `position`, correct_text)
VALUES
  -- CSS Level 1
  ('a1000001-0000-4000-8000-000000000141', 'f0000001-0000-4000-8000-000000000008', 'single_choice',
   'Two rules set colour on the same element: one selector is .card a.link (specificity 0,2,1) and the other is .link (0,1,0). The .link rule is written later in the file. Which one wins?',
   'The .card a.link rule, on specificity. Source order is only consulted when origin, layer and specificity all tie. Two classes beat one class, and the element count is never reached because the comparison stops at the first column that differs.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000142', 'f0000001-0000-4000-8000-000000000008', 'single_choice',
   'What is the specificity of :where(.card, #main, article)?',
   'Zero, always. :where() matches exactly like :is() but contributes nothing to specificity, whatever is inside it. That is what makes it the right wrapper for base styles and resets, which should apply everywhere and lose every argument.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000143', 'f0000001-0000-4000-8000-000000000008', 'single_choice',
   'A box has width: 300px, padding: 1rem and a 4px border, with box-sizing: content-box. How wide is it on screen, assuming a 16px root font size?',
   '340px. content-box measures the 300 as content only, then adds 2rem of padding (32px) and 8px of border on top. Set box-sizing: border-box and the same declarations produce exactly 300px.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000144', 'f0000001-0000-4000-8000-000000000008', 'true_false',
   'Setting a pixel font size on the html or body element is fine as long as the rest of the stylesheet uses rem.',
   'It is not. A user who has raised their browser''s default font size has done so because they need to, and a px value on the root overrides that for the whole page. Everything downstream then scales from a size they did not choose.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-000000000145', 'f0000001-0000-4000-8000-000000000008', 'short_text',
   'Which single declaration, applied to *, *::before and *::after, makes every box measure its width including its own padding and border? Give the property and value, like property: value.',
   'box-sizing: border-box. Applying it to both pseudo-element selectors as well as * matters: pseudo-elements are not covered by * on their own, and one that measures differently from its parent is a nasty bug to track down.',
   2, 5, 'box-sizing: border-box'),

  -- CSS Level 2
  ('a1000001-0000-4000-8000-000000000151', 'f0000001-0000-4000-8000-000000000009', 'single_choice',
   'A row of flex children all have flex: 1, but they come out different widths when you expected them equal. What is the most likely cause?',
   'Some of them have flex: auto rather than flex: 1. flex: 1 expands to 1 1 0, which shares the leftover space equally and ignores content width; flex: auto is 1 1 auto, which shares it proportionally to content. They look interchangeable and are not.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000152', 'f0000001-0000-4000-8000-000000000009', 'single_choice',
   'One long URL in a flex child blows the whole row out of its container. Which declaration on that child fixes it?',
   'min-width: 0. A flex item defaults to min-width: auto, which refuses to shrink below its content size. Setting it to 0 lets the child shrink so the content wraps or scrolls instead of the layout breaking.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000153', 'f0000001-0000-4000-8000-000000000009', 'single_choice',
   'Why is minmax(0, 1fr) often the right grid track instead of a bare 1fr?',
   '1fr is shorthand for minmax(auto, 1fr), and that auto minimum means the track will not shrink below its content. One wide table and the grid overflows its container. minmax(0, 1fr) lets the track shrink so the content scrolls or wraps instead.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000154', 'f0000001-0000-4000-8000-000000000009', 'single_choice',
   'Three cards sit in a wide container using repeat(auto-fit, minmax(13rem, 1fr)). What happens if you change auto-fit to auto-fill?',
   'auto-fill keeps the empty tracks, so the three cards stay at 13rem and leave a gap on the right. auto-fit collapses the empty tracks, so the three cards stretch to fill the row. Neither is wrong - it depends whether items should fill or keep a consistent size.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-000000000155', 'f0000001-0000-4000-8000-000000000009', 'multiple_choice',
   'Which of these still genuinely need a media query rather than intrinsic sizing? Select all that apply.',
   'prefers-reduced-motion and prefers-color-scheme are not width questions at all and have no intrinsic equivalent. Fluid type and a reflowing card grid are handled better by clamp() and auto-fit, which respond to actual available space rather than to a guessed device width.',
   3, 5, NULL),

  -- CSS Level 3
  ('a1000001-0000-4000-8000-000000000161', 'f0000001-0000-4000-8000-00000000000a', 'single_choice',
   'You put your .card rules inside @media (prefers-color-scheme: dark) to restyle them. Why is that the wrong shape for a theme?',
   'You now have two copies of the component to keep in step, and one of them will drift. Redefine tokens, never components: everything the second theme needs should be expressible as a different set of values that the same rules read.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000162', 'f0000001-0000-4000-8000-00000000000a', 'single_choice',
   'A colour token is defined only inside @media (prefers-color-scheme: dark). What do most visitors see?',
   'Nothing for that token, so they get one theme''s text on the other theme''s background. The majority of viewers have no explicit setting and a light system, so they never enter that block. Every token must have its value on the bare :root first.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000163', 'f0000001-0000-4000-8000-00000000000a', 'multiple_choice',
   'Which of these create a stacking context? Select all that apply.',
   'opacity below 1, a transform, and a filter each create one, as do will-change naming any of those, isolation: isolate and contain: paint. position: relative on its own does not - it needs a z-index that is not auto.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000164', 'f0000001-0000-4000-8000-00000000000a', 'single_choice',
   'A dropdown sits behind the sticky header. You set z-index: 9999 on the panel and nothing changes. What is the fix?',
   'Raise the stacking context, not the element. An ancestor has created one - often an opacity or a transform - and every z-index inside it is scoped to that context, so no number can escape. Find that ancestor and raise it, or move the panel to the top layer with <dialog> or popover.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-000000000165', 'f0000001-0000-4000-8000-00000000000a', 'multiple_choice',
   'Which properties can be animated without forcing the browser to redo layout? Select all that apply.',
   'transform and opacity are handled by the compositor and often run off the main thread. width and top both trigger layout, which then forces paint and composite as well - the browser re-lays-out the page on every frame.',
   3, 5, NULL),

  -- CSS Level 4
  ('a1000001-0000-4000-8000-000000000171', 'f0000001-0000-4000-8000-00000000000b', 'single_choice',
   'A rule in @layer base uses an id selector. A rule in @layer components uses one class. The layer order is: reset, base, components. Which wins?',
   'The components rule. Layer order is checked before specificity, so anything in a later layer beats anything in an earlier one regardless of selectors. Specificity is only consulted between rules within the same layer.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000172', 'f0000001-0000-4000-8000-00000000000b', 'true_false',
   'A rule written outside any @layer is weaker than a rule inside the last declared layer.',
   'The opposite. Unlayered styles beat every layer. It is backwards from what most people guess and it is deliberate: it means an existing stylesheet keeps working when a layered design system is introduced underneath it.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000173', 'f0000001-0000-4000-8000-00000000000b', 'single_choice',
   'Why do you put container-type on a wrapper rather than on the component that responds to it?',
   'An element cannot respond to its own size - the query result would change the size the query depends on, so the browser refuses. The wrapper is the container; the component inside it is what the @container rules restyle.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000174', 'f0000001-0000-4000-8000-00000000000b', 'single_choice',
   'What goes wrong if you use content-visibility: auto without contain-intrinsic-size?',
   'The element measures as zero height until it is rendered, so the scrollbar jumps around as you scroll and in-page anchors land in the wrong place. contain-intrinsic-size gives the browser a placeholder size to use meanwhile.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-000000000175', 'f0000001-0000-4000-8000-00000000000b', 'true_false',
   'Adding will-change: transform to every animated element on a page makes it faster.',
   'It makes it slower. Each promoted element gets its own compositor layer and costs GPU memory. will-change is a loan: add it immediately before an animation and remove it afterwards. Left on permanently across many elements it is a pessimisation that looks like an optimisation.',
   2, 5, NULL)
ON DUPLICATE KEY UPDATE
  prompt = VALUES(prompt), explanation = VALUES(explanation),
  points = VALUES(points), correct_text = VALUES(correct_text);

-- ---------------------------------------------------------------------------
-- Options.
--
-- short_text questions carry their answer in questions.correct_text and get
-- no rows here. Options are re-inserted rather than updated, so editing a
-- distractor above and re-running the seed cannot leave the old one behind.
-- ---------------------------------------------------------------------------
DELETE FROM assessment.question_options
 WHERE question_id IN (
   SELECT id FROM assessment.questions
    WHERE quiz_id IN ('f0000001-0000-4000-8000-000000000004',
                      'f0000001-0000-4000-8000-000000000005',
                      'f0000001-0000-4000-8000-000000000006',
                      'f0000001-0000-4000-8000-000000000007',
                      'f0000001-0000-4000-8000-000000000008',
                      'f0000001-0000-4000-8000-000000000009',
                      'f0000001-0000-4000-8000-00000000000a',
                      'f0000001-0000-4000-8000-00000000000b'));

INSERT INTO assessment.question_options (question_id, body, is_correct, `position`)
SELECT v.question_id, v.body, v.is_correct, v.pos
  FROM (
    -- HTML L1 Q1: doctype
    SELECT 'a1000001-0000-4000-8000-000000000101' AS question_id, 'The page refuses to render and the browser shows an error' AS body, 0 AS is_correct, 1 AS pos
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000101', 'The browser switches to quirks mode, changing box sizing and line heights', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000101', 'Nothing at all - it is a comment the browser ignores', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000101', 'Only the validator complains; rendering is identical', 0, 4

    -- HTML L1 Q2: charset position
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000102', 'The browser only scans the first 1024 bytes for it, and guesses the encoding otherwise', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000102', 'Search engines require it to be the first element', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000102', 'It has to come before the viewport meta or the viewport is ignored', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000102', 'Position makes no difference; it is a convention only', 0, 4

    -- HTML L1 Q3: decorative image (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000103', 'Give it alt="" - empty but present', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000103', 'Still set width and height so the space is reserved', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000103', 'Omit the alt attribute entirely', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000103', 'Write alt="decorative image" so it is described', 0, 4

    -- HTML L1 Q4: heading levels (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000104', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000104', 'False', 1, 2

    -- HTML L2 Q1: scope
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000111', 'scope on the header cells', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000111', 'aria-label on the table', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000111', 'role="grid" on the table', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000111', 'title on each cell', 0, 4

    -- HTML L2 Q2: caption position
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000112', 'As the first child of the table', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000112', 'Immediately before the closing table tag', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000112', 'Inside the thead, above the header row', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000112', 'Anywhere inside the table', 0, 4

    -- HTML L2 Q3: placeholder (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000113', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000113', 'False', 1, 2

    -- HTML L2 Q4: one-time code (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000114', 'type="text" with inputmode="numeric"', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000114', 'autocomplete="one-time-code"', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000114', 'type="number", so only digits can be entered', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000114', 'A placeholder showing the expected number of digits', 0, 4

    -- HTML L2 Q5: never lazy
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000115', 'The image at the top of the page, above the fold', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000115', 'Any image inside a picture element', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000115', 'Any image with an empty alt', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000115', 'Images inside a table', 0, 4

    -- HTML L3 Q1: unnamed navs
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000121', 'Three landmarks all called "navigation", with nothing to tell them apart', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000121', 'Only the first one; the others are skipped', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000121', 'It names them automatically from their first link', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000121', 'Nothing - unnamed navs are not exposed as landmarks', 0, 4

    -- HTML L3 Q2: header as banner
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000122', 'Only when it is a direct child of body', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000122', 'Always, wherever it appears', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000122', 'Only when it carries role="banner" explicitly', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000122', 'Only when it is the first element in the document', 0, 4

    -- HTML L3 Q3: skip link hiding
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000123', 'A display: none element cannot receive focus, so the link stops working', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000123', 'display: none is slower to animate back into view', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000123', 'Screen readers ignore off-screen elements, which is what you want', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000123', 'There is no difference; both work', 0, 4

    -- HTML L3 Q4: showModal (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000124', 'It renders the ::backdrop pseudo-element', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000124', 'It makes content outside the dialog inert, so tab cannot leave', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000124', 'It closes the dialog on Escape', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000124', 'It submits the form inside the dialog automatically', 0, 4

    -- HTML L3 Q5: og relative urls (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000125', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000125', 'False', 1, 2

    -- HTML L4 Q1: template vs innerHTML
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000131', 'It is a DOM clone of markup already parsed once, so there is no string concatenation to get wrong', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000131', 'Templates are cached by the browser between page loads', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000131', 'innerHTML cannot create nested elements', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000131', 'Templates render without JavaScript enabled', 0, 4

    -- HTML L4 Q2: constructor
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000132', 'The element may not have attributes or children yet when the constructor runs', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000132', 'The constructor runs in a different thread', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000132', 'Attributes are read-only until the element is upgraded', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000132', 'It would fire attributeChangedCallback recursively', 0, 4

    -- HTML L4 Q3: non-blocking scripts (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000133', 'defer', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000133', 'async', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000133', 'type="module"', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000133', 'A plain script tag with no attributes', 0, 4

    -- HTML L4 Q4: font preload crossorigin
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000134', 'Fonts are fetched in CORS mode, so without it the file downloads twice', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000134', 'It is required by the CSP for any preloaded resource', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000134', 'It tells the browser the font is on a different domain', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000134', 'It is optional and only affects the console warning', 0, 4

    -- CSS L1 Q1: specificity
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000141', '.card a.link, on specificity - two classes beat one', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000141', '.link, because it is written later in the file', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000141', '.link, because shorter selectors are more specific', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000141', 'Neither - the declaration is dropped as ambiguous', 0, 4

    -- CSS L1 Q2: :where specificity
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000142', 'Zero, whatever is inside it', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000142', '1,0,0 - it takes the id, its most specific argument', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000142', '0,1,1 - the average of its arguments', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000142', '1,1,1 - the sum of all three', 0, 4

    -- CSS L1 Q3: box model arithmetic
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000143', '340px', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000143', '300px', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000143', '308px', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000143', '332px', 0, 4

    -- CSS L1 Q4: px root font (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000144', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000144', 'False', 1, 2

    -- CSS L2 Q1: flex 1 vs auto
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000151', 'Some are flex: auto, which is 1 1 auto and shares space proportionally to content', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000151', 'flex: 1 only works when every child has the same tag name', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000151', 'The gap property is subtracted unevenly', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000151', 'justify-content is overriding the flex values', 0, 4

    -- CSS L2 Q2: min-width 0
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000152', 'min-width: 0', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000152', 'overflow: hidden on the flex container', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000152', 'flex-shrink: 0 on the child', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000152', 'white-space: nowrap on the child', 0, 4

    -- CSS L2 Q3: minmax(0, 1fr)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000153', '1fr has an automatic minimum, so wide content makes the grid overflow', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000153', '1fr is not supported in every browser', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000153', 'minmax is faster for the browser to resolve', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000153', 'They are identical; it is a style preference', 0, 4

    -- CSS L2 Q4: auto-fit vs auto-fill
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000154', 'The cards stay at 13rem and leave a gap, because the empty tracks are kept', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000154', 'The cards stretch further, filling more of the row', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000154', 'The grid drops to a single column', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000154', 'Nothing changes with only three items', 0, 4

    -- CSS L2 Q5: still need media queries (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000155', 'prefers-reduced-motion', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000155', 'prefers-color-scheme', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000155', 'Scaling a heading between two sizes', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000155', 'Reflowing a card grid as space allows', 0, 4

    -- CSS L3 Q1: theming shape
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000161', 'You now maintain two copies of the component, and one of them will drift', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000161', 'Media queries cannot contain class selectors', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000161', 'Rules inside a media query have lower specificity', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000161', 'It is fine, and the recommended approach', 0, 4

    -- CSS L3 Q2: token only in dark
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000162', 'The token is undefined for them, so one theme''s text lands on the other theme''s background', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000162', 'The browser falls back to the nearest defined token', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000162', 'The dark value is used for everyone', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000162', 'Nothing - custom properties always inherit a default', 0, 4

    -- CSS L3 Q3: stacking contexts (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000163', 'opacity less than 1', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000163', 'A transform', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000163', 'A filter', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000163', 'position: relative with no z-index', 0, 4

    -- CSS L3 Q4: dropdown behind header
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000164', 'Raise the ancestor that created the stacking context, or move the panel to the top layer', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000164', 'Use a larger z-index, such as 999999', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000164', 'Add position: fixed to the panel', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000164', 'Add !important to the z-index declaration', 0, 4

    -- CSS L3 Q5: cheap to animate (multi)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000165', 'transform', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000165', 'opacity', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000165', 'width', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000165', 'top', 0, 4

    -- CSS L4 Q1: layer beats specificity
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000171', 'The components rule - layer order is checked before specificity', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000171', 'The base rule, because an id outranks a class', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000171', 'Whichever appears later in the file', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000171', 'Neither; layers cannot contain id selectors', 0, 4

    -- CSS L4 Q2: unlayered (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000172', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000172', 'False', 1, 2

    -- CSS L4 Q3: container on wrapper
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000173', 'An element cannot respond to its own size - the query would change what it depends on', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000173', 'container-type is only valid on block-level elements', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000173', 'It is a performance convention rather than a rule', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000173', 'Because container-name must be unique per element', 0, 4

    -- CSS L4 Q4: content-visibility
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000174', 'The element measures as zero until rendered, so the scrollbar jumps and anchors land wrong', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000174', 'The content never renders at all', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000174', 'It falls back to visibility: hidden', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000174', 'Nothing; the pairing is optional', 0, 4

    -- CSS L4 Q5: will-change (true/false)
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000175', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000175', 'False', 1, 2
  ) v;

-- ---------------------------------------------------------------------------
-- The lesson counts changed, so the rollups have to be refreshed.
-- ---------------------------------------------------------------------------
CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000004');
CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000005');
CALL `search`.reindex_all();
