-- ===========================================================================
-- Seed 06 : the HTML course - thirty topics, five modules
--
-- The curriculum follows a topic list rather than four broad levels: one
-- lesson per topic, grouped into five modules, with a quiz closing each one.
-- The level still lives in the module rather than in five separate courses so
-- a learner keeps a single enrolment and a single progress percentage all the
-- way from <!doctype html> to a finished project.
--
-- TWELVE LESSON IDS ARE REUSED, not replaced. The course previously had twelve
-- article lessons; each of those rows is updated in place to become one of the
-- thirty topics rather than left behind, because progress_lesson_progress and
-- progress_enrolments point at lesson ids. Inserting thirty new lessons and
-- abandoning the old twelve would leave every existing learner's progress
-- attached to rows no longer in the curriculum, and a content seed cannot
-- delete them - it must never contain DELETE.
--
-- Every lesson body is Markdown carrying at least one fenced ```html block.
-- That fence is the contract with the front end: the Content Service renders
-- it to <pre><code class="language-html">, and the website turns each of those
-- into a code box with a "Try yourself!" button that opens the playground.
-- Change the fence language and the button quietly disappears, so the tests
-- in learning_website/smoke.php assert it is still there.
--
-- Every example in this file was loaded in Chromium and checked to parse into
-- the structure it is written as - see tests/run-html-examples.mjs. That is a
-- real check rather than a formality: a browser repairs invalid markup
-- silently, so an example with a mis-nested tag still renders something and
-- teaches the reader a structure the parser never built.
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
   'Thirty topics, five modules, every example runnable in the browser',
   'HTML is the language every web page is written in. It is not a programming language: it does not calculate or decide anything. It says what the things on a page are - this is a heading, this is a link, this is a table of sales figures - and the browser, the search engine and the screen reader all work from that answer.

That is why it is worth more attention than it usually gets. CSS can make any element look like any other, so a page built from meaningless divs can be made to look perfect and still be unusable with a keyboard, unreadable aloud, and invisible to the thing that decides whether anyone finds it. The markup is the layer that carries meaning, and nothing above it can put the meaning back.

It is also the smallest useful thing you can learn in web development. By the end of the first module you can build a page that works. Nothing else on this site has that ratio.',
   -- catalog_courses.description is plain text, not Markdown. Only
   -- content_articles carries a format column, and only that body is rendered.
   -- Asterisks here would reach the page as literal asterisks.
   'Thirty topics, in five modules, from the first tag to a finished multi-page project.

Module 1, Foundations, covers the eight topics every page is built from: what HTML is, the document structure, text, attributes, links, images, lists and tables. Module 2 covers forms in three topics, then semantics, the modern HTML feature set and media. Module 3 is graphics, embedded content, metadata, responsive HTML, accessibility and entities. Module 4 is the advanced half: advanced forms and media, performance, security, how HTML meets CSS and JavaScript, SEO, the modern APIs and the standards that hold it all together. Module 5 is a real project and a set of interview questions.

This course assumes nothing. If you have never written a tag, the first topic starts with the nine lines every page begins with and explains what each one is for. If you already write HTML every day, treat Module 1 as revision and start at Module 3: most working developers have never read the rules on landmarks, labelling or what a screen reader does with a div, and that is where the hours here pay for themselves.

Each module ends with a quiz drawn from its own topics, and the course ends with a final exam. A topic is one sitting - a short explanation, complete examples, then the edge cases that bite in real pages.

Every example is a document you can paste into a file and open. Press the "Try yourself!" button under any of them and it opens in the playground, where you can edit it on the left and watch the rendered result on the right. Every example in this course was loaded in a real browser and checked to parse into the structure it is written as, which matters more than it sounds: a browser silently repairs invalid markup, so an example with a mis-nested tag still renders something and teaches a structure the parser never built.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '55555555-5555-4555-8555-555555555555',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/html-from-basics-to-expert.jpg', 0,
   JSON_ARRAY('Write a valid, accessible HTML5 document from memory', 'Choose the right element for text, lists, tables and media every time', 'Build forms the browser validates, labels and autofills for you', 'Structure a page with landmarks a screen reader can navigate', 'Control how a page is previewed, indexed and shared', 'Cut load time with preloads, lazy images and correct script attributes', 'Recognise the HTML-level causes of common security problems', 'Ship a multi-page site that passes a real accessibility and quality review'),
   JSON_ARRAY('A text editor and a browser', 'No previous HTML required'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description), learning_outcomes = VALUES(learning_outcomes),
  requirements = VALUES(requirements), status = VALUES(status);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000008'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-000000000009'),
  ('c0000001-0000-4000-8000-000000000004', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE tag_id = VALUES(tag_id);

-- ---------------------------------------------------------------------------
-- The modules
-- ---------------------------------------------------------------------------
INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'Module 1 - Foundations',
   'The eight topics every page is built from. What HTML is and is not, the document skeleton, the text elements and what each one means, attributes, links, images, lists and tables. By the end you can build a page that validates and reads well with no CSS and no JavaScript at all.', 1),
  ('d0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'Module 2 - Forms, Semantics and Media',
   'The parts of HTML that most often go wrong in real projects. Three topics on forms, from the first label to constraint validation and why none of it is security; then semantic structure, the modern HTML feature set, and audio and video with the captions track that is usually missing.', 2),
  ('d0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'Module 3 - Graphics, Metadata and Access',
   'Six topics on everything around the content. Graphics in markup, embedded content from other origins, the head metadata that decides how a link previews, responsive HTML, accessibility as a set of concrete decisions, and the entities you need when the character you want is also syntax.', 3),
  ('d0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'Module 4 - Advanced HTML',
   'Nine topics that separate a page which works from one which holds up. Advanced forms and media, loading performance, the security problems that start in markup, how HTML meets CSS and JavaScript, what search engines and answer engines actually read, the modern APIs, and the standards and habits behind all of it.', 4),
  ('d0000001-0000-4000-8000-000000000050', 'c0000001-0000-4000-8000-000000000004',
   'Module 5 - Project and Practice',
   'Everything applied. A multi-page site built from semantic markup with a quality checklist to measure it against, and the interview questions an HTML role actually asks, grouped from beginner to advanced with the answers worked through.', 5)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary),
  `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Park the existing positions out of the way first.
--
-- uq_lessons_position is UNIQUE (module_id, position), and this seed renumbers
-- the whole course: the lesson that was second in module 1 becomes third, the
-- one that was third becomes fifth, and so on. The INSERT below is a single
-- statement, so while it runs both numberings exist at once - and the first row
-- whose new position is still held by a row the statement has not reached yet
-- fails with
--
--   #1062 Duplicate entry 'd0000001-...-000000000008-2' for key 'uq_lessons_position'
--
-- which is exactly what happened the first time this seed was imported into a
-- copy of the live database. Moving every existing row of this course a thousand
-- places out of the way leaves 1..n free for the real numbering.
--
-- An UPDATE is safe in a content seed; a DELETE would not be.
--
-- Every row of the course is shifted, not only the ones below 1000. Adding a
-- constant to all of them keeps them distinct from each other whatever they
-- started at, so a second import - or an import run over a database left part
-- way through a first one - cannot land two rows on the same number. The INSERT
-- below then puts every row this seed owns back at its real position.
--
-- ORDER BY position DESC is not decoration. A unique index is checked per row,
-- not at the end of the statement, so renumbering upwards in ascending order
-- moves the first row onto a number a later row still holds. Highest first,
-- every row moves into space that has already been vacated.
-- ---------------------------------------------------------------------------
UPDATE catalog_lessons
   SET `position` = `position` + 1000
 WHERE course_id = 'c0000001-0000-4000-8000-000000000004'
 ORDER BY `position` DESC;

-- ---------------------------------------------------------------------------
-- The lessons
-- ---------------------------------------------------------------------------
INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Module 1 - Foundations
  ('e0000001-0000-4000-8000-000000000130', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'introduction-to-html', 'Introduction to HTML',
   'HTML is the only language on the web that says what things are. It does not calculate and it does not decide; it answers the question every other layer depends on - is this a heading, a link, a button, or a paragraph that someone made look like one?',
   'article', 'published', 1, 420, 1),
  ('e0000001-0000-4000-8000-000000000011', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-document-structure', 'HTML Document Structure',
   'Every page ever shipped starts from the same handful of lines, and they are worth knowing by heart - because a page that omits one still renders, and then behaves strangely in a way that is very hard to trace back to the missing line weeks later.',
   'article', 'published', 2, 360, 1),
  ('e0000001-0000-4000-8000-000000000012', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-text-elements', 'HTML Text Elements',
   'Choosing the right text element is HTML; everything about how it looks belongs to CSS. The question to ask about a piece of text is not how it should look but what it is - and headings answer it as an outline, not as a font size.',
   'article', 'published', 3, 360, 1),
  ('e0000001-0000-4000-8000-000000000131', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-attributes', 'HTML Attributes',
   'Attributes configure an element: where a link goes, what an image is of, whether a field is required. A handful work on almost every element, and two of them - id and class - are how CSS and JavaScript find anything at all.',
   'article', 'published', 4, 360, 0),
  ('e0000001-0000-4000-8000-000000000013', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-links', 'Links',
   'The link is the element the web is named after. Most of what goes wrong with one is in two places: an href that resolves somewhere you did not intend, and link text that means nothing to somebody who hears it without the sentence around it.',
   'article', 'published', 5, 360, 0),
  ('e0000001-0000-4000-8000-000000000132', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-images', 'Images',
   'An image element has two required attributes and people routinely write one. The missing alt text is not a formality - it is the entire content of the image for anybody who cannot see it, including the search engine.',
   'article', 'published', 6, 360, 0),
  ('e0000001-0000-4000-8000-000000000133', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-lists', 'Lists',
   'A list is one of the few elements that tells a screen reader how much is coming before it starts reading. Three kinds cover everything, and the mistake is using the markup for indentation rather than for a set of things.',
   'article', 'published', 7, 360, 0),
  ('e0000001-0000-4000-8000-000000000014', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-tables', 'Tables',
   'A table is the right element for two-dimensional data and the wrong one for layout, and the difference is not aesthetic: a screen reader announces the shape and then reads each cell against its headers. Without a caption and scope it reads a grid of numbers.',
   'article', 'published', 8, 360, 0),
  ('e0000001-0000-4000-8000-000000000029', 'd0000001-0000-4000-8000-000000000008', 'c0000001-0000-4000-8000-000000000004',
   'html-foundations-check', 'Module 1 Check: Foundations',
   'Eight questions on the document structure, text, attributes, links, images, lists and tables. Use the scratchpad under the questions to try anything you are unsure of.',
   'quiz', 'published', 9, 600, 0),

  -- Module 2 - Forms, Semantics and Media
  ('e0000001-0000-4000-8000-000000000015', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'html-forms-introduction', 'HTML Forms: Introduction',
   'A form is the only way a browser sends data back on its own, with no JavaScript involved at all. Most of the work is in two attributes on the form and one relationship between a label and its control.',
   'article', 'published', 1, 360, 0),
  ('e0000001-0000-4000-8000-000000000134', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'basic-input-types', 'Basic Input Types',
   'One element, twenty-odd behaviours. Choosing the right type changes the keyboard a phone shows, the validation the browser performs for free, and whether autofill can help - and costs exactly one word.',
   'article', 'published', 2, 360, 0),
  ('e0000001-0000-4000-8000-000000000135', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'advanced-forms', 'Advanced Forms',
   'The browser will validate, describe and autofill a form for you if you let it. Most of the JavaScript written for forms re-implements something that was already there, and does it worse - without keyboard support, and without saying what went wrong.',
   'article', 'published', 3, 360, 0),
  ('e0000001-0000-4000-8000-000000000017', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'semantic-html', 'Semantic HTML',
   'Semantic elements are how a page says what its parts are. The practical payoff is a set of landmarks a screen reader user can jump between - which is how they skip a navigation menu they have already heard on every other page.',
   'article', 'published', 4, 360, 0),
  ('e0000001-0000-4000-8000-000000000136', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'html5-features', 'HTML5 Features',
   'A tour of what modern HTML gives you without a library: a dialog that traps focus, a disclosure widget, a drawing surface, inline vector graphics and a template the browser parses but does not render.',
   'article', 'published', 5, 360, 0),
  ('e0000001-0000-4000-8000-000000000137', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'audio-and-video', 'Audio and Video',
   'Two elements replace what used to need a plugin. The attributes are easy; the part that gets skipped is the captions track, which is the difference between a video that everybody can use and one that a lot of people cannot.',
   'article', 'published', 6, 360, 0),
  ('e0000001-0000-4000-8000-00000000002a', 'd0000001-0000-4000-8000-000000000009', 'c0000001-0000-4000-8000-000000000004',
   'html-forms-and-media-check', 'Module 2 Check: Forms, Semantics and Media',
   'Eight questions on forms and the labels that make them usable, native validation, semantic structure and media with its captions.',
   'quiz', 'published', 7, 600, 0),

  -- Module 3 - Graphics, Metadata and Access
  ('e0000001-0000-4000-8000-000000000138', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-graphics', 'HTML Graphics',
   'Two ways to put a drawing on a page: SVG, where every shape is an element you can style and script, and canvas, where the page gives you a rectangle of pixels and a drawing API. The choice between them decides what is possible afterwards.',
   'article', 'published', 1, 360, 0),
  ('e0000001-0000-4000-8000-000000000139', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'iframes-and-embedded-content', 'Iframes and Embedded Content',
   'An iframe puts somebody else entire page inside yours. It is the most powerful embed available and the one with the most ways to go wrong - which is why it has a sandbox attribute and why a title on it is not optional.',
   'article', 'published', 2, 360, 0),
  ('e0000001-0000-4000-8000-000000000019', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-metadata', 'HTML Metadata',
   'Nothing in the head is visible on the page, and it decides the tab title, the search snippet, the preview card when somebody shares the link, and whether the page is indexed at all. It is the highest-leverage markup you will write.',
   'article', 'published', 3, 360, 0),
  ('e0000001-0000-4000-8000-000000000016', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'responsive-html', 'Responsive HTML',
   'Most of responsive design is CSS, and the part that is not is the part people skip: one meta tag without which no CSS applies, a source order that still reads correctly when the columns collapse, and images the browser can choose between.',
   'article', 'published', 4, 360, 0),
  ('e0000001-0000-4000-8000-000000000018', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-accessibility', 'Accessibility',
   'Accessibility is not a layer added at the end. Most of it is choosing the element that already does the job, and the single most effective test takes two minutes: put the mouse down and try to use the page.',
   'article', 'published', 5, 360, 0),
  ('e0000001-0000-4000-8000-00000000013a', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-entities', 'HTML Entities',
   'Five characters are syntax, so writing one as itself means writing it as something else. Everything beyond those five is a convenience - and one of them, the non-breaking space, is the most misused character on the web.',
   'article', 'published', 6, 360, 0),
  ('e0000001-0000-4000-8000-00000000002b', 'd0000001-0000-4000-8000-00000000000a', 'c0000001-0000-4000-8000-000000000004',
   'html-graphics-and-access-check', 'Module 3 Check: Graphics, Metadata and Access',
   'Eight questions on graphics in markup, embedded content, metadata, responsive images, accessibility and entities.',
   'quiz', 'published', 7, 600, 0),

  -- Module 4 - Advanced HTML
  ('e0000001-0000-4000-8000-00000000013b', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'advanced-html-forms', 'Advanced HTML Forms',
   'A long form is a usability problem before it is a markup problem. Sections with real headings, a visible sense of progress, uploads that are checked where it counts, and the three elements that report a number without a script.',
   'article', 'published', 1, 360, 0),
  ('e0000001-0000-4000-8000-00000000013c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'advanced-media', 'Advanced Media',
   'Media is almost always the heaviest thing on a page. Choosing the right element, the right format, and the right loading priority is the difference between a page that arrives and one that is still arriving.',
   'article', 'published', 2, 360, 0),
  ('e0000001-0000-4000-8000-00000000001b', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-performance', 'HTML Performance',
   'Most of what makes a page feel slow is decided in the first few lines of the head. The parser works top to bottom, and anything that blocks it blocks the first thing the visitor sees.',
   'article', 'published', 3, 360, 0),
  ('e0000001-0000-4000-8000-00000000013d', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-security', 'HTML Security',
   'Markup cannot secure anything on its own, and several security problems begin in it anyway: content that becomes script, a page framed by someone else, a link that hands over control, a hidden field somebody trusted.',
   'article', 'published', 4, 360, 0),
  ('e0000001-0000-4000-8000-00000000013e', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-with-css', 'HTML with CSS',
   'Three ways to attach styles and only one worth defaulting to. The deeper question is which decisions belong in the markup at all - and the answer is that if it is about appearance, it is not one of them.',
   'article', 'published', 5, 360, 0),
  ('e0000001-0000-4000-8000-00000000013f', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-with-javascript', 'HTML with JavaScript',
   'JavaScript reads and changes the tree the parser built. Which means the markup decides what is easy: good hooks, real elements, and one habit - textContent rather than innerHTML - that closes the commonest security hole on the web.',
   'article', 'published', 6, 360, 0),
  ('e0000001-0000-4000-8000-000000000140', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-and-seo', 'HTML and SEO',
   'No tag makes a page rank. What markup does is make a page findable, understandable and eligible - and most of what helps is the same markup that makes it accessible, which is not a coincidence.',
   'article', 'published', 7, 360, 0),
  ('e0000001-0000-4000-8000-00000000001a', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'modern-html-apis', 'Modern HTML APIs and Features',
   'Custom elements, templates, slots, popovers, editable regions and drag and drop. Each replaces a pile of JavaScript with a declaration - and each has one accessibility obligation that comes with it.',
   'article', 'published', 8, 360, 0),
  ('e0000001-0000-4000-8000-00000000001c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-standards-and-best-practices', 'HTML Standards and Best Practices',
   'What to do when the course is over: validate, check support, write markup the next person can read, and build in the order that survives one piece failing to arrive.',
   'article', 'published', 9, 360, 0),
  ('e0000001-0000-4000-8000-00000000002c', 'd0000001-0000-4000-8000-00000000000b', 'c0000001-0000-4000-8000-000000000004',
   'html-advanced-check', 'Module 4 Check: Advanced HTML',
   'Eight questions on performance, security, how HTML meets CSS and JavaScript, SEO, the modern APIs and standards.',
   'quiz', 'published', 10, 600, 0),

  -- Module 5 - Project and Practice
  ('e0000001-0000-4000-8000-000000000141', 'd0000001-0000-4000-8000-000000000050', 'c0000001-0000-4000-8000-000000000004',
   'real-world-html-project', 'Real-World HTML Project',
   'Ten pages, built from semantic markup, measured against a checklist rather than against how it looks. This is the brief, the shared structure, and the twelve things a reviewer will actually check.',
   'article', 'published', 1, 360, 0),
  ('e0000001-0000-4000-8000-000000000142', 'd0000001-0000-4000-8000-000000000050', 'c0000001-0000-4000-8000-000000000004',
   'html-interview-questions', 'Interview Questions',
   'The questions an HTML interview actually asks, from beginner to advanced, with the answers worked through - including what the question is really testing, which is usually not the fact it asks for.',
   'article', 'published', 2, 480, 0),
  ('e0000001-0000-4000-8000-000000000143', 'd0000001-0000-4000-8000-000000000050', 'c0000001-0000-4000-8000-000000000004',
   'html-final-exam', 'Final Exam: HTML',
   'Twelve questions drawn from all thirty topics. Pass this and you can mark up a page properly.',
   'quiz', 'published', 3, 600, 0)
ON DUPLICATE KEY UPDATE
  module_id = VALUES(module_id), slug = VALUES(slug), title = VALUES(title),
  summary = VALUES(summary), kind = VALUES(kind), status = VALUES(status),
  `position` = VALUES(`position`), duration_seconds = VALUES(duration_seconds),
  is_free_preview = VALUES(is_free_preview);

-- ---------------------------------------------------------------------------
-- Module 1 - Foundations
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000130',
   'Introduction to HTML',
   'markdown',
   '# Introduction to HTML

HTML stands for HyperText Markup Language, and the useful half of that name is the last word. It is a **markup** language: you take content that already exists - words, pictures, numbers - and you mark it up, labelling each piece with what it is. This is a heading. This is a paragraph. This is a link to another document. This is a table of sales figures, and these cells are its column headers.

It is not a programming language, and the distinction is not pedantry. HTML has no variables, no arithmetic, no conditions and no loops. You cannot write "if the user is logged in" in HTML. What you can do is describe a document so precisely that a browser, a search engine, a screen reader and a future maintainer all reach the same conclusions about it.

That sounds modest. It is the foundation everything else is built on.

## The first page

Save this as `index.html`, open it in a browser, and you have shipped a web page.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>My first page</title>
  </head>
  <body>
    <h1>Hello, HTML</h1>
    <p>This page is nine lines long and completely valid.</p>
  </body>
</html>
```

Press **Try yourself!** underneath it. The example opens in the playground, where you can edit it on the left and watch the result on the right. Change `Hello, HTML` to your own name and the heading changes. Nothing is being compiled; the browser is reading your markup and building a document out of it as you type.

## What the three languages each own

Almost every page you will ever build uses three languages, and the reason to keep them separate is that they answer different questions.

**HTML answers "what is this?"** A heading is a heading because it is in an `h1`, not because it is large and bold.

**CSS answers "what should it look like?"** Colour, spacing, layout, typography, what happens on a narrow screen.

**JavaScript answers "what should it do?"** Respond to a click, fetch more data, validate something the browser cannot validate on its own.

You can put a little CSS directly in the markup to see the division:

```html
<h1 style="color: teal">Still a heading</h1>
<p>The colour changed. What the element <em>means</em> did not.</p>
```

The `style` attribute is a shortcut, useful for a one-off demonstration and a poor habit in a real page - a stylesheet keeps the answer to "what should it look like" in one place instead of scattered through the document. But it makes the point: the `h1` was a heading before the colour was applied and remains one after. CSS changed the presentation and touched nothing about the meaning.

That separation is why HTML repays attention. CSS can make any element look like any other. A page built entirely from meaningless `div` elements can be styled to look flawless, and it will still be unusable with a keyboard, unreadable aloud, and invisible to the thing that decides whether anyone finds it. The markup is the layer that carries meaning, and nothing above it can put the meaning back.

## What happens when a page loads

It is worth knowing the sequence, because most confusing bugs sit somewhere in it.

1. The browser **fetches** the HTML document - over the network, or straight off disk when you open a local file.
2. It **parses** the markup from the top, building a tree of objects called the DOM: the `html` element with a `head` and a `body` inside it, and everything else nested underneath.
3. As it meets references to other files - stylesheets, scripts, images, fonts - it **requests** those too. A stylesheet blocks the first paint, because rendering without it would flash unstyled content. A plain script blocks parsing, because it might write into the document.
4. It **renders**: works out the position and size of every box, paints them, and shows you the result.

The parser never refuses. This is the single most surprising thing about HTML and the reason for most of the advice in this course. Hand a browser markup with a tag left open or elements nested in an impossible order, and it does not show you an error. It **repairs** the markup, silently, according to rules written down in the specification, and shows you a document. Often the repaired document is what you meant. Sometimes it is not, and then you are looking at a page that is wrong in a way the source does not explain.

## HTML5, and what "the living standard" means

You will see HTML5 everywhere, and it is now slightly misleading. There is no HTML6 coming. HTML is maintained as a **living standard**: it is amended continuously rather than published in numbered editions, so the right question about an element is not which version introduced it but whether browsers support it today.

What that means in practice is that a handful of old presentational tags are obsolete. They still render, because browsers do not break the past, but they put presentation back into the markup layer where it does not belong.

```html
<p><font color="red" size="5">Obsolete: presentation in the markup.</font></p>
<center>Obsolete: layout in the markup.</center>
<p><strong>Modern: the markup says this matters.</strong> CSS decides how that looks.</p>
```

That second line is written without a paragraph around it on purpose, and it is worth knowing why: `center` is a block-level element, and a paragraph cannot contain one. Write `<p><center>…</center></p>` and the browser closes the paragraph, puts the `center` after it, and leaves you with an empty paragraph as well. Three elements where you wrote two, and nothing in the source says so.

`font` and `center` are the famous ones. The rule behind them generalises: if an element or attribute exists only to change an appearance, there is a CSS property that does it better.

## What you need to start

A text editor and a browser. That is genuinely the whole toolchain. There is no build step, no package to install and no server to run - a file on your disk, opened in a browser, is a working web page.

Two habits are worth forming on day one:

**Give the file a `.html` extension.** The browser decides how to treat a file by its name.

**Open the developer tools.** Press F12, or right-click any element and choose Inspect. The Elements panel shows you the tree the browser actually built - which, as above, is not always the tree you wrote. The Console shows errors. The Network panel shows every file the page requested and how long each took.

Get used to comparing the Elements panel against your source. When a page behaves strangely, the difference between the two is very often the whole explanation. Note that edits you make in the inspector are temporary: they change the live document, not your file, and vanish on reload.

## The tree, and why it is worth looking at

Everything above describes the browser building a tree. It is worth seeing one, because the tree - not your file - is what CSS styles, what JavaScript queries and what a screen reader reads.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>A small tree</title>
  </head>
  <body>
    <h1>Courses</h1>
    <ul>
      <li><a href="/html">HTML</a></li>
      <li><a href="/css">CSS</a></li>
    </ul>
  </body>
</html>
```

Open that in the playground, then open the Elements panel. The nesting you see there is the nesting you wrote: `html` contains `head` and `body`; `body` contains an `h1` and a `ul`; the `ul` contains two `li` elements, each containing an `a`. Click the `ul` and the browser highlights it on the page, because a box on screen and a node in the tree are the same object seen two ways.

Now try breaking it. Delete the `</li>` from the first list item and reload. The page looks unchanged - but the Elements panel still shows two separate list items, because the parser inferred the missing end tag. That is the repair behaviour, doing what you meant. Later lessons cover the cases where it does not.

## Practice task

Build a one-page introduction to yourself. Give it a `title`, one `h1`, two or three paragraphs, and a line of text you have marked as important. Open it, then open the Elements panel and find each element you wrote. Change one word in the inspector, watch the page update, then reload and watch your change disappear - that is the difference between the document and the file, and it catches everyone once.
',
   'HTML is the only language on the web that says what things are. It does not calculate and it does not decide; it answers the question every other layer depends on - is this a heading, a link, a button, or a paragraph that someone made look like one?', 7, 1413, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000011',
   'HTML Document Structure',
   'markdown',
   '# HTML Document Structure

Every HTML page ever shipped starts from the same handful of lines. They are worth knowing by heart, and not because anybody will test you on them. They are worth knowing because a page that omits one of them still **renders** - the browser repairs it and shows you something - and then behaves strangely in a way that is hard to trace back to the missing line.

```html
<!doctype html>
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

## The doctype

`<!doctype html>` is not an element and it is not HTML. It is a single instruction to the browser: use **standards mode**.

Leave it out and the browser switches to quirks mode, which emulates the bugs of browsers from the late 1990s so that pages written for them still work. In quirks mode the box model is different, so every width you set is computed from a different starting point, and your layout is subtly and consistently wrong in a way that no amount of staring at your CSS will explain.

It is fifteen characters and it has no options. Type it first, always.

## The root element and `lang`

`<html>` is the root: everything else lives inside it. The `lang` attribute names the document''s main language.

`lang` is the one attribute in this skeleton that is easiest to skip and most visibly wrong when you do. A screen reader uses it to choose a pronunciation engine; without it, English read with a French engine is not an accent, it is noise. Browsers use it to offer translation and to pick the right hyphenation and quotation marks. Search engines use it to decide who to show the page to.

## The head and the body

The `head` holds information **about** the document. The `body` holds the document. Nothing in the head is rendered as page content; everything in the body is.

```html
<head>
  <meta charset="utf-8">
  <title>Course notes</title>
</head>
<body>
  <h1>Course notes</h1>
  <p>Only this part appears on the page.</p>
