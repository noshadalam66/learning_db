-- ===========================================================================
-- Seed 04 : quizzes, questions and options
-- ===========================================================================

BEGIN;

INSERT INTO assessment.quizzes
  (id, course_id, lesson_id, title, description, pass_percent, time_limit_seconds, max_attempts, status)
VALUES
  ('f0000001-0000-4000-8000-000000000001',
   'c0000001-0000-4000-8000-000000000001',
   'e0000001-0000-4000-8000-000000000003',
   'Module 1 Knowledge Check',
   'Five questions on service boundaries and the trade-offs of splitting.',
   60, 600, 3, 'published'),

  ('f0000001-0000-4000-8000-000000000002',
   'c0000001-0000-4000-8000-000000000001',
   'e0000001-0000-4000-8000-000000000008',
   'Final Exam: Node.js Microservices',
   'Covers boundaries, the three layers and the gateway.',
   70, 1800, NULL, 'published'),

  ('f0000001-0000-4000-8000-000000000003',
   'c0000001-0000-4000-8000-000000000002',
   'e0000001-0000-4000-8000-00000000000d',
   'Indexing Quiz',
   'Four questions on choosing and reading indexes.',
   75, 900, 5, 'published')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Questions
-- ---------------------------------------------------------------------------
INSERT INTO assessment.questions (id, quiz_id, kind, prompt, explanation, points, position, correct_text) VALUES
  ('a1000001-0000-4000-8000-000000000001', 'f0000001-0000-4000-8000-000000000001', 'single_choice',
   'Which signal is the most reliable indicator that two pieces of data belong in the same service?',
   'Transactional coupling is the strongest signal. If two writes must succeed or fail together to keep the data correct, splitting them means inventing a distributed transaction.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000002', 'f0000001-0000-4000-8000-000000000001', 'true_false',
   'Splitting a codebase into microservices automatically improves its design.',
   'It does not. Splitting a poorly factored system produces the same poor factoring with network calls between the pieces, plus new failure modes.',
   1, 2, NULL),

  ('a1000001-0000-4000-8000-000000000003', 'f0000001-0000-4000-8000-000000000001', 'multiple_choice',
   'Which costs do you take on when you split a monolith into services? Select all that apply.',
   'You lose cross-service foreign keys and cross-service transactions. Deployment does get more independent, so that is a benefit rather than a cost.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000004', 'f0000001-0000-4000-8000-000000000001', 'single_choice',
   'In this platform, which service owns the article body of a lesson?',
   'The Content Service owns article bodies and video URL metadata. The Course Service owns the lesson row itself.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-000000000005', 'f0000001-0000-4000-8000-000000000001', 'short_text',
   'What single word names the pattern of one public entry point routing requests to many internal services?',
   'The gateway (also called an API gateway) terminates the public request and forwards it inward.',
   1, 5, 'gateway'),

  -- Final exam
  ('a1000001-0000-4000-8000-000000000006', 'f0000001-0000-4000-8000-000000000002', 'single_choice',
   'Which responsibility belongs in the route/controller layer?',
   'Controllers parse and validate the request, call one service method, and map the result to a status code. Business rules and SQL both live lower down.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000007', 'f0000001-0000-4000-8000-000000000002', 'single_choice',
   'A service-layer module imports the pg driver directly. What is the problem?',
   'Data access belongs in a repository. Once SQL leaks into the service layer, the business rules can no longer be tested or reused without a database.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000008', 'f0000001-0000-4000-8000-000000000002', 'multiple_choice',
   'Which of these are jobs of the API gateway in this architecture? Select all that apply.',
   'The gateway routes, verifies the access token once, and propagates a request id. Grading a quiz is the Quiz Service''s job and must not move into the gateway.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000009', 'f0000001-0000-4000-8000-000000000002', 'true_false',
   'A domain error thrown by the service layer should carry an HTTP status code.',
   'It should not. Domain errors describe what went wrong in business terms; a single error middleware at the edge maps them onto status codes.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-00000000000a', 'f0000001-0000-4000-8000-000000000002', 'short_text',
   'Which HTTP header does the gateway use to carry a correlation id to every downstream service?',
   'X-Request-Id is the conventional header, and every service logs it so one id ties the whole hop chain together.',
   2, 5, 'x-request-id'),

  -- Indexing quiz
  ('a1000001-0000-4000-8000-00000000000b', 'f0000001-0000-4000-8000-000000000003', 'single_choice',
   'EXPLAIN ANALYZE shows an estimated 12 rows and 480,000 actual rows for one node. What does that suggest first?',
   'A large estimate/actual gap means the planner is working from stale or insufficient statistics. Every join decision above that node was made on a bad number.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-00000000000c', 'f0000001-0000-4000-8000-000000000003', 'true_false',
   'A sequential scan always means the query is badly written.',
   'No. On a small table, or when a query genuinely touches most rows, a sequential scan is the cheapest plan available.',
   1, 2, NULL),

  ('a1000001-0000-4000-8000-00000000000d', 'f0000001-0000-4000-8000-000000000003', 'multiple_choice',
   'Which index types are appropriate for full-text and fuzzy matching in PostgreSQL? Select all that apply.',
   'GIN serves tsvector columns, and GIN with gin_trgm_ops serves trigram similarity. A plain B-tree on the text column helps with neither.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-00000000000e', 'f0000001-0000-4000-8000-000000000003', 'short_text',
   'Which keyword makes a unique index apply to only a subset of rows?',
   'A partial index is written with a WHERE clause, which is what limits it to a subset of rows.',
   1, 4, 'where')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Options
