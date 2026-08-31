-- ===========================================================================
-- Post-migration / post-seed checks.
--
-- Every check raises an exception on failure, so psql with ON_ERROR_STOP=1
-- exits non-zero and CI notices. Run with: ./scripts/verify.sh
-- ===========================================================================

\set ON_ERROR_STOP on
\timing off

DO $$
DECLARE
  missing text;
BEGIN
  SELECT string_agg(s, ', ')
    INTO missing
    FROM unnest(ARRAY['identity','catalog','content','progress','assessment','search','analytics']) AS s
   WHERE NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = s);

  IF missing IS NOT NULL THEN
    RAISE EXCEPTION 'missing schema(s): %', missing;
  END IF;
  RAISE NOTICE 'ok  all seven service schemas exist';
END;
$$;

DO $$
DECLARE
  missing text;
BEGIN
  SELECT string_agg(t, ', ')
    INTO missing
    FROM unnest(ARRAY[
      'identity.users','identity.roles','identity.user_roles','identity.refresh_tokens',
      'catalog.courses','catalog.modules','catalog.lessons','catalog.categories',
      'content.articles','content.lesson_videos','content.article_revisions',
      'progress.enrolments','progress.lesson_progress','progress.certificates',
      'assessment.quizzes','assessment.questions','assessment.question_options',
      'assessment.quiz_attempts','assessment.attempt_answers',
      'search.documents','search.query_log',
      'analytics.events','analytics.daily_course_stats'
    ]) AS t
   WHERE to_regclass(t) IS NULL;

  IF missing IS NOT NULL THEN
    RAISE EXCEPTION 'missing table(s): %', missing;
  END IF;
  RAISE NOTICE 'ok  all expected tables exist';
END;
$$;

-- ---------------------------------------------------------------------------
-- Seed data landed
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM identity.users;
  IF n < 5 THEN RAISE EXCEPTION 'expected at least 5 seeded users, found %', n; END IF;

  SELECT count(*) INTO n FROM catalog.courses WHERE status = 'published';
  IF n < 3 THEN RAISE EXCEPTION 'expected at least 3 published courses, found %', n; END IF;

  SELECT count(*) INTO n FROM catalog.lessons;
  IF n < 10 THEN RAISE EXCEPTION 'expected at least 10 lessons, found %', n; END IF;

  RAISE NOTICE 'ok  seed data present';
END;
$$;

-- ---------------------------------------------------------------------------
-- Videos are URLs, never bytes. No column in the database should be holding
-- media, and every stored URL must be an absolute http(s) address.
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n
    FROM content.lesson_videos
   WHERE video_url !~ '^https?://';
  IF n > 0 THEN RAISE EXCEPTION '% video row(s) hold something that is not an http URL', n; END IF;

  SELECT count(*) INTO n
    FROM information_schema.columns
   WHERE table_schema IN ('content','catalog')
     AND data_type IN ('bytea', 'oid');
  IF n > 0 THEN
    RAISE EXCEPTION 'found % binary column(s) in content/catalog - media must live behind a URL', n;
  END IF;

  RAISE NOTICE 'ok  videos are stored as URLs only';
END;
$$;

-- ---------------------------------------------------------------------------
-- Articles: both storage formats are exercised and each has a body.
-- ---------------------------------------------------------------------------
DO $$
DECLARE md bigint; html bigint;
BEGIN
  SELECT count(*) INTO md   FROM content.articles WHERE format = 'markdown';
  SELECT count(*) INTO html FROM content.articles WHERE format = 'html';

  IF md = 0   THEN RAISE EXCEPTION 'no Markdown articles seeded'; END IF;
  IF html = 0 THEN RAISE EXCEPTION 'no HTML articles seeded'; END IF;

  IF EXISTS (SELECT 1 FROM content.articles WHERE btrim(body) = '') THEN
    RAISE EXCEPTION 'an article has an empty body';
  END IF;

  RAISE NOTICE 'ok  articles stored as both markdown (%) and html (%)', md, html;
END;
$$;