</body>
```

Both are optional in the sense that the parser will insert them if you do not - which is exactly why writing them yourself is worth the two lines. A page where you forgot the `head` still has one; it is just one the browser decided the contents of.

## The character encoding

`<meta charset="utf-8">` tells the browser how to turn the file''s bytes back into letters.

This is the line whose absence produces the most recognisable symptom on the web: a page where every apostrophe has turned into `â€™` and every accented letter into a pair of nonsense characters. The file was saved as UTF-8 and read as something else. One line, declared before any text, and it cannot happen.

Put it first in the head. The browser only reads the first kilobyte or so before it has to commit to a guess, and a charset declaration it has already passed is no use to it.

Nothing about this is specific to accented letters. In UTF-8 `é` is two bytes, `世界` is six and `👍` is four, and a page read as the wrong encoding mangles all three the same way. That makes a line like

```
Hello, 世界 👍
```

a better test of a page than a word like `café`: it exercises one, three and four-byte characters at once, and if all of it arrives intact the declaration is doing its job.

## The viewport

`<meta name="viewport" content="width=device-width, initial-scale=1">` tells a phone to lay the page out at the phone''s own width.

Without it, a mobile browser assumes the page was designed for a desktop, renders it at about 980 pixels wide, and then zooms the whole thing out to fit - which is why some older sites arrive as a perfect, unreadable miniature. No amount of responsive CSS has any effect until this line is present, because the CSS is being asked about a 980-pixel viewport that does not exist.

## The title

`<title>` is the one piece of the head that people actually see. It is the browser tab, the bookmark name, the window title, and the blue line in a search result. Write it for someone reading a list of twenty tabs, not for a crawler: specific, front-loaded, and different on every page.

## Elements, nesting and comments

An element usually has a start tag, content and an end tag. Some - `img`, `br`, `hr`, `meta`, `link`, `input` - are **void**: they have no content, so they have no end tag.

Elements nest, and they must nest cleanly: an element that opens inside another must close inside it too.

```html
<!-- A comment. The browser ignores everything between these markers. -->
<h1>Welcome <em>back</em></h1>
<p>Correctly nested: <strong>the <em>inner</em> element closes first</strong>.</p>
```

Get the order wrong and you meet the repair behaviour head on:

```html
<p>Written as overlapping tags</p>
<p>The browser will not build what the next line says.</p>
```

If you write `<p><div>text</div></p>`, the browser does not produce a div inside a paragraph. A `p` cannot contain a `div`, so the parser closes the paragraph, creates the div, and then finds a stray `</p>` and makes an empty paragraph out of it. You get three elements where you wrote two, and the Elements panel is the only place that says so.

## What else lives in the head

The skeleton above is the minimum. Four more things turn up in the head of most real pages, and all of them are covered properly later - this is so you recognise them.

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Course notes</title>
  <meta name="description" content="Notes from the HTML course, with runnable examples.">
  <link rel="canonical" href="https://example.com/notes">
  <link rel="stylesheet" href="/styles.css">
  <script src="/app.js" defer></script>
</head>
```

`meta name="description"` is the sentence a search engine may show under your title. `link rel="canonical"` names the one true address for this page, which matters when the same content is reachable by more than one URL. `link rel="stylesheet"` pulls in CSS. `script` with `defer` loads JavaScript without blocking the parser.

The order is not arbitrary. `charset` first, always. Then viewport, then title, then everything else - because the first two change how the rest of the document is interpreted, and the title is what a browser shows while the page is still loading.

## Syntax rules worth adopting

- **Lowercase tag names.** HTML does not care, but consistency means search and replace works.
- **Quote every attribute value.** Unquoted values end at the first space, which turns `class=card wide` into one class and a stray attribute.
- **Close every non-void element.** The parser will infer missing end tags in many cases, and the cases where it infers something different from what you meant are not predictable from reading the source.
- **Indent to show nesting.** The browser does not care; the next person does, and so do you in six months.

## Practice task

Type the nine-line skeleton out from memory, then check it against this page. Add a second paragraph and a comment. Then delete the `meta charset` line, save the file with an accented character in it - a word like `café` - and reload: you have just reproduced the most common encoding bug on the web, and fixed it by putting one line back.
',
   'Every page ever shipped starts from the same handful of lines, and they are worth knowing by heart - because a page that omits one still renders, and then behaves strangely in a way that is very hard to trace back to the missing line weeks later.', 6, 1161, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000012',
   'HTML Text Elements',
   'markdown',
   '# HTML Text Elements

Most of a web page is text, and most of the markup you write will be choosing which element a piece of text belongs in. There is a reliable way to make that choice and a tempting way to get it wrong.

The tempting way is to pick by appearance: this line should be big, so `h1`; this should be bold, so `b`. The reliable way is to pick by meaning: this line is the title of the page, so `h1`; this word carries a warning, so `strong`. The two often produce the same element, which is why the wrong method survives. When they differ, the appearance-led choice is the one that breaks.

## Headings are an outline

`h1` through `h6` are not six sizes. They are six **levels**, and together they form the page''s outline - the same outline a screen reader user navigates by, and a search engine summarises from.

```html
<h1>HTML Text Elements</h1>
<p>One page, one main heading.</p>

<h2>Headings</h2>
<p>A section of the page.</p>

<h3>Choosing a level</h3>
<p>A subsection of that section.</p>

<h2>Paragraphs</h2>
<p>Back up a level, because this is a sibling of Headings.</p>
```

Two rules follow from treating them as an outline:

**One `h1` per page**, naming what the whole page is about. More than one and there is no single answer to "what is this page?"

**Do not skip levels.** Jumping from `h2` to `h4` describes a subsection of a section that does not exist. If the `h4` looks right and the `h3` looks wrong, that is a CSS problem with a CSS solution.

A screen reader can list every heading on a page and jump between them, which for most users is how they find out what a page contains. A page with one heading, or with six `h1` elements, gives them a table of contents with one entry or six equally important ones.

## Paragraphs, line breaks and thematic breaks

`p` is a paragraph. It is the default container for running text and you will use it more than anything else.

`br` forces a line break **inside** a block of text where the break is part of the content - a postal address, a line of a poem, a verse. It is not a way to add space between paragraphs; that is a margin, and margins belong in CSS.

`hr` represents a thematic break: a change of subject within a section. It renders as a line by default, which makes it tempting as a decoration. Use it when the break is in the content, and CSS borders when the line is decoration.

```html
<p>
  Omni Academy<br>
  14 Example Street<br>
  Doha
</p>

<hr>

<p>A new subject begins here.</p>
```

## Emphasis and importance

Four elements are involved and they divide into two pairs.

`strong` means **this is important**. `em` means **this word carries the stress**, in the way that saying a word differently changes a sentence''s meaning.

`b` and `i` are the ones that were once "bold" and "italic" and now have narrower jobs: `b` draws attention without implying importance (a keyword, a product name in a review), and `i` marks an alternate voice or mood - a technical term, a phrase in another language, a thought.

```html
<p><strong>Warning:</strong> this operation cannot be undone.</p>
<p>I said <em>she</em> wrote it, not that I did.</p>
<p>The <i lang="la">Felis catus</i> is the domestic cat.</p>
```

The difference is audible. A screen reader can change its delivery for `strong` and `em`. It has nothing to say about `b` and `i`, which is correct - they are not carrying importance.

If what you actually want is bold text with no extra meaning, the honest answer is a class and a CSS rule.

## The rest of the text semantics

A handful of smaller elements cover cases that come up often enough to be worth knowing.

```html
<p>Water is H<sub>2</sub>O, and 2<sup>3</sup> is 8.</p>
<p>Price: <del>50</del> <ins>35</ins> today only.</p>
<p>Search results for <mark>semantic markup</mark> are highlighted.</p>
<p><small>Terms and conditions apply.</small></p>
```

`sub` and `sup` are subscript and superscript, for formulae and footnote markers. `del` and `ins` mark removed and added content, which matters on anything with a revision history - a screen reader announces them, where a strikethrough drawn in CSS is silent. `mark` highlights text for the reader''s current purpose, most obviously a search term. `small` is for side comments and small print.

## Quotations and code

```html
<p>As the specification puts it:</p>
<blockquote cite="https://html.spec.whatwg.org/">
  <p>Authors must not use elements, attributes, or attribute values for purposes other than their appropriate intended semantic purpose.</p>
</blockquote>

<p>She called it <q>a markup language, not a programming language</q>.</p>

<p>Use <code>&lt;p&gt;</code> for a paragraph.</p>

<pre><code>function greet(name) {
  return "Hello, " + name;
}</code></pre>
```

`blockquote` is a quotation that stands as its own block; `q` is a short one inside a sentence, and the browser supplies the quotation marks, in the right style for the document language. `code` marks a fragment of code inline. `pre` preserves whitespace exactly as written, which is why a code block is conventionally `pre` wrapping `code`: one preserves the layout, the other says what the text is.

Note `&lt;p&gt;` in that example. To show a tag on screen rather than have it interpreted, the angle brackets have to be written as entities. There is a whole lesson on that later.

## The ones people forget

A few more elements each solve a specific problem well, and each is routinely replaced by a `span` and a class that does less.

```html
<p>Published <time datetime="2026-03-14">14 March 2026</time>.</p>
<p>The <abbr title="World Wide Web Consortium">W3C</abbr> publishes specifications.</p>
<p>Press <kbd>Ctrl</kbd> + <kbd>S</kbd> to save.</p>
<p>The program printed <samp>File not found</samp>.</p>
<p>Solve for <var>x</var> in the equation above.</p>
<p>A <dfn>void element</dfn> is one that cannot have content.</p>
<p>From <cite>The Art of Readable Markup</cite>, page 14.</p>
<address>
  Written by <a href="mailto:lena@example.com">Lena</a>.
</address>
```

`time` carries a machine-readable date in `datetime` alongside whatever wording you prefer for humans - so "last Tuesday" can still be indexed correctly. `abbr` gives an abbreviation its expansion. `kbd` is keys the reader should press, `samp` is output a program produced, and `var` is a variable in a mathematical or programming sense. `dfn` marks the point in the text where a term is being defined, which is what lets a glossary link back to it. `cite` names a work, not a person. `address` gives contact details for the nearest article or for the page as a whole, and is for contact information rather than for any postal address that happens to appear in the text.

None of these change much visually. All of them tell something downstream what the text is, which a `span` cannot.

## Practice task

Take a page you have already written and audit its text. For every piece of styled text, ask what it is rather than how it looks. Replace any bolding that means "important" with `strong`, any italics that mean "stressed" with `em`, and check that your headings form an outline you could read aloud as a table of contents. Then open the page in the browser and use the developer tools accessibility panel to list the headings - what it shows you is what a screen reader user gets.
',
   'Choosing the right text element is HTML; everything about how it looks belongs to CSS. The question to ask about a piece of text is not how it should look but what it is - and headings answer it as an outline, not as a font size.', 6, 1199, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000131',
   'HTML Attributes',
   'markdown',
   '# HTML Attributes

An element says what something is. An **attribute** configures it: where this link goes, what this image shows, which field this label belongs to, whether this input must be filled in. Attributes go in the start tag, as name-and-value pairs.

```html
<a href="https://example.com" title="The example domain">Visit example.com</a>
<img src="cat.jpg" alt="A grey cat asleep on a windowsill" width="400" height="300">
```

Three rules cover almost everything:

**Quote the value.** HTML permits unquoted values in simple cases, and the day you write `class=card wide` you get one class called `card` and a mysterious attribute called `wide`. Quotes cost two characters and remove the question.

**Attribute names are case-insensitive, values usually are not.** `HREF` and `href` are the same attribute; `cat.jpg` and `Cat.JPG` are different files on most servers.

**Order does not matter.** Put them in whatever order reads best, consistently.

## Global attributes

Most attributes belong to one element - `href` on a link, `src` on an image. A set of **global** attributes work on nearly all of them:

| Attribute | What it is for |
|---|---|
| `id` | A unique name for this one element |
| `class` | A shared label, used by CSS and scripts |
| `title` | Advisory information, usually shown as a tooltip |
| `lang` | The language of this element''s content |
| `dir` | Text direction: `ltr`, `rtl` or `auto` |
| `hidden` | Remove the element from the page entirely |
| `tabindex` | Change whether and where the element takes keyboard focus |
| `data-*` | Your own data, for your own scripts |

## id and class

These two carry most of the weight, and the difference is simple.

An **id** names exactly one element in the document. It must be unique, and it is how a fragment link finds its target, how a `label` finds its input, and how a script grabs a single known element.

A **class** is a label that any number of elements can share. It is the normal hook for CSS and for scripts that act on a group.

```html
<h2 id="overview" class="section-title">Overview</h2>
<p class="lead">The first paragraph of the section.</p>
<p class="lead">Another paragraph with the same treatment.</p>

<a href="#overview">Jump to the overview</a>
```

Duplicate ids are the common mistake, usually created by copying a block of markup. Nothing visibly breaks: the page renders, CSS still applies. But `#overview` as a fragment link scrolls to the first one, a script asking for that id gets the first one, and a `label` pointing at a duplicated input labels the wrong field. It is a bug that hides until the page gets long.

## style, title, lang and dir

`style` applies CSS directly to one element. It works, it is occasionally the right tool for a value a script has calculated, and as a habit it is a trap: it scatters presentation through the document, it overrides your stylesheet in a way that is awkward to undo, and it cannot express a hover state or a media query.

`title` supplies advisory text, usually surfaced as a tooltip. It is worth knowing that it is weak: it does not appear on touch devices, it is inconsistently announced by screen readers, and it cannot be reached by keyboard in most browsers. Never put information in a `title` that is not available some other way.

`lang` and `dir` handle language. `lang` on the `html` element declares the document''s language; `lang` on a smaller element marks a passage in a different one, which is what lets a screen reader switch pronunciation mid-sentence. `dir="rtl"` sets right-to-left text direction for languages such as Arabic and Hebrew.

```html
<p>The French call it <span lang="fr">la langue de balisage</span>.</p>
<p dir="rtl" lang="ar">مرحبا بالعالم</p>
<p>Prefer a stylesheet, but <span style="color: teal">this works</span>.</p>
```

## Boolean attributes

Some attributes are true simply by being there. `required`, `disabled`, `checked`, `readonly`, `multiple`, `hidden` - their presence is the value.

```html
<form>
  <label for="email">Email</label>
  <input id="email" name="email" type="email" required>

  <button type="submit">Sign up</button>
  <button type="button" disabled>Unavailable</button>
</form>
```

There is no `required="false"`. Writing it sets the attribute, and the attribute being present makes the field required - the string `false` is simply ignored. To turn a boolean attribute off, remove it.

## Data attributes

`data-*` attributes let you attach your own information to an element without inventing attributes the browser does not know.

```html
<article class="course-card" data-course-id="html-101" data-level="beginner">
  <h3>HTML: From Basics to Expert</h3>
  <p>Thirty topics, every example runnable.</p>
</article>
```

A script reads these through the element''s `dataset` property, where `data-course-id` arrives as `dataset.courseId`. CSS can match on them too, with an attribute selector.

Two cautions. They are visible in the page source, so nothing secret goes in one. And they are for data, not for meaning: `data-heading="true"` on a `div` does not make it a heading to anything except your own code, where an `h2` would have made it a heading to everything.

## hidden and tabindex

Two globals in that table deserve a warning each.

`hidden` removes an element from the page completely: it is not rendered, not read aloud, and not reachable by keyboard. That is the right behaviour when content genuinely does not apply yet. It is the wrong tool for anything you want visually hidden but still announced - a label for a search box, say - because `hidden` hides it from everyone.

`tabindex` controls keyboard focus, and has three cases:

```html
<div tabindex="0" role="button">Focusable, in the normal order</div>
<div tabindex="-1" id="main">Focusable only by script, not by tabbing</div>
<p hidden>Not rendered, not announced, not reachable.</p>
```

`tabindex="0"` puts an element into the natural tab order. `tabindex="-1"` makes it focusable by script - useful on a `main` element so a skip link can move focus there - without adding it to the tab order. Any **positive** number jumps the element to the front of the tab order ahead of everything natural, and the result on a real page is a tab sequence nobody can predict. Treat positive values as a mistake.

The deeper point is that a `button` is already focusable, already activated by Enter and Space, and already announced as a button. Reaching for `tabindex` and `role` on a `div` usually means an element that already exists was passed over.

## Matching on attributes

Attributes are not only configuration; they are how CSS and scripts find things.

```html
<a class="external" href="https://example.com" target="_blank" rel="noopener">
  Opens in a new tab
</a>
<input id="email" name="email" type="email" required>
```

CSS can select on any of that: `a[target="_blank"]` to add an icon to every link that opens a new tab, `input[required]` to mark required fields, `[lang="fr"]` to set a different font. Scripts can do the same through `querySelectorAll`. It means a consistent attribute is often a better hook than an extra class, because it is already carrying the meaning you would be duplicating.

## Practice task

Take the page from the previous lesson and add a navigation list at the top whose links jump to each `h2` on the page, using `id` on the headings and `#fragment` links in the list. Then add a `data-` attribute to one element and read it back in the console with `document.querySelector(''[data-your-attribute]'').dataset`. The point of the second half is to see that the browser hands your own data back to you without you having to parse anything.
',
   'Attributes configure an element: where a link goes, what an image is of, whether a field is required. A handful work on almost every element, and two of them - id and class - are how CSS and JavaScript find anything at all.', 6, 1214, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000013',
   'Links',
   'markdown',
   '# Links

The hyperlink is the element the web is named after. It is also, after thirty years, still the element people most often get subtly wrong - not by writing an invalid tag, but by writing an address that resolves somewhere unexpected, or text that is useless to half the people who encounter it.

## The anchor and its href

An `a` element becomes a link when it has an `href`. Without one it is not a link at all: it is a placeholder, not focusable, not announced, and not clickable.

```html
<p>
  <a href="https://developer.mozilla.org/">The MDN HTML reference</a> is the
  reference most working developers actually use.
</p>
<p><a href="about.html">About this course</a></p>
```

The first is an **absolute** URL: scheme, host and path, complete in itself. The second is **relative**: the browser resolves it against the current document''s address. If the current page is `https://example.com/courses/html/index.html`, then `about.html` means `https://example.com/courses/html/about.html`.

Relative URLs come in three useful shapes, and mixing them up is the commonest cause of a link that works locally and 404s in production.

| Written | Resolved against `/courses/html/index.html` |
|---|---|
| `about.html` | `/courses/html/about.html` - same directory |
| `../index.html` | `/courses/index.html` - one directory up |
| `/about` | `/about` - from the site root, ignoring the current directory |

The leading slash is the one to remember. `/about` always means the same thing wherever it appears, which is why site-wide navigation should use root-relative links. A bare `about.html` in a shared header means something different on every page that includes it.

## Linking within a page

Give an element an `id` and a link can point at it with a `#` fragment.

```html
<nav>
  <a href="#forms">Jump to Forms</a> ·
  <a href="#tables">Jump to Tables</a>
</nav>

<h2 id="forms">Forms</h2>
<p>Everything about forms.</p>

<h2 id="tables">Tables</h2>
<p>Everything about tables.</p>

<p><a href="#top">Back to the top</a></p>
```

Two details. `href="#"` on its own jumps to the top of the page and is a common placeholder - but a placeholder link is still announced as a link, so a button that does nothing is better written as a `button`. And a fragment link to an element that does not exist does nothing at all, silently, which is why a renamed heading quietly breaks every link to it.

## Email, telephone and downloads

Three schemes cover almost every non-http link you will write.

```html
<p>
  <a href="mailto:hello@example.com?subject=Course%20question">Email us</a> ·
  <a href="tel:+97455555555">Call us</a> ·
  <a href="/handbook.pdf" download="omni-handbook.pdf">Download the handbook</a>
</p>
```

`mailto:` hands the address to whatever the reader uses for email, and accepts `subject` and `body` as query parameters - URL-encoded, so a space is `%20`. `tel:` starts a call on a phone and is usually inert on a desktop; write the number in full international form so it works from anywhere. `download` asks the browser to save the file rather than navigate to it, and the value is the suggested filename. It only works for same-origin files, which is a deliberate restriction rather than a bug.

## target and rel

`target="_blank"` opens the link in a new tab.

```html
<p>
  <a href="https://example.com" target="_blank" rel="noopener noreferrer">
    Opens in a new tab
  </a>
</p>
```

Two things to know. First, `rel="noopener"`: without it, the page you opened gets a reference back to yours through `window.opener` and can redirect it somewhere else. Modern browsers imply `noopener` for `target="_blank"`, but writing it costs nothing and covers the ones that do not. `noreferrer` additionally stops the destination learning where the visitor came from.

Second, and more important: opening a new tab takes the Back button away. The reader did not ask for a new tab, and on a phone they may not notice they are in one. Open a new tab when leaving the page would genuinely lose work - a half-filled form, a running process - and not as a reflex for external links.

## What a URL is made of

Being able to read a URL makes most link bugs obvious on sight.

    https://example.com:443/courses/html?page=2&sort=new#forms
    |____| |_________| |_| |___________| |______________| |___|
    scheme    host    port    path            query       fragment

The **scheme** says which protocol. The **host** says which machine. The **path** names the resource on it. The **query** carries parameters, starting at `?` and separated by `&`. The **fragment** starts at `#` and is never sent to the server at all - it is for the browser alone, which is why fragment links do not reload the page.

A protocol-relative URL - one beginning `//example.com` - inherits the scheme of the current page. It was once good practice and is now a mistake: every site should be https, and `//` leaves the door open to http.

## rel, beyond noopener

`rel` describes the **relationship** between this document and the one being linked to, and a few values are worth knowing.

```html
<p>
  <a href="https://example.com/sponsored" rel="nofollow sponsored">A paid link</a> ·
  <a href="https://github.com/example" rel="me">My profile elsewhere</a> ·
  <a href="/chapter-3" rel="next">The next chapter</a>
</p>
```

`nofollow` tells search engines not to pass ranking credit through the link, and `sponsored` and `ugc` are the more specific modern forms for paid links and user-generated content. `me` asserts that both addresses are the same person, which is what identity verification on several platforms reads. `prev` and `next` describe sequence in a series of pages.

## A link or a button?

The most common markup mistake on any interactive page is choosing between these two by appearance.

A **link navigates**: it takes you somewhere, it has a URL, you can open it in a new tab, bookmark it, and come back with the Back button. A **button acts**: it submits, opens, toggles or deletes something on the page you are already on.

```html
<p><a href="/checkout">Go to checkout</a></p>
<p><button type="button">Add to basket</button></p>
```

They behave differently at the keyboard - a link activates on Enter, a button on Enter **and** Space - and they are announced differently. Styling a link to look like a button is fine. Using an `a href="#"` to run a script is not, because it promises navigation that never happens.

## Link text people can use

This is the part that matters most and costs least.

```html
<p>Bad: To read about accessibility, <a href="/a11y">click here</a>.</p>
<p>Good: Read the <a href="/a11y">guide to accessibility</a>.</p>
```

Screen reader users commonly ask for a list of every link on a page, read out of context. A page whose links are "click here", "read more", "click here", "more" is a list that says nothing. The same list from the second example reads "guide to accessibility", and the reader can act on it.

The test is simple: read the link text on its own, with the sentence hidden. If it does not say where it goes, rewrite it.

Three more habits follow from the same idea:

- **Do not hide that a link is a link.** Underlines exist because colour alone fails for colour-blind readers and in high-contrast modes.
- **Do not describe the mechanism.** "Link to" and "Click here" add nothing; the element already announces itself as a link, and not everyone clicks.
- **Make the target big enough.** A link of one or two characters is hard to hit on a phone and with a tremor. Padding is a CSS fix for an HTML-shaped problem.

## Practice task

Build a two-page site: `index.html` and `about.html`, each linking to the other with a relative URL, and each with a table of contents at the top whose links jump to that page''s own headings. Then read every link''s text aloud with the surrounding sentence covered. Rewrite any that does not say where it goes.
',
   'The link is the element the web is named after. Most of what goes wrong with one is in two places: an href that resolves somewhere you did not intend, and link text that means nothing to somebody who hears it without the sentence around it.', 6, 1254, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000132',
   'Images',
   'markdown',
   '# Images

An image is one void element and a handful of attributes, two of which are required and one of which is skipped constantly.

```html
<img src="images/cat.jpg" alt="A grey cat asleep on a sunlit windowsill"
     width="640" height="480">
```

`src` is the file. `alt` is what the image **says**. Everything else is optimisation.

## alt text is content, not metadata

The habit to break is thinking of `alt` as a label. It is a replacement: the text that takes the image''s place for anybody who is not receiving the image - a screen reader user, somebody on a connection where it failed to load, and the search engine indexing the page.

So the question is not "what is in this picture?" It is **"what would I write here if I could not use a picture?"**

```html
<p>
  <img src="chart.png"
       alt="Revenue rose each quarter, from 1.2 million in Q1 to 2.1 million in Q4.">
</p>

<p>
  <a href="/profile">
    <img src="avatar.jpg" alt="Your profile">
  </a>
</p>

<p>
  <img src="divider.svg" alt="">
  A decorative flourish, which should say nothing at all.
</p>
```

Three cases, three different answers:

**An informative image** gets the information. A chart''s `alt` is the finding, not the word "chart" - a reader who cannot see it needs what it shows, and "Quarterly revenue chart" tells them only that they are missing something.

**An image inside a link** gets the link''s destination, because the image is standing in for the link text. `alt="Your profile"`, not `alt="Photograph of a person"`.

**A decorative image** gets `alt=""` - present and empty. That is not the same as omitting it. An empty `alt` tells assistive technology to skip the image entirely; a **missing** `alt` leaves it with nothing to go on, so many screen readers read the filename instead, and `hero-image-final-v3-compressed.jpg` is read out, character by character.

A good rule for length: one sentence. If it needs a paragraph, the information belongs in the page where everybody can read it, with the image carrying `alt=""`.

## Width, height and why they are back

For years the advice was to leave dimensions out and let CSS handle sizing. That advice reversed.

Set `width` and `height` to the image''s real pixel dimensions and the browser knows the aspect ratio before the file arrives, so it can reserve exactly the right space. Without them the space is zero until the image loads, and everything underneath jumps down when it does - the single most irritating thing on a modern web page, and one of the things search engines measure.

They do not fight your CSS. `img { max-width: 100%; height: auto; }` still scales the image; the attributes supply the ratio, the stylesheet supplies the size.

## figure and figcaption

When an image needs a visible caption, the two belong together as one unit.

```html
<figure>
  <img src="parse-tree.png"
       alt="The parser builds html, then head and body, then the elements inside each.">
  <figcaption>How a browser turns markup into a document tree.</figcaption>
</figure>
```

`figure` marks self-contained content that is referred to from the main text - an illustration, a chart, a code listing, a photograph - and `figcaption` is its caption. The association is explicit, so a screen reader announces the caption with the figure rather than leaving a stray sentence after an image.

The caption and the `alt` do different jobs. The caption is read by everyone and says what the figure is for; the `alt` is read instead of the image and says what it shows. Repeating one in the other means a screen reader user hears the same sentence twice.

## Formats, and choosing one

| Format | Use it for |
|---|---|
| JPEG | Photographs. Lossy, small, no transparency. |
| PNG | Screenshots, flat colour, anything needing transparency. Lossless. |
| SVG | Logos, icons, diagrams. Vector, so it stays sharp at any size. |
| WebP | A modern replacement for both JPEG and PNG, usually 25-35% smaller. |
| AVIF | Smaller again, slower to encode, now widely supported. |

The practical advice is short: photographs as WebP or AVIF with a JPEG fallback, anything drawn rather than photographed as SVG, screenshots as PNG unless they are large enough to be worth WebP.

## One image, several files

Sending a 2400-pixel photograph to a phone wastes the visitor''s data and their battery. `srcset` lets you offer the same image at several sizes and have the browser pick.

```html
<img src="photo-800.jpg"
     srcset="photo-400.jpg 400w, photo-800.jpg 800w, photo-1600.jpg 1600w"
     sizes="(max-width: 700px) 100vw, 700px"
     alt="The lecture hall during an open day"
     width="800" height="533">
```

`srcset` lists the files with their real widths. `sizes` tells the browser how wide the image will be **laid out** - here, the full viewport below 700 pixels and 700 pixels above it. The browser combines the two with the device''s pixel density and downloads one file. `src` stays as the fallback for anything that does not understand `srcset`.

When the files are different **formats** rather than different sizes, the element is `picture`:

```html
<picture>
  <source srcset="photo.avif" type="image/avif">
  <source srcset="photo.webp" type="image/webp">
  <img src="photo.jpg" alt="The lecture hall during an open day"
       width="800" height="533">
</picture>
```

The browser takes the first `source` whose type it supports and falls back to the `img`. Note that the `img` is required and carries the `alt`: `picture` is a wrapper that chooses a file, not a replacement for the image element. There is a whole lesson on this later, under responsive HTML.

## Lazy loading

```html
<img src="far-down-the-page.jpg" alt="A diagram of the box model"
     width="800" height="600" loading="lazy">
```

`loading="lazy"` tells the browser not to fetch the image until it is near the viewport. On a long page that is a large saving for anybody who does not scroll to the bottom.

One rule: never put it on an image that is visible when the page opens. Lazy-loading the first thing the visitor sees delays exactly the image whose speed is being measured.

## When an image is not an img

An SVG can be referenced like any other file, or pasted straight into the document.

```html
<p>Referenced, like any other image:</p>
<img src="logo.svg" alt="Omni Academy" width="160" height="40">

<p>Inlined, so CSS and script can reach inside it:</p>
<svg width="24" height="24" viewBox="0 0 24 24" role="img" aria-label="Download">
  <path d="M12 3v12m0 0l-4-4m4 4l4-4M4 19h16" fill="none"
        stroke="currentColor" stroke-width="2" stroke-linecap="round"></path>
</svg>
```

