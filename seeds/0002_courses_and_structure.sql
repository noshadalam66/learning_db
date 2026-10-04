-- ===========================================================================
-- Seed 02 : three courses with their module / lesson structure
-- ===========================================================================

INSERT INTO catalog_courses
  (id, slug, title, subtitle, overview, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000001',
   'nodejs-microservices',
   'Node.js Microservices from Scratch',
   'Split a monolith into seven services without losing your weekends',
   'This is a course about a decision, not a technology. Splitting an application into services is a trade: you give up a single deployment and a local function call, and you get independent releases and independent scaling. Whether that is a good trade depends on facts about your system, and most of the writing on the subject skips straight past them.

So the first module is the argument against. A monolith is one deployable unit, which is not the same as a mess, and splitting a mess produces several messes with a network between them. Knowing when not to split is the more valuable half of this.

The rest builds the thing properly: three layers inside each service, one gateway in front of them all, a request id that survives every hop, and failures that look like failures rather than hangs. By the end you will have the experience the opinion should be based on.',
   'A hands-on course that takes a single Express application and pulls it apart into independently deployable services. You will build a gateway, wire up service-to-service calls, and learn where a three-layer architecture pays for itself and where it does not.

It is written for developers who already ship an Express application and are being asked, by a growing team or a slowing deploy, whether it should be several. The first module is deliberately the argument against: most systems that were split should not have been, and the lesson on boundaries is about recognising which case you are in before any code moves.

Three modules, eight items: six lessons, a knowledge check after the first module, and a final exam. The examples are a working system rather than a diagram - the gateway you build routes real requests, propagates a request id across every hop, and degrades to a readable error when a service behind it is down.

By the end you will be able to decide whether a split is justified, draw the boundary where the data actually divides, lay out each service as routes, services and repositories without the layers leaking into each other, and put one front door in front of all of them.',
   'aaaaaaa1-0000-4000-8000-000000000001',
   '22222222-2222-4222-8222-222222222222',
   'intermediate', 'published',
   'https://images.example-cdn.test/courses/nodejs-microservices.jpg', 0,
   JSON_ARRAY('Design service boundaries that survive contact with a real product',
              'Structure each service as routes, services and repositories',
              'Route traffic through an API gateway',
              'Propagate a request id across service hops'),
   JSON_ARRAY('Comfortable with JavaScript', 'Have written at least one HTTP endpoint'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 60 DAY)),

  ('c0000001-0000-4000-8000-000000000002',
   'mysql-for-applications',
   'MySQL for Application Developers',
   'Schema design, indexing and the queries behind a real product',
   'Most performance problems are schema problems wearing a disguise. A query that cannot be served by an index is slow no matter how it is written, and no amount of caching in front of it fixes the cause.

This course works through modelling a real application in MySQL from the brief upwards: turning nouns into tables, choosing keys and constraints so invalid data cannot be stored in the first place, and then reading query plans to find out what the database is actually doing rather than what you assume.

It also covers the point at which you do not need another piece of infrastructure. Full-text search in MySQL replaces the separate search service a surprising number of applications add before they have measured anything - and knowing where the real limits are is what makes the decision to add one defensible.',
   'Most performance problems are schema problems wearing a disguise. This course works through modelling a learning platform in MySQL: normalising the catalogue, choosing indexes InnoDB will actually use, and reaching for FULLTEXT before adding a second datastore.

It assumes you can already write SQL and have never been entirely sure why one query is fast and the next one is not. The answer is almost always visible in EXPLAIN, and the second module is largely about learning to read it - which is the difference between adding an index and adding the right one.

Two modules and five items, built around a single schema that grows as the course goes on. Every statement is one you can run: the tables, the constraints that keep the data honest, the query plans before and after, and a full-text search that replaces a service most teams add too early.

By the end you will be able to turn a product brief into tables that will not need rewriting, say what a composite index can and cannot serve, read a query plan without guessing, and know when MySQL is enough and when it genuinely is not.',
   'aaaaaaa1-0000-4000-8000-000000000002',
   '33333333-3333-4333-8333-333333333333',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/mysql-for-applications.jpg', 0,
   JSON_ARRAY('Model a domain in third normal form and know when to break it',
              'Read an EXPLAIN plan without flinching',
              'Use FULLTEXT indexes for search',
              'Write migrations that are safe to run on a live database'),
   JSON_ARRAY('Basic SQL: SELECT, JOIN, GROUP BY'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 45 DAY)),

  ('c0000001-0000-4000-8000-000000000003',
   'dynamic-php-frontends',
   'Dynamic PHP Front Ends',
   'Server-rendered pages that talk to a JSON API',
   'PHP did not go anywhere, and server-rendered HTML is still the simplest way to put a page in front of a user: no build step, no hydration, no client-side router, and a page that works before any JavaScript has loaded.

This course builds a front end on top of a JSON API using nothing but PHP - a layout, some templates, sessions and a CSRF token - and spends most of its time on the three mechanisms that a framework would otherwise hide from you. Knowing them is what lets you judge a framework rather than adopt one.

It is short on purpose. Three lessons, no Composer, and every piece of it is in the site you are reading this on.',
   'PHP did not go anywhere. This course builds a server-rendered front end on top of a JSON API: templating without a framework, session handling, CSRF protection, and escaping every single thing you echo.

It is for anyone who has to put a page in front of an API and would rather understand the three mechanisms underneath than adopt a framework to hide them. Nothing here needs Composer, and everything here is what a framework would be doing on your behalf.

Two modules and three lessons, short on purpose. The templating lesson is a layout and a handful of views; the escaping lesson is the one rule that prevents most of the vulnerabilities in server-rendered PHP; and the sessions lesson covers cookies, fixation and the CSRF token that makes a form safe to submit.

By the end you will be able to render a page from an API response without a template engine, escape output in the right place every time rather than most of the time, and handle a session and a form post without leaving either open to the attacks they invite.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '22222222-2222-4222-8222-222222222222',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/dynamic-php-frontends.jpg', 0,
   JSON_ARRAY('Render pages from API data with a tiny template layer',
              'Handle sessions and CSRF tokens correctly',
              'Escape output so user content cannot become markup'),
   JSON_ARRAY('Any programming experience'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 20 DAY))
