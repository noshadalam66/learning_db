-- ===========================================================================
-- Seed 05 : enrolments, lesson progress, a graded attempt, events, index
-- ===========================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Enrolments. lessons_total comes from the catalogue so the rollup has a
-- denominator before any lesson rows exist.
-- ---------------------------------------------------------------------------
INSERT INTO progress.enrolments (id, user_id, course_id, lessons_total, enrolled_at)
SELECT v.enrolment_id, v.user_id, v.course_id, c.lesson_count, now() - v.age
  FROM (VALUES
    ('b0000001-0000-4000-8000-000000000001'::uuid, '44444444-4444-4444-8444-444444444444'::uuid,
     'c0000001-0000-4000-8000-000000000001'::uuid, interval '30 days'),
    ('b0000001-0000-4000-8000-000000000002'::uuid, '44444444-4444-4444-8444-444444444444'::uuid,
     'c0000001-0000-4000-8000-000000000002'::uuid, interval '12 days'),
    ('b0000001-0000-4000-8000-000000000003'::uuid, '55555555-5555-4555-8555-555555555555'::uuid,
     'c0000001-0000-4000-8000-000000000003'::uuid, interval '9 days'),
    ('b0000001-0000-4000-8000-000000000004'::uuid, '55555555-5555-4555-8555-555555555555'::uuid,
     'c0000001-0000-4000-8000-000000000001'::uuid, interval '5 days')
  ) AS v(enrolment_id, user_id, course_id, age)
  JOIN catalog.courses c ON c.id = v.course_id
ON CONFLICT (user_id, course_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Sam has worked through the first four lessons of the microservices course
-- and is part way into the fifth.
-- ---------------------------------------------------------------------------
INSERT INTO progress.lesson_progress
  (enrolment_id, user_id, course_id, lesson_id, state, seconds_watched,
   last_position_seconds, view_count, first_viewed_at, last_viewed_at, completed_at)
VALUES
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000001',
   'completed', 742, 742, 2, now() - interval '30 days', now() - interval '29 days', now() - interval '29 days'),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000002',
   'completed', 540, 540, 1, now() - interval '28 days', now() - interval '28 days', now() - interval '28 days'),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000003',
   'completed', 300, 300, 1, now() - interval '26 days', now() - interval '26 days', now() - interval '26 days'),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000004',
   'completed', 913, 913, 3, now() - interval '20 days', now() - interval '18 days', now() - interval '18 days'),
  ('b0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001', 'e0000001-0000-4000-8000-000000000005',
   'in_progress', 410, 410, 1, now() - interval '3 days', now() - interval '3 days', NULL),

  -- Lena has just started the PHP course.
  ('b0000001-0000-4000-8000-000000000003', '55555555-5555-4555-8555-555555555555',
   'c0000001-0000-4000-8000-000000000003', 'e0000001-0000-4000-8000-00000000000e',
   'completed', 612, 612, 1, now() - interval '9 days', now() - interval '9 days', now() - interval '9 days'),
  ('b0000001-0000-4000-8000-000000000003', '55555555-5555-4555-8555-555555555555',
   'c0000001-0000-4000-8000-000000000003', 'e0000001-0000-4000-8000-00000000000f',
   'in_progress', 120, 120, 1, now() - interval '2 days', now() - interval '2 days', NULL)
ON CONFLICT (user_id, lesson_id) DO NOTHING;

UPDATE progress.enrolments
   SET last_lesson_id = 'e0000001-0000-4000-8000-000000000005'
 WHERE id = 'b0000001-0000-4000-8000-000000000001';

UPDATE progress.enrolments
   SET last_lesson_id = 'e0000001-0000-4000-8000-00000000000f'
 WHERE id = 'b0000001-0000-4000-8000-000000000003';

SELECT progress.refresh_enrolment_rollup(id) FROM progress.enrolments;

-- Notes are free-form and deliberately not unique, so guard the seed by hand.
INSERT INTO progress.lesson_notes (user_id, lesson_id, course_id, body, at_seconds)
SELECT v.user_id, v.lesson_id, v.course_id, v.body, v.at_seconds
  FROM (VALUES
    ('44444444-4444-4444-8444-444444444444'::uuid, 'e0000001-0000-4000-8000-000000000004'::uuid,
     'c0000001-0000-4000-8000-000000000001'::uuid,
     'Rewatch this bit - the point about controllers never holding rules is the one I keep breaking.', 412),
    ('44444444-4444-4444-8444-444444444444', 'e0000001-0000-4000-8000-000000000002',
     'c0000001-0000-4000-8000-000000000001',
     'Transactional coupling as the boundary test. Try this on the billing code at work.', NULL)
  ) AS v(user_id, lesson_id, course_id, body, at_seconds)
 WHERE NOT EXISTS (
   SELECT 1 FROM progress.lesson_notes n
    WHERE n.user_id = v.user_id AND n.lesson_id = v.lesson_id
 );

-- ---------------------------------------------------------------------------
-- A completed quiz attempt, graded by the same function the Quiz Service calls.
-- Sam gets question 1 right, question 2 right, question 3 partially wrong
-- (choice questions are all-or-nothing), question 4 right and question 5 right.
-- ---------------------------------------------------------------------------
INSERT INTO assessment.quiz_attempts
  (id, quiz_id, user_id, course_id, attempt_no, state, started_at, submitted_at)
VALUES
  ('a2000001-0000-4000-8000-000000000001',
   'f0000001-0000-4000-8000-000000000001',
   '44444444-4444-4444-8444-444444444444',
   'c0000001-0000-4000-8000-000000000001',
   1, 'submitted', now() - interval '26 days', now() - interval '26 days' + interval '7 minutes')