Referenced is right for anything large or reused across pages: the browser caches one file. Inline is right for icons, because `stroke="currentColor"` then picks up the surrounding text colour automatically, and because an inline icon costs no request at all.

An inline `svg` needs `role="img"` and `aria-label` to be announced, or `aria-hidden="true"` if it is decorative and sits next to text that already says the same thing. There is a lesson on graphics later that goes further.

## Practice task

Build a page with four images: a photograph, a chart, an image that is also a link, and a decorative divider. Write the `alt` for each by covering the image and asking what you would write in its place. Then set `width` and `height` on all four, throttle the network in the developer tools to a slow connection, and reload - with the dimensions present, nothing on the page should move as the images arrive.
',
   'An image element has two required attributes and people routinely write one. The missing alt text is not a formality - it is the entire content of the image for anybody who cannot see it, including the search engine.', 6, 1205, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000133',
   'Lists',
   'markdown',
   '# Lists

More of a web page is a list than people realise. Navigation is a list of links. A set of product cards is a list of products. Search results are a list. Steps in a recipe are an ordered list that happens to be styled without numbers.

Marking them up as lists is worth doing because a list announces itself. A screen reader says "list, six items" before it begins, and the reader knows what they are in and how long it is. A stack of `div` elements styled identically says nothing.

## Ordered and unordered

The choice is about whether the order is part of the meaning.

```html
<h2>Steps</h2>
<ol>
  <li>Open a text editor.</li>
  <li>Write the document skeleton.</li>
  <li>Save the file with a .html extension.</li>
  <li>Open it in a browser.</li>
</ol>

<h2>What you will need</h2>
<ul>
  <li>A text editor</li>
  <li>A browser</li>
  <li>Thirty minutes</li>
</ul>
```

`ol` when the sequence matters - steps, rankings, instructions. `ul` when it does not - features, ingredients, navigation. Both contain `li` elements and nothing else: a `ul` whose direct child is a `div` is invalid, and the parser will move the div out of the list.

`ol` has two attributes worth knowing. `start` begins the numbering somewhere other than 1, which matters when a list is interrupted by prose and resumes. `reversed` counts down, for a countdown or a top-ten listed from ten.

```html
<ol start="4">
  <li>The fourth step, after an interruption.</li>
  <li>The fifth.</li>
</ol>
```

Numbers are content here, not decoration - that is why they come from `ol` and not from CSS. If what you want is a visual bullet or number on something that is not a list, that is a CSS `::before`.

## Description lists

`dl` pairs terms with descriptions: a glossary, a set of metadata, a specification table that is not really tabular.

```html
<dl>
  <dt>HTML</dt>
  <dd>The markup language that describes the structure of a web page.</dd>

  <dt>CSS</dt>
  <dd>The language that describes how that structure should look.</dd>

  <dt>Void element</dt>
  <dd>An element that cannot have content, such as img or br.</dd>
</dl>
```

The rules are looser than they look. One `dt` can have several `dd` elements - a term with several definitions. Several `dt` elements can share one `dd` - synonyms with a single definition. Both are valid and both are announced correctly.

What `dl` is not is a layout tool. It gets reached for because the default styling indents the description, which is a bad reason: the indent is CSS and the meaning is "these terms have these descriptions".

## Nesting

A list inside a list represents hierarchy, and there is one placement rule that catches everyone.

```html
<ul>
  <li>Foundations
    <ul>
      <li>Introduction</li>
      <li>Document structure</li>
    </ul>
  </li>
  <li>Forms and media
    <ul>
      <li>Forms</li>
      <li>Audio and video</li>
    </ul>
  </li>
</ul>
```

The nested `ul` goes **inside the `li`**, not between two `li` elements. Put it between them and it is a child of the outer `ul`, which is invalid, and the parser will attach it to the preceding item anyway - producing something that looks right and is not what you wrote.

Keep nesting shallow. Three levels is usually a sign the information wants a different shape.

## Navigation is a list

The single most common real use, and worth writing out in full because it combines three lessons.

```html
<nav aria-label="Main">
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/courses">Courses</a></li>
    <li><a href="/playground" aria-current="page">Playground</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>
```

A `nav` landmark so it can be jumped to, a `ul` so its length is announced, and `aria-current="page"` on the link to the page you are already on - which is the piece almost always missing, and the one that tells a screen reader user where they are.

The bullets and the vertical stacking are removed in CSS with `list-style: none` and a flex row. Removing the bullets visually does not remove the list semantics, with one caveat worth knowing: Safari with VoiceOver stops announcing a list whose `list-style` is `none`, and the fix is `role="list"` on the `ul`.

## Things that are lists but do not look like them

A row of cards, a gallery, a set of search results, a comment thread: each is a set of similar things, so each is a list, however it is laid out.

```html
<h2>Courses</h2>
<ul class="card-grid">
  <li>
    <article>
      <h3><a href="/courses/html">HTML</a></h3>
      <p>Thirty topics, every example runnable.</p>
    </article>
  </li>
  <li>
    <article>
      <h3><a href="/courses/css">CSS</a></h3>
      <p>Layout, typography and the cascade.</p>
    </article>
  </li>
</ul>
```

The CSS turns that into a grid of cards. The markup still says "list, 2 items", so a screen reader user knows how many courses there are before reading any of them - which a set of sibling `article` elements would not tell them.

## The one element inside a list

`li` is the only child a `ul` or an `ol` may have. Anything else - a `div` wrapping two items, a stray paragraph between them, a heading - is invalid, and the parser moves it **out of the list** rather than keeping it where you wrote it.

```html
<ul>
  <li>
    <h3>Foundations</h3>
    <p>Eight topics covering structure, text, links and tables.</p>
  </li>
  <li>
    <h3>Forms and media</h3>
    <p>Six topics on collecting input and embedding media.</p>
  </li>
</ul>
```

Note where the headings and paragraphs are: **inside** the `li`, which is allowed and useful. An `li` can contain anything - headings, paragraphs, images, another list, a whole article. What it cannot do is have a sibling that is not another `li`.

That is why a list of cards wraps each card in an `li` rather than giving the `ul` a row of `div` children. The structure survives; a screen reader still counts the items.

## Removing the bullets without removing the list

Almost every list on a real site has its markers removed in CSS. That is normal and it does not change the markup''s meaning - with one exception worth knowing about, because it silently costs you the thing the list was for.

```html
<nav aria-label="Footer">
  <ul role="list" style="list-style: none; padding-left: 0">
    <li><a href="/privacy">Privacy</a></li>
    <li><a href="/terms">Terms</a></li>
    <li><a href="/contact">Contact</a></li>
  </ul>
</nav>
```

Safari with VoiceOver stops announcing a list once `list-style` is `none`, on the reasoning that a list without markers is being used for layout. Often it is - but not here. Adding `role="list"` restores the announcement, and it is harmless everywhere else because it only states what the element already is.

The same applies to `ol`. If the numbers are decoration you are free to remove them; if they are content, consider whether the list should be a `ul` of items that each contain their own label.

## When something is not a list

Two cases to resist:

**Indentation.** A `ul` with one item, used because its margin happens to indent. That is a CSS margin.

**Prose with bullets for emphasis.** Three sentences that flow into each other are a paragraph. Bulleting them because bullets look organised produces a list of fragments that read badly aloud.

The test: could the items be reordered, or counted, and would either operation make sense? If yes, it is a list.

## Practice task

Take the navigation on a page you have built and rewrite it as a `nav` containing a `ul`, with `aria-current="page"` on the current page''s link. Then add a nested list somewhere - a table of contents with sections and subsections - and check in the Elements panel that the inner `ul` really is inside an `li` and not a sibling of one.
',
   'A list is one of the few elements that tells a screen reader how much is coming before it starts reading. Three kinds cover everything, and the mistake is using the markup for indentation rather than for a set of things.', 6, 1236, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000014',
   'Tables',
   'markdown',
   '# Tables

A table is for data with two dimensions: rows that mean something, columns that mean something, and cells that mean the intersection of the two. Sales by quarter. Students by assessment. Timetable by day.

It is not for layout. That use is twenty years out of date and it is worth knowing why it was abandoned rather than just that it was: a screen reader reading a layout table announces "table, 3 columns, 14 rows" and then reads a navigation menu cell by cell as though it were data. CSS Grid does layout, and does it responsively, which a table never did.

## The whole structure

```html
<table>
  <caption>Course completions by quarter, 2026</caption>
  <thead>
    <tr>
      <th scope="col">Course</th>
      <th scope="col">Q1</th>
      <th scope="col">Q2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">HTML</th>
      <td>128</td>
      <td>164</td>
    </tr>
    <tr>
      <th scope="row">CSS</th>
      <td>96</td>
      <td>131</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <th scope="row">Total</th>
      <td>224</td>
      <td>295</td>
    </tr>
  </tfoot>
</table>
```

Six elements, and each earns its place.

`caption` names the table, and it goes **first**, immediately after the opening `table` tag. It is the table''s heading: a screen reader reads it before anything else, so somebody skipping through the page knows whether to stop. It is the single most valuable line in the whole example and the one most often left out.

`thead`, `tbody` and `tfoot` group the rows. They let a long table scroll its body under a fixed head in CSS, they let a printer repeat the header row on each page, and they tell assistive technology which row is the header.

`tr` is a row. `th` is a header cell, `td` is a data cell.

## scope is what makes it readable

This is the part that changes the experience, and it is one attribute.

`scope="col"` on a header cell says it heads the column beneath it. `scope="row"` says it heads the row beside it. With them, a screen reader reading the cell `164` announces **"HTML, Q2, 164"** - it looks up the row header and the column header and reads them with the value.

Without them, it reads "164". Then "96". Then "131". The numbers are all there and none of them mean anything.

The rule: every `th` gets a `scope`. There is no case where you want a header cell that heads nothing.

## colspan and rowspan

A cell can span several columns or rows when the data genuinely merges.

```html
<table>
  <caption>Timetable</caption>
  <thead>
    <tr>
      <th scope="col">Time</th>
      <th scope="col">Monday</th>
      <th scope="col">Tuesday</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">09:00</th>
      <td colspan="2">Induction, both days</td>
    </tr>
    <tr>
      <th scope="row">11:00</th>
      <td>HTML</td>
      <td>CSS</td>
    </tr>
  </tbody>
</table>
```

The arithmetic has to work: each row''s cells, counting spans, must add up to the same total. A row that comes to four columns in a three-column table does not produce an error - the browser widens the table and the layout quietly goes wrong from that row down.

Use them when the data merges, not to achieve a visual effect. Heavily merged tables are hard to read aloud, and at that point the data usually wants splitting into two simpler tables.

## When the headers are not simple

For a table with two levels of column headers, `scope` is not enough to express which header belongs to which cell. The explicit form uses `id` on the headers and `headers` on the cells.

```html
<table>
  <caption>Revenue by region and quarter</caption>
  <tbody>
    <tr>
      <td></td>
      <th scope="col" id="h-q1">Q1</th>
      <th scope="col" id="h-q2">Q2</th>
    </tr>
    <tr>
      <th scope="row" id="h-north">North</th>
      <td headers="h-north h-q1">1204</td>
      <td headers="h-north h-q2">1388</td>
    </tr>
    <tr>
      <th scope="row" id="h-south">South</th>
      <td headers="h-south h-q1">980</td>
      <td headers="h-south h-q2">1102</td>
    </tr>
  </tbody>
</table>
```

Every cell names the headers that apply to it, by id. It is verbose, and the verbosity is the signal: if a table needs this, it is complex enough that a reader may need the simpler version too.

## Styling whole columns

A table is built out of rows, so there is no element that contains a column - which makes styling one awkward. `colgroup` and `col` exist for exactly that.

```html
<table>
  <caption>Marks</caption>
  <colgroup>
    <col>
    <col class="numeric">
    <col class="numeric">
  </colgroup>
  <thead>
    <tr>
      <th scope="col">Student</th>
      <th scope="col">Theory</th>
      <th scope="col">Practical</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Amina</th>
      <td>92</td>
      <td>88</td>
    </tr>
  </tbody>
</table>
```

One `col` per column, in order, and a class on it reaches every cell in that column. Only a few CSS properties apply through `col` - background, border, width and visibility - but those are the ones column styling usually needs.

## Saying a table is sorted

If your table can be sorted, say so in the markup rather than only in an arrow drawn with CSS.

```html
<table>
  <caption>Courses by completions</caption>
  <thead>
    <tr>
      <th scope="col"><button type="button">Course</button></th>
      <th scope="col" aria-sort="descending">
        <button type="button">Completions</button>
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">HTML</th>
      <td>292</td>
    </tr>
    <tr>
      <th scope="row">CSS</th>
      <td>227</td>
    </tr>
  </tbody>
</table>
```

`aria-sort` goes on the header of the column currently sorted, with `ascending`, `descending` or `none`, and only one header carries it at a time. The header''s control is a real `button`, so it is reachable by keyboard without any of the `tabindex` work a clickable `th` would need.

## A table on a phone

A table does not reflow. It is a grid, and a grid 700 pixels wide stays 700 pixels wide on a 360-pixel screen.

The honest fix is to let it scroll horizontally inside a container, and to make that container focusable so a keyboard user can scroll it:

```html
<div role="region" aria-label="Course completions" tabindex="0" style="overflow-x: auto">
  <table>
    <caption>Course completions by quarter</caption>
    <tbody>
      <tr>
        <th scope="row">HTML</th>
        <td>128</td>
        <td>164</td>
      </tr>
    </tbody>
  </table>
</div>
```

The `tabindex="0"` is the part that is usually missing: without it, somebody navigating by keyboard can reach the table but cannot scroll it sideways to see the columns that are off screen.

## Two small things that bite

**The empty corner cell.** A table with both row and column headers has a cell at the top left that belongs to neither. Write it as an empty `td`, as in the headers example above - not as a `th`, which would claim to head something, and not by leaving it out, which shifts every header in that row one column left.

**Never omit a cell.** If a row has no value for a column, write an empty `td` or one containing a dash. Leaving the cell out does not leave a gap: the remaining cells shift left, and every value after it is filed under the wrong header. The table still renders, so nothing says it has happened.

```html
<table>
  <caption>Attendance</caption>
  <tbody>
    <tr>
      <td></td>
      <th scope="col">Monday</th>
      <th scope="col">Tuesday</th>
    </tr>
    <tr>
      <th scope="row">Amina</th>
      <td>Present</td>
      <td>-</td>
    </tr>
  </tbody>
</table>
```

## Practice task

Build a table of your own data - books read this year, expenses by month, anything with rows and columns - with a caption, a `thead`, and `scope` on every header cell. Then turn on your operating system''s screen reader and listen to one data cell. Remove the `scope` attributes and listen again. That difference is the whole lesson.
',
   'A table is the right element for two-dimensional data and the wrong one for layout, and the difference is not aesthetic: a screen reader announces the shape and then reads each cell against its headers. Without a caption and scope it reads a grid of numbers.', 6, 1155, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Module 2 - Forms, Semantics and Media
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000015',
   'HTML Forms: Introduction',
   'markdown',
   '# HTML Forms: Introduction

A form is how a browser sends data somewhere. It is worth saying plainly at the start that this works with no JavaScript whatsoever: the browser gathers the values, encodes them, and sends the request itself. Everything JavaScript adds to a form is an improvement on something that already works.

```html
<form action="/register" method="post">
  <p>
    <label for="full-name">Full name</label>
    <input id="full-name" name="fullName" type="text" required>
  </p>
  <p>
    <label for="email">Email</label>
    <input id="email" name="email" type="email" required>
  </p>
  <p>
    <button type="submit">Create account</button>
  </p>
</form>
```

That is a complete, working, accessible form. Every piece of it is doing something.

## action and method

`action` is the URL the data goes to. Leave it out and the form submits to the current page, which is a reasonable default for a page that handles its own submission.

`method` is how. There are two, and the difference is not stylistic.

**GET** puts the values in the URL as a query string: `/search?q=markup&page=2`. The request is repeatable, bookmarkable and cacheable. Use it for anything that **retrieves** - a search, a filter, a sort.

**POST** puts the values in the request body. The URL does not change, the browser warns before re-submitting, and there is no practical length limit. Use it for anything that **changes** something - creating an account, posting a comment, deleting a record.

The test is whether running the same request twice should do the same thing twice. Searching twice is harmless; registering twice is not.

A warning that belongs here rather than three lessons later: **a form on its own stores nothing and secures nothing.** `method="post"` is not encryption; https is. Required fields can be removed by anybody with developer tools open. Everything a form collects has to be validated again by whatever receives it.

## Labels, and why `for` matters

Every control needs a label, and the label has to be **associated** with it rather than just sitting nearby.

```html
<p>
  <label for="course">Course</label>
  <input id="course" name="course" type="text">
</p>

<p>
  <label>
    Course
    <input name="course-two" type="text">
  </label>
</p>
```

Two valid forms of the same thing. The first pairs `for` with the control''s `id`. The second wraps the control, which needs no ids at all but is harder to style.

The association buys three things. A screen reader announces the label when focus reaches the field, so the user knows what they are typing into. Clicking the label focuses the field, which on a phone turns a 16-pixel checkbox into a target the width of its text. And it is the mechanism that automated testing and autofill both rely on.

A `div` with text above an input gives you none of that. It looks identical and is, functionally, an unlabelled field.

## Placeholder is not a label

The commonest form bug on the modern web, and worth its own heading.

```html
<p>
  <label for="postcode">Postcode</label>
  <input id="postcode" name="postcode" type="text" placeholder="e.g. SW1A 1AA">
</p>
```

A placeholder is a **hint**, shown while the field is empty and gone the moment somebody types. As a label it fails in every direction: it disappears exactly when the user wants to check what they are filling in, it is low-contrast by default, it is inconsistently announced by screen readers, and it leaves a form that has been half-completed looking like a column of unlabelled boxes.

Use a label for the name of the field. Use a placeholder, if at all, for the format.

## The other controls

```html
<form action="/feedback" method="post">
  <p>
    <label for="topic">Topic</label>
    <select id="topic" name="topic">
      <option value="">Choose one</option>
      <option value="content">Course content</option>
      <option value="technical">A technical problem</option>
      <option value="other">Something else</option>
    </select>
  </p>

  <p>
    <label for="message">Message</label>
    <textarea id="message" name="message" rows="5" required></textarea>
  </p>

  <p>
    <button type="submit">Send</button>
    <button type="button">Save draft</button>
  </p>
</form>
```

`select` with `option` children is a menu; the `value` is what gets submitted and the text is what is shown. `textarea` is multi-line text - note that it is **not** a void element and its value goes between the tags, not in a `value` attribute.

`button` has a `type` and you should always set it. Inside a form, a button with no `type` defaults to `submit`, so a "Save draft" button that forgot its `type="button"` submits the form instead. That is a bug that only shows up when someone presses the wrong thing.

## Grouping with fieldset and legend

Some controls only make sense together: a set of radio buttons, a group of related preferences, a section of a long form.

```html
<form action="/signup" method="post">
  <fieldset>
    <legend>How should we contact you?</legend>

    <p>
      <input id="by-email" name="contact" type="radio" value="email" checked>
      <label for="by-email">By email</label>
    </p>
    <p>
      <input id="by-phone" name="contact" type="radio" value="phone">
      <label for="by-phone">By phone</label>
    </p>
    <p>
      <input id="not-at-all" name="contact" type="radio" value="none">
      <label for="not-at-all">Not at all</label>
    </p>
  </fieldset>

  <button type="submit">Save preferences</button>
</form>
```

`fieldset` groups the controls and `legend` names the group. For radio buttons this is not optional: each radio has its own label ("By email"), but without a legend nothing says what the choice is **about**. A screen reader reads "By email, radio button, 1 of 3" and the user has no idea what question they are answering.

Note also that the three radios share one `name`. That is what makes them one group where only one can be chosen; give them different names and you get three independent buttons that cannot be unselected.

## What actually happens on submit

Worth walking through once, because it explains several otherwise mysterious behaviours.

1. The browser **validates** the form against whatever constraints the markup declares. If something fails, it stops, focuses the first invalid control and shows a message - and the submission never happens.
2. It **collects** every control that has a `name` and is not disabled.
3. It **encodes** them. For GET, as a query string on the URL. For POST, as the request body, by default in the same `name=value&name=value` form.
4. It **navigates**. A form submission is a page navigation, which is why the page reloads and why anything held only in JavaScript is lost.

Point four is the one that surprises people. Unless a script calls `preventDefault`, submitting a form means leaving the page.

A submit button can override the form''s own settings, which is how one form offers two destinations:

```html
<form action="/entries" method="post">
  <p>
    <label for="title">Title</label>
    <input id="title" name="title" type="text" required>
  </p>
  <button type="submit">Publish</button>
  <button type="submit" formaction="/entries/draft">Save as draft</button>
  <button type="submit" formnovalidate>Save without checking</button>
</form>
```

`formaction` sends this submission somewhere else. `formnovalidate` skips validation for this button only, which is exactly what a "save draft" needs - a half-finished form should still be storable.

## Practice task

Build a contact form with a name, an email, a topic `select`, a message `textarea` and a fieldset of radio buttons. Give every control a real `label` with a matching `for`. Then try the form using only the keyboard: Tab through it, use the arrow keys on the radio group, and submit with Enter. Anything you cannot reach or operate is a bug, and the fix is almost always a missing label or a wrong element.
',
   'A form is the only way a browser sends data back on its own, with no JavaScript involved at all. Most of the work is in two attributes on the form and one relationship between a label and its control.', 6, 1159, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000134',
   'Basic Input Types',
   'markdown',
   '# Basic Input Types

`input` is one element that becomes about twenty different controls depending on its `type`. Choosing the right one is the cheapest improvement available in a form: it changes the on-screen keyboard a phone offers, it enables validation you would otherwise write by hand, and it lets the browser autofill from what it already knows.

The default is `type="text"`, which is what you get if you omit it entirely.

## The text-like types

```html
<form action="/profile" method="post">
  <p>
    <label for="username">Username</label>
    <input id="username" name="username" type="text" autocomplete="username" required>
  </p>
  <p>
    <label for="password">Password</label>
    <input id="password" name="password" type="password" autocomplete="new-password" required>
  </p>
  <p>
    <label for="email">Email</label>
    <input id="email" name="email" type="email" autocomplete="email" required>
  </p>
  <p>
    <label for="phone">Phone</label>
    <input id="phone" name="phone" type="tel" autocomplete="tel">
  </p>
  <p>
    <label for="site">Website</label>
    <input id="site" name="site" type="url" placeholder="https://example.com">
  </p>
  <p>
    <label for="age">Age</label>
    <input id="age" name="age" type="number" min="13" max="120" step="1">
  </p>
  <button type="submit">Save</button>
</form>
```

Each type earns its keep:

`email` validates that the value looks like an address and shows a keyboard with `@` on a phone. `tel` shows a numeric keypad but does **not** validate, deliberately - phone number formats vary too much for a useful rule. `url` validates for a scheme and host. `number` gives a numeric keyboard, accepts `min`, `max` and `step`, and provides spinner buttons.

`password` masks the characters on screen. It is worth being explicit that this is all it does: the value is submitted exactly like any other field, and what protects it in transit is https.

A caution about `number`: it is for quantities you would do arithmetic with. It is wrong for anything that merely looks numeric - a credit card number, a postcode, a phone number - because it strips leading zeros, accepts exponent notation, and some browsers let a scroll wheel change the value. For those, `type="text"` with `inputmode="numeric"` gives the numeric keyboard without the arithmetic.

## Choices: checkbox and radio

```html
<form action="/preferences" method="post">
  <fieldset>
    <legend>Email me about</legend>
    <p>
      <input id="new-courses" name="topics" type="checkbox" value="courses" checked>
      <label for="new-courses">New courses</label>
    </p>
    <p>
      <input id="new-articles" name="topics" type="checkbox" value="articles">
      <label for="new-articles">New articles</label>
    </p>
  </fieldset>

  <fieldset>
    <legend>Email frequency</legend>
    <p>
      <input id="weekly" name="frequency" type="radio" value="weekly" checked>
      <label for="weekly">Weekly</label>
    </p>
    <p>
      <input id="monthly" name="frequency" type="radio" value="monthly">
      <label for="monthly">Monthly</label>
    </p>
  </fieldset>

  <button type="submit">Save</button>
</form>
```

**Checkboxes are independent.** Several can share a name, and every checked one is submitted - so `topics` arrives as a list.

**Radios are exclusive.** Sharing a name is what makes them one group, and exactly one value is submitted. Once a radio group has a selection, the user cannot clear it without a reload, so always pre-select a sensible default or include an explicit "none of these" option.

Both submit their `value` attribute, and both submit **nothing at all** when unchecked - not an empty string, not false. Code on the receiving end has to treat absence as the "off" state.

## Dates and times

```html
<form action="/booking" method="post">
  <p>
    <label for="start">Start date</label>
    <input id="start" name="start" type="date" min="2026-01-01" max="2026-12-31">
  </p>
  <p>
    <label for="at">Time</label>
    <input id="at" name="at" type="time">
  </p>
  <p>
    <label for="week">Week</label>
    <input id="week" name="week" type="week">
  </p>
  <p>
    <label for="shade">Highlight colour</label>
    <input id="shade" name="shade" type="color" value="#11785f">
  </p>
  <p>
    <label for="volume">Volume</label>
    <input id="volume" name="volume" type="range" min="0" max="100" value="50">
  </p>
  <button type="submit">Book</button>
</form>
```

`date` gives a date picker and submits `YYYY-MM-DD` regardless of how it was displayed - which is the real benefit, since it removes the ambiguity between 03/04 as March the fourth and the third of April. `time` submits `HH:MM`. `color` submits a hex value. `range` is a slider, and it is worth remembering that a slider gives no visible number, so it suits values where the exact figure does not matter.

## Files, hidden fields and buttons

```html
<form action="/upload" method="post" enctype="multipart/form-data">
  <p>
    <label for="avatar">Profile picture</label>
    <input id="avatar" name="avatar" type="file" accept="image/png, image/jpeg">
  </p>

  <input type="hidden" name="formVersion" value="3">

  <p>
    <button type="submit">Upload</button>
  </p>
</form>
```

`file` opens a file picker, and `accept` filters what it shows. A form containing one must have `enctype="multipart/form-data"`, or the browser sends the filename instead of the file - a silent failure that looks like a server bug.

`hidden` carries a value the user does not edit. It is not secret and it is not trustworthy: it is in the page source and anybody can change it before submitting. Treat it as a convenience for your own code, never as a security measure.

`type="reset"` exists and is best avoided: it clears the form, it sits next to the submit button, and the only people who press it are the ones who meant to press submit.

## name is what makes a field exist

```html
<form action="/search" method="get">
  <label for="q">Search</label>
  <input id="q" name="q" type="search">
  <input id="scope" type="search">
  <button type="submit">Search</button>
</form>
```

Submit that and the URL contains `?q=whatever`. The second field is missing entirely - **a control with no `name` is not submitted**. It is a real bug and a quiet one, because the field looks and behaves normally right up until the data arrives without it.

`id` and `name` are different things doing different jobs: `id` is for the label and for CSS, `name` is the key the value is submitted under. They are often given the same string, which makes it easy to assume one implies the other.

## autocomplete and inputmode

Two attributes that cost nothing and make a form noticeably faster to fill in.

`autocomplete` names what a field is **for**, from a fixed vocabulary, so the browser can offer the value it already holds. Guessing from the `name` attribute is what browsers did before it existed, and they guessed badly.

```html
<form action="/checkout" method="post">
  <p>
    <label for="cc-name">Name on card</label>
    <input id="cc-name" name="ccName" type="text" autocomplete="cc-name">
  </p>
  <p>
    <label for="cc-number">Card number</label>
    <input id="cc-number" name="ccNumber" type="text" inputmode="numeric"
           autocomplete="cc-number">
  </p>
  <p>
    <label for="postal">Postcode</label>
    <input id="postal" name="postal" type="text" autocomplete="postal-code">
  </p>
  <p>
    <label for="otp">One-time code</label>
    <input id="otp" name="otp" type="text" inputmode="numeric"
           autocomplete="one-time-code">
  </p>
  <button type="submit">Pay</button>
</form>
```

The vocabulary covers names, addresses, phone numbers, payment details and credentials: `given-name`, `family-name`, `street-address`, `postal-code`, `country`, `tel`, `email`, `username`, `current-password`, `new-password`, `one-time-code`. That last one is the reason a verification code can be filled from a text message on a phone.

`inputmode` chooses the on-screen keyboard without changing the input''s type or its validation. `inputmode="numeric"` on a `type="text"` field gives the number pad while keeping leading zeros and avoiding the spinner - which is the right combination for codes, card numbers and postcodes.

One place to think before switching autofill off: `autocomplete="off"` is widely ignored by browsers on login and payment fields, because switching it off there was mostly used to stop password managers working. Use it for genuinely one-off values, not as a habit.

## Practice task

