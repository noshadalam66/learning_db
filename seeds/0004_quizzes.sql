-- ===========================================================================
-- Seed 04 : quizzes, questions and options
-- ===========================================================================

INSERT INTO assessment_quizzes
  (id, course_id, lesson_id, title, description, pass_percent, time_limit_seconds,
   max_attempts, status)
VALUES
  ('f0000001-0000-4000-8000-000000000001',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000003',
   'Module 1 Knowledge Check',
   'Five questions on service boundaries and the trade-offs of splitting.',
   60, 600, 3, 'published'),

  ('f0000001-0000-4000-8000-000000000002',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000008',
   'Final Exam: Node.js Microservices',
   'Covers boundaries, the three layers and the gateway.',
   70, 1800, NULL, 'published'),

  ('f0000001-0000-4000-8000-000000000003',
   'c0000001-0000-4000-8000-000000000002', 'e0000001-0000-4000-8000-00000000000d',
   'Indexing Quiz', 'Four questions on choosing and reading indexes in MySQL.',
   75, 900, 5, 'published')
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO assessment_questions
  (id, quiz_id, kind, prompt, explanation, points, `position`, correct_text)
VALUES
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
   'You give up cross-service foreign keys and cross-service transactions. Deployment does become more independent, so that is a benefit rather than a cost.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-000000000004', 'f0000001-0000-4000-8000-000000000001', 'single_choice',
   'In this platform, which service owns the article body of a lesson?',
   'The Content Service owns article bodies and video URL metadata. The Course Service owns the lesson row itself.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-000000000005', 'f0000001-0000-4000-8000-000000000001', 'short_text',
   'What single word names the pattern of one public entry point routing requests to many internal services?',
   'The gateway (also called an API gateway) terminates the public request and forwards it inward.',
   1, 5, 'gateway'),

  ('a1000001-0000-4000-8000-000000000006', 'f0000001-0000-4000-8000-000000000002', 'single_choice',
   'Which responsibility belongs in the route/controller layer?',
   'Controllers parse and validate the request, call one service method, and map the result to a status code. Business rules and SQL both live lower down.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000007', 'f0000001-0000-4000-8000-000000000002', 'single_choice',
   'A service-layer module imports the database driver directly. What is the problem?',
   'Data access belongs in a repository. Once SQL leaks into the service layer, the business rules can no longer be tested or reused without a database.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000008', 'f0000001-0000-4000-8000-000000000002', 'multiple_choice',
   'Which of these are jobs of the API gateway in this architecture? Select all that apply.',
   'The gateway routes, verifies the access token once, and propagates a request id. Grading a quiz is the Quiz Service job and must not move into the gateway.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000009', 'f0000001-0000-4000-8000-000000000002', 'true_false',
   'A domain error thrown by the service layer should carry an HTTP status code.',
   'It should not. Domain errors describe what went wrong in business terms; a single error middleware at the edge maps them onto status codes.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-00000000000a', 'f0000001-0000-4000-8000-000000000002', 'short_text',
   'Which HTTP header does the gateway use to carry a correlation id to every downstream service?',
   'X-Request-Id is the conventional header, and every service logs it so one id ties the whole hop chain together.',
   2, 5, 'x-request-id'),

  ('a1000001-0000-4000-8000-00000000000b', 'f0000001-0000-4000-8000-000000000003', 'single_choice',
   'EXPLAIN shows an estimated 12 rows and the query actually reads 480,000. What does that suggest first?',
   'A large estimate/actual gap means the optimizer is working from stale or insufficient statistics. Every join decision above that point was made on a bad number. ANALYZE TABLE is the first thing to try.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-00000000000c', 'f0000001-0000-4000-8000-000000000003', 'true_false',
   'A full table scan always means the query is badly written.',
   'No. On a small table, or when a query genuinely touches most rows, a full scan is the cheapest plan available.',
   1, 2, NULL),

  ('a1000001-0000-4000-8000-00000000000d', 'f0000001-0000-4000-8000-000000000003', 'multiple_choice',
   'Which statements about MySQL FULLTEXT indexes are true? Select all that apply.',
   'Words shorter than innodb_ft_min_token_size (3 by default) are not indexed, and MySQL cannot weight fields inside the index the way a PostgreSQL tsvector can - weighting has to be computed at query time. FULLTEXT does work on InnoDB, and it is not limited to a single column.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-00000000000e', 'f0000001-0000-4000-8000-000000000003', 'short_text',
   'Which MySQL feature lets you emulate a partial unique index, because a unique index permits duplicates of it?',
   'A generated column that evaluates to NULL outside the subset. MySQL unique indexes allow duplicate NULLs, so only the rows in the subset collide.',
   1, 4, 'null')
ON DUPLICATE KEY UPDATE prompt = VALUES(prompt);

-- ---------------------------------------------------------------------------
-- Options.
--
-- Inserted through a SELECT with a NOT EXISTS guard rather than
-- ON DUPLICATE KEY UPDATE, because the natural key here is
-- (question_id, position) and re-running must not renumber anything.
-- ---------------------------------------------------------------------------
INSERT INTO assessment_question_options (question_id, body, is_correct, `position`)
SELECT v.question_id, v.body, v.is_correct, v.pos
  FROM (
    SELECT 'a1000001-0000-4000-8000-000000000001' AS question_id, 'They are displayed on the same screen' AS body, 0 AS is_correct, 1 AS pos
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000001', 'They must be written in the same transaction to stay correct', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000001', 'They were added to the codebase in the same week', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000001', 'They have a similar number of columns', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000002', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000002', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000003', 'You lose foreign keys across service boundaries', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000003', 'You lose transactions that span services', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000003', 'You can no longer deploy services independently', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000003', 'Every service is forced to use the same language', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000004', 'Course Service', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000004', 'Content Service', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000004', 'Progress Service', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000004', 'Search Service', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000006', 'Deciding whether a learner is allowed to enrol', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000006', 'Validating the request body and mapping the result to a status code', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000006', 'Building the SQL that loads the course', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000006', 'Computing a learner completion percentage', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000007', 'Nothing, it is faster that way', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000007', 'Data access belongs in a repository, so the rules stay testable without a database', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000007', 'The driver cannot be imported outside a repository file', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000007', 'It breaks connection pooling', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000008', 'Routing a public path to the service that owns it', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000008', 'Verifying the access token once for all services', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000008', 'Generating and forwarding a request id', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000008', 'Grading quiz attempts', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000009', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000009', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000b', 'The table needs to be optimized immediately', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000b', 'The optimizer is working from stale or insufficient statistics', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000b', 'The query should be rewritten as a CTE', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000b', 'The result is wrong', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000c', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000c', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000d', 'Words shorter than innodb_ft_min_token_size are not indexed', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000d', 'Field weighting must be computed at query time, not in the index', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000d', 'FULLTEXT indexes only work on MyISAM tables', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-00000000000d', 'A FULLTEXT index can only cover one column', 0, 4
  ) v
 WHERE NOT EXISTS (
   SELECT 1 FROM assessment_question_options o
    WHERE o.question_id = v.question_id AND o.`position` = v.pos
 );