-- ---------------------------------------------------------------------------
-- Structural integrity that spans tables
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n
    FROM catalog.lessons l
    JOIN catalog.modules m ON m.id = l.module_id
   WHERE m.course_id <> l.course_id;
  IF n > 0 THEN RAISE EXCEPTION '% lesson(s) disagree with their module about the course', n; END IF;

  SELECT count(*) INTO n
    FROM catalog.courses c
   WHERE c.lesson_count <> (SELECT count(*) FROM catalog.lessons l
                             WHERE l.course_id = c.id AND l.status = 'published');
  IF n > 0 THEN RAISE EXCEPTION '% course(s) have a stale lesson_count', n; END IF;

  SELECT count(*) INTO n
    FROM assessment.questions q
   WHERE q.kind IN ('single_choice','multiple_choice','true_false')
     AND NOT EXISTS (SELECT 1 FROM assessment.question_options o
                      WHERE o.question_id = q.id AND o.is_correct);
  IF n > 0 THEN RAISE EXCEPTION '% choice question(s) have no correct option', n; END IF;

  RAISE NOTICE 'ok  cross-table integrity holds';
END;
$$;

-- ---------------------------------------------------------------------------
-- Progress rollups agree with the detail rows they summarise.
-- ---------------------------------------------------------------------------
DO $$
DECLARE bad bigint;
BEGIN
  SELECT count(*) INTO bad
    FROM progress.enrolments e
   WHERE e.lessons_completed <> (SELECT count(*) FROM progress.lesson_progress p
                                  WHERE p.enrolment_id = e.id AND p.state = 'completed');
  IF bad > 0 THEN RAISE EXCEPTION '% enrolment(s) have a stale lessons_completed', bad; END IF;
  RAISE NOTICE 'ok  enrolment rollups match lesson progress';
END;
$$;

-- ---------------------------------------------------------------------------
-- Grading really grades. Sam answered Q3 (multiple choice) with only one of
-- two correct options, so choice scoring being all-or-nothing means that
-- question must be marked wrong.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  a record;
  partial boolean;
BEGIN
  SELECT * INTO a FROM assessment.quiz_attempts
   WHERE id = 'a2000001-0000-4000-8000-000000000001';

  IF a IS NULL THEN RAISE EXCEPTION 'seeded quiz attempt is missing'; END IF;
  IF a.state <> 'graded' THEN RAISE EXCEPTION 'attempt was not graded (state=%)', a.state; END IF;
  IF a.points_possible <> 7 THEN
    RAISE EXCEPTION 'expected 7 possible points on the module 1 quiz, got %', a.points_possible;
  END IF;

  SELECT is_correct INTO partial
    FROM assessment.attempt_answers
   WHERE attempt_id = a.id AND question_id = 'a1000001-0000-4000-8000-000000000003';
  IF partial THEN
    RAISE EXCEPTION 'a partially-correct multiple-choice answer was marked correct';
  END IF;

  IF a.points_earned <> 5 THEN
    RAISE EXCEPTION 'expected 5 earned points (2+1+0+1+1), got %', a.points_earned;
  END IF;
  IF NOT a.passed THEN
    RAISE EXCEPTION 'attempt scored % percent but was not marked passed', a.score_percent;
  END IF;

  RAISE NOTICE 'ok  grading: % of % points (% percent) - passed', a.points_earned, a.points_possible, a.score_percent;
END;
$$;

-- ---------------------------------------------------------------------------
-- Search index is populated, weighted and actually returns hits.
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint; hits bigint;
BEGIN
  SELECT count(*) INTO n FROM search.documents;
  IF n = 0 THEN RAISE EXCEPTION 'search index is empty - did search.reindex_all() run?'; END IF;

  SELECT count(*) INTO hits
    FROM search.documents
   WHERE search_vector @@ websearch_to_tsquery('english', 'microservices');
  IF hits = 0 THEN RAISE EXCEPTION 'search for "microservices" returned nothing'; END IF;

  -- word_similarity, not similarity: the latter scores the query against the
  -- whole title, so a short typo inside a long title always falls below any
  -- useful threshold. This is the operator the Search Service falls back to.
  SELECT count(*) INTO hits
    FROM search.documents
   WHERE word_similarity('postgrs', title) > 0.4;
  IF hits = 0 THEN RAISE EXCEPTION 'trigram fallback found nothing for the typo "postgrs"'; END IF;

  RAISE NOTICE 'ok  search: % documents indexed, exact and fuzzy both match', n;
END;
$$;