Build a registration form using at least six different input types, each with a label and an `autocomplete` value. Open it on a phone, or in the device emulator in developer tools, and tap through the fields - watch the keyboard change between the text, email, numeric and telephone fields. Then submit it with `method="get"` and read the query string: every field you expected should be there, and any missing one has lost its `name`.
',
   'One element, twenty-odd behaviours. Choosing the right type changes the keyboard a phone shows, the validation the browser performs for free, and whether autofill can help - and costs exactly one word.', 6, 1168, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000135',
   'Advanced Forms',
   'markdown',
   '# Advanced Forms

The browser has a complete validation engine built into it. It checks values as they are typed, blocks submission when something is wrong, focuses the first bad field and shows a message in the user''s own language - all declared in markup, with no script.

Most form JavaScript on the web reimplements some part of that, usually worse.

## Constraint validation

```html
<form action="/register" method="post">
  <p>
    <label for="code">Access code</label>
    <input id="code" name="code" type="text"
           minlength="4" maxlength="12" required>
  </p>
  <p>
    <label for="quantity">How many seats?</label>
    <input id="quantity" name="quantity" type="number"
           min="1" max="20" step="1" value="1" required>
  </p>
  <p>
    <label for="username">Username</label>
    <input id="username" name="username" type="text"
           pattern="[a-z0-9_]{3,16}" required
           title="Three to sixteen lower-case letters, numbers or underscores">
  </p>
  <button type="submit">Register</button>
</form>
```

`required` means it cannot be empty. `minlength` and `maxlength` bound the length; `min`, `max` and `step` bound a number or a date. `pattern` is a regular expression the whole value must match.

Two things about `pattern` that are worth knowing before you use it. The expression is implicitly anchored, so it has to match the entire value - no need for start and end markers. And **always pair it with `title`**: when the pattern fails, the browser''s message is generic unless `title` supplies a description, and "Please match the requested format" helps nobody.

A validation message can also be styled by targeting the state, since CSS can see it: `input:invalid` and `input:valid` match as the user types. One refinement worth adopting is `input:user-invalid`, which only matches **after** somebody has interacted with the field - so an empty required field is not shown as an error before they have had a chance to fill it in.

## Turning validation off, deliberately

```html
<form action="/draft" method="post" novalidate>
  <p>
    <label for="title">Title</label>
    <input id="title" name="title" type="text" required>
  </p>
  <button type="submit">Save draft</button>
</form>
```

`novalidate` on the form switches the browser''s checking off for the whole thing. That sounds like throwing away the feature, and there are two good reasons for it: a half-finished draft should still save, and a script that provides richer inline messages needs the browser to stop interrupting with its own. The constraints stay in the markup either way, which matters because a script can still read them.

## Attributes that help the user rather than the validator

```html
<form action="/support" method="post">
  <p>
    <label for="ticket">Ticket reference</label>
    <input id="ticket" name="ticket" type="text" value="OMN-4821" readonly>
  </p>
  <p>
    <label for="plan">Plan</label>
    <input id="plan" name="plan" type="text" value="Team" disabled>
  </p>
  <p>
    <label for="browser">Which browser?</label>
    <input id="browser" name="browser" type="text" list="browsers">
    <datalist id="browsers">
      <option value="Chrome"></option>
      <option value="Firefox"></option>
      <option value="Safari"></option>
      <option value="Edge"></option>
    </datalist>
  </p>
  <button type="submit">Send</button>
</form>
```

`readonly` shows a value that cannot be edited but **is** submitted. `disabled` shows a value that cannot be edited and is **not** submitted, and is skipped by the keyboard entirely. The difference matters: a disabled field that the server expects arrives missing.

`datalist` offers suggestions without restricting the value - it is a text field with a list attached, not a `select`. Use it when the common answers are known but the list is not exhaustive.

## multiple, accept and output

```html
<form action="/apply" method="post" enctype="multipart/form-data">
  <p>
    <label for="docs">Supporting documents</label>
    <input id="docs" name="docs" type="file" accept=".pdf,image/*" multiple>
  </p>
  <p>
    <label for="referees">Referee emails</label>
    <input id="referees" name="referees" type="email" multiple
           placeholder="comma separated">
  </p>
  <p>
    <label for="budget">Budget</label>
    <input id="budget" name="budget" type="range" min="0" max="5000" value="1500">
    <output for="budget" name="shown">1500</output>
  </p>
  <button type="submit">Apply</button>
</form>
```

`multiple` lets a file input take several files and an email input take a comma-separated list. `accept` hints which file types the picker should show - a hint, not a restriction, so the server still has to check what it receives.

`output` is the element for a value your page has calculated - the number next to a slider, a running total, a conversion. It has an implicit live region, which means a screen reader announces it when it changes without any extra attributes. Writing the same number into a `span` is silent.

## Encoding, and what the server receives

A form''s `enctype` decides how the body is built.

| enctype | When |
|---|---|
| `application/x-www-form-urlencoded` | The default. Everything except file uploads. |
| `multipart/form-data` | Required whenever the form contains a file input. |
| `text/plain` | For debugging only; never parse this on a server. |

Forget `multipart/form-data` on a form with a file input and the browser sends the **filename** as a plain text value. Nothing errors. The upload simply never arrives, and the bug is usually hunted in the server for a while before anybody looks at the form tag.

## Controls that live outside their form

A control does not have to be inside the `form` element it belongs to. The `form` attribute names it by id, which is what lets a submit button sit in a sticky footer while the fields are in a dialog.

```html
<form id="settings" action="/settings" method="post">
  <p>
    <label for="display-name">Display name</label>
    <input id="display-name" name="displayName" type="text" required>
  </p>
</form>

<p>Elsewhere in the page entirely:</p>
<button type="submit" form="settings">Save settings</button>
```

`autofocus` is the related attribute, and the one to use sparingly: it moves focus on page load, which is helpful on a page whose only purpose is one search box and disorienting anywhere else, because it moves a screen reader user past everything above it without saying so.

## Validation is not security

This section matters more than everything above it.

Everything in this lesson runs in the user''s browser, and the user controls their browser. Developer tools can remove `required`, change `max`, edit a `hidden` value and submit whatever they like. A request does not even have to come from your form - anyone can post to your endpoint directly.

So the rules are:

- **Validate again on the server**, for every field, every time. Treat the browser''s checks as a courtesy to honest users.
- **Authorise as well as validate.** "Is this value well-formed?" and "is this person allowed to do this to this record?" are different questions, and only the second one stops somebody editing an order that is not theirs.
- **Check uploads by content, not by name.** `accept=".pdf"` is a filter in the file picker. The server has to limit size, verify the real type, and store the file somewhere it cannot be executed.
- **Encode on output.** Anything a user submitted that gets rendered back into a page has to be escaped, or you have built a cross-site scripting hole. There is a whole lesson on this later.

Client-side validation exists to save a round trip and tell somebody about a typo immediately. It is a usability feature that happens to look like a security feature, which is what makes it dangerous.

## Practice task

Take the registration form you built in the last lesson and add constraints: a `pattern` with a `title` on the username, `min` and `max` on a number, `minlength` on the password. Submit it with bad values and read the messages the browser produces. Then open developer tools, delete the `required` attributes from the DOM, and submit again - watch it go through. That is the demonstration of why the server has to check too.
',
   'The browser will validate, describe and autofill a form for you if you let it. Most of the JavaScript written for forms re-implements something that was already there, and does it worse - without keyboard support, and without saying what went wrong.', 6, 1175, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000017',
   'Semantic HTML',
   'markdown',
   '# Semantic HTML

A `div` is an element with no meaning. That is its purpose: it is a box for grouping things when no better element exists. The trouble is that it is also the easiest element to type, so pages get built entirely out of boxes, and then nothing about them says what anything is.

Semantic elements are the alternative. They look identical by default - a `header` and a `div` render the same - and they differ in what they tell every machine that reads the page.

## The landmarks

Five elements carve a page into regions that assistive technology can navigate between.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Semantic layout</title>
  </head>
  <body>
    <a class="skip-link" href="#main">Skip to content</a>

    <header>
      <a href="/">Omni Academy</a>
      <nav aria-label="Main">
        <ul>
          <li><a href="/courses">Courses</a></li>
          <li><a href="/about">About</a></li>
        </ul>
      </nav>
    </header>

    <main id="main">
      <h1>Semantic HTML</h1>
      <p>The primary content of the page goes here, once.</p>
    </main>

    <aside aria-label="Related">
      <h2>Related lessons</h2>
      <ul>
        <li><a href="/lessons/accessibility">Accessibility</a></li>
      </ul>
    </aside>

    <footer>
      <p>Omni Academy</p>
    </footer>
  </body>
</html>
```

`header` is introductory content - a masthead, or the top of an article. `nav` is a block of navigation links. `main` is the page''s primary content. `aside` is tangential: related links, a pull quote, an advertisement. `footer` is closing information.

Three rules govern them:

**One `main` per page**, and it should not be inside any of the others. It is the target of the skip link and the first thing a screen reader user jumps to.

**`header` and `footer` can repeat.** At the top level of the body they mean the page''s header and footer; inside an `article` they mean that article''s. The context decides.

**Label repeated landmarks.** Two `nav` elements on a page are announced as "navigation" and "navigation" unless `aria-label` distinguishes them.

A screen reader user can list every landmark and jump straight to one. That is how somebody skips a navigation menu they have already heard on the previous eight pages - and on a page built from `div` elements there is nothing to list.

## Sectioning content

```html
<main>
  <h1>Course notes</h1>

  <article>
    <header>
      <h2>Why semantics matter</h2>
      <p>Published <time datetime="2026-03-14">14 March 2026</time></p>
    </header>

    <p>An article is content that would still make sense somewhere else.</p>

    <section>
      <h3>In a feed</h3>
      <p>A section is a thematic grouping that belongs where it is.</p>
    </section>

    <footer>
      <p>Written by Lena.</p>
    </footer>
  </article>
</main>
```

`article` is content that is **independently distributable**: a blog post, a news story, a comment, a product card. The test is whether it would still make sense syndicated into a feed on its own.

`section` is a thematic grouping **within** something - a chapter of a document, a part of a form. It is not a generic container: a `section` should have a heading, and if you cannot think of one, you wanted a `div`.

The difference catches people out, and the heading test is the reliable version: an article is a thing, a section is part of a thing.

## details and summary

A disclosure widget, with no JavaScript at all.

```html
<details>
  <summary>What is a void element?</summary>
  <p>An element that cannot have content, such as img, br or input.
     It has a start tag and no end tag.</p>
</details>

<details open>
  <summary>Does this need JavaScript?</summary>
  <p>No. The browser handles the toggling, the keyboard and the announcement.</p>
</details>
```

The `summary` is the always-visible label; everything else is revealed when it opens. It is focusable, it toggles on Enter and Space, it is announced with its expanded state, and `open` makes it start expanded. A hand-built accordion needs a button, `aria-expanded`, a keyboard handler and a script to match; this needs two tags.

One limitation worth knowing: `details` cannot be animated open in most browsers, and content inside a closed `details` is not findable by the browser''s own Find on page in older versions. If either matters, that is the reason to build it by hand.

## Time, mark, and the small ones

```html
<article>
  <h2>Release notes</h2>
  <p>Shipped <time datetime="2026-10-11T09:30">this morning</time>.</p>
  <p>The release fixes the <mark>form validation</mark> bug reported last week.</p>
  <address>
    Questions to <a href="mailto:support@example.com">support@example.com</a>.
  </address>
</article>
```

`time` holds a machine-readable value in `datetime` while displaying whatever reads naturally. `mark` highlights text relevant to the reader''s current activity - the match in a set of search results, not permanent emphasis. `address` gives contact details for the nearest `article`, or for the page when it is not inside one.

## Sectioning does not fix your headings

There was once a plan for an outline algorithm: nest a `section` and its `h1` would automatically become a second-level heading, so you could write `h1` everywhere and let the structure sort itself out.

It was never implemented by any browser or screen reader, and it has been removed from the specification. The advice that followed from it is still repeated, so it is worth being direct: **nesting a section does not change what an `h1` means.** Heading levels are what you write, and nothing adjusts them.

```html
<main>
  <h1>Course notes</h1>
  <section aria-labelledby="forms-heading">
    <h2 id="forms-heading">Forms</h2>
    <p>Still a second-level heading, because it says h2.</p>
  </section>
</main>
```

Note `aria-labelledby` on the section, pointing at its own heading. That is what gives the region a name in the landmark list; a `section` without one is announced as an unnamed region, which is no more useful than a `div`.

## An element beats a role

ARIA can put a role on any element: `role="button"`, `role="navigation"`, `role="main"`. It exists for the cases where no element fits.

The first rule of ARIA, from the specification itself, is not to use it when an element will do. A `button` gives you focus, Enter, Space, the disabled state and the announcement. A `div role="button"` gives you the announcement and nothing else - you now owe `tabindex`, a keydown handler for two keys, and a focus style, and each is a chance to get it wrong.

Reach for a role when you are building something HTML has no element for. Reach for the element every other time.

## What a div is still for

Semantic markup is not a competition to eliminate every `div`. A `div` is correct whenever you need a box purely to hang layout or styling on and no element describes what is inside it.

```html
<section aria-labelledby="pricing">
  <h2 id="pricing">Pricing</h2>
  <div class="grid">
    <article class="plan">
      <h3>Free</h3>
      <p>Everything in the catalogue.</p>
    </article>
    <article class="plan">
      <h3>Team</h3>
      <p>Progress reporting for a group.</p>
    </article>
  </div>
</section>
```

The `div` there exists to be a CSS grid container. It describes nothing, which is exactly right, because "the thing that makes these sit in two columns" is not a fact about the content.

## Practice task

Take any page you have built and mark its regions: `header`, `nav`, `main`, `footer`, with `aside` if it has one. Add a skip link at the very top pointing at `#main`. Then open the accessibility tree in developer tools - in Chrome it is in the Elements panel - and look at the landmark list. If it is empty, nothing on your page has told a screen reader where anything is.
',
   'Semantic elements are how a page says what its parts are. The practical payoff is a set of landmarks a screen reader user can jump between - which is how they skip a navigation menu they have already heard on every other page.', 6, 1170, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000136',
   'HTML5 Features',
   'markdown',
   '# HTML5 Features

"HTML5" names a set of capabilities that arrived in markup rather than in a library: media without a plugin, form validation without a script, graphics without an image file, and several interactive elements that previously took a few hundred lines of JavaScript each.

They are worth a tour in one place, because the usual way to discover them is to build the hand-made version first.

## dialog

A real modal dialog, with the behaviour that is hard to get right by hand.

```html
<dialog id="confirm">
  <form method="dialog">
    <h2>Delete this draft?</h2>
    <p>This cannot be undone.</p>
    <button value="cancel">Keep it</button>
    <button value="delete">Delete</button>
  </form>
</dialog>

<button type="button" onclick="document.getElementById(''confirm'').showModal()">
  Delete draft
</button>
```

Opened with `showModal()`, a dialog does four things a hand-built overlay usually forgets: it traps focus inside itself, it makes everything behind it inert so a click or a Tab cannot reach it, it closes on Escape, and it gets a backdrop you can style with `::backdrop`.

`method="dialog"` on a form inside it is the neat part: submitting closes the dialog without navigating anywhere, and the pressed button''s `value` is available afterwards as the dialog''s `returnValue`.

Two notes. `show()` opens it non-modally, without the focus trap, which is usually not what you want. And the element needs a heading or an `aria-label`, or it is announced as an unnamed dialog.

## template

Markup the browser parses but does not render.

```html
<template id="course-card">
  <article class="card">
    <h3 class="title"></h3>
    <p class="summary"></p>
    <a class="link" href="#">Explore</a>
  </article>
</template>

<ul id="courses"></ul>
```

Everything inside a `template` is parsed into a document fragment and stays inert: images are not fetched, scripts do not run, styles do not apply, and nothing appears on the page. A script clones it with `template.content.cloneNode(true)`, fills in the blanks and inserts the copy.

The alternative is building HTML by string concatenation in JavaScript, which is both harder to read and the usual route to an injection bug. A template keeps the markup in the markup.

## details and summary

Covered in the semantics lesson and worth repeating here as a feature rather than as a semantic: a disclosure widget with no script.

```html
<details>
  <summary>Show the full specification</summary>
  <p>The content appears when the summary is activated, and the browser
     handles the keyboard, the focus and the announcement.</p>
</details>
```

## canvas

A drawing surface. The element itself is two attributes and an empty box; everything that appears on it is drawn by script.

```html
<canvas id="sparkline" width="300" height="80">
  Enrolments rose steadily through the year, from 40 in January to 290 in December.
</canvas>
```

The text inside is the fallback, and it is the part people miss. A canvas is a bitmap: there are no elements inside it, so a screen reader has nothing whatever to read. Whatever the drawing communicates has to be available in the markup as well, either as that fallback content or as a table nearby.

Use canvas for things that change every frame - a game, a visualisation of thousands of points, video processing. For anything static or interactive, SVG is usually the better answer.

## Inline SVG

Vector graphics written as markup, so they are elements like any others.

```html
<figure>
  <svg width="220" height="90" viewBox="0 0 220 90" role="img"
       aria-label="Enrolments rose from 40 in January to 290 in December">
    <polyline points="10,80 60,62 110,45 160,28 210,12"
              fill="none" stroke="currentColor" stroke-width="3"></polyline>
    <circle cx="210" cy="12" r="4" fill="currentColor"></circle>
  </svg>
  <figcaption>Enrolments, January to December</figcaption>
</figure>
```

Because the shapes are elements, CSS can style them and scripts can attach events to them. `stroke="currentColor"` inherits the surrounding text colour, so the chart follows a dark mode without any extra work. `viewBox` is what makes it scale: it defines the coordinate system, and the `width` and `height` then just say how big to draw it.

`role="img"` with `aria-label` gives the whole graphic a single text alternative. Without them, a screen reader may try to read the individual shapes, which is noise.

## Media, in one line

```html
<p>
  <audio controls src="lesson.mp3">
    Your browser cannot play audio.
  </audio>
</p>
```

Audio and video are covered properly in the next lesson. The point here is the contrast: embedding media used to mean a plugin, an `object` tag and a fallback chain. It is now one element with a `controls` attribute.

## Two more that save a script each

```html
<p>
  <label for="upload">Uploading</label>
  <progress id="upload" value="64" max="100">64%</progress>
</p>

<p>
  <label for="disk">Disk used</label>
  <meter id="disk" value="0.82" low="0.5" high="0.8" optimum="0.2">82%</meter>
</p>

<p>
  <label for="browser">Browser</label>
  <input id="browser" name="browser" type="text" list="browser-options">
  <datalist id="browser-options">
    <option value="Chrome"></option>
    <option value="Firefox"></option>
  </datalist>
</p>
```

`progress` is a task advancing towards completion - an upload, an install. Omit `value` and it becomes an indeterminate spinner, which is the right thing when you genuinely do not know how long is left.

`meter` is a measurement within a known range, which is a different idea: disk usage, a score, a temperature. `low`, `high` and `optimum` let the browser colour it, and `optimum` is what tells it which end is good - so a meter where low values are better is expressed rather than inverted by hand.

The text inside each is the fallback for a browser that does not render them.

## Obsolete elements

The other half of "modern HTML" is what has been retired.

| Obsolete | Use instead |
|---|---|
| `font`, `center`, `big`, `strike` | CSS |
| `frameset`, `frame` | CSS layout, or `iframe` for genuinely separate documents |
| `marquee`, `blink` | CSS animation, and usually nothing at all |
| `applet` | Nothing; the plugin era is over |
| `acronym` | `abbr` |

They mostly still render, because browsers do not break old pages. That is not a reason to write new ones: each puts presentation back into the markup layer, and `frameset` additionally breaks bookmarking, the Back button and search indexing.

## Checking support

Features arrive at different times in different browsers, and the reliable answer to "can I use this?" is a compatibility table rather than a specification - the specification says what should exist, the table says what does.

The markup-level fallback pattern is worth knowing, because it is built into most of these elements. A `canvas` falls back to its contents. A `video` falls back to its contents. A `picture` falls back to its `img`. An unknown element renders as an inline box with its contents visible, which is why a `dialog` in a very old browser shows its content rather than hiding it - and why `dialog` is one to feature-detect before relying on.

## Practice task

Build a page with a `details` FAQ, a `dialog` that confirms an action, and an inline `svg` icon that inherits the text colour. Open the dialog and press Escape, then Tab repeatedly and confirm focus never leaves it. Then look at the `canvas` example above and write the fallback sentence you would need if the drawing were a real chart - that sentence is what a screen reader user gets, and writing it is usually the moment you realise what the chart is actually for.
',
   'A tour of what modern HTML gives you without a library: a dialog that traps focus, a disclosure widget, a drawing surface, inline vector graphics and a template the browser parses but does not render.', 6, 1168, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000137',
   'Audio and Video',
   'markdown',
   '# Audio and Video

Playing media in a browser once meant a plugin, a fallback chain and a prayer. It is now two elements that work everywhere.

```html
<video controls width="640" poster="lesson-preview.jpg">
  <source src="lesson.webm" type="video/webm">
  <source src="lesson.mp4" type="video/mp4">
  <track kind="captions" src="lesson-en.vtt" srclang="en" label="English" default>
  <p>Your browser cannot play this video.
     <a href="lesson.mp4">Download it instead</a>.</p>
</video>
```

Everything in that example is doing something, and the pieces are worth taking one at a time.

## controls, and what happens without it

`controls` gives the browser''s own play button, scrubber, volume and fullscreen. Without it the media is invisible and inert unless a script drives it.

The browser''s controls are keyboard accessible, screen reader accessible, and translated. A custom control bar has to reimplement all of that, and most do not. Build your own when the design genuinely requires it, and then test it with the keyboard before anything else.

## Several sources, one element

```html
<audio controls>
  <source src="episode.opus" type="audio/ogg; codecs=opus">
  <source src="episode.m4a" type="audio/mp4">
  <source src="episode.mp3" type="audio/mpeg">
  <p>Your browser cannot play audio.
     <a href="episode.mp3">Download the episode</a>.</p>
</audio>
```

The browser walks the `source` list in order and takes the **first one it can play**, using the `type` attribute to decide without downloading anything. Order them best-first: the efficient modern format first, the universally supported one last.

For video that pairing is usually WebM then MP4; for audio, Opus then MP3. If you only ship one format, MP4 with H.264 and MP3 are the safest, at a cost in file size.

Anything after the sources that is not a `source` or a `track` is **fallback content**, shown only when the element itself is unsupported. A download link there is more useful than a sentence of apology.

## poster, autoplay, muted, loop and preload

```html
<video controls muted loop playsinline
       poster="loop-preview.jpg" preload="metadata" width="480">
  <source src="background.mp4" type="video/mp4">
  <p>A short looping clip of the campus.</p>
</video>
```

`poster` is the still shown before playback starts. Without it, browsers show either a blank box or the first frame, which is often black.

`preload` hints how much to fetch up front: `none`, `metadata` or `auto`. `metadata` is the useful default - enough to know the duration and show the scrubber, without pulling megabytes for a video nobody plays.

`autoplay` requests automatic playback and is **blocked by every browser** unless the video is also `muted`. This is deliberate: sound starting on its own is the single most complained-about behaviour on the web. If you need an autoplaying clip, it must be muted, and it should be short, looping and decorative.

`playsinline` stops iOS taking a playing video fullscreen, which is what you want for a background clip and not for a feature film.

`loop` repeats. Combine with `muted` and `autoplay` for a background video and with nothing else, ever.

## Captions, and why this is the important section

```html
<video controls width="640" poster="interview-preview.jpg">
  <source src="interview.mp4" type="video/mp4">
  <track kind="captions" src="interview-en.vtt" srclang="en" label="English" default>
  <track kind="subtitles" src="interview-ar.vtt" srclang="ar" label="العربية">
  <track kind="descriptions" src="interview-described.vtt" srclang="en" label="Audio descriptions">
  <p>Your browser cannot play this video.</p>
</video>
```

`track` attaches a timed text file - a WebVTT file, which is a plain text list of timestamps and lines. Four kinds matter:

- **`captions`** are for people who cannot hear the audio. They include speech *and* the other sounds that carry meaning: a door closing, music starting, laughter.
- **`subtitles`** are a translation for people who can hear but do not speak the language.
- **`descriptions`** narrate what is happening on screen, for people who cannot see it.
- **`chapters`** give named points to jump between.

`default` marks the track shown without the viewer choosing one.

Captions are the attribute most often skipped and the one with the widest reach. They are necessary for deaf and hard-of-hearing viewers, and they are used far more broadly than that: on a phone in a quiet carriage, in a loud room, by anybody watching in their second language, and by search engines, which index the caption text and cannot index the audio.

A WebVTT file is simple enough to write by hand:

    WEBVTT

    00:00:00.000 --> 00:00:04.000
    Welcome to the HTML course.

    00:00:04.000 --> 00:00:09.500
    We will start with the document skeleton.

One thing to know about `track`: it is subject to the same-origin policy, so a caption file on another domain needs CORS headers, and locally a `file://` page will refuse to load it. Test captions over a real server, even a local one.

## A transcript is not the same as captions

Captions sit on the video, timed to it. A **transcript** is the whole text, on the page, readable without playing anything.

```html
<figure>
  <video controls width="560" poster="talk-preview.jpg">
    <source src="talk.mp4" type="video/mp4">
    <track kind="captions" src="talk-en.vtt" srclang="en" label="English" default>
    <p>Your browser cannot play this video.</p>
  </video>
  <figcaption>Why markup carries meaning - a fifteen-minute talk</figcaption>
</figure>

<details>
  <summary>Read the transcript</summary>
  <p><strong>Lena:</strong> The thing people miss about HTML is that it is the
     only layer that says what anything is.</p>
  <p><strong>Lena:</strong> CSS can make a div look like a heading. It cannot
     make it one.</p>
</details>
```

Both are worth having and they serve different people. Captions help somebody watching. A transcript helps somebody who would rather read, somebody skimming for one fact, somebody on a connection where the video will not load, and the search engine - which can index the transcript as page text but cannot index a caption file as readily.

Putting it in a `details` keeps it out of the way without hiding it from anything: the text is in the document whether or not the widget is open.

## Media is heavy

A video is almost always the largest thing on a page. Three habits keep that in proportion:

**Do not autoplay what nobody asked for.** It costs the visitor their data allowance for something they may never watch.

**Use `preload="metadata"`** unless you are confident the media will be played.

**Consider not hosting it.** A dedicated video host gives you adaptive streaming - several qualities, switched automatically - which a plain `video` element with one file cannot do. The trade is a third-party embed, with the privacy and performance costs covered in the lesson on iframes.

For short clips, loops and audio, self-hosting with the `video` element is simpler and faster than any embed.

## Controlling media from script

The elements have a full API, and knowing the shape of it saves reinventing the controls.

```html
<audio id="player" controls preload="metadata">
  <source src="episode.mp3" type="audio/mpeg">
  <p>Your browser cannot play audio.</p>
</audio>

<p>
  <button type="button" onclick="document.getElementById(''player'').play()">Play</button>
  <button type="button" onclick="document.getElementById(''player'').pause()">Pause</button>
  <button type="button" onclick="document.getElementById(''player'').currentTime = 0">
    Back to the start
  </button>
</p>
```

`play()`, `pause()`, `currentTime`, `volume`, `playbackRate` and `muted` cover most of what a custom control needs, and the elements emit events - `play`, `pause`, `timeupdate`, `ended`, `loadedmetadata` - for keeping an interface in step.

Two things to expect. `play()` returns a promise that **rejects** when the browser blocks playback, so an autoplay attempt needs a `catch` or it produces an unhandled rejection in the console. And `duration` is `NaN` until metadata has loaded, which is why a scrubber built without waiting for `loadedmetadata` starts out broken.

## Practice task

Embed a video with `controls`, a `poster`, two `source` formats and a captions `track`, plus fallback content containing a download link. Write a short VTT file by hand for the first ten seconds. Then turn the volume off and watch it: whatever you cannot follow is what your captions are missing.
',
   'Two elements replace what used to need a plugin. The attributes are easy; the part that gets skipped is the captions track, which is the difference between a video that everybody can use and one that a lot of people cannot.', 6, 1231, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Module 3 - Graphics, Metadata and Access
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000138',
   'HTML Graphics',
   'markdown',
   '# HTML Graphics

A browser can draw. There are two mechanisms for it, they work completely differently, and choosing the wrong one is hard to undo later.

**SVG** describes shapes as markup. Every circle, line and path is an element in the document, so CSS can style it, JavaScript can attach a click handler to it, and a screen reader can be told what it is.

**Canvas** gives you a rectangle of pixels and an API for painting into it. Once a shape is painted there is no shape any more, only pixels - nothing to select, style, or describe.

## SVG, inline