ON CONFLICT (id) DO NOTHING;

INSERT INTO assessment.attempt_answers (attempt_id, question_id, selected_option_ids, text_answer)
SELECT 'a2000001-0000-4000-8000-000000000001', q.id, sel.option_ids, sel.text_answer
  FROM (VALUES
    ('a1000001-0000-4000-8000-000000000001'::uuid, ARRAY['They must be written in the same transaction to stay correct'], NULL::text),
    ('a1000001-0000-4000-8000-000000000002'::uuid, ARRAY['False'], NULL),
    ('a1000001-0000-4000-8000-000000000003'::uuid, ARRAY['You lose foreign keys across service boundaries'], NULL),
    ('a1000001-0000-4000-8000-000000000004'::uuid, ARRAY['Content Service'], NULL),
    ('a1000001-0000-4000-8000-000000000005'::uuid, ARRAY[]::text[], 'Gateway')
  ) AS chosen(question_id, option_bodies, text_answer)
  JOIN assessment.questions q ON q.id = chosen.question_id
  CROSS JOIN LATERAL (
    SELECT coalesce(array_agg(o.id), '{}'::uuid[]) AS option_ids,
           chosen.text_answer
      FROM assessment.question_options o
     WHERE o.question_id = chosen.question_id
       AND o.body = ANY (chosen.option_bodies)
  ) AS sel
ON CONFLICT (attempt_id, question_id) DO NOTHING;

SELECT assessment.grade_attempt('a2000001-0000-4000-8000-000000000001');

-- ---------------------------------------------------------------------------
-- Behaviour events across the last two weeks, then the rollups.
-- ---------------------------------------------------------------------------
SELECT analytics.ensure_month_partition(current_date);
SELECT analytics.ensure_month_partition((current_date - interval '1 month')::date);
SELECT analytics.ensure_month_partition((current_date + interval '1 month')::date);

INSERT INTO analytics.events
  (occurred_at, user_id, session_id, event_name, entity_type, entity_id, course_id, lesson_id, properties)
SELECT
  now() - (d || ' days')::interval - (random() * interval '8 hours'),
  u.user_id,
  'sess_' || to_char(now() - (d || ' days')::interval, 'YYYYMMDD') || '_' || substr(u.user_id::text, 1, 8),
  ev.event_name,
  'lesson',
  l.lesson_id,
  l.course_id,
  l.lesson_id,
  jsonb_build_object('seconds', (60 + floor(random() * 600))::int, 'source', 'web')
FROM generate_series(0, 13) AS d
CROSS JOIN (VALUES
  ('44444444-4444-4444-8444-444444444444'::uuid),
  ('55555555-5555-4555-8555-555555555555'::uuid)
) AS u(user_id)
CROSS JOIN (VALUES ('lesson_viewed'), ('video_progress'), ('lesson_started')) AS ev(event_name)
CROSS JOIN LATERAL (
  SELECT id AS lesson_id, course_id
    FROM catalog.lessons
   WHERE status = 'published'
   ORDER BY md5(id::text || d::text || u.user_id::text)
   LIMIT 1
) AS l
WHERE NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'lesson_viewed');

INSERT INTO analytics.events (occurred_at, user_id, event_name, entity_type, course_id, properties)
SELECT e.enrolled_at, e.user_id, 'course_enrolled', 'course', e.course_id,
       jsonb_build_object('source', 'catalogue')
  FROM progress.enrolments e
 WHERE NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'course_enrolled');

INSERT INTO analytics.events (occurred_at, user_id, event_name, properties)
SELECT now() - (n || ' days')::interval, '44444444-4444-4444-8444-444444444444', 'search_performed',
       jsonb_build_object('query', q.term, 'results', q.hits)
  FROM generate_series(1, 6) AS n
  CROSS JOIN LATERAL (VALUES ('postgres indexes', 4), ('microservices', 3), ('csrf', 1)) AS q(term, hits)
 WHERE n % 2 = 1
   AND NOT EXISTS (SELECT 1 FROM analytics.events WHERE event_name = 'search_performed');

-- query_log is an append-only log with no natural key; only seed it once.
INSERT INTO search.query_log (user_id, query_text, result_count)
SELECT v.user_id, v.query_text, v.result_count
  FROM (VALUES
    ('44444444-4444-4444-8444-444444444444'::uuid, 'postgres indexes', 4),
    ('44444444-4444-4444-8444-444444444444', 'microservices', 3),
    ('55555555-5555-4555-8555-555555555555', 'csrf token php', 1),
    ('55555555-5555-4555-8555-555555555555', 'kubernetes operators', 0)
  ) AS v(user_id, query_text, result_count)
 WHERE NOT EXISTS (SELECT 1 FROM search.query_log);

INSERT INTO search.synonyms (term, expands_to) VALUES
  ('js',       ARRAY['javascript']),
  ('pg',       ARRAY['postgres', 'postgresql']),
  ('postgres', ARRAY['postgresql']),
  ('api',      ARRAY['rest', 'endpoint'])
ON CONFLICT (term) DO NOTHING;

-- Build the search index and the last week of rollups.
SELECT search.reindex_all();

SELECT analytics.rollup_day((current_date - n)::date) FROM generate_series(0, 7) AS n;

-- Refresh the course rating counters (no reviews seeded yet, but keeps the
-- denormalised columns honest if you add some).
SELECT catalog.refresh_course_rating(id) FROM catalog.courses;

COMMIT;