-- ---------------------------------------------------------------------------
-- Analytics: events landed in a real monthly partition, not just the default,
-- and the rollups produced rows.
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint; in_default bigint;
BEGIN
  SELECT count(*) INTO n FROM analytics.events;
  IF n = 0 THEN RAISE EXCEPTION 'no analytics events seeded'; END IF;

  SELECT count(*) INTO in_default FROM analytics.events_default;
  IF in_default > 0 THEN
    RAISE EXCEPTION '% event(s) fell into the default partition - a monthly partition is missing', in_default;
  END IF;

  SELECT count(*) INTO n FROM analytics.daily_platform_stats;
  IF n = 0 THEN RAISE EXCEPTION 'daily_platform_stats is empty - did rollup_day() run?'; END IF;

  RAISE NOTICE 'ok  analytics events partitioned and rolled up';
END;
$$;

-- ---------------------------------------------------------------------------
-- The cross-service read views resolve and return rows.
-- ---------------------------------------------------------------------------
DO $$
DECLARE n bigint;
BEGIN
  SELECT count(*) INTO n FROM public.v_course_outline;
  IF n = 0 THEN RAISE EXCEPTION 'v_course_outline is empty'; END IF;

  SELECT count(*) INTO n FROM public.v_course_cards;
  IF n = 0 THEN RAISE EXCEPTION 'v_course_cards is empty'; END IF;

  SELECT count(*) INTO n FROM public.v_learner_course_progress;
  IF n = 0 THEN RAISE EXCEPTION 'v_learner_course_progress is empty'; END IF;

  RAISE NOTICE 'ok  cross-service views return data';
END;
$$;

-- ---------------------------------------------------------------------------
-- Constraints actually bite. Each of these must fail.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  BEGIN
    INSERT INTO content.lesson_videos (lesson_id, video_url)
    VALUES (gen_random_uuid(), '/local/file.mp4');
    RAISE EXCEPTION 'a relative video path was accepted - the http check is not working';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;

  BEGIN
    INSERT INTO catalog.courses (slug, title, instructor_id, status)
    VALUES ('no-date-course', 'No Date', gen_random_uuid(), 'published');
    RAISE EXCEPTION 'a published course without published_at was accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;

  BEGIN
    INSERT INTO assessment.quiz_attempts (quiz_id, user_id, course_id, attempt_no, state)
    VALUES ('f0000001-0000-4000-8000-000000000001',
            '44444444-4444-4444-8444-444444444444',
            'c0000001-0000-4000-8000-000000000001', 9, 'in_progress');
    INSERT INTO assessment.quiz_attempts (quiz_id, user_id, course_id, attempt_no, state)
    VALUES ('f0000001-0000-4000-8000-000000000001',
            '44444444-4444-4444-8444-444444444444',
            'c0000001-0000-4000-8000-000000000001', 10, 'in_progress');
    RAISE EXCEPTION 'two attempts were open at once - the partial unique index is not working';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  RAISE NOTICE 'ok  check constraints and partial unique index reject bad rows';

  -- Nothing above should persist.
  RAISE EXCEPTION 'rollback_marker';
EXCEPTION WHEN OTHERS THEN
  IF SQLERRM <> 'rollback_marker' THEN RAISE; END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Article edits are versioned by the snapshot trigger.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  target uuid;
  before_rev integer;
  after_rev  integer;
  snapshots  bigint;
BEGIN
  SELECT id, revision INTO target, before_rev FROM content.articles ORDER BY created_at LIMIT 1;

  UPDATE content.articles SET body = body || E'\n\nAppended by the verify suite.' WHERE id = target;

  SELECT revision INTO after_rev FROM content.articles WHERE id = target;
  SELECT count(*) INTO snapshots FROM content.article_revisions WHERE article_id = target;

  IF after_rev <> before_rev + 1 THEN
    RAISE EXCEPTION 'article revision did not advance (% -> %)', before_rev, after_rev;
  END IF;
  IF snapshots = 0 THEN
    RAISE EXCEPTION 'no revision snapshot was written';
  END IF;

  RAISE NOTICE 'ok  article edits snapshot into article_revisions (rev % -> %)', before_rev, after_rev;

  RAISE EXCEPTION 'rollback_marker';
EXCEPTION WHEN OTHERS THEN
  IF SQLERRM <> 'rollback_marker' THEN RAISE; END IF;
END;
$$;