```html
<figure>
  <svg width="240" height="120" viewBox="0 0 240 120" role="img"
       aria-label="Enrolments rose from 40 in January to 290 in December">
    <polyline points="10,110 60,86 110,62 160,38 230,14"
              fill="none" stroke="currentColor" stroke-width="3"
              stroke-linecap="round"></polyline>
    <circle cx="230" cy="14" r="5" fill="currentColor"></circle>
    <text x="10" y="20" font-size="12" fill="currentColor">Enrolments</text>
  </svg>
  <figcaption>Enrolments, January to December</figcaption>
</figure>
```

Three attributes do the work. `viewBox` establishes the coordinate system - here, 240 units across and 120 down - and every coordinate inside is in those units. `width` and `height` say how large to draw it on the page. Because the two are separate, the same graphic scales to any size with no loss, which is the whole point of vectors.

`stroke="currentColor"` is the trick worth remembering: it inherits the surrounding text colour, so the graphic follows a dark mode automatically without a second copy.

`role="img"` plus `aria-label` gives the whole drawing one text alternative. Without them a screen reader may announce the individual shapes, or nothing at all.

## SVG as a file

```html
<p>
  <img src="logo.svg" alt="Omni Academy" width="160" height="40">
</p>
```

Referencing an SVG as an image is right when it is large, reused across pages, or not meant to be interactive. The browser caches one file and the page stays small.

The trade is that an SVG loaded through `img` is a sealed box: your page''s CSS cannot reach into it, scripts cannot touch it, and `currentColor` has nothing to inherit from. Icons that need to change colour have to be inline; logos that do not, should not be.

## Canvas

```html
<figure>
  <canvas id="growth" width="300" height="150">
    Monthly growth rose from 2% in January to 11% in December.
  </canvas>
  <figcaption>Monthly growth</figcaption>
</figure>
```

The element is a blank surface. Everything visible on it is drawn by script through a context object, typically with `getContext(''2d'')` and then calls like `fillRect`, `arc` and `lineTo`.

The text inside the element is **fallback content**, and it is the part most often left empty. A canvas has no internal structure, so a screen reader has nothing whatsoever to read: whatever the drawing says must also be said in text, either there or in the page beside it. A canvas with no fallback is, for some of your readers, a blank rectangle.

## Choosing between them

| | SVG | Canvas |
|---|---|---|
| Shapes are | elements | pixels |
| Styling | CSS | drawing calls |
| Events | per shape | one element, work out what was hit |
| Accessibility | roles and labels on elements | fallback text only |
| Scaling | resolution independent | redraw, or it blurs |
| Many thousands of objects | slows down | stays fast |

The practical rule: **SVG unless you have a reason**. Icons, logos, diagrams, charts with a few dozen points, anything interactive. Canvas for games, visualisations of tens of thousands of points, video and image processing - cases where there are too many objects for a document tree to hold, or where every pixel changes every frame.

## One file, many icons

Repeating the same inline icon twenty times repeats its markup twenty times. `symbol` and `use` define it once and reference it.

```html
<svg width="0" height="0" style="position: absolute" aria-hidden="true">
  <symbol id="icon-check" viewBox="0 0 16 16">
    <path d="M3 8l3 3 7-7" fill="none" stroke="currentColor" stroke-width="2"></path>
  </symbol>
  <symbol id="icon-cross" viewBox="0 0 16 16">
    <path d="M4 4l8 8M12 4l-8 8" fill="none" stroke="currentColor" stroke-width="2"></path>
  </symbol>
</svg>

<ul>
  <li>
    <svg width="16" height="16" aria-hidden="true"><use href="#icon-check"></use></svg>
    Included
  </li>
  <li>
    <svg width="16" height="16" aria-hidden="true"><use href="#icon-cross"></use></svg>
    Not included
  </li>
</ul>
```

The sprite block defines the shapes and renders nothing; each `use` draws one of them. The icons still inherit `currentColor`, and changing a path once changes it everywhere.

A detail on the hidden sprite: `width="0" height="0"` plus `position: absolute` is deliberate. `display: none` would work in most browsers and breaks `use` in some, which is the sort of thing that is maddening to debug.

## Keeping SVG small

An SVG exported from a design tool is often ten times larger than it needs to be: editor metadata, hidden layers, coordinates to twelve decimal places. Running it through an optimiser removes all of that without changing the drawing.

Two things to check by eye afterwards. Optimisers sometimes strip the `viewBox`, which breaks scaling. And they may remove `id` attributes that a `use` or a CSS rule depends on.

## Graphics responsibly

Three habits that apply to both.

**Make it scale.** An SVG with a `viewBox` and no fixed `width` fills its container. A canvas needs its `width` and `height` attributes to match its CSS size, or the bitmap is stretched and everything looks soft.

**Give it a name, or hide it.** Every graphic is either informative or decorative, and both cases need saying.

```html
<p>
  <svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true" focusable="false">
    <circle cx="8" cy="8" r="6" fill="currentColor"></circle>
  </svg>
  Status: online
</p>

<p>
  <svg width="16" height="16" viewBox="0 0 16 16" role="img" aria-label="Verified">
    <path d="M3 8l3 3 7-7" fill="none" stroke="currentColor" stroke-width="2"></path>
  </svg>
</p>
```

The first icon sits next to the word "online", so it is decorative: `aria-hidden="true"` stops it being announced twice, and `focusable="false"` stops older browsers putting it in the tab order. The second icon is the only thing saying "verified", so it needs a real label.

**Never let colour be the only signal.** A chart where the red line is last year and the green one is this year is unreadable to about one man in twelve. Use a dashed stroke, a label on the line, or a different marker - something that survives being printed in grey.

## Practice task

Draw the same simple bar chart twice: once as inline SVG with three `rect` elements, and once on a `canvas` with three `fillRect` calls. Give the SVG a `role` and a label, and the canvas a fallback sentence. Then try to make the third bar turn orange when the mouse is over it. In SVG that is one CSS rule; on the canvas you will need to track the pointer position and redraw. That difference is the whole decision.
',
   'Two ways to put a drawing on a page: SVG, where every shape is an element you can style and script, and canvas, where the page gives you a rectangle of pixels and a drawing API. The choice between them decides what is possible afterwards.', 6, 1109, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000139',
   'Iframes and Embedded Content',
   'markdown',
   '# Iframes and Embedded Content

An `iframe` embeds a whole other document inside your page - its own browsing context, with its own URL, its own scripts, its own cookies. A video player, a map, a payment form, a comment widget.

That makes it the most powerful embedding mechanism in HTML and the one with the most ways to go wrong.

## The basics

```html
<iframe src="https://www.example.com/embed/lesson-1"
        title="Lesson 1: the document skeleton"
        width="560" height="315"
        loading="lazy"
        allowfullscreen></iframe>
```

`src` is the document to embed. `width` and `height` size the frame - set them, for the same reason images need them: without a known size the space is zero until the frame loads and the page jumps.

**`title` is not optional.** It is how the frame is announced. A screen reader user navigating by frames gets a list, and without titles that list reads "frame", "frame", "frame". One short phrase describing what is inside fixes it, and it takes ten seconds.

`loading="lazy"` defers the load until the frame is near the viewport. On a page with several embeds this is a large saving, because each one is a whole extra document with its own scripts.

`allowfullscreen` lets the embedded document go fullscreen, which video players need.

## Making an embed responsive

An iframe has fixed pixel dimensions and does not reflow. The modern fix is one CSS property.

```html
<div style="max-width: 560px">
  <iframe src="https://www.example.com/embed/lesson-1"
          title="Lesson 1: the document skeleton"
          style="width: 100%; aspect-ratio: 16 / 9; border: 0"
          loading="lazy" allowfullscreen></iframe>
</div>
```

`aspect-ratio` keeps the height proportional to the width as the container shrinks. It replaces the old padding-top trick, which worked by giving a wrapper a percentage top padding and absolutely positioning the frame inside it - if you meet that pattern in an older codebase, this is what it was for.

`border: 0` removes the default inset border, which is almost never wanted.

## sandbox

`sandbox` takes away the embedded document''s privileges, and then you grant back only what it needs.

```html
<iframe src="/preview.html"
        title="Preview of your page"
        sandbox="allow-scripts"
        style="width: 100%; height: 320px; border: 1px solid #ccc"></iframe>
```

With a bare `sandbox` attribute the frame cannot run scripts, submit forms, open popups, navigate the top-level page, or use plugins, and it is treated as a unique origin, so it cannot read cookies or storage belonging to your site.

Each token gives one thing back: `allow-scripts`, `allow-forms`, `allow-popups`, `allow-same-origin`, `allow-downloads`, `allow-modals`.

The combination to think twice about is **`allow-scripts` together with `allow-same-origin`** on content you do not control. Together they let the framed document run script with your origin''s privileges - which means it can remove its own sandbox attribute from the parent document. The sandbox is then decorative.

This site''s own playground runs learner-written HTML in a sandboxed frame with `allow-scripts` and deliberately without `allow-same-origin`, which is why code in the playground cannot read your session.

## allow, and permissions

Separately from the sandbox, `allow` controls which browser features the frame may use.

```html
<iframe src="https://maps.example.com/embed?q=Doha"
        title="Map of our office in Doha"
        allow="geolocation ''self''"
        loading="lazy"
        style="width: 100%; aspect-ratio: 4 / 3; border: 0"></iframe>
```

Without an `allow` entry the embedded document cannot use the camera, microphone, geolocation, fullscreen or autoplay, even if the user has granted your page permission. Grant the minimum the embed genuinely needs.

## PDFs and other embeds

```html
<p>
  <iframe src="/handbook.pdf" title="Student handbook"
          style="width: 100%; height: 600px; border: 0"></iframe>
</p>
<p>
  If the handbook does not display,
  <a href="/handbook.pdf" download>download it instead</a>.
</p>
```

PDF rendering inside a frame is inconsistent: some browsers display it, some download it, and mobile browsers often do neither. **Always provide a direct link**, which is the only version guaranteed to work.

Two older elements do related jobs. `embed` and `object` both existed for plugin content; `object` is still occasionally used for PDFs because it can carry fallback content between its tags. Neither is needed for anything an `iframe`, `img`, `video` or `audio` can do.

## Talking to a frame, and being framed

A frame from another origin is isolated: your page cannot read its DOM and it cannot read yours. The sanctioned channel between them is `postMessage`.

```html
<iframe id="preview" src="/preview.html" title="Live preview"
        sandbox="allow-scripts"
        style="width: 100%; height: 280px; border: 1px solid #ccc"></iframe>

<script>
  const frame = document.getElementById(''preview'');
  frame.addEventListener(''load'', function () {
    frame.contentWindow.postMessage({ type: ''render'', html: ''<h1>Hello</h1>'' }, ''*'');
  });
</script>
```

The receiving side listens for `message` events. Two rules make it safe: always **check `event.origin`** before trusting a message, and prefer naming a specific target origin rather than `''*''` when you know it.

The reverse question is whether anyone may frame **your** page. By default they may, and that is the basis of clickjacking: your page loaded invisibly over a decoy, so a click lands on your button. The defence is a response header rather than markup - `Content-Security-Policy: frame-ancestors ''self''`, or the older `X-Frame-Options: SAMEORIGIN`. It is worth knowing that no `meta` tag can do this: `frame-ancestors` is ignored in a meta CSP, so it has to come from the server.

## The cost of a third-party embed

An embed from another company is not free, and the costs are easy to miss because the frame looks like a small box.

**Weight.** A video embed is routinely a megabyte of script before a single frame of video. Three of them on a page can outweigh everything else you wrote.

**Privacy.** The embedded document sees the visitor''s IP address and can set its own cookies. On a page in a jurisdiction with consent requirements, a third-party embed is often the thing that requires the consent banner.

**Availability.** If the embed is slow, your page is slow. If it breaks, your page has a broken box in it.

Two mitigations are worth knowing. `loading="lazy"` means an embed below the fold costs nothing until someone scrolls. And the **facade pattern** - show a poster image with a play button, and insert the real iframe only when it is clicked - turns a megabyte of startup cost into a thumbnail, at the price of one click.

## When not to use one

An iframe is for a genuinely separate document. Three things it gets used for that have better answers:

**Layout.** An iframe to put a sidebar on every page is the `frameset` idea in a new costume. It breaks bookmarking, the Back button and search indexing, and a server-side include or a template does the job properly.

**Reusing your own markup.** Loading your own header in a frame means a second request, a second document and a scroll bar. A template or a build step is cheaper.

**Avoiding a CSS conflict.** Frames do isolate styles, and that is occasionally the point - an email preview, a WYSIWYG editor. For everything else, scoped class names or shadow DOM cost less.

## Practice task

Embed a map or a video with a `title`, `loading="lazy"` and an `aspect-ratio` so it stays proportional. Then open the Network panel and reload: note how many requests the embed makes and how many bytes it costs. Add `loading="lazy"` if it is not there, scroll away from it, and reload again - the difference is what the attribute is worth.
',
   'An iframe puts somebody else entire page inside yours. It is the most powerful embed available and the one with the most ways to go wrong - which is why it has a sandbox attribute and why a title on it is not optional.', 6, 1190, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000019',
   'HTML Metadata',
   'markdown',
   '# HTML Metadata

Nothing in the `head` renders. It still decides the browser tab, the bookmark, the search result, the preview card when the link is pasted into a chat, and whether the page is indexed at all. Per line written, it is the highest-leverage markup on a page.

Here is a complete head, with everything that earns its place:

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>HTML Metadata - Omni Academy</title>
  <meta name="description"
        content="What belongs in the head of an HTML document: encoding, viewport, title, description, robots, canonical and the social preview tags.">
  <link rel="canonical" href="https://example.com/courses/html/metadata">

  <meta name="theme-color" content="#11785f">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">

  <meta property="og:type" content="article">
  <meta property="og:title" content="HTML Metadata">
  <meta property="og:description" content="What belongs in the head of an HTML document.">
  <meta property="og:url" content="https://example.com/courses/html/metadata">
  <meta property="og:image" content="https://example.com/og/metadata.png">
  <meta name="twitter:card" content="summary_large_image">
</head>
```

## The two that change how the document is read

`charset` and `viewport` were covered in the document-structure lesson, and they come first for a reason: both change how everything after them is interpreted, so a browser needs them before it has read far.

`charset` must appear within roughly the first kilobyte. `viewport` must be present or no responsive CSS has any effect on a phone.

## Title and description

The `title` is the tab, the bookmark, the window and the blue line of a search result. Rules that follow from that list:

- **Unique per page.** Twenty pages called "Omni Academy" are twenty indistinguishable tabs.
- **Front-load the specific part.** "HTML Metadata - Omni Academy", not the other way round, because a narrow tab shows the first few characters.
- **Around 60 characters.** Longer is not wrong, but search results truncate.

`meta name="description"` is the sentence that may appear under it. It is not a ranking factor and it is not guaranteed - search engines frequently write their own snippet from the page when it answers the query better. Write it as the one sentence you would use to persuade somebody to click, around 150 characters, and accept that it is a suggestion.

## Canonical

```html
<link rel="canonical" href="https://example.com/courses/html/metadata">
```

The same content is often reachable at several addresses: with and without a trailing slash, with tracking parameters, through a print version. A canonical link names which one is the real one, so the ranking credit from all of them lands in one place rather than being split.

Two rules. It must be **absolute** - a relative canonical is a common and silent mistake. And it must be self-referential on the canonical page itself: every page should point at its own true address.

## Robots

```html
<meta name="robots" content="noindex, nofollow">
```

This instructs crawlers not to index the page or follow its links. The useful directives are `noindex`, `nofollow`, `noarchive`, `nosnippet`, and `max-snippet`, `max-image-preview` and `max-video-preview` for controlling how much may be shown.

Worth being clear about what this is **not**: it is not access control. A crawler that ignores the directive indexes the page anyway, and anyone with the URL can read it. Pages that must not be read need a login.

There is an interaction that catches people: a page blocked in `robots.txt` cannot be crawled, so its `noindex` is never read, so it can still appear in results as a bare URL. To keep something out of an index, allow the crawl and use `noindex`.

## Favicons and theme colour

```html
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<meta name="theme-color" content="#11785f">
```

An SVG favicon scales to every size from one file and can respond to dark mode with a media query inside the SVG. The `.ico` stays as a fallback for older browsers, and `apple-touch-icon` is the home-screen icon on iOS, which needs to be a 180-pixel PNG.

`theme-color` tints browser UI - the address bar on Android, the title bar of an installed web app. It accepts a `media` attribute, so a site can offer one colour for light mode and another for dark.

## Social previews

Open Graph decides what a link looks like when it is pasted into a chat, a post or a message.

```html
<meta property="og:type" content="article">
<meta property="og:title" content="HTML Metadata">
<meta property="og:description" content="What belongs in the head of an HTML document.">
<meta property="og:url" content="https://example.com/courses/html/metadata">
<meta property="og:image" content="https://example.com/og/metadata.png">
<meta property="og:image:alt" content="A diagram of the head of an HTML document">
<meta name="twitter:card" content="summary_large_image">
```

Note `property` rather than `name` on the Open Graph tags - a scraper looking for `property` will not find `name`, and the tag is silently ignored. That single typo is the commonest cause of a preview that will not generate.

The image must be an **absolute URL** and publicly reachable, with no login. Around 1200 by 630 pixels is the safe size. `og:image:alt` describes it, because previews are read aloud too.

A detail that confuses people: scrapers cache aggressively. Fix a broken preview and the old one often persists for days - most platforms have a debugging tool that forces a refresh, and that is the only reliable way to see your change.

## Structured data

Everything above describes the page to a human reading a preview. Structured data describes it to a machine, in a vocabulary search engines and answer engines understand.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "HTML: From Basics to Expert",
  "description": "Thirty topics, five modules, every example runnable in the browser.",
  "provider": {
    "@type": "Organization",
    "name": "Omni Academy",
    "url": "https://example.com"
  }
}
</script>
```

JSON-LD in a `script` tag is the recommended form: it sits in one block rather than being scattered through the markup as attributes, so it can be generated and validated on its own.

Two things to be honest about. Structured data makes a page **eligible** for a rich result; it does not guarantee one, and no amount of markup forces a search engine to show one. And it must describe what is actually on the page - marking up a rating that does not appear is a policy violation, not a trick.

There is a lesson on SEO later that goes further into which types are worth the effort.

## Hints the browser can act on early

Two `link` relationships in the head change the order the network does its work. They belong to the performance lesson, and they live in the head, so they are worth recognising here.

```html
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>
```

`preconnect` opens the connection to another origin before anything needs it, which saves the DNS lookup and the handshake. `preload` fetches a resource the parser has not reached yet at high priority - typically a font, which is otherwise discovered only after the CSS has loaded.

Both reward restraint: preloading everything means prioritising nothing, and a `preload` whose `as` is wrong fetches the file twice.

## Practice task

Give a page a unique title, a description, a self-referential canonical, a favicon and a full set of Open Graph tags. Then paste the URL into a messaging app and look at the preview. If nothing appears, check three things in order: is `og:image` absolute, is the image publicly reachable, and did you write `property` rather than `name`.
',
   'Nothing in the head is visible on the page, and it decides the tab title, the search snippet, the preview card when somebody shares the link, and whether the page is indexed at all. It is the highest-leverage markup you will write.', 6, 1192, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000016',
   'Responsive HTML',
   'markdown',
   '# Responsive HTML

Responsive design is mostly CSS. The HTML share is small, and it is the part that is skipped - which is why so many responsive stylesheets have no effect on a phone, and why so many pages that reflow correctly still read in the wrong order when they do.

Three things belong to the markup: the viewport declaration, the source order, and giving the browser a choice of image.

## The viewport, one more time

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

Without this, a mobile browser pretends it is about 980 pixels wide, renders the desktop layout and zooms out to fit. Every media query is then answered against 980 pixels, so the whole stylesheet behaves as though the phone were a laptop.

Two values sometimes added to it should not be. `user-scalable=no` and a `maximum-scale` below about 5 stop people zooming in - which is how a great many readers cope with small text. iOS now ignores both, and the fact that they fail is not a reason to write them.

## Source order is reading order

CSS can move anything anywhere. Flexbox has `order`, grid has explicit placement, and either can put the third element in the markup at the top of the screen.

Nothing moves for a screen reader, or for the Tab key. Those follow the **document** order, which means a page where CSS reorders the columns is a page where the keyboard focus jumps around the screen.

```html
<main>
  <article>
    <h1>Choosing an element</h1>
    <p>The main content comes first in the markup, because it is the
       most important thing on the page.</p>
  </article>

  <aside aria-label="Related">
    <h2>Related lessons</h2>
    <ul>
      <li><a href="/lessons/semantic-html">Semantic HTML</a></li>
    </ul>
  </aside>
</main>
```

Write the markup in the order the content matters, then let CSS place it. The sidebar may be drawn on the left; it should not come first in the source.

The test is to disable CSS entirely - every browser''s developer tools can - and read the page top to bottom. If that order makes sense, the responsive version will too.

## Letting the browser choose an image

A single large image sent to every device is the most common waste on a responsive page. Two attributes fix it.

```html
<img src="hero-800.jpg"
     srcset="hero-400.jpg 400w,
             hero-800.jpg 800w,
             hero-1600.jpg 1600w"
     sizes="(max-width: 700px) 100vw, 700px"
     alt="Students working at laptops in the library"
     width="800" height="450">
```

`srcset` lists the available files with their **real pixel widths**. `sizes` tells the browser how wide the image will be once laid out - a CSS-length answer, which may use media conditions. The browser combines them with the device pixel ratio and downloads exactly one file.

The common mistake is giving `sizes` a value that does not match the CSS. The browser trusts `sizes` and downloads accordingly, so a wrong value silently picks the wrong file - too small and blurry, or too large and wasteful.

## Art direction with picture

`srcset` is for the same image at different sizes. When the image itself should **change** - a wide landscape crop on a desktop, a tight portrait crop on a phone - that is `picture`.

```html
<picture>
  <source media="(min-width: 800px)" srcset="team-wide.jpg">
  <source media="(min-width: 400px)" srcset="team-square.jpg">
  <img src="team-portrait.jpg"
       alt="The six people who built this course"
       width="400" height="600">
</picture>
```

The browser takes the first `source` whose `media` matches and falls back to the `img`. The `img` is required: it carries the `alt`, and it is what every attribute other than the source selection applies to.

`picture` also selects by **format**, which is how to ship AVIF or WebP with a safe fallback:

```html
<picture>
  <source srcset="diagram.avif" type="image/avif">
  <source srcset="diagram.webp" type="image/webp">
  <img src="diagram.png" alt="How the parser builds a document tree"
       width="900" height="500">
</picture>
```

## Media and tables on a narrow screen

A `video` needs `width: 100%` and `height: auto` in CSS to scale; the HTML part is setting `width` and `height` attributes so the space is reserved.

A table does not reflow at all, and the honest answer is a scrolling container that a keyboard can reach:

```html
<div role="region" aria-label="Fees by programme" tabindex="0" style="overflow-x: auto">
  <table>
    <caption>Fees by programme</caption>
    <thead>
      <tr>
        <th scope="col">Programme</th>
        <th scope="col">Term 1</th>
        <th scope="col">Term 2</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th scope="row">Foundation</th>
        <td>1200</td>
        <td>1200</td>
      </tr>
    </tbody>
  </table>
</div>
```

## Mobile-first, as a markup decision

"Mobile first" is usually described as a CSS strategy - write the narrow layout, then add complexity at wider breakpoints. It has a markup half that matters more.

A narrow screen shows perhaps a third as much at once. So the question for every page becomes: what does somebody need **first**? That answer should be first in the document.

```html
<body>
  <a class="skip-link" href="#main">Skip to content</a>

  <header>
    <a href="/">Omni Academy</a>
    <button type="button" aria-expanded="false" aria-controls="menu">Menu</button>
    <nav id="menu" aria-label="Main" hidden>
      <ul>
        <li><a href="/courses">Courses</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </nav>
  </header>

  <main id="main">
    <h1>Responsive HTML</h1>
    <p>The content a visitor came for, as early in the document as it can be.</p>
  </main>
</body>
```

Three decisions in that fragment are markup rather than styling. The skip link comes first so a keyboard user can jump past the header. The navigation is behind a real `button` with `aria-expanded`, rather than a checkbox hack, so its state is announced. And `main` holds the content, so the skip link has somewhere to land.

A page that works at 320 pixels usually works everywhere. The reverse is rarely true.

## Things that break at narrow widths

A short list of what to check, all of which are markup decisions rather than CSS ones:

**Text inside images.** It does not reflow, does not scale with the reader''s font size, and cannot be selected, searched or translated. Put the words in the page.

**Fixed `size` and `cols` attributes.** `input size="40"` and `textarea cols="60"` set widths in characters that will not shrink. Leave them off and size the controls in CSS.

**Long unbroken strings.** A URL or a reference number with no spaces forces the page wider than the screen. `overflow-wrap: anywhere` is the fix; the markup contribution is to use `wbr` where a break is genuinely acceptable.

**Touch targets.** A link of two or three characters is hard to hit. Padding is CSS, but the decision to write "Read the accessibility guide" rather than "here" is markup.

## Practice task

Take a two-column page and check three things. Disable CSS and read it top to bottom - does the order make sense? Open it at 320 pixels wide and look for anything that forces a horizontal scroll bar. Then zoom the browser to 200% and confirm nothing is cut off or overlapping. Each of those is a separate failure mode, and the first one is the one that only HTML can fix.
',
   'Most of responsive design is CSS, and the part that is not is the part people skip: one meta tag without which no CSS applies, a source order that still reads correctly when the columns collapse, and images the browser can choose between.', 6, 1112, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000018',
   'Accessibility',
   'markdown',
   '# Accessibility

Accessibility means the page works for people who are not using it the way you are: with a screen reader, with a keyboard and no mouse, at 200% zoom, with a tremor, with colour vision deficiency, with the sound off, in a hurry on a cracked phone screen.

Almost all of it is choosing elements that already do the work. This lesson is the specifics.

## The four principles

WCAG - the Web Content Accessibility Guidelines - organises everything under four words, and they are a useful checklist even if you never read the standard.

**Perceivable.** Can the information get in? Text alternatives for images, captions for video, enough contrast, not relying on colour alone.

**Operable.** Can it be used? Everything reachable by keyboard, no traps, enough time, nothing that flashes.

**Understandable.** Is it predictable? Consistent navigation, clear labels, errors that say what to do.

**Robust.** Does it work with the tools people actually use? Valid markup, correct semantics, no reliance on one browser''s behaviour.

## Headings, links and images

Three things carry most of the weight, and all three were covered earlier - they are repeated here because they are where real audits find problems.

**Headings are an outline.** One `h1`, no skipped levels, and chosen by level rather than by size. Screen reader users navigate by heading more than by anything else.

**Link text makes sense alone.** "Read the accessibility guide", not "click here". The list of links on a page is a thing people actually read.

**Images say what they show.** Informative images get the information, images inside links get the destination, decorative images get `alt=""`.

```html
<main>
  <h1>Course handbook</h1>

  <h2>Enrolment</h2>
  <p>See the <a href="/enrolment">enrolment process</a> for deadlines.</p>

  <h3>Deadlines</h3>
  <p>
    <img src="calendar.svg" alt="" width="24" height="24">
    Applications close on 14 March.
  </p>
</main>
```

The calendar icon has `alt=""` because the sentence next to it already says what it says. An icon that repeats adjacent text is decoration.

## Forms and the keyboard

```html
<form action="/apply" method="post">
  <p>
    <label for="name">Full name</label>
    <input id="name" name="name" type="text" autocomplete="name" required>
  </p>

  <fieldset>
    <legend>Study mode</legend>
    <p>
      <input id="full-time" name="mode" type="radio" value="full" checked>
      <label for="full-time">Full time</label>
    </p>
    <p>
      <input id="part-time" name="mode" type="radio" value="part">
      <label for="part-time">Part time</label>
    </p>
  </fieldset>

  <p>
    <label for="ref">Reference number</label>
    <input id="ref" name="ref" type="text"
           aria-describedby="ref-help" pattern="[A-Z]{3}-[0-9]{4}"
           title="Three capital letters, a hyphen, then four digits">
    <span id="ref-help">For example, OMN-4821. Leave blank if you do not have one.</span>
  </p>

  <button type="submit">Apply</button>
</form>
```

Every control has a real `label`. The radio group has a `fieldset` and `legend`, so the question is announced along with the options. `aria-describedby` attaches the help text, which is then read **after** the label rather than instead of it - the distinction `title` cannot make.

Then test it with the keyboard, which takes two minutes and finds more than any tool:

- Tab through every control. Anything you cannot reach is unusable for a lot of people.
- Watch the focus ring. If you cannot see where you are, neither can they. Never write `outline: none` without putting something else in its place.
- Check the order matches the visual order.
- Make sure you can get **out** of everything you can get into. A focus trap outside a modal is a dead end.

## ARIA, and when not to

ARIA adds roles, names, states and properties to elements that do not carry them natively.

The first rule of ARIA, from the specification: **do not use ARIA if a native element will do**. A `button` is focusable, activates on Enter and Space, exposes a disabled state and announces itself. A `div role="button"` gives you the announcement only, and you now owe `tabindex`, two key handlers and a focus style.

