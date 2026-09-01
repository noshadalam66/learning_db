-- ===========================================================================
-- Seed 05 : enrolments, lesson progress, a graded attempt, events, index
-- ===========================================================================

-- lessons_total comes from the catalogue so the rollup has a denominator.
INSERT INTO progress.enrolments (id, user_id, course_id, lessons_total, enrolled_at)
SELECT v.enrolment_id, v.user_id, v.course_id, c.lesson_count,
       DATE_SUB(UTC_TIMESTAMP(3), INTERVAL v.age_days DAY)
  FROM (
    SELECT 'b0000001-0000-4000-8000-000000000001' AS enrolment_id,
           '44444444-4444-4444-8444-444444444444' AS user_id,
           'c0000001-0000-4000-8000-000000000001' AS course_id, 30 AS age_days
    UNION ALL SELECT 'b0000001-0000-4000-8000-000000000002',
           '44444444-4444-4444-8444-444444444444', 'c0000001-0000-4000-8000-000000000002', 12
    UNION ALL SELECT 'b0000001-0000-4000-8000-000000000003',
           '55555555-5555-4555-8555-555555555555', 'c0000001-0000-4000-8000-000000000003', 9
    UNION ALL SELECT 'b0000001-0000-4000-8000-000000000004',
           '55555555-5555-4555-8555-555555555555', 'c0000001-0000-4000-8000-000000000001', 5
  ) v
  JOIN catalog.courses c ON c.id = v.course_id
ON DUPLICATE KEY UPDATE lessons_total = VALUES(lessons_total);

-- Sam has worked through the first four lessons of the microservices course
-- and is part way into the fifth.
INSERT INTO progress.lesson_progress
  (enrolment_id, user_id, course_id, lesson_id, state, seconds_watched,
   last_position_seconds, view_count, first_viewed_at, last_viewed_at, completed_at)
VALUES
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000001',
   'completed', 742, 742, 2, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 30 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 29 DAY), DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 29 DAY)),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000002',
   'completed', 540, 540, 1, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 28 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 28 DAY), DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 28 DAY)),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000003',
   'completed', 300, 300, 1, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 26 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 26 DAY), DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 26 DAY)),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000004',
   'completed', 913, 913, 3, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 20 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 18 DAY), DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 18 DAY)),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000005',
   'in_progress', 410, 410, 1, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 3 DAY), NULL),

  ('b0000001-0000-4000-8000-000000000003', '55555555-5555-4555-8555-555555555555',
   'c0000001-0000-4000-8000-000000000003', 'e0000001-0000-4000-8000-00000000000e',
   'completed', 612, 612, 1, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY), DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),
  ('b0000001-0000-4000-8000-000000000003', '55555555-5555-4555-8555-555555555555',
   'c0000001-0000-4000-8000-000000000003', 'e0000001-0000-4000-8000-00000000000f',
   'in_progress', 120, 120, 1, DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY), NULL)
ON DUPLICATE KEY UPDATE state = VALUES(state);

UPDATE progress.enrolments SET last_lesson_id = 'e0000001-0000-4000-8000-000000000005'
 WHERE id = 'b0000001-0000-4000-8000-000000000001';
UPDATE progress.enrolments SET last_lesson_id = 'e0000001-0000-4000-8000-00000000000f'
 WHERE id = 'b0000001-0000-4000-8000-000000000003';

CALL progress.refresh_enrolment_rollup('b0000001-0000-4000-8000-000000000001');
CALL progress.refresh_enrolment_rollup('b0000001-0000-4000-8000-000000000002');
CALL progress.refresh_enrolment_rollup('b0000001-0000-4000-8000-000000000003');
CALL progress.refresh_enrolment_rollup('b0000001-0000-4000-8000-000000000004');