-- Re-importing a seed is how an edit reaches a database that already has the
-- row, so every field this seed owns has to be listed here. Refreshing only
-- the title - which is what this said - meant a rewritten description was
-- silently dropped on every database except an empty one.
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000001', 'bbbbbbb1-0000-4000-8000-000000000001'),
  ('c0000001-0000-4000-8000-000000000001', 'bbbbbbb1-0000-4000-8000-000000000002'),
  ('c0000001-0000-4000-8000-000000000001', 'bbbbbbb1-0000-4000-8000-000000000006'),
  ('c0000001-0000-4000-8000-000000000001', 'bbbbbbb1-0000-4000-8000-000000000007'),
  ('c0000001-0000-4000-8000-000000000002', 'bbbbbbb1-0000-4000-8000-000000000003'),
  ('c0000001-0000-4000-8000-000000000002', 'bbbbbbb1-0000-4000-8000-000000000004'),
  ('c0000001-0000-4000-8000-000000000003', 'bbbbbbb1-0000-4000-8000-000000000005'),
  ('c0000001-0000-4000-8000-000000000003', 'bbbbbbb1-0000-4000-8000-000000000006')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000001',
   'Why Split at All', 'The argument before the architecture. The first lesson is about the monolith you already have, and what is actually wrong with it - which is usually deployment and ownership rather than code. The second is finding boundaries: where the data divides, where a team boundary already exists, and why the wrong line costs more than no line at all.', 1),
  ('d0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'Three Layers per Service', 'The inside of a single service, one layer per lesson. Routes and controllers translate HTTP into a call and nothing more; the service layer holds the rules and must not know what a status code is; repositories own the SQL so a query can change without the rules changing. The rule that makes it work is a single import restriction, and this module is about keeping it.', 2),
  ('d0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'The Gateway', 'What the outside world talks to. The gateway lesson covers routing, the headers that must be stripped and the identity headers that must be set, how a request id survives every hop, and what a service that does not answer should look like to a caller. The final exam covers the whole course.', 3),
  ('d0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'Modelling the Domain', 'Schema design, which is where performance is decided long before an index is added. The first lesson turns a product brief into tables - what is an entity, what is an attribute, and what is a join table pretending to be neither. The second is the constraints, keys and types that make invalid data impossible to store rather than merely unlikely.', 1),
  ('d0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'Indexes and Query Plans', 'Why a query is slow, answered with evidence. Reading EXPLAIN output comes first, because it is what turns index choice from folklore into a decision; then full-text search with FULLTEXT indexes, which replaces the separate search service a surprising number of applications add before they need it. The module ends with a quiz on indexing.', 2),
  ('d0000001-0000-4000-8000-000000000006', 'c0000001-0000-4000-8000-000000000003',
   'Rendering Pages', 'Rendering a page without a framework. The templating lesson builds a layout and the views that fill it, using nothing but PHP, and shows where the seams go so the pages stay small. The escaping lesson is the single most important habit in server-rendered PHP: escape at output, every time, in the context you are escaping for.', 1),
  ('d0000001-0000-4000-8000-000000000007', 'c0000001-0000-4000-8000-000000000003',
   'Sessions and Safety', 'The state between two requests, and the attacks that live there. Sessions, how the cookie actually works, what fixation is and how regeneration prevents it, and the CSRF token that makes a form safe to submit - with the check on the server, where it counts, rather than on the page that generated it.', 2)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  ('e0000001-0000-4000-8000-000000000001', 'd0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000001',
   'the-monolith-you-have', 'The Monolith You Already Have',
   'A monolith is not a failure state. Here is when it stops being the right answer.',
   'article', 'published', 1, 742, 1),
  ('e0000001-0000-4000-8000-000000000002', 'd0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000001',
   'finding-service-boundaries', 'Finding Service Boundaries',
   'Boundaries follow the way your team and your data actually change.',
   'article', 'published', 2, 540, 1),
  ('e0000001-0000-4000-8000-000000000003', 'd0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000001',
   'module-one-check', 'Module 1 Knowledge Check', 'Five questions on boundaries and trade-offs.',
   'quiz', 'published', 3, 300, 0),

  ('e0000001-0000-4000-8000-000000000004', 'd0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'routes-controllers-layer', 'Layer One: Routes and Controllers',
   'HTTP in, HTTP out. No business rules allowed past this line.',
   'article', 'published', 1, 913, 0),
  ('e0000001-0000-4000-8000-000000000005', 'd0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'service-layer', 'Layer Two: The Service Layer',
   'Where the rules live, and why it must not know what HTTP is.',
   'article', 'published', 2, 660, 0),
  ('e0000001-0000-4000-8000-000000000006', 'd0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'repository-layer', 'Layer Three: Repositories',
   'Every SQL statement in the codebase lives here and nowhere else.',
   'article', 'published', 3, 805, 0),

  ('e0000001-0000-4000-8000-000000000007', 'd0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'building-the-gateway', 'Building the Gateway',
   'Routing, auth verification and request-id propagation in one small service.',
   'article', 'published', 1, 1120, 0),
  ('e0000001-0000-4000-8000-000000000008', 'd0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'final-exam', 'Final Exam', 'Everything from the three modules.',
   'quiz', 'published', 2, 900, 0),

  ('e0000001-0000-4000-8000-000000000009', 'd0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'from-brief-to-tables', 'From Brief to Tables',
   'Reading a product description and finding the entities inside it.',
   'article', 'published', 1, 688, 1),
  ('e0000001-0000-4000-8000-00000000000a', 'd0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'keys-and-constraints', 'Keys, Constraints and Honest Data',
   'A constraint you did not write is a bug you will write later.',
   'article', 'published', 2, 720, 0),

  ('e0000001-0000-4000-8000-00000000000b', 'd0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'reading-explain', 'Reading EXPLAIN Output',
   'Table scans, index lookups, and when each one is fine.',
   'article', 'published', 1, 954, 0),
  ('e0000001-0000-4000-8000-00000000000c', 'd0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'full-text-search', 'Full-Text Search with FULLTEXT Indexes',
   'Search that is good enough, without a second datastore.',
   'article', 'published', 2, 840, 0),
  ('e0000001-0000-4000-8000-00000000000d', 'd0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'indexing-quiz', 'Indexing Quiz', 'Four questions on choosing indexes.',
   'quiz', 'published', 3, 420, 0),

  ('e0000001-0000-4000-8000-00000000000e', 'd0000001-0000-4000-8000-000000000006', 'c0000001-0000-4000-8000-000000000003',
   'templates-without-a-framework', 'Templates Without a Framework',
   'Plain PHP as a template language, done deliberately.',
   'article', 'published', 1, 612, 1),
  ('e0000001-0000-4000-8000-00000000000f', 'd0000001-0000-4000-8000-000000000006', 'c0000001-0000-4000-8000-000000000003',
   'escaping-everything', 'Escaping Everything You Echo',
   'The one habit that closes most XSS holes.',
   'article', 'published', 2, 480, 0),
  ('e0000001-0000-4000-8000-000000000010', 'd0000001-0000-4000-8000-000000000007', 'c0000001-0000-4000-8000-000000000003',
   'sessions-and-csrf', 'Sessions and CSRF Tokens',
   'Keeping a login and making sure only your own forms can use it.',
   'article', 'published', 1, 877, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

-- Refresh the denormalised counters now that lessons exist.
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000001');
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000002');
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000003');
