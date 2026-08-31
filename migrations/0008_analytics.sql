-- ===========================================================================
-- 0008 : analytics schema  --  owned by the Analytics Service
--
-- A wide, append-only event table plus daily rollups. The raw table is
-- partitioned by month so old behaviour data can be detached and archived
-- without a giant DELETE.
-- ===========================================================================

BEGIN;

CREATE TABLE analytics.events (
  id           bigint GENERATED ALWAYS AS IDENTITY,
  occurred_at  timestamptz NOT NULL DEFAULT now(),
  user_id      uuid,
  session_id   text,
  event_name   text NOT NULL,
  entity_type  text,
  entity_id    uuid,
  course_id    uuid,
  lesson_id    uuid,
  properties   jsonb NOT NULL DEFAULT '{}'::jsonb,
  referrer     text,
  user_agent   text,
  ip_hash      text,            -- salted hash, never the raw address

  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

COMMENT ON TABLE  analytics.events    IS 'Append-only behaviour stream. Partitioned monthly by occurred_at.';
COMMENT ON COLUMN analytics.events.ip_hash IS 'Salted SHA-256 of the client IP. The raw address is never persisted.';

CREATE INDEX events_user_time_idx   ON analytics.events (user_id, occurred_at DESC);
CREATE INDEX events_name_time_idx   ON analytics.events (event_name, occurred_at DESC);
CREATE INDEX events_course_time_idx ON analytics.events (course_id, occurred_at DESC);
CREATE INDEX events_properties_idx  ON analytics.events USING gin (properties jsonb_path_ops);

-- A catch-all partition means an insert can never fail for want of one; the
-- maintenance function below carves the current and next month out of it.
CREATE TABLE analytics.events_default PARTITION OF analytics.events DEFAULT;

-- ---------------------------------------------------------------------------
-- Creates the monthly partition covering p_month, if it does not exist yet.
-- Run from cron on the 25th of each month, or ad hoc.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION analytics.ensure_month_partition(p_month date DEFAULT current_date)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  start_at date := date_trunc('month', p_month)::date;
  end_at   date := (date_trunc('month', p_month) + interval '1 month')::date;
  part_name text := format('events_%s', to_char(start_at, 'YYYY_MM'));
BEGIN
  IF to_regclass('analytics.' || part_name) IS NOT NULL THEN
    RETURN part_name;
  END IF;

  EXECUTE format(
    'CREATE TABLE analytics.%I PARTITION OF analytics.events FOR VALUES FROM (%L) TO (%L)',
    part_name, start_at, end_at);

  RETURN part_name;
END;
$$;

-- ---------------------------------------------------------------------------
-- Daily rollups. Recomputed for a single day at a time so a late-arriving
-- event only forces one day to be rebuilt.
-- ---------------------------------------------------------------------------
CREATE TABLE analytics.daily_course_stats (
  day             date NOT NULL,
  course_id       uuid NOT NULL,
  views           integer NOT NULL DEFAULT 0,
  unique_learners integer NOT NULL DEFAULT 0,
  enrolments      integer NOT NULL DEFAULT 0,
  completions     integer NOT NULL DEFAULT 0,
  watch_seconds   bigint  NOT NULL DEFAULT 0,
  quiz_attempts   integer NOT NULL DEFAULT 0,
  quiz_pass_rate  numeric(5,2) NOT NULL DEFAULT 0,
  computed_at     timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (day, course_id)
);

CREATE INDEX daily_course_stats_course_idx ON analytics.daily_course_stats (course_id, day DESC);

CREATE TABLE analytics.daily_platform_stats (
  day             date PRIMARY KEY,
  active_users    integer NOT NULL DEFAULT 0,
  new_users       integer NOT NULL DEFAULT 0,
  lessons_started integer NOT NULL DEFAULT 0,
  lessons_completed integer NOT NULL DEFAULT 0,
  searches        integer NOT NULL DEFAULT 0,
  watch_seconds   bigint  NOT NULL DEFAULT 0,
  computed_at     timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Recompute both rollups for one day.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION analytics.rollup_day(p_day date DEFAULT (current_date - 1))
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  day_start timestamptz := p_day::timestamptz;
  day_end   timestamptz := (p_day + 1)::timestamptz;
BEGIN
  DELETE FROM analytics.daily_course_stats WHERE day = p_day;

  INSERT INTO analytics.daily_course_stats
    (day, course_id, views, unique_learners, watch_seconds, quiz_attempts, enrolments, completions)
  SELECT p_day,
         e.course_id,
         count(*) FILTER (WHERE e.event_name IN ('lesson_viewed', 'course_viewed')),
         count(DISTINCT e.user_id),
         coalesce(sum((e.properties ->> 'seconds')::bigint)
                  FILTER (WHERE e.event_name = 'video_progress'), 0),
         count(*) FILTER (WHERE e.event_name = 'quiz_submitted'),
         count(*) FILTER (WHERE e.event_name = 'course_enrolled'),
         count(*) FILTER (WHERE e.event_name = 'course_completed')
    FROM analytics.events e
   WHERE e.occurred_at >= day_start
     AND e.occurred_at <  day_end
     AND e.course_id IS NOT NULL
   GROUP BY e.course_id;

  -- Pass rate comes from the assessment schema, which holds the graded truth.
  UPDATE analytics.daily_course_stats s
     SET quiz_pass_rate = coalesce(g.pass_rate, 0)
    FROM (
      SELECT course_id,
             round(count(*) FILTER (WHERE passed)::numeric * 100 / nullif(count(*), 0), 2) AS pass_rate
        FROM assessment.quiz_attempts
       WHERE submitted_at >= day_start AND submitted_at < day_end
       GROUP BY course_id
    ) g
   WHERE s.day = p_day AND s.course_id = g.course_id;

  INSERT INTO analytics.daily_platform_stats
    (day, active_users, lessons_started, lessons_completed, searches, watch_seconds)
  SELECT p_day,
         count(DISTINCT user_id),
         count(*) FILTER (WHERE event_name = 'lesson_started'),
         count(*) FILTER (WHERE event_name = 'lesson_completed'),
         count(*) FILTER (WHERE event_name = 'search_performed'),
         coalesce(sum((properties ->> 'seconds')::bigint)
                  FILTER (WHERE event_name = 'video_progress'), 0)
    FROM analytics.events
   WHERE occurred_at >= day_start AND occurred_at < day_end
  ON CONFLICT (day) DO UPDATE SET
    active_users      = EXCLUDED.active_users,
    lessons_started   = EXCLUDED.lessons_started,
    lessons_completed = EXCLUDED.lessons_completed,
    searches          = EXCLUDED.searches,
    watch_seconds     = EXCLUDED.watch_seconds,
    computed_at       = now();

  UPDATE analytics.daily_platform_stats s
     SET new_users = (SELECT count(*) FROM identity.users u
                       WHERE u.created_at >= day_start AND u.created_at < day_end)
   WHERE s.day = p_day;
END;
$$;

COMMIT;
