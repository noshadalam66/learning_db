-- ===========================================================================
-- Seed 02 : three courses with their module / lesson structure
-- ===========================================================================

INSERT INTO catalog_courses
  (id, slug, title, subtitle, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000001',
   'nodejs-microservices',
   'Node.js Microservices from Scratch',
   'Split a monolith into seven services without losing your weekends',
   'A hands-on course that takes a single Express application and pulls it apart into independently deployable services. You will build a gateway, wire up service-to-service calls, and learn where a three-layer architecture pays for itself and where it does not.',
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
   'Most performance problems are schema problems wearing a disguise. This course works through modelling a learning platform in MySQL: normalising the catalogue, choosing indexes InnoDB will actually use, and reaching for FULLTEXT before adding a second datastore.',
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
   'PHP did not go anywhere. This course builds a server-rendered front end on top of a JSON API: templating without a framework, session handling, CSRF protection, and escaping every single thing you echo.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '22222222-2222-4222-8222-222222222222',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/dynamic-php-frontends.jpg', 0,
   JSON_ARRAY('Render pages from API data with a tiny template layer',
              'Handle sessions and CSRF tokens correctly',
              'Escape output so user content cannot become markup'),
   JSON_ARRAY('Any programming experience'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 20 DAY))
ON DUPLICATE KEY UPDATE title = VALUES(title);

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
   'Why Split at All', 'The honest case for and against microservices.', 1),
  ('d0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'Three Layers per Service', 'Routes, services, repositories - and what belongs in each.', 2),
  ('d0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'The Gateway', 'One front door, seven services behind it.', 3),
  ('d0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'Modelling the Domain', 'Turning a product brief into tables.', 1),
  ('d0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'Indexes and Query Plans', 'Making InnoDB do less work.', 2),
  ('d0000001-0000-4000-8000-000000000006', 'c0000001-0000-4000-8000-000000000003',
   'Rendering Pages', 'Templates, escaping and layout.', 1),
  ('d0000001-0000-4000-8000-000000000007', 'c0000001-0000-4000-8000-000000000003',
   'Sessions and Safety', 'Cookies, CSRF and the things that bite.', 2)
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  ('e0000001-0000-4000-8000-000000000001', 'd0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000001',
   'the-monolith-you-have', 'The Monolith You Already Have',
   'A monolith is not a failure state. Here is when it stops being the right answer.',
   'video', 'published', 1, 742, 1),
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
   'video', 'published', 1, 913, 0),
  ('e0000001-0000-4000-8000-000000000005', 'd0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'service-layer', 'Layer Two: The Service Layer',
   'Where the rules live, and why it must not know what HTTP is.',
   'article', 'published', 2, 660, 0),
  ('e0000001-0000-4000-8000-000000000006', 'd0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
   'repository-layer', 'Layer Three: Repositories',
   'Every SQL statement in the codebase lives here and nowhere else.',
   'video', 'published', 3, 805, 0),

  ('e0000001-0000-4000-8000-000000000007', 'd0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'building-the-gateway', 'Building the Gateway',
   'Routing, auth verification and request-id propagation in one small service.',
   'video', 'published', 1, 1120, 0),
  ('e0000001-0000-4000-8000-000000000008', 'd0000001-0000-4000-8000-000000000003', 'c0000001-0000-4000-8000-000000000001',
   'final-exam', 'Final Exam', 'Everything from the three modules.',
   'quiz', 'published', 2, 900, 0),

  ('e0000001-0000-4000-8000-000000000009', 'd0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'from-brief-to-tables', 'From Brief to Tables',
   'Reading a product description and finding the entities inside it.',
   'video', 'published', 1, 688, 1),
  ('e0000001-0000-4000-8000-00000000000a', 'd0000001-0000-4000-8000-000000000004', 'c0000001-0000-4000-8000-000000000002',
   'keys-and-constraints', 'Keys, Constraints and Honest Data',
   'A constraint you did not write is a bug you will write later.',
   'article', 'published', 2, 720, 0),

  ('e0000001-0000-4000-8000-00000000000b', 'd0000001-0000-4000-8000-000000000005', 'c0000001-0000-4000-8000-000000000002',
   'reading-explain', 'Reading EXPLAIN Output',
   'Table scans, index lookups, and when each one is fine.',
   'video', 'published', 1, 954, 0),
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
   'video', 'published', 1, 612, 1),
  ('e0000001-0000-4000-8000-00000000000f', 'd0000001-0000-4000-8000-000000000006', 'c0000001-0000-4000-8000-000000000003',
   'escaping-everything', 'Escaping Everything You Echo',
   'The one habit that closes most XSS holes.',
   'article', 'published', 2, 480, 0),
  ('e0000001-0000-4000-8000-000000000010', 'd0000001-0000-4000-8000-000000000007', 'c0000001-0000-4000-8000-000000000003',
   'sessions-and-csrf', 'Sessions and CSRF Tokens',
   'Keeping a login and making sure only your own forms can use it.',
   'video', 'published', 1, 877, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- Refresh the denormalised counters now that lessons exist.
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000001');
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000002');
CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000003');