The attributes worth knowing are small in number:

```html
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/courses">Courses</a></li>
    <li><a href="/courses/html" aria-current="page">HTML</a></li>
  </ol>
</nav>

<button type="button" aria-expanded="false" aria-controls="filters">
  Filters
</button>
<div id="filters" hidden>
  <p>The filter controls.</p>
</div>

<p aria-live="polite" id="status">Nothing to report.</p>
```

`aria-label` names something that has no visible label. `aria-labelledby` points at an element that already contains the name. `aria-describedby` attaches extra detail. `aria-current` marks which item in a set is the current one. `aria-expanded` reports whether a disclosure is open - and it has to be **updated** when it toggles, or it is worse than absent. `aria-live` on a region announces changes to it without moving focus.

Bad ARIA is worse than none, because it overrides what the element really is. `role="button"` on a link makes a screen reader announce "button" for something that navigates.

## Colour, contrast and motion

**Contrast.** Body text needs a ratio of at least 4.5 to 1 against its background; large text needs 3 to 1. Every browser''s developer tools will measure it.

**Never colour alone.** A required field marked only in red, an error shown only by a red border, a chart distinguished only by hue - each is invisible to a substantial number of people. Add a symbol, a label, a pattern.

**Motion.** Anything that animates should respect `prefers-reduced-motion`, and nothing should flash more than three times a second.

## Hiding things, four different ways

"Hidden" is not one state, and choosing the wrong one is a common cause of a page that works visually and not otherwise.

```html
<p hidden>Hidden from everybody: not drawn, not announced, not focusable.</p>

<p class="visually-hidden">Visible to a screen reader, not drawn on screen.</p>

<p aria-hidden="true">Drawn on screen, not announced. For decoration only.</p>

<div inert>
  <p>Still drawn and announced, but not interactive:
     <a href="/somewhere">this link cannot be reached or clicked</a>.</p>
</div>
```

`hidden` - and CSS `display: none` - removes an element from everything.

The `visually-hidden` class is the opposite: a CSS pattern that keeps an element in the accessibility tree while taking it off screen. It is how a search box gets a real label without showing one, and how a skip link stays invisible until focused.

`aria-hidden="true"` hides from assistive technology only. Correct for a decorative icon beside text that already says the same thing; wrong for anything focusable, because a screen reader user can still reach it with Tab and will be told nothing about it.

`inert` makes a subtree non-interactive while leaving it visible - what a modal dialog needs for everything behind it, and what `showModal()` applies for you.

## Testing

Automated tools catch perhaps a third of real problems, and they catch the mechanical ones: missing `alt`, missing labels, low contrast, duplicate ids. Run one - the Lighthouse accessibility audit in Chrome is built in - and fix what it reports.

Then do the parts it cannot:

1. **Unplug the mouse** and use the page.
2. **Zoom to 200%** and check nothing is lost.
3. **Turn on a screen reader.** VoiceOver on a Mac is Cmd-F5, Narrator on Windows is Ctrl-Windows-Enter. Listen to one form and one table.
4. **Read the page with CSS off.**

The last word belongs to people who use these tools daily: no checklist substitutes for testing with actual users.

## Practice task

Run Lighthouse against a page you have built and fix everything it reports. Then do the manual passes: keyboard only, 200% zoom, CSS off. Write down what the tool missed - that list is the one worth keeping, because it is the same list on every page you will ever build.
',
   'Accessibility is not a layer added at the end. Most of it is choosing the element that already does the job, and the single most effective test takes two minutes: put the mouse down and try to use the page.', 6, 1208, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000013a',
   'HTML Entities',
   'markdown',
   '# HTML Entities

Some characters are part of HTML''s syntax. To show one on the page you have to write it as a **character reference** - an escape sequence the parser turns back into the character.

```html
<p>Use &lt;h1&gt; for the main heading of a page.</p>
<p>Tom &amp; Jerry</p>
<p>She said &quot;markup is not programming&quot; and she was right.</p>
```

Without those, `<h1>` would start a heading rather than appear as text.

## The five that matter

| Character | Reference | Write it as a reference when |
|---|---|---|
| `<` | `&lt;` | always in text content |
| `>` | `&gt;` | always in text content |
| `&` | `&amp;` | always |
| `"` | `&quot;` | inside a double-quoted attribute value |
| `''` | `&apos;` | inside a single-quoted attribute value |

In practice two of them account for almost everything. `&lt;` and `&gt;` are needed any time a page shows HTML - every code example in this course is written that way. `&amp;` is needed in text and, importantly, **in URLs**:

```html
<p>
  <a href="/search?q=markup&amp;page=2">Page 2 of the results</a>
</p>
```

`&page` is the start of a character reference as far as the parser is concerned. In that particular case there is no entity called `page` so most browsers recover, but `&copy=1` genuinely becomes `©=1`, and the link quietly loses a parameter. Escaping the ampersand removes the question.

## Everything else is optional

HTML has about two and a half thousand named references - `&copy;`, `&hellip;`, `&mdash;`, `&nbsp;`, `&rarr;` and so on - plus numeric forms like `&#169;` and `&#x00A9;`.

With `<meta charset="utf-8">` you do not need them. The file can contain the character itself:

```html
<p>© 2026 Omni Academy — all rights reserved.</p>
<p>Prix : 12,50 € · 温度: 25°C · مرحبا</p>
<p>&copy; 2026 Omni Academy &mdash; all rights reserved.</p>
```

The first and third lines produce identical output. The first is easier to read in the source; the third survives a file being saved in the wrong encoding.

Three cases where a reference is still the better choice:

- The character is **ambiguous on screen** - a non-breaking space looks exactly like a space, and an en dash looks much like a hyphen. Writing `&nbsp;` and `&ndash;` makes the intent visible to the next person reading the source.
- You cannot **type** it and do not want to paste it.
- The content passes through a pipeline whose encoding you do not control.

## The non-breaking space

`&nbsp;` is the most misused character on the web, and worth understanding properly.

HTML collapses whitespace. Any run of spaces, tabs and newlines in the source becomes a single space on screen. That is a feature - it lets you indent markup freely - and it is why this does not do what it looks like:

```html
<p>These        many spaces     collapse to one each.</p>
<p>So does
   a line break
   in the source.</p>
```

A non-breaking space does two things: it does not collapse, and it does not allow a line break. The second is what it is for.

```html
<p>The deadline is 14&nbsp;March.</p>
<p>Weight: 2.5&nbsp;kg</p>
<p>See Figure&nbsp;3 for the parse tree.</p>
```

Each of those is a pair that should not be split across two lines. That is a genuine, useful job.

What it is **not** for is spacing. A row of `&nbsp;` to indent a paragraph or to push two buttons apart is layout written into the content: it does not scale with the reader''s font size, it cannot be adjusted responsively, and a screen reader may read the gaps. Margin and padding are the answer, every time.

## Showing markup on a page

Any page that teaches HTML has to display tags without the browser acting on them.

```html
<p>To mark up a paragraph, use the <code>&lt;p&gt;</code> element.</p>

<pre><code>&lt;ul&gt;
  &lt;li&gt;First&lt;/li&gt;
  &lt;li&gt;Second&lt;/li&gt;
&lt;/ul&gt;</code></pre>
```

`pre` preserves the whitespace, `code` says it is code, and the angle brackets are escaped so the list is shown rather than rendered. Note that the content starts immediately after `<code>` with no newline: `pre` preserves everything, and a newline there becomes a blank first line.

Forgetting to escape produces one of two symptoms, both initially baffling: the example vanishes because the browser rendered it, or everything after it is swallowed because an unclosed tag was opened.

## Where references are not expanded

A character reference is only expanded where the parser is reading markup. Three places it is not, each of which surprises somebody regularly.

```html
<p>Inside a script, this is literal text: the parser is not reading markup.</p>
<script>
  var greeting = "Tom & Jerry";
</script>

<style>
  .note::before { content: "Note &mdash; "; }
</style>

<textarea>&lt;p&gt;This IS expanded, and shows as a tag.&lt;/p&gt;</textarea>
```

Inside `script` and `style` the content is raw text. That `content` value renders the literal characters `Note &mdash; ` rather than a dash, because the HTML parser never looked at it - CSS has its own escape syntax, and this is a CSS string. Inside `textarea` and `title`, by contrast, references **are** expanded, which is why an escaped tag shows as a tag there.

The practical consequence: when you build a page from a template, the escaping has to know which context the value is landing in. One escaping function applied everywhere is wrong in at least one of these places.

## Escaping is also a security boundary

This lesson has been about showing characters. The same mechanism is what stops user input becoming markup.

If somebody types `<script>alert(1)</script>` into a comment box and your page renders it unescaped, the browser runs it. Escaping the five syntax characters on output turns it into visible text instead.

The rule is **escape at output, not at input**: the same value may end up in HTML text, in an attribute, in a URL and in JSON, and each needs different escaping. Store what the user typed; escape when you render. There is a whole lesson on this under security.

## The references worth memorising

A short list covers nearly every real use.

| Need | Reference | Why not just type it |
|---|---|---|
| `<` `>` | `&lt;` `&gt;` | They are syntax |
| `&` | `&amp;` | It starts a reference |
| Non-breaking space | `&nbsp;` | Looks like a normal space in the source |
| En dash, em dash | `&ndash;` `&mdash;` | Look like a hyphen in the source |
| Ellipsis | `&hellip;` | Three dots can be split across lines |
| Curly quotes | `&lsquo;` `&rsquo;` `&ldquo;` `&rdquo;` | Hard to type, easy to get wrong |
| Non-breaking hyphen | `&#8209;` | No named form exists |

Everything on that list is there because the character is either syntax or **invisible in the source**. For `©`, `€`, `→`, `°` and every accented letter, type the character.

One trap: a named reference must end in a semicolon. `&copy` without one works in some legacy cases and fails in others, and `&amp` inside a URL is exactly where it fails. Always close it.

## Practice task

Build a page that displays an HTML example inside a `pre` and a `code`, with every bracket escaped. Then add a line with a measurement in it - `2.5 kg`, `14 March` - and use `&nbsp;` to keep each pair together. Narrow the window until the text wraps and watch those pairs stay intact while everything else reflows.
',
   'Five characters are syntax, so writing one as itself means writing it as something else. Everything beyond those five is a convenience - and one of them, the non-breaking space, is the most misused character on the web.', 6, 1238, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Module 4 - Advanced HTML
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000013b',
   'Advanced HTML Forms',
   'markdown',
   '# Advanced HTML Forms

The forms lessons so far covered one form at a time. This one is about the forms that are long enough to be abandoned: an application, a checkout, an onboarding flow.

At that length the markup problems and the usability problems become the same problem.

## Structure a long form

```html
<form action="/apply" method="post">
  <h1>Course application</h1>
  <p>Step 2 of 4 &mdash; About you</p>
  <progress value="2" max="4">Step 2 of 4</progress>

  <fieldset>
    <legend>Your details</legend>
    <p>
      <label for="given">First name</label>
      <input id="given" name="givenName" type="text" autocomplete="given-name" required>
    </p>
    <p>
      <label for="family">Last name</label>
      <input id="family" name="familyName" type="text" autocomplete="family-name" required>
    </p>
  </fieldset>

  <fieldset>
    <legend>Contact</legend>
    <p>
      <label for="email">Email</label>
      <input id="email" name="email" type="email" autocomplete="email"
             aria-describedby="email-why" required>
      <span id="email-why">We use this only to send your application result.</span>
    </p>
  </fieldset>

  <p>
    <button type="submit">Continue</button>
    <button type="submit" formaction="/apply/draft" formnovalidate>Save and finish later</button>
  </p>
</form>
```

Four decisions there are worth copying.

**Sections are `fieldset` with a real `legend`**, not `div` with a heading. The legend is announced with every control inside the group, so somebody arriving at the email field hears "Contact, Email" rather than just "Email".

**Progress is stated**, both in text and in a `progress` element. A form with no visible end is the one people abandon.

**Every field that needs justifying gets one**, through `aria-describedby`. "Why do you want my phone number?" is the question that stops people typing, and answering it next to the field costs one line.

**There is a way out that does not lose the work.** `formnovalidate` on a save-draft button is what lets a half-finished form be stored.

## Uploads

```html
<form action="/apply/documents" method="post" enctype="multipart/form-data">
  <p>
    <label for="transcript">Transcript</label>
    <input id="transcript" name="transcript" type="file"
           accept=".pdf,application/pdf" required
           aria-describedby="transcript-help">
    <span id="transcript-help">PDF, up to 5&nbsp;MB.</span>
  </p>
  <p>
    <label for="portfolio">Portfolio images</label>
    <input id="portfolio" name="portfolio" type="file"
           accept="image/png,image/jpeg" multiple>
  </p>
  <button type="submit">Upload</button>
</form>
```

Three things have to be right or the upload fails silently.

`enctype="multipart/form-data"` on the form. Without it the browser sends the **filename** as a plain value and the file never leaves the machine.

`accept` filters the file picker. It is a convenience, not a constraint: the picker usually offers an "all files" option, and a request can be made without a browser at all.

The size limit in the help text is for the human. The real limit is enforced by whatever receives the upload.

Which leads to the part that matters: **everything about an upload has to be checked on the server.** The real content type, not the extension and not the browser''s claim. The size, before the file is written anywhere. Whether this user is allowed to attach a file to this application. And the file has to be stored somewhere it cannot be executed - an uploaded `.php` or `.jsp` in a served directory is a remote shell.

## progress, meter and output

Three elements that report a number, each meaning something different.

```html
<p>
  <label for="upload-progress">Uploading</label>
  <progress id="upload-progress" value="0.7">70%</progress>
</p>

<p>
  <label for="quota">Storage used</label>
  <meter id="quota" value="0.82" low="0.5" high="0.8" optimum="0.2">82% of 5 GB</meter>
</p>

<form>
  <p>
    <label for="seats">Seats</label>
    <input id="seats" name="seats" type="number" value="3" min="1" max="20">
  </p>
  <p>
    Total: <output name="total" for="seats">150</output>
  </p>
</form>
```

**`progress`** is a task moving towards completion. Omit `value` and it becomes indeterminate, which is the honest rendering when you do not know how long is left.

**`meter`** is a measurement inside a known range. `low`, `high` and `optimum` let the browser colour it, and `optimum` is what says which end is good - so a meter where a low value is better is expressed rather than inverted by hand.

**`output`** is a value the page computed. It is a live region by default, so a screen reader announces it when it changes. The same number written into a `span` is silent, which is why a running total built that way is invisible to some of the people who most need it.

The text inside each is the fallback for a browser that does not render the element.

## Controls that are not inside the form

```html
<form id="application" action="/apply" method="post">
  <p>
    <label for="statement">Personal statement</label>
    <textarea id="statement" name="statement" rows="8" required></textarea>
  </p>
</form>

<footer>
  <button type="submit" form="application">Submit application</button>
  <button type="reset" form="application">Start again</button>
</footer>
```

The `form` attribute associates a control with a form by id, from anywhere in the document. That is what lets the submit button live in a sticky footer, or a field live inside a dialog, without nesting them.

Two notes. The association is real: the control is validated and submitted with the form. And the attribute is on the **control**, naming the form - the opposite direction from what people first guess.

## Multi-step forms

A long form split across pages has to solve one problem the single-page version does not: the data from step 1 has to survive step 2.

```html
<form action="/apply/step-3" method="post">
  <h1>Course application</h1>
  <p>Step 3 of 4 &mdash; Your experience</p>
  <progress value="3" max="4">Step 3 of 4</progress>

  <input type="hidden" name="applicationId" value="a-48213">

  <fieldset>
    <legend>Previous study</legend>
    <p>
      <label for="level">Highest level completed</label>
      <select id="level" name="level">
        <option value="">Choose one</option>
        <option value="secondary">Secondary school</option>
        <option value="degree">Undergraduate degree</option>
      </select>
    </p>
  </fieldset>

  <p>
    <a href="/apply/step-2">Back</a>
    <button type="submit">Continue</button>
  </p>
</form>
```

The hidden field carries an identifier, not the data. That is the important distinction: the earlier answers live on the server against that id, because a hidden field is editable by anybody who opens developer tools. Carrying a price, a user id or an eligibility decision in one is the classic form vulnerability.

The **Back** link is a link, not a button, because going back is navigation. It also means the browser''s own Back button does the same thing, which is what people press anyway.

## Errors people can act on

When validation fails, three things have to be true: the message says what to do, it is attached to the field, and somebody not looking at the screen finds out.

```html
<form action="/apply" method="post" novalidate>
  <p>
    <label for="code">Reference</label>
    <input id="code" name="code" type="text"
           aria-describedby="code-error" aria-invalid="true">
    <span id="code-error" role="alert">
      Enter the reference from your email, like OMN-4821.
    </span>
  </p>
  <button type="submit">Check</button>
</form>
```

`aria-invalid="true"` marks the field as failing. `aria-describedby` attaches the message so it is read with the field. `role="alert"` makes it announced as soon as it appears.

And the message itself says what a correct value looks like. "Invalid input" describes the problem; "like OMN-4821" solves it.

## Practice task

Build a two-step application form with `fieldset` sections, a `progress` element, a file upload with the right `enctype`, and a save-draft button that skips validation. Then submit it with an empty required field and check three things: does the message say what to do, is it attached to the field with `aria-describedby`, and does the focus move to the field that failed?
',
   'A long form is a usability problem before it is a markup problem. Sections with real headings, a visible sense of progress, uploads that are checked where it counts, and the three elements that report a number without a script.', 6, 1104, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000013c',
   'Advanced Media',
   'markdown',
   '# Advanced Media

Images and video are usually the heaviest part of a page by an order of magnitude. This lesson is the markup that decides how much of that weight the visitor actually pays for.

## picture, srcset and sizes, decided properly

Three mechanisms, and choosing between them is the whole skill.

**Same image, different sizes** - `srcset` with `sizes`. The browser decides.

```html
<img src="library-800.jpg"
     srcset="library-400.jpg 400w, library-800.jpg 800w, library-1600.jpg 1600w"
     sizes="(max-width: 700px) 100vw, 700px"
     alt="Students working at laptops in the library"
     width="800" height="450">
```

**Same image, different formats** - `picture` with `type`. The browser takes the first it supports.

```html
<picture>
  <source srcset="library.avif" type="image/avif">
  <source srcset="library.webp" type="image/webp">
  <img src="library.jpg" alt="Students working at laptops in the library"
       width="800" height="450">
</picture>
```

**Different image entirely** - `picture` with `media`. You decide.

```html
<picture>
  <source media="(min-width: 800px)" srcset="team-wide.jpg">
  <img src="team-portrait.jpg" alt="The six people who built this course"
       width="400" height="600">
</picture>
```

The rule for which to reach for: if the browser could work it out, let it - that is `srcset`. If the decision depends on something only you know, like which crop reads better on a phone, that is `picture` with `media`.

In all three the `img` is required and carries the `alt`. `picture` and `source` select a file; they do not replace the image element.

## Optimisation, in order of effect

The order matters because the first item usually outweighs the rest combined.

**1. Resize to the real display size.** A 4000-pixel photograph displayed in a 600-pixel column is about forty times the bytes needed. No compression setting recovers that.

**2. Choose the format.** AVIF or WebP for photographs, SVG for anything drawn, PNG only for screenshots and transparency that WebP cannot better.

**3. Compress.** Quality 75 to 85 is usually indistinguishable from 100 at a fraction of the size.

**4. Strip metadata.** Camera files carry EXIF - GPS coordinates included, which is a privacy matter as well as a size one.

**5. Serve several sizes.** Then `srcset` as above.

For video: the single biggest win is deciding not to host it. A plain `video` element serves one file at one bitrate to everybody; a dedicated host serves adaptive streams that adjust to the connection. For short loops and clips, self-hosting is simpler and faster.

## Loading priority

```html
<img src="hero.jpg" alt="The campus at dusk"
     width="1200" height="600" fetchpriority="high">

<img src="footer-map.png" alt="" width="400" height="300" loading="lazy">

<iframe src="https://maps.example.com/embed" title="Map of the campus"
        loading="lazy" style="width: 100%; aspect-ratio: 4 / 3; border: 0"></iframe>
```

`loading="lazy"` defers a fetch until the element is near the viewport. It belongs on everything below the fold and on **nothing** above it: lazy-loading the hero image delays the exact thing whose speed is being measured.

`fetchpriority="high"` tells the browser to prioritise an image it would otherwise treat as ordinary. Reserve it for the one image that defines the page - usually the largest element visible on load.

And the easiest win of all is still `width` and `height` on every image. They reserve the space, so nothing shifts as images arrive.

## Making video fit

A `video` scales with two CSS declarations and one markup habit.

```html
<figure style="max-width: 720px">
  <video controls playsinline preload="metadata"
         poster="walkthrough-preview.jpg"
         width="1280" height="720"
         style="width: 100%; height: auto">
    <source src="walkthrough.webm" type="video/webm">
    <source src="walkthrough.mp4" type="video/mp4">
    <track kind="captions" src="walkthrough-en.vtt" srclang="en" label="English" default>
    <p>Your browser cannot play this video.
       <a href="walkthrough.mp4">Download it</a>.</p>
  </video>
  <figcaption>A walkthrough of the finished project</figcaption>
</figure>
```

`width` and `height` give the aspect ratio so the space is reserved; `width: 100%` and `height: auto` let it scale inside its container. Both halves are needed: the attributes stop the layout jumping, the CSS stops the video overflowing.

`preload="metadata"` fetches enough to show the duration and let the scrubber work, and no more. `preload="auto"` on a page with three videos starts downloading all three.

`poster` matters more than it looks. Without one, a browser shows either a blank box or the first frame, and the first frame of most videos is black.

## Media accessibility, properly

```html
<figure>
  <video controls width="640" poster="lecture-preview.jpg" preload="metadata">
    <source src="lecture.webm" type="video/webm">
    <source src="lecture.mp4" type="video/mp4">
    <track kind="captions" src="lecture-en.vtt" srclang="en" label="English" default>
    <track kind="descriptions" src="lecture-ad.vtt" srclang="en" label="Audio descriptions">
    <p>Your browser cannot play this video.
       <a href="lecture.mp4">Download it</a>.</p>
  </video>
  <figcaption>Lecture 3: how the parser builds a tree</figcaption>
</figure>

<details>
  <summary>Read the transcript</summary>
  <p><strong>Lena:</strong> The parser never refuses. That is the thing to
     hold on to.</p>
</details>
```

Captions for people who cannot hear it. Descriptions for people who cannot see it. A transcript for everyone else, and for search engines. Keyboard-operable controls, which the browser''s own already are.

And one rule that is easy to break by accident: **do not let audio be the only carrier of information**. A video whose crucial number is only spoken aloud is a video that number is missing from, for a lot of people and in every noisy room.

`autoplay` deserves its own warning here. It is blocked unless muted, it costs the visitor data they did not ask to spend, and an autoplaying video with sound is the most complained-about behaviour on the web. If a clip must play on its own, it should be muted, short, looping and decorative.

## Alt text at scale

A page with fifty images is where alt text stops being a per-image decision and becomes a policy. Four categories cover almost everything.

```html
<article>
  <h2>Quarterly review</h2>

  <img src="chart.png" width="600" height="300"
       alt="Revenue rose each quarter, from 1.2 million in Q1 to 2.1 million in Q4.">

  <p>
    <a href="/report.pdf">
      <img src="pdf-icon.svg" alt="Download the full report (PDF)"
           width="24" height="24">
    </a>
  </p>

  <p>
    <img src="tick.svg" alt="" width="16" height="16"> Target met
  </p>

  <figure>
    <img src="office.jpg" alt="The Doha office on opening day, with staff on the terrace"
         width="800" height="500">
    <figcaption>The Doha office, March 2026</figcaption>
  </figure>
</article>
```

**Informative** - the alt is the information, not a description of the picture. A chart''s alt is its finding.

**Functional** - an image that is a link or a button gets the action, not the appearance.

**Decorative** - `alt=""`, present and empty. The tick is next to the words "Target met", so repeating it is noise.

**Complex with a caption** - the `alt` says what it shows, the `figcaption` says what it is for, and they should not be the same sentence or it is read twice.

The one rule that resolves most arguments: cover the image and ask what you would write in its place.

## Practice task

Take a page with three images and do the arithmetic: open the Network panel, note the transferred size of each, then check its displayed size in the Elements panel. Resize any image that is more than twice its display width, add `width` and `height` to all three, `loading="lazy"` to the ones below the fold, and `fetchpriority="high"` to the hero. Reload and compare the totals.
',
   'Media is almost always the heaviest thing on a page. Choosing the right element, the right format, and the right loading priority is the difference between a page that arrives and one that is still arriving.', 6, 1124, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000001b',
   'HTML Performance',
   'markdown',
   '# HTML Performance

A browser parses HTML top to bottom. Anything that stops the parser stops the page appearing. Most of what makes a page feel slow is decided in the first few lines of the head, which is also where it is cheapest to fix.

## What the parser is doing

1. Bytes arrive and are decoded into characters - using the `charset` you declared.
2. Characters are tokenised into tags, and tags are built into the DOM tree.
3. On meeting a `link rel="stylesheet"`, the browser fetches it and **will not paint** until it has arrived. Painting without CSS would flash unstyled content.
4. On meeting a classic `script` with no attributes, the parser **stops**, fetches it, runs it, and then resumes. A script could call `document.write`, so the parser cannot safely continue.
5. Images and iframes are fetched without blocking anything.

Points 3 and 4 are the two levers. Everything below is about them.

## Script loading

```html
<head>
  <meta charset="utf-8">
  <title>Script loading</title>

  <script src="/blocking.js"></script>
  <script src="/analytics.js" async></script>
  <script src="/app.js" defer></script>
  <script type="module" src="/main.js"></script>
</head>
<body>
  <h1>Four scripts, four behaviours</h1>
</body>
```

**No attribute** - the parser stops, downloads, executes, resumes. Every one of these in the head delays the first paint by a whole round trip.

**`async`** - downloads in parallel and executes **as soon as it arrives**, interrupting parsing at an unpredictable moment. Order between async scripts is not preserved. Right for something genuinely independent, such as an analytics beacon.

**`defer`** - downloads in parallel and executes after parsing finishes, in document order. This is the sensible default for application code: nothing blocks, and the script can rely on the whole document existing.

**`type="module"`** - deferred automatically, so a module script in the head does not block.

The old advice was to put scripts at the end of the body. `defer` is better: the download starts immediately rather than after the whole document has been parsed, and execution still waits.

## Resource hints

```html
<head>
  <meta charset="utf-8">
  <title>Resource hints</title>

  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="dns-prefetch" href="https://cdn.example.com">

  <link rel="preload" href="/fonts/inter.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/hero.webp" as="image">

  <link rel="prefetch" href="/courses" as="document">

  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <h1>Hints the browser may act on</h1>
</body>
```

`preconnect` opens the connection to another origin early - DNS, TCP and TLS take hundreds of milliseconds, and doing them before anything needs the origin takes that off the critical path.

`preload` fetches something at high priority that the parser has not reached yet. Fonts are the standard case: a font is discovered only after the CSS has loaded and been applied, which is late.

`prefetch` fetches something at low priority for a **later** navigation.

Three warnings. Hints are advice, not commands. `preload` requires a correct `as`, and a wrong one fetches the file twice. And preloading everything prioritises nothing - a handful is the right number.

The `crossorigin` on the font preload is not optional: fonts are fetched in anonymous CORS mode, and a preload without it does not match the later request, so the file is downloaded twice.

## Keeping the document small

**Remove redundant markup.** Deeply nested wrappers are nodes the browser must build, style and lay out. A tree three times deeper than it needs to be costs three times the work on every layout.

**Avoid duplicating content.** A mobile version and a desktop version of the same navigation, hidden alternately by CSS, is both in the DOM. One, laid out differently, is correct.

**Inline only what is tiny.** Inlining the critical CSS in a `style` block removes a round trip, and inlining anything substantial means it is re-downloaded with every page because it cannot be cached.

**Compress.** Gzip or Brotli on the server typically takes HTML to a fifth of its size, and it is a server setting rather than anything you write.

## Stylesheets, and the one blocking resource worth keeping

