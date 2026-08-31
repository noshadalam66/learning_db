-- ===========================================================================
-- 0009 : cross-service read views, rollup helpers and database roles
--
-- Services never SELECT from each other's tables directly. These read-only
-- views are the sanctioned join points, and the grants below make that a rule
-- the database enforces rather than a convention people remember.
-- ===========================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Recompute a course's denormalised lesson_count / duration_minutes.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION catalog.refresh_course_rollup(p_course_id uuid)
RETURNS void
LANGUAGE sql
AS $$
  UPDATE catalog.courses c
     SET lesson_count     = agg.lessons,
         duration_minutes = agg.minutes
    FROM (
      SELECT count(*)::integer AS lessons,
             (coalesce(sum(duration_seconds), 0) / 60)::integer AS minutes
        FROM catalog.lessons
       WHERE course_id = p_course_id AND status = 'published'
    ) agg
   WHERE c.id = p_course_id;
$$;

CREATE OR REPLACE FUNCTION catalog.refresh_course_rating(p_course_id uuid)
RETURNS void
LANGUAGE sql
AS $$
  UPDATE catalog.courses c
     SET rating_average = coalesce(agg.avg_rating, 0),
         rating_count   = agg.n
    FROM (
      SELECT round(avg(rating), 2) AS avg_rating, count(*)::integer AS n
        FROM catalog.course_reviews
       WHERE course_id = p_course_id
    ) agg
   WHERE c.id = p_course_id;
$$;

-- ---------------------------------------------------------------------------
-- The full course outline: modules, their lessons, and whichever body each
-- lesson has (a video URL, an article, or a quiz). One query for the page the
-- PHP front end renders most.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_course_outline AS
SELECT
  c.id            AS course_id,
  c.slug          AS course_slug,
  c.title         AS course_title,
  c.status        AS course_status,
  m.id            AS module_id,
  m.title         AS module_title,
  m.position      AS module_position,
  l.id            AS lesson_id,
  l.slug          AS lesson_slug,
  l.title         AS lesson_title,
  l.summary       AS lesson_summary,
  l.kind          AS lesson_kind,
  l.position      AS lesson_position,
  l.duration_seconds,
  l.is_free_preview,
  l.status        AS lesson_status,
  v.video_url,
  v.hls_url,
  v.thumbnail_url AS video_thumbnail_url,
  v.provider      AS video_provider,
  a.id            AS article_id,
  a.format        AS article_format,
  a.reading_time_minutes,
  q.id            AS quiz_id,
  q.title         AS quiz_title,
  q.pass_percent
FROM catalog.courses c
JOIN catalog.modules m ON m.course_id = c.id
JOIN catalog.lessons l ON l.module_id = m.id
LEFT JOIN content.lesson_videos v ON v.lesson_id = l.id
LEFT JOIN content.articles      a ON a.lesson_id = l.id
LEFT JOIN assessment.quizzes    q ON q.lesson_id = l.id;

COMMENT ON VIEW public.v_course_outline IS 'Course -> module -> lesson -> body. The read model behind the course page.';

-- ---------------------------------------------------------------------------
-- A learner's position in a course: outline plus their own progress.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_learner_course_progress AS
SELECT
  e.user_id,
  e.course_id,
  c.slug          AS course_slug,
  c.title         AS course_title,
  c.thumbnail_url,
  e.id            AS enrolment_id,
  e.state,
  e.progress_percent,
  e.lessons_completed,
  e.lessons_total,
  e.last_lesson_id,
  e.enrolled_at,
  e.last_activity_at,
  e.completed_at,
  cert.serial     AS certificate_serial
FROM progress.enrolments e
JOIN catalog.courses c ON c.id = e.course_id
LEFT JOIN progress.certificates cert ON cert.enrolment_id = e.id;

-- ---------------------------------------------------------------------------
-- Course cards for listing pages: catalogue row plus instructor and enrolment
-- count, already filtered to published courses.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_course_cards AS
SELECT
  c.id,
  c.slug,
  c.title,
  c.subtitle,
  c.level,
  c.language,
  c.thumbnail_url,
  c.price_cents,
  c.currency,
  c.duration_minutes,
  c.lesson_count,
  c.rating_average,
  c.rating_count,
  c.published_at,
  cat.slug  AS category_slug,
  cat.name  AS category_name,
  u.id      AS instructor_id,
  u.full_name AS instructor_name,
  u.avatar_url AS instructor_avatar_url,
  (SELECT count(*) FROM progress.enrolments e WHERE e.course_id = c.id) AS enrolment_count
FROM catalog.courses c
LEFT JOIN catalog.categories cat ON cat.id = c.category_id
LEFT JOIN identity.users     u   ON u.id  = c.instructor_id
WHERE c.status = 'published';

-- ---------------------------------------------------------------------------
-- Database roles, one per service. Each gets write access to its own schema
-- and read-only access to the shared views.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  svc text;
BEGIN
  FOREACH svc IN ARRAY ARRAY[
    'svc_user', 'svc_course', 'svc_content',
    'svc_progress', 'svc_quiz', 'svc_search', 'svc_analytics'
  ] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = svc) THEN
      EXECUTE format('CREATE ROLE %I NOLOGIN', svc);
    END IF;
  END LOOP;
END;
$$;

-- Owner-schema write grants.
GRANT USAGE ON SCHEMA identity   TO svc_user;
GRANT USAGE ON SCHEMA catalog    TO svc_course;
GRANT USAGE ON SCHEMA content    TO svc_content;
GRANT USAGE ON SCHEMA progress   TO svc_progress;
GRANT USAGE ON SCHEMA assessment TO svc_quiz;
GRANT USAGE ON SCHEMA search     TO svc_search;
GRANT USAGE ON SCHEMA analytics  TO svc_analytics;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA identity   TO svc_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA catalog    TO svc_course;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA content    TO svc_content;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA progress   TO svc_progress;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA assessment TO svc_quiz;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA search     TO svc_search;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analytics  TO svc_analytics;

-- The Search and Analytics services read from the schemas they summarise.
GRANT USAGE ON SCHEMA catalog, content, assessment, identity TO svc_search, svc_analytics;
GRANT SELECT ON ALL TABLES IN SCHEMA catalog    TO svc_search, svc_analytics;
GRANT SELECT ON ALL TABLES IN SCHEMA content    TO svc_search, svc_analytics;
GRANT SELECT ON ALL TABLES IN SCHEMA assessment TO svc_analytics;
GRANT SELECT ON ALL TABLES IN SCHEMA identity   TO svc_analytics;

-- Everyone may read the sanctioned cross-service views.
GRANT SELECT ON public.v_course_outline, public.v_learner_course_progress, public.v_course_cards
  TO svc_user, svc_course, svc_content, svc_progress, svc_quiz, svc_search, svc_analytics;

COMMIT;