-- ---------------------------------------------------------------------------
-- Guarded with NOT EXISTS rather than ON CONFLICT: the (question_id, position)
-- unique constraint is DEFERRABLE, and PostgreSQL will not use a deferrable
-- constraint as an ON CONFLICT arbiter.
INSERT INTO assessment.question_options (question_id, body, is_correct, position)
SELECT v.question_id, v.body, v.is_correct, v.position
  FROM (VALUES
  ('a1000001-0000-4000-8000-000000000001'::uuid, 'They are displayed on the same screen', false, 1),
  ('a1000001-0000-4000-8000-000000000001', 'They must be written in the same transaction to stay correct', true, 2),
  ('a1000001-0000-4000-8000-000000000001', 'They were added to the codebase in the same week', false, 3),
  ('a1000001-0000-4000-8000-000000000001', 'They have a similar number of columns', false, 4),

  ('a1000001-0000-4000-8000-000000000002', 'True', false, 1),
  ('a1000001-0000-4000-8000-000000000002', 'False', true, 2),

  ('a1000001-0000-4000-8000-000000000003', 'You lose foreign keys across service boundaries', true, 1),
  ('a1000001-0000-4000-8000-000000000003', 'You lose transactions that span services', true, 2),
  ('a1000001-0000-4000-8000-000000000003', 'You can no longer deploy services independently', false, 3),
  ('a1000001-0000-4000-8000-000000000003', 'Every service is forced to use the same language', false, 4),

  ('a1000001-0000-4000-8000-000000000004', 'Course Service', false, 1),
  ('a1000001-0000-4000-8000-000000000004', 'Content Service', true, 2),
  ('a1000001-0000-4000-8000-000000000004', 'Progress Service', false, 3),
  ('a1000001-0000-4000-8000-000000000004', 'Search Service', false, 4),

  ('a1000001-0000-4000-8000-000000000006', 'Deciding whether a learner is allowed to enrol', false, 1),
  ('a1000001-0000-4000-8000-000000000006', 'Validating the request body and mapping the result to a status code', true, 2),
  ('a1000001-0000-4000-8000-000000000006', 'Building the SQL that loads the course', false, 3),
  ('a1000001-0000-4000-8000-000000000006', 'Computing a learner''s completion percentage', false, 4),

  ('a1000001-0000-4000-8000-000000000007', 'Nothing, it is faster that way', false, 1),
  ('a1000001-0000-4000-8000-000000000007', 'Data access belongs in a repository, so the rules stay testable without a database', true, 2),
  ('a1000001-0000-4000-8000-000000000007', 'The pg driver cannot be imported outside a repository file', false, 3),
  ('a1000001-0000-4000-8000-000000000007', 'It breaks connection pooling', false, 4),

  ('a1000001-0000-4000-8000-000000000008', 'Routing a public path to the service that owns it', true, 1),
  ('a1000001-0000-4000-8000-000000000008', 'Verifying the access token once for all services', true, 2),
  ('a1000001-0000-4000-8000-000000000008', 'Generating and forwarding a request id', true, 3),
  ('a1000001-0000-4000-8000-000000000008', 'Grading quiz attempts', false, 4),

  ('a1000001-0000-4000-8000-000000000009', 'True', false, 1),
  ('a1000001-0000-4000-8000-000000000009', 'False', true, 2),

  ('a1000001-0000-4000-8000-00000000000b', 'The table needs to be vacuumed immediately', false, 1),
  ('a1000001-0000-4000-8000-00000000000b', 'The planner is working from stale or insufficient statistics', true, 2),
  ('a1000001-0000-4000-8000-00000000000b', 'The query should be rewritten as a CTE', false, 3),
  ('a1000001-0000-4000-8000-00000000000b', 'The result is wrong', false, 4),

  ('a1000001-0000-4000-8000-00000000000c', 'True', false, 1),
  ('a1000001-0000-4000-8000-00000000000c', 'False', true, 2),

  ('a1000001-0000-4000-8000-00000000000d', 'GIN on a tsvector column', true, 1),
  ('a1000001-0000-4000-8000-00000000000d', 'GIN with gin_trgm_ops on a text column', true, 2),
  ('a1000001-0000-4000-8000-00000000000d', 'A plain B-tree on the text column', false, 3),
  ('a1000001-0000-4000-8000-00000000000d', 'A hash index on the text column', false, 4)
  ) AS v(question_id, body, is_correct, position)
 WHERE NOT EXISTS (
   SELECT 1 FROM assessment.question_options o
    WHERE o.question_id = v.question_id AND o.position = v.position
 );

COMMIT;
