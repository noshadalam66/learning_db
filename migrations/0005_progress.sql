-- ===========================================================================
-- 0005 : progress schema  --  owned by the Progress Service
-- Enrolments, per-lesson progress and resume points.
-- ===========================================================================

BEGIN;

CREATE TABLE progress.enrolments (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL,
  course_id         uuid NOT NULL,
  state             public.enrolment_state NOT NULL DEFAULT 'active',
  progress_percent  numeric(5,2) NOT NULL DEFAULT 0,
  lessons_completed integer NOT NULL DEFAULT 0,
  lessons_total     integer NOT NULL DEFAULT 0,
  last_lesson_id    uuid,                        -- "continue where you left off"
  enrolled_at       timestamptz NOT NULL DEFAULT now(),
  last_activity_at  timestamptz NOT NULL DEFAULT now(),
  completed_at      timestamptz,
  expires_at        timestamptz,

  CONSTRAINT enrolments_one_per_course UNIQUE (user_id, course_id),
  CONSTRAINT enrolments_percent_range  CHECK (progress_percent BETWEEN 0 AND 100),
  CONSTRAINT enrolments_completed_has_date
    CHECK (state <> 'completed' OR completed_at IS NOT NULL)
);

COMMENT ON TABLE progress.enrolments IS 'A learner''s registration in a course plus the rolled-up completion figures.';

CREATE INDEX enrolments_user_idx     ON progress.enrolments (user_id, last_activity_at DESC);
CREATE INDEX enrolments_course_idx   ON progress.enrolments (course_id);
CREATE INDEX enrolments_state_idx    ON progress.enrolments (state);

-- ---------------------------------------------------------------------------
-- Per-lesson progress. last_position_seconds is what lets the video player
-- resume mid-lesson.
-- ---------------------------------------------------------------------------
CREATE TABLE progress.lesson_progress (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrolment_id           uuid NOT NULL REFERENCES progress.enrolments (id) ON DELETE CASCADE,
  user_id                uuid NOT NULL,
  course_id              uuid NOT NULL,
  lesson_id              uuid NOT NULL,
  state                  public.progress_state NOT NULL DEFAULT 'not_started',
  seconds_watched        integer NOT NULL DEFAULT 0,
  last_position_seconds  integer NOT NULL DEFAULT 0,
  view_count             integer NOT NULL DEFAULT 0,
  first_viewed_at        timestamptz,
  last_viewed_at         timestamptz,
  completed_at           timestamptz,

  CONSTRAINT lesson_progress_one_per_lesson UNIQUE (user_id, lesson_id),
  CONSTRAINT lesson_progress_seconds_positive CHECK (seconds_watched >= 0),
  CONSTRAINT lesson_progress_position_positive CHECK (last_position_seconds >= 0),
  CONSTRAINT lesson_progress_completed_has_date
    CHECK (state <> 'completed' OR completed_at IS NOT NULL)
);

CREATE INDEX lesson_progress_enrolment_idx ON progress.lesson_progress (enrolment_id);
CREATE INDEX lesson_progress_user_course_idx ON progress.lesson_progress (user_id, course_id);
CREATE INDEX lesson_progress_completed_idx ON progress.lesson_progress (course_id, completed_at)
  WHERE state = 'completed';

-- ---------------------------------------------------------------------------
-- Bookmarks and notes a learner leaves on a lesson, optionally pinned to a
-- timestamp inside the video.
-- ---------------------------------------------------------------------------
CREATE TABLE progress.lesson_notes (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL,
  lesson_id       uuid NOT NULL,
  course_id       uuid NOT NULL,
  body            text NOT NULL,
  at_seconds      integer,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT lesson_notes_body_not_blank CHECK (btrim(body) <> '')
);

CREATE INDEX lesson_notes_user_lesson_idx ON progress.lesson_notes (user_id, lesson_id, at_seconds);

CREATE TRIGGER lesson_notes_touch
  BEFORE UPDATE ON progress.lesson_notes
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Certificates issued when an enrolment reaches 100%.
-- ---------------------------------------------------------------------------
CREATE TABLE progress.certificates (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrolment_id  uuid NOT NULL UNIQUE REFERENCES progress.enrolments (id) ON DELETE CASCADE,
  user_id       uuid NOT NULL,
  course_id     uuid NOT NULL,
  serial        text NOT NULL UNIQUE,
  issued_at     timestamptz NOT NULL DEFAULT now(),
  certificate_url text
);

CREATE INDEX certificates_user_idx ON progress.certificates (user_id, issued_at DESC);

-- ---------------------------------------------------------------------------
-- Recomputes an enrolment's rolled-up numbers from its lesson rows. The
-- Progress Service calls this after every progress write; keeping it in SQL
-- means the totals can never drift from the detail rows.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION progress.refresh_enrolment_rollup(p_enrolment_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  done  integer;
  total integer;
BEGIN
  SELECT count(*) FILTER (WHERE state = 'completed'), count(*)
    INTO done, total
    FROM progress.lesson_progress
   WHERE enrolment_id = p_enrolment_id;

  UPDATE progress.enrolments e
     SET lessons_completed = done,
         lessons_total     = GREATEST(total, e.lessons_total),
         progress_percent  = CASE
                               WHEN GREATEST(total, e.lessons_total) = 0 THEN 0
                               ELSE round(done::numeric * 100 / GREATEST(total, e.lessons_total), 2)
                             END,
         state             = CASE
                               WHEN GREATEST(total, e.lessons_total) > 0
                                AND done >= GREATEST(total, e.lessons_total) THEN 'completed'::public.enrolment_state
                               WHEN e.state = 'completed' THEN 'active'::public.enrolment_state
                               ELSE e.state
                             END,
         completed_at      = CASE
                               WHEN GREATEST(total, e.lessons_total) > 0
                                AND done >= GREATEST(total, e.lessons_total)
                               THEN COALESCE(e.completed_at, now())
                               ELSE NULL
                             END,
         last_activity_at  = now()
   WHERE e.id = p_enrolment_id;
END;
$$;

COMMIT;