A stylesheet blocks the first paint. That is correct behaviour - the alternative is a flash of unstyled text - so the goal is not to remove the block but to shorten it.

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Critical CSS</title>

  <style>
    body { margin: 0; font: 16px/1.6 system-ui, sans-serif; }
    header { padding: 1rem; border-bottom: 1px solid #ddd; }
    h1 { font-size: 1.6rem; margin: 1rem; }
  </style>

  <link rel="stylesheet" href="/styles.css" media="print" onload="this.media=''all''">
  <noscript><link rel="stylesheet" href="/styles.css"></noscript>
</head>
<body>
  <header><strong>Omni Academy</strong></header>
  <h1>The page paints before the full stylesheet arrives</h1>
</body>
```

The inline block holds just enough CSS to draw what is visible first. The full stylesheet is then loaded without blocking, by the old `media="print"` trick: a print stylesheet is not render-blocking, and swapping its media to `all` once it has loaded applies it. The `noscript` copy covers a reader with JavaScript off.

This is a real technique with a real cost: the inlined CSS is re-sent with every page because it cannot be cached. It is worth it for a landing page and usually not worth it for an application somebody keeps open.

## Streaming, and why order matters

A browser does not wait for the whole document. It parses and paints as bytes arrive, which means markup near the top can be rendered while the rest is still coming.

Two consequences worth knowing. Content that matters should be early in the document - which is the same advice the responsive lesson gave for a different reason. And a slow server-side fragment in the middle of a page holds up everything after it, so an expensive widget belongs at the end of the markup, positioned wherever you like by CSS.

## What to measure

Three numbers describe how a page feels:

**Largest Contentful Paint** - when the main content appeared. Usually decided by the hero image and by whatever blocks rendering.

**Cumulative Layout Shift** - how much the page moved while loading. Almost always missing `width` and `height` on images, or a web font swapping in at a different size.

**Interaction to Next Paint** - how long the page takes to respond to a tap. A JavaScript problem rather than a markup one.

Lighthouse, in every Chromium browser''s developer tools, reports all three.

The order to work in is: measure first, fix the largest number, measure again. Performance work done by intuition reliably optimises the thing that was not the problem.

## Practice task

Run Lighthouse on a page you have built and note the Largest Contentful Paint. Then make three changes: add `defer` to every script in the head, add `width` and `height` to every image, and add `loading="lazy"` to everything below the fold. Run it again. The layout-shift number should fall furthest, because it is the one with a purely markup-level cause.
',
   'Most of what makes a page feel slow is decided in the first few lines of the head. The parser works top to bottom, and anything that blocks it blocks the first thing the visitor sees.', 6, 1112, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000013d',
   'HTML Security',
   'markdown',
   '# HTML Security

Nothing in HTML enforces security. The browser runs whatever the page tells it to, and the user controls the browser. What markup can do is avoid creating problems, and make the server''s job possible.

This lesson is the HTML-shaped half of five real attacks.

## Cross-site scripting

XSS happens when content that somebody else supplied is interpreted as markup instead of text.

Imagine a comment field, and somebody types:

```html
<p>Nice lesson!<img src="x" onerror="alert(''this ran'')"></p>
```

If your page renders that comment without escaping, the browser sees an image element with an event handler, the image fails, and the handler runs - with full access to the page, the session cookie and anything the signed-in user can do.

The fix is **escape on output, in the right context**.

```html
<p>Nice lesson!&lt;img src="x" onerror="alert(''this ran'')"&gt;</p>
```

Now it is text. The five syntax characters are escaped, so nothing is interpreted.

Three rules behind that:

**Escape at output, never at input.** The same stored value may be rendered into HTML text, into an attribute, into a URL and into JSON, and each needs different escaping. Store what the user typed.

**Context decides the escaping.** HTML text needs the five characters. An attribute value needs quotes handled too. A URL needs percent-encoding. Inside a `script` block, HTML escaping does nothing at all, because the parser is not reading markup there.

**Prefer `textContent` to `innerHTML`.** Setting `textContent` cannot create an element. `innerHTML` with any untrusted fragment in it is the single most common route to an XSS bug.

## Content Security Policy

A CSP is a server-sent header that tells the browser what the page is allowed to load and run. It does not stop an injection; it limits what an injection can do.

```html
<head>
  <meta charset="utf-8">
  <title>A page with a policy</title>
  <meta http-equiv="Content-Security-Policy"
        content="default-src ''self''; img-src ''self'' https://images.example.com; object-src ''none''; base-uri ''self''">
</head>
<body>
  <h1>Scripts from anywhere else will not run</h1>
</body>
```

With a policy like that, an injected `<script src="https://attacker.example/x.js">` is blocked, because the origin is not in the list. So is an inline `onerror` handler, unless `unsafe-inline` is granted - which is why a strict CSP and inline event handlers do not coexist.

Two things to know. The `meta` form works for most directives but **not** `frame-ancestors`, which must come from a real header. And a policy is something to grow into: start in report-only mode, see what breaks, then enforce.

## Clickjacking

Your page is loaded in an invisible iframe on top of a decoy, and a click meant for the decoy lands on your "Confirm payment" button.

The defence is to say who may frame you, and it is a header rather than markup:

    Content-Security-Policy: frame-ancestors ''self''
    X-Frame-Options: SAMEORIGIN

The markup-level half is the other direction - when **you** frame somebody else, sandbox them:

```html
<iframe src="/preview.html" title="Preview of your page"
        sandbox="allow-scripts"
        style="width: 100%; height: 300px; border: 1px solid #ccc"></iframe>
```

A bare `sandbox` removes scripts, forms, popups, top-level navigation and same-origin privileges, and each token grants one back. The pair to think hard about is `allow-scripts` with `allow-same-origin`: together they let the framed page remove its own sandbox from the parent, which makes the attribute decorative.

## Links that open new tabs

```html
<p>
  <a href="https://example.com/review" target="_blank" rel="noopener noreferrer">
    Read the external review
  </a>
</p>
```

Without `noopener`, the page you opened holds a reference to yours through `window.opener` and can navigate it somewhere else - so a visitor who returns to your tab finds a convincing fake. Modern browsers imply `noopener` for `target="_blank"`, and writing it covers the rest.

`noreferrer` additionally stops the destination learning which page the visitor came from.

For user-submitted links, add `rel="ugc nofollow"` so you are not vouching for them to search engines either.

## Forms, hidden fields and prices

Everything the browser validates, the user can change.

```html
<form action="/checkout" method="post">
  <input type="hidden" name="productId" value="course-html">
  <input type="hidden" name="price" value="4900">
  <button type="submit">Pay</button>
</form>
```

That second hidden field is the bug. Anybody can open developer tools, set the value to `1`, and submit. Nothing in HTML prevents it, because nothing in HTML can.

The correct version sends the **identifier** and lets the server look up the price:

```html
<form action="/checkout" method="post">
  <input type="hidden" name="productId" value="course-html">
  <input type="hidden" name="csrfToken" value="a-token-the-server-issued">
  <button type="submit">Pay</button>
</form>
```

The CSRF token is the other half. Without one, any other site can post a form to your endpoint using the visitor''s cookies - a request that is fully authenticated and that the visitor never intended. The token is issued by your server, tied to the session, and checked on arrival. `SameSite` cookies help and are not a complete substitute.

## Autocomplete, passwords and what the browser leaks

Three smaller markup decisions with security consequences.

```html
<form action="/login" method="post">
  <p>
    <label for="user">Username</label>
    <input id="user" name="username" type="text" autocomplete="username" required>
  </p>
  <p>
    <label for="pass">Password</label>
    <input id="pass" name="password" type="password"
           autocomplete="current-password" required>
  </p>
  <button type="submit">Sign in</button>
</form>
```

**Use `type="password"`.** It masks the field, it keeps the value out of autofill previews, and browsers treat it specially - including refusing to autofill it across origins.

**Do not fight the password manager.** `autocomplete="off"` on a login field is widely ignored, because switching it off there was mostly used to stop managers working, and a manager produces stronger passwords than a person does.

**Never put a secret in the markup.** An API key in a `data-` attribute, a token in a hidden field, an internal URL in a comment - all of it is in View Source. If the browser can read it, so can the visitor.

One more: a form that sends credentials must have an `https` action. A `post` to `http` is readable by anything between the visitor and the server, and browsers now warn about it - correctly.

## The short version

- Escape output, in the right context, every time.
- Never build HTML by concatenating untrusted strings.
- Validate and authorise on the server. Browser validation is a courtesy.
- Treat hidden fields, disabled fields and `readonly` as user input.
- Sandbox what you embed; declare who may embed you.
- Use https everywhere, so there is nothing to tamper with in transit.

## Practice task

Take a page that renders something a user typed - a search term echoed back is enough. Enter `<b>test</b>` and see whether it is bolded or shown as text. If it is bolded, you have found an injection point; fix it by escaping on output, then try `<img src=x onerror=alert(1)>` to confirm it is now inert. Then add a `meta` CSP with `default-src ''self''` and watch which of your own scripts stop working - that list is your inline-handler inventory.
',
   'Markup cannot secure anything on its own, and several security problems begin in it anyway: content that becomes script, a page framed by someone else, a link that hands over control, a hidden field somebody trusted.', 6, 1110, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000013e',
   'HTML with CSS',
   'markdown',
   '# HTML with CSS

HTML says what things are. CSS says what they look like. This lesson is the join between them: how styles get attached, what the markup owes the stylesheet, and the line between the two that is worth defending.

## Three ways to attach styles

```html
<head>
  <meta charset="utf-8">
  <title>Three ways</title>

  <link rel="stylesheet" href="/styles.css">

  <style>
    .lead { font-size: 1.125rem; color: #444; }
  </style>
</head>
<body>
  <p class="lead">Styled by the embedded block.</p>
  <p style="color: teal">Styled inline.</p>
</body>
```

**External**, with `link`. The default, for every reason that matters: one file for the whole site, cached after the first page, and one place to change anything.

**Embedded**, with `style` in the head. Right for the small block of critical CSS discussed in the performance lesson, and for a single-file demonstration. The cost is that it is re-sent with every page.

**Inline**, with the `style` attribute. Right for a value computed by script, and almost nothing else. It cannot express a hover state, a media query or a focus style; it is hard to override because of how specifically it applies; and it scatters presentation through the document.

## What the markup owes the stylesheet

CSS needs something to aim at, and the markup decides what is available. Three kinds of hook, in order of preference.

```html
<article class="card">
  <h3 class="card-title">HTML: From Basics to Expert</h3>
  <p class="card-summary">Thirty topics, every example runnable.</p>
  <a class="card-link" href="/courses/html" aria-current="page">Continue</a>
</article>
```

**The element itself.** `article`, `h3`, `a` can all be styled directly. An element selector costs nothing and works everywhere the element does.

**A class.** The normal hook. Reusable, as many per element as you like, no specificity surprises.

**A state already in the markup.** `a[aria-current="page"]`, `input:required`, `details[open]`, `button:disabled`. These are the best hooks of all, because the state is already true - there is no second copy to keep in step.

That last point deserves emphasis. A navigation link marked `aria-current="page"` can be styled with an attribute selector, and it is announced correctly as well. Adding `class="active"` instead gives you the styling and nothing else, and now two things have to be updated together.

## ids are not a styling system

An `id` is unique, so an `#id` selector can match only one element - which makes it a poor fit for styling anything you might ever have two of.

It also carries very high specificity, which is the practical problem: a rule written with an id beats almost any rule written with classes, so overriding it means another id or an `!important`, and that is how a stylesheet becomes unmaintainable.

Use ids for what they are for: a fragment link target, a `label` pointing at its control, `aria-describedby`, a script that needs one known element.

## Class names that survive a redesign

```html
<p class="note note-warning">A warning, described by what it is.</p>
<p class="red-box">A warning, described by what it currently looks like.</p>
```

The second works today and is a liability tomorrow: the day warnings become amber, either the markup changes everywhere or the class called `red-box` makes things orange.

Name a class after what the thing **is**, not what it looks like. `card`, `note-warning`, `price`, `byline`. The stylesheet decides the colour, which is the whole point of having one.

## Separation, and where it really sits

The rule is usually stated as "content in HTML, presentation in CSS", which is right and slightly too neat. The practical version is a set of questions:

**Does it change what the content means?** Then it is HTML. A heading is an `h2` because it is a second-level heading, at any size.

**Does it change only how it looks?** Then it is CSS. Including things that feel structural - the number of columns, the order of a flex row, whether something is visible at this width.

**Is it a state the content has?** Then it belongs in the markup as an attribute, and CSS should read it. Disabled, required, expanded, current, invalid, open.

The test that settles arguments: **turn the stylesheet off**. Whatever is left should be a readable document in a sensible order. If turning CSS off loses information - because the only indication of an error was a red border, or a heading was a styled `div` - that information was in the wrong layer.

## Where a class is the wrong answer

Two patterns worth recognising, because both are markup problems wearing a CSS costume.

```html
<p><span class="heading-large">This looks like a heading</span></p>
<h2>This is one</h2>

<p><span class="button-primary" onclick="buy()">Buy</span></p>
<button type="button" onclick="buy()">Buy</button>
```

A `span` styled to look like a heading is not in the outline, is not navigable, and is invisible to every tool that summarises a page. A `span` styled to look like a button is not focusable, not activated by Enter or Space, and not announced as a button.

In both cases the class produces the appearance and nothing else, and the correct element produces both. The giveaway is a class name that is the name of an element.

## Utility classes, and the obvious objection

```html
<div class="flex gap-4 items-center">
  <img class="w-12 h-12 rounded-full" src="avatar.jpg" alt="" width="48" height="48">
  <p class="text-sm text-gray-600">Lena Novak</p>
</div>
```

Utility-first CSS puts presentational names back into the markup, and it is popular because it removes the hardest problem in CSS at scale, which is naming things and knowing when a rule is safe to delete.

It is worth being even-handed: the separation that matters is not whether a class name mentions a colour, it is whether the **elements** are right. The example above is fine on that test - and would not be if the `p` were a `div` and the avatar had no `alt`. Semantics live in the element names; class names are a maintenance question with reasonable people on both sides.

## Styles the markup already carries

A short list of states worth styling directly rather than mirroring into classes.

```html
<form>
  <p>
    <label for="email">Email</label>
    <input id="email" name="email" type="email" required>
  </p>
  <p>
    <label for="ref">Reference</label>
    <input id="ref" name="ref" type="text" disabled value="OMN-4821">
  </p>
  <button type="submit">Send</button>
</form>

<nav aria-label="Main">
  <ul>
    <li><a href="/courses">Courses</a></li>
    <li><a href="/about" aria-current="page">About</a></li>
  </ul>
</nav>

<details open>
  <summary>Already open</summary>
  <p>Styled with details[open] rather than a class.</p>
</details>
```

`input:required`, `input:disabled`, `input:user-invalid`, `a[aria-current="page"]`, `details[open]`, `button[aria-expanded="true"]` - each is a hook that is already correct and already announced. Mirroring any of them into a class creates a second source of truth that will drift.

`:user-invalid` deserves a mention of its own: unlike `:invalid`, it only matches after somebody has interacted with the field, so an empty required input is not shown as an error before they have had a chance to type.

## Practice task

Take a page you have built and remove its stylesheet entirely. Read what is left. Every piece of information that has disappeared - an error shown only in red, a heading that was a styled `div`, a status indicated only by an icon''s colour - is something that was living in the wrong layer. Fix those in the markup, then put the stylesheet back.
',
   'Three ways to attach styles and only one worth defaulting to. The deeper question is which decisions belong in the markup at all - and the answer is that if it is about appearance, it is not one of them.', 6, 1164, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000013f',
   'HTML with JavaScript',
   'markdown',
   '# HTML with JavaScript

JavaScript does not act on your HTML file. It acts on the **DOM** - the tree the parser built from it - which is why the Elements panel and your source sometimes disagree, and why a script that runs too early finds nothing.

This lesson is the join: how to load a script, how it finds things, and the two habits that keep the join safe.

## Loading a script

```html
<head>
  <meta charset="utf-8">
  <title>Loading a script</title>
  <script src="/app.js" defer></script>
</head>
<body>
  <h1>The script runs after this exists</h1>
</body>
```

`defer` is the right default, and it solves two problems at once. The download starts immediately, in parallel with parsing, so nothing is blocked. And execution waits until the document has been parsed, so the script can rely on every element existing.

Without it, a script in the head runs **before** the body is parsed, so `document.querySelector(''h1'')` returns null - which is the single most common "my JavaScript does nothing" bug.

`async` is for genuinely independent scripts such as analytics; it executes the moment it arrives, in no guaranteed order. `type="module"` is deferred automatically.

## Finding elements

```html
<main>
  <h1 id="title">Course notes</h1>
  <ul class="course-list">
    <li class="course" data-course-id="html-101">HTML</li>
    <li class="course" data-course-id="css-101">CSS</li>
  </ul>
  <button type="button" id="refresh">Refresh</button>
</main>

<script>
  var title = document.querySelector(''#title'');
  var courses = document.querySelectorAll(''.course'');
  var first = document.querySelector(''[data-course-id="html-101"]'');
  var refresh = document.getElementById(''refresh'');
</script>
```

`querySelector` takes any CSS selector and returns the first match; `querySelectorAll` returns all of them. `getElementById` is the fast path for an id.

The markup decision here is **what to select on**. An id is stable and unique, and right for one known element. A `data-` attribute is explicit about being a hook for script - which means a designer renaming a class cannot break your code. Selecting on a class that exists for styling is the fragile option, because the two purposes then move independently.

## Events

```html
<form id="search" action="/search" method="get">
  <label for="q">Search courses</label>
  <input id="q" name="q" type="search" required>
  <button type="submit">Search</button>
</form>
<p id="status" role="status"></p>

<script>
  var form = document.getElementById(''search'');
  var status = document.getElementById(''status'');

  form.addEventListener(''submit'', function (event) {
    event.preventDefault();
    status.textContent = ''Searching for '' + form.elements.q.value;
  });
</script>
```

`addEventListener` attaches a handler. `event.preventDefault()` stops the default behaviour - here, navigating away - which is what turns a working form into one the page handles itself.

Three things in that example are markup decisions rather than script ones. The form works **without** the script: remove it and the browser submits to `/search`, which is progressive enhancement in two lines. The input is `required`, so the browser still validates. And the status paragraph has `role="status"`, so its text is announced when it changes - a plain `p` would update silently.

Note also `form.elements.q` - a form exposes its controls by `name`, which is more robust than a separate selector because it is the same name the server sees.

## textContent, not innerHTML

The most important line in this lesson.

```html
<p>Results for: <span id="echo"></span></p>

<script>
  var term = new URLSearchParams(location.search).get(''q'') || '''';

  document.getElementById(''echo'').textContent = term;
</script>
```

`textContent` sets text. Whatever the string contains - angle brackets, a script tag, an event handler - it becomes visible characters and nothing is parsed as markup.

`innerHTML` parses. Assigning a string that came from a URL, a form, an API or a database means handing the parser content you did not write, and if any of it is markup, the browser builds it.

So: **`textContent` unless you are certain**, and when you do need structure, build it from elements rather than from a string.

```html
<ul id="courses"></ul>

<script>
  var courses = [
    { id: ''html-101'', title: ''HTML'' },
    { id: ''css-101'', title: ''CSS'' }
  ];
  var list = document.getElementById(''courses'');

  courses.forEach(function (course) {
    var item = document.createElement(''li'');
    var link = document.createElement(''a'');
    link.href = ''/courses/'' + encodeURIComponent(course.id);
    link.textContent = course.title;
    item.appendChild(link);
    list.appendChild(item);
  });
</script>
```

Longer than one `innerHTML` assignment, and it cannot produce an injection: every value goes in as text or as an encoded URL component.

## Enhance, do not replace

The order to build in is: make it work with HTML alone, then add script.

```html
<form action="/subscribe" method="post" id="subscribe">
  <p>
    <label for="sub-email">Email</label>
    <input id="sub-email" name="email" type="email" required
           autocomplete="email">
  </p>
  <button type="submit">Subscribe</button>
  <p id="sub-status" role="status"></p>
</form>

<script>
  var form = document.getElementById(''subscribe'');
  var out = document.getElementById(''sub-status'');

  form.addEventListener(''submit'', function (event) {
    event.preventDefault();
    out.textContent = ''Subscribing '' + form.elements.email.value;
  });
</script>
```

Delete the script and the form still works: it posts to `/subscribe`, the browser still validates the address, and the person is still subscribed. The script makes it feel instant, which is an improvement on something that already worked rather than the only thing that works.

That matters more often than it sounds. Scripts fail to arrive on bad connections, are blocked by corporate proxies, and error on one browser out of five. A form built script-first is broken in all of those cases; this one is merely slower.

## Keep the state in the markup

When a script changes what something is, the markup has to say so - or the change is visible only to people looking at the screen.

```html
<button type="button" id="toggle" aria-expanded="false" aria-controls="panel">
  Show filters
</button>
<div id="panel" hidden>
  <p>The filter controls.</p>
</div>

<script>
  var toggle = document.getElementById(''toggle'');
  var panel = document.getElementById(''panel'');

  toggle.addEventListener(''click'', function () {
    var open = toggle.getAttribute(''aria-expanded'') === ''true'';
    toggle.setAttribute(''aria-expanded'', String(!open));
    panel.hidden = open;
    toggle.textContent = open ? ''Show filters'' : ''Hide filters'';
  });
</script>
```

`aria-expanded` is updated alongside the visual change. A toggle that animates perfectly and never updates that attribute is announced as collapsed forever.

And the element is a real `button`: focusable, activated by Enter and Space, announced as a button. A `div` with a click handler is none of those, and fixing that takes `tabindex`, `role` and two key handlers to get back to where `button` started.

## Running at the right moment

Three timings, and choosing wrongly is the other common "it does nothing" bug.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Timing</title>
  <script src="/early.js"></script>
  <script src="/app.js" defer></script>
</head>
<body>
  <h1>Three moments</h1>
  <script>
    document.addEventListener(''DOMContentLoaded'', function () {
      document.querySelector(''h1'').textContent = ''The tree is built'';
    });

    window.addEventListener(''load'', function () {
      document.title = ''Images and stylesheets have arrived too'';
    });
  </script>
</body>
</html>
```

**Immediately** - a plain script runs where it sits, so it sees only what is above it.

**`DOMContentLoaded`** - the tree is complete. This is the moment most code wants, and it is also exactly when a `defer` script runs, which is why `defer` plus top-level code needs no listener at all.

**`load`** - everything has arrived, including images and stylesheets. Only needed when you must measure something whose size depends on an image.

## Practice task

Build a page with a search form that a script intercepts and echoes the term back into the page - first with `innerHTML`, then with `textContent`. Submit `<img src=x onerror=alert(1)>` to each version. One shows an alert; the other shows the text. Then remove the script entirely and confirm the form still submits, because that is the version that works when the script fails to load.
',
   'JavaScript reads and changes the tree the parser built. Which means the markup decides what is easy: good hooks, real elements, and one habit - textContent rather than innerHTML - that closes the commonest security hole on the web.', 6, 1176, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000140',
   'HTML and SEO',
   'markdown',
   '# HTML and SEO

There is no tag that makes a page rank. Anyone selling one is selling 2004.

What markup does is three things: make a page **findable**, make it **understandable**, and make it **eligible** for the richer result formats. Most of what helps is the same markup that makes a page accessible, because both audiences want the same thing - content whose structure is stated rather than implied.

## The foundations

Before any tag: a page has to be worth finding, reachable by a crawler, reasonably fast, and usable on a phone. Markup contributes to the last three.

**Crawlable.** Real links with real `href` attributes. A navigation built from `div` elements with click handlers is invisible to a crawler, which does not click.

**Fast.** The loading advice from the performance lesson, with layout shift mattering most because it is measured directly.

**Usable on a phone.** The viewport tag, text that is not inside images, touch targets large enough to hit.

## Title, headings, description

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>HTML and SEO: what markup can and cannot do - Omni Academy</title>
  <meta name="description"
        content="Which HTML actually helps a page be found: titles, headings, canonical links, structured data, and the three claims that are myths.">
  <link rel="canonical" href="https://example.com/courses/html/seo">
</head>
<body>
  <main>
    <h1>HTML and SEO</h1>
    <h2>What markup can do</h2>
    <h3>Titles and headings</h3>
    <h2>What markup cannot do</h2>
  </main>
</body>
```

The `title` is the strongest single signal you control, and it is also the blue line somebody decides to click. Unique per page, specific part first, around 60 characters.

Headings are an outline. One `h1` naming the page, `h2` for sections, no skipped levels. Search engines summarise from this, and so do answer engines quoting a passage.

The description does not affect ranking. It may become the snippet, and it is frequently rewritten when the engine thinks it can do better for a particular query. Write it anyway: when it is used, it is your sentence rather than an extracted fragment.

## Canonical, robots, and the ways to disappear by accident

```html
<link rel="canonical" href="https://example.com/courses/html/seo">
<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large">
```

A canonical names which address is the real one when the same content is reachable several ways. It must be **absolute**, and it should be self-referential on the canonical page.

`robots` controls indexing. The failure modes are more interesting than the directives:

- A `noindex` left on a page from staging. The single most common cause of a page that never appears.
- A canonical pointing at the **home page** from every page, usually from a template mistake. Every page then claims to be a duplicate of the home page.
- A page blocked in `robots.txt` **and** carrying `noindex`. The crawler cannot fetch it, so it never reads the `noindex`, so the URL can still appear as a bare link. To remove a page, allow the crawl and use `noindex`.

## Structured data

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "HTML: From Basics to Expert",
  "description": "Thirty topics, five modules, every example runnable in the browser.",
  "provider": { "@type": "Organization", "name": "Omni Academy" },
  "educationalLevel": "Beginner"
}
</script>
```

Structured data states facts about the page in a vocabulary search engines parse. JSON-LD in a `script` block is the recommended form - one block, generatable, validatable, and separate from the markup it describes.

The types worth the effort are few: `Article` or `BlogPosting` for writing, `Product` with `Offer` for things for sale, `FAQPage` for questions and answers, `BreadcrumbList` for hierarchy, `Organization` once per site, `Course` for courses.

Two honest limits. It makes a page **eligible** for a rich result and guarantees nothing. And the data must describe what is actually on the page - marked-up ratings or prices that do not appear are a policy violation, and the penalty is losing rich results entirely.

## Breadcrumbs

Worth their own mention because they are the easiest win on a deep site, and because they should exist twice: once as markup people can click, once as structured data.

```html
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/courses">Courses</a></li>
    <li><a href="/courses/html">HTML</a></li>
    <li><a href="/courses/html/seo" aria-current="page">SEO</a></li>
  </ol>
</nav>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com/" },
    { "@type": "ListItem", "position": 2, "name": "Courses", "item": "https://example.com/courses" },
    { "@type": "ListItem", "position": 3, "name": "HTML", "item": "https://example.com/courses/html" }
  ]
}
</script>
```

The visible version is an ordered list inside a labelled `nav`, with `aria-current="page"` on the last item. The structured version lets a search result show the path instead of a bare URL.

## Images, links and language

```html
<img src="parse-tree.png"
     alt="A browser parses markup into a tree of html, head and body"
     width="800" height="450" loading="lazy">

<p>Read the <a href="/courses/html/accessibility">guide to accessibility</a>.</p>
```

`alt` text is indexed, and it is how image search understands a picture. Write it for a person and it will be right for the engine.

Link text is a signal about the destination. "Guide to accessibility" tells both a reader and a crawler what is at the other end; "click here" tells neither.

Language is declared on the root element, and on a multilingual site the versions are connected to each other in the head:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>HTML and SEO - Omni Academy</title>
    <link rel="alternate" hreflang="en" href="https://example.com/courses/html/seo">
    <link rel="alternate" hreflang="ar" href="https://example.com/ar/courses/html/seo">
    <link rel="alternate" hreflang="x-default" href="https://example.com/courses/html/seo">
  </head>
  <body>
    <h1>HTML and SEO</h1>
  </body>
</html>
```

`hreflang` tells an engine which version to show which audience, and `x-default` names the fallback. The rule that catches people: the set has to be **reciprocal** - every version must list every other, including itself - or the whole group is ignored.

## Three myths worth retiring

**Meta keywords.** Ignored by every major engine since about 2009. Harmless, useless.

**Keyword density.** Writing a phrase nine times does not help and reads badly, which does hurt.

**Hidden text for crawlers.** Text positioned off screen or coloured to match the background, intended to be indexed but not seen, is a policy violation. Note the distinction from a visually-hidden label, which exists to be **read aloud** rather than to be indexed - that is legitimate and a different thing entirely.

## Practice task

Take a page and check six things: unique `title`, one `h1`, no skipped heading levels, an absolute self-referential canonical, `alt` on every informative image, and link text that makes sense out of context. Then add a `BreadcrumbList` block and validate it with a structured-data testing tool. The validator will tell you about a missing required property in seconds, which is faster than waiting for a search result that never improves.
',
   'No tag makes a page rank. What markup does is make a page findable, understandable and eligible - and most of what helps is the same markup that makes it accessible, which is not a coincidence.', 6, 1102, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000001a',
   'Modern HTML APIs and Features',
   'markdown',
   '# Modern HTML APIs and Features

Several things that used to need a framework are now in the platform. This lesson is the ones worth knowing, with the obligation each one brings.

## Custom elements

```html
<course-card course="html-101">
  <span slot="title">HTML: From Basics to Expert</span>
  <span slot="summary">Thirty topics, every example runnable.</span>
</course-card>

<template id="course-card-template">
  <article>
    <h3><slot name="title">Untitled course</slot></h3>
    <p><slot name="summary"></slot></p>
    <a href="#">Explore</a>
  </article>
</template>
```