-- Notes carry no unique key, so guard the insert by hand.
INSERT INTO progress.lesson_notes (user_id, lesson_id, course_id, body, at_seconds)
SELECT v.user_id, v.lesson_id, v.course_id, v.body, v.at_seconds
  FROM (
    SELECT '44444444-4444-4444-8444-444444444444' AS user_id,
           'e0000001-0000-4000-8000-000000000004' AS lesson_id,
           'c0000001-0000-4000-8000-000000000001' AS course_id,
           'Rewatch this bit - the point about controllers never holding rules is the one I keep breaking.' AS body,
           412 AS at_seconds
    UNION ALL SELECT '44444444-4444-4444-8444-444444444444',
           'e0000001-0000-4000-8000-000000000002', 'c0000001-0000-4000-8000-000000000001',
           'Transactional coupling as the boundary test. Try this on the billing code at work.', NULL
  ) v
 WHERE NOT EXISTS (
   SELECT 1 FROM progress.lesson_notes n
    WHERE n.user_id = v.user_id AND n.lesson_id = v.lesson_id
 );

-- ---------------------------------------------------------------------------
-- A completed quiz attempt, graded by the same procedure the Quiz Service calls.
-- Sam gets Q1 right, Q2 right, Q3 partially wrong (choice questions are
-- all-or-nothing), Q4 right and Q5 right: 5 of 7 points.
-- ---------------------------------------------------------------------------
INSERT INTO assessment.quiz_attempts
  (id, quiz_id, user_id, course_id, attempt_no, state, started_at, submitted_at)
VALUES
  ('a2000001-0000-4000-8000-000000000001', 'f0000001-0000-4000-8000-000000000001',
   '44444444-4444-4444-8444-444444444444', 'c0000001-0000-4000-8000-000000000001',
   1, 'submitted', DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 26 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 26 DAY))
ON DUPLICATE KEY UPDATE state = VALUES(state);

INSERT INTO assessment.attempt_answers (attempt_id, question_id, selected_option_ids, text_answer)
SELECT 'a2000001-0000-4000-8000-000000000001', v.question_id,
       IFNULL(
         (SELECT JSON_ARRAYAGG(o.id) FROM assessment.question_options o
           WHERE o.question_id = v.question_id AND o.body = v.chosen_body),
         JSON_ARRAY()
       ),
       v.text_answer
  FROM (
    SELECT 'a1000001-0000-4000-8000-000000000001' AS question_id,
           'They must be written in the same transaction to stay correct' AS chosen_body,
           NULL AS text_answer
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000002', 'False', NULL
    -- Only one of the two correct options: all-or-nothing means this scores 0.
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000003', 'You lose foreign keys across service boundaries', NULL
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000004', 'Content Service', NULL
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000005', NULL, 'Gateway'
  ) v
ON DUPLICATE KEY UPDATE selected_option_ids = VALUES(selected_option_ids);

CALL assessment.grade_attempt('a2000001-0000-4000-8000-000000000001');

-- ---------------------------------------------------------------------------
-- Behaviour events across the last two weeks, then the rollups.
-- ---------------------------------------------------------------------------
CALL analytics.ensure_month_partition(DATE(UTC_TIMESTAMP()));
CALL analytics.ensure_month_partition(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 1 MONTH));
CALL analytics.ensure_month_partition(DATE_ADD(DATE(UTC_TIMESTAMP()), INTERVAL 1 MONTH));

-- MySQL has no generate_series, so the day range comes from a small derived
-- table of digits. 14 days x 2 learners x 3 event kinds.
INSERT INTO analytics.events
  (occurred_at, user_id, session_id, event_name, entity_type, entity_id,
   course_id, lesson_id, properties)
SELECT
  DATE_SUB(UTC_TIMESTAMP(3), INTERVAL (d.n * 24 + FLOOR(RAND() * 8)) HOUR),
  u.user_id,
  CONCAT('sess_', DATE_FORMAT(DATE_SUB(UTC_TIMESTAMP(), INTERVAL d.n DAY), '%Y%m%d'),
         '_', SUBSTRING(u.user_id, 1, 8)),
  ev.event_name, 'lesson', l.id, l.course_id, l.id,
  JSON_OBJECT('seconds', 60 + FLOOR(RAND() * 600), 'source', 'web')
FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
      UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
      UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
      UNION ALL SELECT 12 UNION ALL SELECT 13) d
CROSS JOIN (SELECT '44444444-4444-4444-8444-444444444444' AS user_id
            UNION ALL SELECT '55555555-5555-4555-8555-555555555555') u
CROSS JOIN (SELECT 'lesson_viewed' AS event_name UNION ALL SELECT 'video_progress'
            UNION ALL SELECT 'lesson_started') ev
-- Spread the events over the published lessons deterministically. A
-- MD5(CONCAT(...)) shuffle would be shorter but mixes an ascii id, a number
-- and a utf8mb4 string in one CONCAT, which MySQL rejects as an illegal mix
-- of collations.
JOIN (
  SELECT id, course_id,
         ROW_NUMBER() OVER (ORDER BY course_id, `position`) - 1 AS rn,
         COUNT(*) OVER () AS total
    FROM catalog.lessons
   WHERE status = 'published'
) l
  ON l.rn = (d.n * 3 + IF(u.user_id = '44444444-4444-4444-8444-444444444444', 0, 1)) % l.total
WHERE NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'lesson_viewed');

INSERT INTO analytics.events (occurred_at, user_id, event_name, entity_type, course_id, properties)
SELECT e.enrolled_at, e.user_id, 'course_enrolled', 'course', e.course_id,
       JSON_OBJECT('source', 'catalogue')
  FROM progress.enrolments e
 WHERE NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'course_enrolled');

INSERT INTO analytics.events (occurred_at, user_id, event_name, properties)
SELECT DATE_SUB(UTC_TIMESTAMP(3), INTERVAL d.n DAY),
       '44444444-4444-4444-8444-444444444444', 'search_performed',
       JSON_OBJECT('query', q.term, 'results', q.hits)
  FROM (SELECT 1 n UNION ALL SELECT 3 UNION ALL SELECT 5) d
 CROSS JOIN (SELECT 'mysql indexes' AS term, 4 AS hits
             UNION ALL SELECT 'microservices', 3
             UNION ALL SELECT 'csrf', 1) q
 WHERE NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'search_performed');

INSERT INTO `search`.query_log (user_id, query_text, result_count)
SELECT v.user_id, v.query_text, v.result_count
  FROM (
    SELECT '44444444-4444-4444-8444-444444444444' AS user_id, 'mysql indexes' AS query_text, 4 AS result_count
    UNION ALL SELECT '44444444-4444-4444-8444-444444444444', 'microservices', 3
    UNION ALL SELECT '55555555-5555-4555-8555-555555555555', 'csrf token php', 1
    UNION ALL SELECT '55555555-5555-4555-8555-555555555555', 'kubernetes operators', 0
  ) v
 WHERE NOT EXISTS (SELECT 1 FROM `search`.query_log);

-- Synonyms also rescue terms shorter than innodb_ft_min_token_size (3), which
-- FULLTEXT will not index at all.
INSERT INTO `search`.synonyms (term, expands_to) VALUES
  ('js',    JSON_ARRAY('javascript')),
  ('ci',    JSON_ARRAY('continuous', 'integration')),
  ('db',    JSON_ARRAY('database', 'mysql')),
  ('api',   JSON_ARRAY('rest', 'endpoint')),
  ('sql',   JSON_ARRAY('mysql', 'query'))
ON DUPLICATE KEY UPDATE expands_to = VALUES(expands_to);

CALL `search`.reindex_all();

-- Roll up the last eight days.
CALL analytics.rollup_day(DATE(UTC_TIMESTAMP()));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 1 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 2 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 3 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 4 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 5 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 6 DAY));
CALL analytics.rollup_day(DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 7 DAY));

CALL catalog.refresh_course_rating('c0000001-0000-4000-8000-000000000001');
CALL catalog.refresh_course_rating('c0000001-0000-4000-8000-000000000002');
CALL catalog.refresh_course_rating('c0000001-0000-4000-8000-000000000003');