A custom element is an element you define. The name must contain a hyphen - that is what keeps it from ever colliding with a future standard element - and it is registered in JavaScript with `customElements.define`.

The `template` holds its markup, inert until cloned. `slot` elements mark where the consumer''s content appears, and the text inside a `slot` is the fallback when nothing is supplied.

With shadow DOM the component''s styles are encapsulated: your page''s CSS cannot reach in and its CSS cannot leak out. That is the main attraction, and the main cost - themeable components have to expose CSS custom properties or `::part` deliberately.

The obligation: a custom element has **no** semantics. `<course-card>` means nothing to a screen reader. Everything inside it has to be real elements - a heading that is an `h3`, a link that is an `a` - which is exactly what the template above does.

## dialog

```html
<dialog id="confirm-delete">
  <form method="dialog">
    <h2>Delete this draft?</h2>
    <p>This cannot be undone.</p>
    <button value="cancel">Keep it</button>
    <button value="delete">Delete</button>
  </form>
</dialog>

<button type="button" onclick="document.getElementById(''confirm-delete'').showModal()">
  Delete draft
</button>
```

`showModal()` gives you a focus trap, Escape to close, everything behind made inert, and a styleable `::backdrop`. A hand-built overlay has to implement all four and usually implements two.

`method="dialog"` on a form inside closes the dialog on submit without navigating, and the pressed button''s `value` becomes `returnValue`.

The obligation: it needs a name. A heading inside it or an `aria-label` on it, or it is announced as an unnamed dialog.

## popover

```html
<button type="button" popovertarget="course-info">About this course</button>

<div id="course-info" popover>
  <h3>HTML: From Basics to Expert</h3>
  <p>Thirty topics across five modules.</p>
  <button type="button" popovertarget="course-info" popovertargetaction="hide">
    Close
  </button>
</div>
```

The `popover` attribute makes an element hidden until invoked, and `popovertarget` on a button invokes it - with no JavaScript at all. The browser handles light dismiss (clicking outside closes it), Escape, and the top layer so it is never clipped by an ancestor.

The difference from `dialog` is modality: a popover is non-modal, so the page behind stays interactive. Use it for menus, tooltips and disclosures; use `dialog` when the answer is required before anything else can happen.

## contenteditable

```html
<div contenteditable="true" role="textbox" aria-multiline="true"
     aria-label="Lesson notes" style="border: 1px solid #ccc; padding: .5rem; min-height: 6rem">
  <p>Type here. This region is editable.</p>
</div>
```

One attribute turns any element into an editable region. It is how every rich-text editor on the web starts.

Three obligations, and they are why editors are hard. It is not a form control, so it has no `name` and submits nothing - the value has to be collected by script and put in a hidden field. It needs `role="textbox"` and a label to be announced. And what the user types is **markup**: paste from a word processor and you get a page of foreign HTML, which has to be sanitised before it is stored or re-rendered. A `contenteditable` region whose content is later inserted with `innerHTML` is an injection hole with extra steps.

For plain text, `textarea` is better in every way.

## Drag and drop

```html
<ul>
  <li draggable="true" ondragstart="event.dataTransfer.setData(''text/plain'', ''html-101'')">
    HTML
  </li>
  <li draggable="true" ondragstart="event.dataTransfer.setData(''text/plain'', ''css-101'')">
    CSS
  </li>
</ul>

<div ondragover="event.preventDefault()"
     ondrop="event.preventDefault(); this.textContent = ''Dropped: '' + event.dataTransfer.getData(''text/plain'')"
     style="border: 2px dashed #999; padding: 1rem">
  Drop a course here
</div>
```

`draggable="true"` makes an element draggable; the drop target must call `preventDefault()` on `dragover`, which is the counter-intuitive part - without it the browser refuses the drop.

The obligation is large: **drag and drop is unusable by keyboard, and difficult with a tremor or a touch screen.** Any reordering offered by dragging needs another route - up and down buttons, a number field, a move-to menu. Dragging is an enhancement on top of that, never the only way.

## inert, and the elements that arrived quietly

Two smaller additions that remove work.

```html
<search>
  <form action="/search" method="get" role="search">
    <label for="site-q">Search courses</label>
    <input id="site-q" name="q" type="search">
    <button type="submit">Search</button>
  </form>
</search>

<div inert>
  <p>Visible, read aloud, and not interactive:
     <a href="/somewhere">this link cannot be reached or clicked</a>.</p>
</div>
```

`search` is a landmark element for a search form - the equivalent of writing `role="search"` on a wrapper, and the newest of the landmarks. Support is recent enough that keeping the explicit `role` alongside it is still sensible.

`inert` makes a whole subtree non-interactive while leaving it visible: nothing inside takes focus, responds to clicks, or appears in the tab order. It is what a modal needs for the page behind it - and `showModal()` applies it for you, which is one more reason to use the element rather than build the overlay.

## Web storage, and what it is not

`localStorage` and `sessionStorage` are JavaScript APIs, not HTML. They are mentioned here because people reach for them from markup-shaped thinking.

Three facts worth carrying: both are readable by **any** script on your origin, so an XSS bug reads everything in them. Both are plain strings, synchronous, and roughly 5 MB. And neither is sent to the server, which is the real difference from a cookie.

So: never a token, a password or personal data. Preferences and drafts, at most.

## Choosing between the three component routes

Having custom elements does not mean reaching for them. Three levels, in order of cost.

**Plain markup with classes.** A card is an `article` with a heading and a link. No JavaScript, works everywhere, nothing to register. This covers most of what people build components for.

**A `template` cloned by script.** Markup written once in the document, filled in and inserted many times. Right for a repeated item whose content comes from data, and it keeps the markup out of JavaScript strings.

**A custom element with shadow DOM.** Encapsulated styles, a defined lifecycle, reusable across projects. The cost is real: it needs JavaScript to exist at all, so nothing renders if the script fails; its internals are invisible to your page''s CSS; and every semantic inside has to be built deliberately.

The question to ask is whether the thing needs **behaviour and isolation**, or whether it just needs to appear several times. Only the first is worth a custom element.

## Practice task

Build a disclosure three ways: with `details` and `summary`, with the `popover` attribute, and by hand with a `div` and a click handler. Then try each with the keyboard only. The first two work; the third needs `tabindex`, a `role`, `aria-expanded`, Enter and Space handlers and a focus style before it catches up. That is the argument for the platform version in one exercise.
',
   'Custom elements, templates, slots, popovers, editable regions and drag and drop. Each replaces a pile of JavaScript with a declaration - and each has one accessibility obligation that comes with it.', 6, 1151, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-00000000001c',
   'HTML Standards and Best Practices',
   'markdown',
   '# HTML Standards and Best Practices

Thirty topics of specifics. This one is the habits that keep them true on a real project.

## Validate

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>A page that validates</title>
  </head>
  <body>
    <h1>Nothing here is ambiguous</h1>
    <p>Every element is closed, every attribute quoted, every id unique.</p>
  </body>
</html>
```

A validator reads your markup the way the specification says to, and reports what it finds. It catches the things a browser silently repairs: unclosed elements, duplicate ids, invalid nesting, attributes on elements that do not take them, missing required attributes.

Those are exactly the bugs that are hardest to find by looking, because the page renders.

What validation does **not** prove: that the page is accessible, that the elements are the right ones, that it is secure or usable. A page of `div` elements with correct syntax validates perfectly. Validation is a floor.

## Check support, then degrade

Features arrive at different times in different browsers. The question is never "is this in the specification" but "what happens in the browsers my readers use".

```html
<details>
  <summary>Works everywhere</summary>
  <p>Supported for years.</p>
</details>

<div popover id="newer">
  <p>Newer. In an older browser this is simply visible.</p>
</div>

<picture>
  <source srcset="diagram.avif" type="image/avif">
  <img src="diagram.png" alt="How the parser builds a tree" width="800" height="400">
</picture>
```

Notice that two of those degrade by themselves. `picture` falls back to the `img`. An unknown attribute is ignored. Markup tends to fail softly, which is its great advantage over script - the `popover` case is the exception worth testing, because an unsupported popover is not hidden, it is just shown.

The pattern to follow is **progressive enhancement**: build the version that works with plain HTML, then add the version that feels better. In that order, because the first one is what runs when the second fails to arrive - and scripts fail to arrive more often than anyone expects.

## Markup the next person can read

```html
<article class="course-card">
  <h3 class="course-card__title">
    <a href="/courses/html">HTML: From Basics to Expert</a>
  </h3>
  <p class="course-card__summary">Thirty topics, every example runnable.</p>
  <footer class="course-card__meta">
    <time datetime="2026-03-14">Updated 14 March 2026</time>
  </footer>
</article>
```

A short list, all of it boring and all of it worth doing:

- **Lowercase tag and attribute names.** Consistency makes search and replace work.
- **Quote every attribute value.**
- **Close every non-void element.**
- **Indent to show nesting**, and keep lines short enough to read.
- **One idea per element.** An element doing three jobs is three elements.
- **Name classes after what the thing is.**
- **Comment the surprising**, not the obvious. `<!-- the empty cell is deliberate, see the headers below -->` earns its place; `<!-- the header -->` above a `header` does not.

The test for all of it: open the file in six months and see how long it takes to find the thing you want to change.

## Do not divide what is already joined

Three habits that follow from the whole course, stated once:

**Choose the element before the class.** A `button` is focusable, keyboard-operable and announced; a styled `div` is none of those and takes four attributes to catch up.

**Let the markup carry state.** `aria-expanded`, `aria-current`, `open`, `required`, `disabled`, `aria-invalid`. Each is already true and already announced; a parallel class is a second copy that will drift.

**Keep the reading order right.** CSS can move anything; the keyboard and the screen reader follow the document. Write the order the content matters, then place it.

## Reading a validator message

Validator output reads like a compiler''s until you have seen each kind once.

**"End tag `li` implied"** - something was left open and the parser closed it for you. Usually a missing `</li>`, and the real mistake is often several lines earlier.

**"Element `div` not allowed as child of element `ul`"** - a content-model violation. Only `li` may be a child of `ul`; the parser will move the div out.

**"Duplicate ID"** - almost always copied markup. The symptom is a label pointing at the wrong field, or a fragment link scrolling to the wrong place.

**"Attribute `X` not allowed on element `Y`"** - either a typo or an attribute borrowed from a different element.

**"Element `h1` is missing required instance of child element"** - some elements have required content, and an empty one is a mistake rather than a placeholder.

The one piece of advice that saves the most time: fix the **first** error and re-run. A single unclosed tag produces a cascade of errors underneath it, and most of them vanish when the first one is fixed.

## A review checklist

Before shipping any page:

1. Doctype, `lang`, `charset`, viewport, unique `title`.
2. One `h1`, no skipped heading levels.
3. Every image has `alt` - informative, functional or empty.
4. Every form control has a real `label`; groups have a `fieldset` and `legend`.
5. Every link''s text makes sense read on its own.
6. Tables have a `caption` and `scope` on every header cell.
7. Landmarks present: `header`, `nav`, `main`, `footer`, and a skip link.
8. `width` and `height` on images; `loading="lazy"` below the fold.
9. Scripts `defer`red; nothing blocking in the head that need not be.
10. Keyboard: everything reachable, focus visible, nothing trapped.
11. Validator clean.
12. It still makes sense with CSS off and with JavaScript off.

## The living standard

HTML is not versioned any more. There is no HTML6 coming; the specification is amended continuously, which has two practical consequences.

**"Is it HTML5?" is the wrong question.** The right one is whether the browsers your readers use support it, which is a support table rather than a specification.

**Nothing is removed abruptly.** Elements are marked obsolete, browsers keep rendering them, and the cost of using one is not that it breaks but that it puts presentation back in the markup. `font`, `center`, `frameset`, `marquee` all still work and are all still mistakes.

The corollary is that markup you write correctly today keeps working. HTML''s compatibility record is the best of any web technology, and that is worth something when choosing between a platform feature and a library.

## Where to look things up

The specification - the WHATWG HTML Standard - is the authority, and it is written for implementers. MDN is the reference most working developers actually use and is a better first stop. For "can I use this yet", a browser-support table beats both, because the specification describes what should exist and the table describes what does.

One habit worth more than any of them: when something behaves strangely, **look at the Elements panel**. The difference between what you wrote and what the browser built explains a surprising share of all HTML bugs, and nothing else shows it to you.

## Practice task

Run a page you have built through the W3C validator and fix everything it reports. Then go through the twelve-point checklist above. Keep the list; it is the same list for every page you will ever write, and the fourth time through it takes about ten minutes.
',
   'What to do when the course is over: validate, check support, write markup the next person can read, and build in the order that survives one piece failing to arrive.', 6, 1175, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Module 5 - Project and Practice
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000141',
   'Real-World HTML Project',
   'markdown',
   '# Real-World HTML Project

Everything in this course, applied once. The brief is a small multi-page learning site, built with HTML alone - CSS and JavaScript are the extension, not the requirement.

Build it as files on your own disk. There is no server, no build step and nothing to install.

## The brief

Ten pages, linked together:

| Page | What it has to contain |
|---|---|
| `index.html` | A hero, a short introduction, links into the catalogue |
| `about.html` | Prose, an image with real `alt` text, contact details |
| `courses.html` | A list of courses as a list, each linking to its detail page |
| `course.html` | One course: description, a curriculum list, a table of dates |
| `blog.html` | A list of articles with dates |
| `article.html` | One article, with a figure and a quotation |
| `contact.html` | A contact form and an embedded map |
| `register.html` | A registration form with validation |
| `login.html` | Email and password, correctly labelled |
| `profile.html` | A details list and a progress indicator |

Ten is the number on purpose. At that size the shared structure starts to matter, which is the thing a single page never teaches.

## The shared structure

Every page gets the same skeleton. Write it once, then copy it - and notice, as you go, how much you would like a template, because that is the lesson.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Courses - Omni Academy</title>
    <meta name="description" content="Every course in the catalogue, with level and length.">
    <link rel="canonical" href="https://example.com/courses.html">
    <link rel="stylesheet" href="styles.css">
  </head>
  <body>
    <a class="skip-link" href="#main">Skip to content</a>

    <header>
      <a href="index.html">Omni Academy</a>
      <nav aria-label="Main">
        <ul>
          <li><a href="courses.html" aria-current="page">Courses</a></li>
          <li><a href="blog.html">Blog</a></li>
          <li><a href="about.html">About</a></li>
          <li><a href="contact.html">Contact</a></li>
        </ul>
      </nav>
    </header>

    <main id="main">
      <h1>Courses</h1>
      <p>Everything in the catalogue.</p>
    </main>

    <footer>
      <p>&copy; 2026 Omni Academy</p>
      <address>
        Questions to <a href="mailto:hello@example.com">hello@example.com</a>.
      </address>
    </footer>
  </body>
</html>
```

Four things in that skeleton are the ones a reviewer checks first: the skip link, the landmarks, `aria-current="page"` on the current page''s link, and a `title` that differs per page.

Links between pages are **relative**, because the site has to work from a folder on your disk as well as from a server.

## The catalogue and a course

```html
<main id="main">
  <h1>Courses</h1>

  <ul class="course-list">
    <li>
      <article>
        <h2><a href="course.html">HTML: From Basics to Expert</a></h2>
        <p>Thirty topics, from the first tag to a finished project.</p>
        <p><small>Beginner &middot; 12 hours</small></p>
      </article>
    </li>
    <li>
      <article>
        <h2><a href="course-css.html">CSS: Layout and Type</a></h2>
        <p>Grid, flexbox and the cascade, without a framework.</p>
        <p><small>Intermediate &middot; 10 hours</small></p>
      </article>
    </li>
  </ul>
</main>
```

A list of courses is a `ul`, so its length is announced. Each card is an `article`, because it would make sense on its own. The heading inside each is the link, so the link text is the course name.

The course detail page needs a table, and a table needs a caption:

```html
<section aria-labelledby="dates">
  <h2 id="dates">Upcoming dates</h2>
  <table>
    <caption>Start dates and places remaining</caption>
    <thead>
      <tr>
        <th scope="col">Starts</th>
        <th scope="col">Format</th>
        <th scope="col">Places</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th scope="row"><time datetime="2026-04-06">6 April</time></th>
        <td>Online</td>
        <td>12</td>
      </tr>
      <tr>
        <th scope="row"><time datetime="2026-05-11">11 May</time></th>
        <td>In person</td>
        <td>4</td>
      </tr>
    </tbody>
  </table>
</section>
```

## The registration form

The hardest page, and the one worth most.

```html
<main id="main">
  <h1>Create an account</h1>

  <form action="/register" method="post">
    <fieldset>
      <legend>About you</legend>
      <p>
        <label for="given">First name</label>
        <input id="given" name="givenName" type="text" autocomplete="given-name" required>
      </p>
      <p>
        <label for="family">Last name</label>
        <input id="family" name="familyName" type="text" autocomplete="family-name" required>
      </p>
      <p>
        <label for="email">Email</label>
        <input id="email" name="email" type="email" autocomplete="email"
               aria-describedby="email-help" required>
        <span id="email-help">We use this only to confirm your enrolment.</span>
      </p>
      <p>
        <label for="password">Password</label>
        <input id="password" name="password" type="password"
               autocomplete="new-password" minlength="10" required
               aria-describedby="password-help">
        <span id="password-help">At least ten characters.</span>
      </p>
    </fieldset>

    <fieldset>
      <legend>How would you like to study?</legend>
      <p>
        <input id="online" name="mode" type="radio" value="online" checked>
        <label for="online">Online</label>
      </p>
      <p>
        <input id="in-person" name="mode" type="radio" value="in-person">
        <label for="in-person">In person</label>
      </p>
    </fieldset>

    <p>
      <input id="updates" name="updates" type="checkbox" value="yes">
      <label for="updates">Email me when new courses are published</label>
    </p>

    <button type="submit">Create account</button>
  </form>
</main>
```

Every control has a real `label` with a matching `for`. The radio group has a `fieldset` and a `legend`, so the question is announced. `autocomplete` is set on everything the browser could fill. The help text is attached with `aria-describedby`, not left floating.

## Media, and the contact page

```html
<figure>
  <img src="images/campus.jpg"
       alt="The campus courtyard at dusk, with students on the steps"
       width="900" height="500" loading="lazy">
  <figcaption>The campus, March 2026</figcaption>
</figure>

<iframe src="https://maps.example.com/embed?q=Doha"
        title="Map showing the campus in Doha"
        loading="lazy"
        style="width: 100%; aspect-ratio: 4 / 3; border: 0"></iframe>
```

Dimensions on the image so nothing shifts. A `title` on the iframe so it can be identified. `loading="lazy"` on both, because they are below the fold.

## The evaluation checklist

Mark your own work against this. A reviewer would.

1. Every page has a doctype, `lang`, `charset`, viewport and a **unique** title.
2. Every page has one `h1` and a heading order with no skipped levels.
3. Navigation works on every page, with `aria-current="page"` on the current one.
4. Every link''s text makes sense read on its own.
5. Every image has `alt` - the information, the destination, or empty - plus `width` and `height`.
6. Every form control has a real `label`; groups have a `fieldset` and `legend`.
7. Tables are used for data, with a `caption` and `scope` on every header cell.
8. Media has controls and a captions track or a transcript.
9. Everything is reachable by keyboard and the focus ring is visible.
10. It works at 320 pixels wide, and at 200% zoom.
11. The W3C validator is clean and the console has no errors.
12. The pages still read sensibly with CSS switched off.

## What a reviewer looks at first

Having marked work like this: the order is almost always the same. Open the page, press Tab four times, and look at where the focus went and whether it is visible. Then run the validator. Then turn the stylesheet off.

Three minutes, and it finds the majority of what is wrong - which is a useful thing to know while you are still building, because you can do the same three minutes yourself.

## Extensions, in order

Once the markup is right, and not before:

**CSS** for layout - a grid for the catalogue, a readable measure for the article, a stylesheet that respects `prefers-color-scheme`.

**JavaScript** as enhancement - inline validation on top of the browser''s, a filter on the catalogue that still works as a form without it.

**A back end** only when you are ready to handle authentication, validation and storage properly. Every form in this project posts somewhere that does not exist yet, and that is the correct state for a front-end project.

## Practice task

Build all ten pages, then do the checklist in one sitting. Count how many of the twelve you pass first time. The ones you miss are not random: they will be the same ones you miss on your next project, which is what makes the list worth keeping.
',
   'Ten pages, built from semantic markup, measured against a checklist rather than against how it looks. This is the brief, the shared structure, and the twelve things a reviewer will actually check.', 6, 1173, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY)),
  ('e0000001-0000-4000-8000-000000000142',
   'Interview Questions',
   'markdown',
   '# Interview Questions

The questions below are the ones that come up. For each there is an answer and, more usefully, a note on what the question is testing - because the fact asked for is rarely the point.

## Beginner

**What is HTML, and how does it differ from CSS and JavaScript?**

HTML is a markup language that describes the structure and meaning of content: this is a heading, this is a link, this is a table of data. CSS describes presentation. JavaScript describes behaviour. HTML is not a programming language - it has no variables, arithmetic or control flow.

*Testing:* whether you can separate the three cleanly. The follow-up is usually "so where does a disabled button belong?" - and the answer is HTML, because disabled is a state of the control, not a look.

**What is an element? What is an attribute?**

An element is a piece of structure, usually a start tag, content and an end tag. An attribute goes in the start tag as a name-value pair and configures the element: where a link goes, what an image shows, whether a field is required.

**What are `head` and `body` for?**

`head` holds metadata about the document - encoding, viewport, title, stylesheet and script references. `body` holds the content that is rendered. Nothing in the head appears on the page.

**What is the difference between `div` and `span`?**

Both are generic containers with no meaning. `div` is block-level, `span` is inline. The real answer is that both should be the last resort: if an element describes the content, use it.

**What is semantic HTML?**

Choosing elements for what the content is rather than how it should look. `header`, `nav`, `main`, `article`, `footer`, `h1` to `h6`, `table`, `button`. The payoff is that assistive technology, search engines and the next developer all get the same answer about the structure.

**What is `alt` text for?**

It is the text that replaces an image for anybody not receiving the image - a screen reader user, somebody on a failed connection, a search engine. Informative images get the information. An image that is a link gets the link''s destination. Decorative images get `alt=""`, present and empty, because a missing `alt` makes some screen readers read the filename.

## Intermediate

**`strong` versus `b`, and `em` versus `i`?**

`strong` means important; `em` means stressed, in the way that changes a sentence''s meaning. Both can change how a screen reader delivers the text. `b` draws attention without importance and `i` marks an alternate voice - a term, a foreign phrase - and neither carries emphasis. If you only want bold text, that is a class and a CSS rule.

**When would you use a table rather than a list?**

When the data has two dimensions: rows that mean something, columns that mean something, cells that mean the intersection. A table needs a `caption` and `scope` on every header cell, because that is what lets a screen reader read "HTML, Q2, 164" rather than "164". Never for layout.

**How do GET and POST differ?**

GET puts the values in the URL, so the request is bookmarkable, cacheable and repeatable - right for retrieval. POST puts them in the body, has no practical length limit, and is right for anything that changes something. The test is whether running the same request twice should do the same thing twice.

**What are `required`, `pattern` and `autocomplete` for?**

`required` and `pattern` are constraint validation: the browser checks before submitting and blocks on failure. `pattern` should always be paired with `title`, or the error message is generic. `autocomplete` names what a field is for, from a fixed vocabulary, so the browser can fill it from what it knows.

*Testing:* almost always followed by "so is client-side validation enough?" - and it is not. The user controls the browser; everything has to be revalidated and authorised on the server.

**How do `srcset` and `picture` support responsive images?**

`srcset` with `sizes` offers the same image at several widths and lets the **browser** choose, based on the viewport and pixel density. `picture` with `source` lets **you** choose, either by media condition - a different crop on a phone - or by format, with the first supported `type` winning. In both, the `img` is required and carries the `alt`.

**What is ARIA, and why prefer native HTML?**

ARIA adds roles, names, states and properties to elements that do not carry them. The first rule of ARIA is not to use it when an element will do: a `button` is focusable, activated by Enter and Space, exposes a disabled state and announces itself, whereas `div role="button"` gives only the announcement and leaves you owing `tabindex`, two key handlers and a focus style. Bad ARIA is worse than none, because it overrides what the element really is.

## Advanced

**What happens when a browser parses an HTML document?**

Bytes are decoded using the declared encoding, tokenised into tags, and built into a DOM tree. A stylesheet blocks the first paint. A classic script with no attributes blocks parsing entirely. Images and iframes do not block. Crucially, the parser never refuses: invalid markup is repaired according to rules in the specification, so a page with a mis-nested tag still renders - as a structure you did not write.

**What is the difference between `async` and `defer`?**

Both download in parallel with parsing. `async` executes as soon as it arrives, interrupting parsing at an unpredictable point, with no order guarantee between scripts. `defer` executes after parsing finishes, in document order. `defer` is the sensible default for application code; `async` suits genuinely independent scripts such as an analytics beacon. Module scripts are deferred automatically.

**How would you improve page loading performance?**

Measure first. Then: `defer` the scripts, give every image `width` and `height` so nothing shifts, `loading="lazy"` below the fold and never above it, `fetchpriority="high"` on the one image that defines the page, `preconnect` to third-party origins and `preload` for the font the CSS will ask for. Serve the right image size and format. Keep the DOM shallow.

**Which HTML and server controls reduce security risk?**

From the markup: escape output in the right context, prefer `textContent` to `innerHTML`, `rel="noopener noreferrer"` on new-tab links, `sandbox` on embedded content with as few tokens as possible, and never trusting a hidden field. From the server: a Content Security Policy, `frame-ancestors` against clickjacking, CSRF tokens on state-changing forms, and validation and authorisation of everything.

*Testing:* whether you know that HTML cannot enforce any of it. The right framing is that markup avoids creating problems and the server enforces the rules.

**How would you make a complex form accessible?**

A real `label` for every control. `fieldset` and `legend` for every group, so the question is announced with the options. `aria-describedby` for help text and for error messages, `aria-invalid` on fields that failed, and messages that say what a correct value looks like rather than that the value is wrong. Focus moved to the first failure. Sections with headings and a visible sense of progress. Then test it with the keyboard, which finds more than any tool.

**What is progressive enhancement?**

Build the version that works with HTML alone, then add the version that feels better. A form that posts to a real endpoint, enhanced by a script that intercepts the submit - delete the script and it still works. The reason is not purity: scripts fail to arrive on bad connections, are blocked by proxies and error on one browser in five, and a script-first page is broken in all three cases.

**What is structured data, and does it guarantee a rich result?**

A description of the page''s entities in a vocabulary such as Schema.org, usually as JSON-LD in a `script` block. It makes the page **eligible** for a richer result and guarantees nothing - the engine decides. It must describe what is actually on the page; marking up data that does not appear is a policy violation.

## Two answers worth being able to show

Interviews increasingly ask you to write something small rather than describe it. Two are worth having ready.

**"Show me progressive enhancement."**

```html
<form action="/subscribe" method="post" id="subscribe">
  <p>
    <label for="sub-email">Email</label>
    <input id="sub-email" name="email" type="email" autocomplete="email" required>
  </p>
  <button type="submit">Subscribe</button>
  <p id="sub-status" role="status"></p>
</form>

<script>
  var form = document.getElementById(''subscribe'');
  var status = document.getElementById(''sub-status'');

  form.addEventListener(''submit'', function (event) {
    event.preventDefault();
    status.textContent = ''Subscribing '' + form.elements.email.value;
  });
</script>
```

Point at the three things: the form posts somewhere real, the browser validates the address, and the status paragraph has `role="status"` so the update is announced. Delete the script and everything still works.

**"Show me why the parser matters."**

```html
<p>One paragraph.</p>
<div>A div, which cannot live inside a paragraph.</div>
<p>Another paragraph.</p>
```

Then explain what `<p><div>...</div></p>` would have produced instead: the parser closes the paragraph, places the div, and makes an empty paragraph out of the stray end tag - three elements where two were written, visible only in the Elements panel.

## The question behind most of them

A surprising number reduce to the same thing: **do you know that the browser never refuses, and that nothing in the markup is enforced?**

The parser repairs rather than rejects. Validation is a courtesy, not a boundary. ARIA describes but does not implement. A hidden field is user input. Knowing where the real guarantees live - in the element you chose, and on the server - is most of what separates an intermediate answer from a senior one.

## Practice task

Pick three questions from the advanced section and answer them aloud, in under a minute each, without notes. Then build a page that demonstrates the answer to one of them - a form that works without JavaScript, or a page that survives a mis-nested tag being fixed. Being able to show it is a better answer than being able to say it.
',
   'The questions an HTML interview actually asks, from beginner to advanced, with the answers worked through - including what the question is really testing, which is usually not the fact it asks for.', 8, 1641, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Refresh the denormalised counters and re-index for search.
-- ---------------------------------------------------------------------------
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000004');
CALL search_reindex_all_quiet();
