-- ===========================================================================
-- 0006 : assessment schema  --  owned by the Quiz Service
-- Quizzes, questions, options, attempts and answers.
-- ===========================================================================

BEGIN;

CREATE TABLE assessment.quizzes (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id         uuid NOT NULL,
  lesson_id         uuid,            -- NULL => a course-level final exam
  title             text NOT NULL,
  description       text NOT NULL DEFAULT '',
  pass_percent      smallint NOT NULL DEFAULT 70,
  time_limit_seconds integer,        -- NULL => untimed
  max_attempts      smallint,        -- NULL => unlimited
  shuffle_questions boolean NOT NULL DEFAULT false,
  shuffle_options   boolean NOT NULL DEFAULT true,
  show_answers      boolean NOT NULL DEFAULT true,
  status            public.publish_status NOT NULL DEFAULT 'draft',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT quizzes_pass_percent_range CHECK (pass_percent BETWEEN 0 AND 100),
  CONSTRAINT quizzes_time_limit_positive CHECK (time_limit_seconds IS NULL OR time_limit_seconds > 0),
  CONSTRAINT quizzes_max_attempts_positive CHECK (max_attempts IS NULL OR max_attempts > 0),
  CONSTRAINT quizzes_one_per_lesson UNIQUE (lesson_id)
);

CREATE INDEX quizzes_course_idx ON assessment.quizzes (course_id);
CREATE INDEX quizzes_status_idx ON assessment.quizzes (status);

CREATE TRIGGER quizzes_touch
  BEFORE UPDATE ON assessment.quizzes
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Questions. correct_text is only meaningful for 'short_text'; choice
-- questions carry their answer on the option rows instead.
-- ---------------------------------------------------------------------------
CREATE TABLE assessment.questions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id      uuid NOT NULL REFERENCES assessment.quizzes (id) ON DELETE CASCADE,
  kind         public.question_kind NOT NULL DEFAULT 'single_choice',
  prompt       text NOT NULL,
  explanation  text NOT NULL DEFAULT '',
  points       smallint NOT NULL DEFAULT 1,
  position     integer NOT NULL,
  correct_text text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT questions_points_positive CHECK (points > 0),
  CONSTRAINT questions_unique_position UNIQUE (quiz_id, position) DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT questions_short_text_has_answer
    CHECK (kind <> 'short_text' OR btrim(coalesce(correct_text, '')) <> '')
);

CREATE INDEX questions_quiz_idx ON assessment.questions (quiz_id, position);

CREATE TRIGGER questions_touch
  BEFORE UPDATE ON assessment.questions
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

CREATE TABLE assessment.question_options (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL REFERENCES assessment.questions (id) ON DELETE CASCADE,
  body        text NOT NULL,
  is_correct  boolean NOT NULL DEFAULT false,
  position    integer NOT NULL,

  CONSTRAINT question_options_unique_position UNIQUE (question_id, position) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX question_options_question_idx ON assessment.question_options (question_id, position);
-- Speeds up grading, which only ever asks for the correct ones.
CREATE INDEX question_options_correct_idx ON assessment.question_options (question_id)
  WHERE is_correct;

-- ---------------------------------------------------------------------------
-- Attempts. One row per sitting; attempt_no starts at 1 per (quiz, user).
-- ---------------------------------------------------------------------------
CREATE TABLE assessment.quiz_attempts (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id        uuid NOT NULL REFERENCES assessment.quizzes (id) ON DELETE CASCADE,
  user_id        uuid NOT NULL,
  course_id      uuid NOT NULL,
  attempt_no     smallint NOT NULL,
  state          public.attempt_state NOT NULL DEFAULT 'in_progress',
  points_earned  integer NOT NULL DEFAULT 0,
  points_possible integer NOT NULL DEFAULT 0,
  score_percent  numeric(5,2) NOT NULL DEFAULT 0,
  passed         boolean NOT NULL DEFAULT false,
  started_at     timestamptz NOT NULL DEFAULT now(),
  submitted_at   timestamptz,
  expires_at     timestamptz,

  CONSTRAINT quiz_attempts_unique UNIQUE (quiz_id, user_id, attempt_no),
  CONSTRAINT quiz_attempts_no_positive CHECK (attempt_no > 0),
  CONSTRAINT quiz_attempts_score_range CHECK (score_percent BETWEEN 0 AND 100),
  CONSTRAINT quiz_attempts_submitted_has_date
    CHECK (state = 'in_progress' OR state = 'abandoned' OR submitted_at IS NOT NULL)
);

CREATE INDEX quiz_attempts_user_idx   ON assessment.quiz_attempts (user_id, started_at DESC);
CREATE INDEX quiz_attempts_quiz_idx   ON assessment.quiz_attempts (quiz_id, state);
CREATE INDEX quiz_attempts_course_idx ON assessment.quiz_attempts (course_id);

-- Only one attempt may be open at a time for a given quiz and learner.
CREATE UNIQUE INDEX quiz_attempts_one_open_idx
  ON assessment.quiz_attempts (quiz_id, user_id)
  WHERE state = 'in_progress';

CREATE TABLE assessment.attempt_answers (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id     uuid NOT NULL REFERENCES assessment.quiz_attempts (id) ON DELETE CASCADE,
  question_id    uuid NOT NULL REFERENCES assessment.questions (id) ON DELETE CASCADE,
  selected_option_ids uuid[] NOT NULL DEFAULT '{}',
  text_answer    text,
  is_correct     boolean NOT NULL DEFAULT false,
  points_awarded integer NOT NULL DEFAULT 0,
  answered_at    timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT attempt_answers_one_per_question UNIQUE (attempt_id, question_id)
);

CREATE INDEX attempt_answers_attempt_idx  ON assessment.attempt_answers (attempt_id);
CREATE INDEX attempt_answers_question_idx ON assessment.attempt_answers (question_id);

-- ---------------------------------------------------------------------------
-- Grades a submitted attempt server-side. Keeping the marking scheme in the
-- database means the correct answers never have to travel to the browser.
-- Choice questions are all-or-nothing: every correct option and no incorrect
-- one.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION assessment.grade_attempt(p_attempt_id uuid)
RETURNS TABLE (points_earned integer, points_possible integer, score_percent numeric, passed boolean)
LANGUAGE plpgsql
AS $$
DECLARE
  v_quiz_id      uuid;
  v_pass_percent smallint;
  v_earned       integer := 0;
  v_possible     integer := 0;
  v_percent      numeric(5,2) := 0;
  v_passed       boolean := false;
BEGIN
  SELECT a.quiz_id, q.pass_percent
    INTO v_quiz_id, v_pass_percent
    FROM assessment.quiz_attempts a
    JOIN assessment.quizzes q ON q.id = a.quiz_id
   WHERE a.id = p_attempt_id;

  IF v_quiz_id IS NULL THEN
    RAISE EXCEPTION 'attempt % not found', p_attempt_id;
  END IF;

  -- Mark every answer of this attempt.
  UPDATE assessment.attempt_answers ans
     SET is_correct = graded.correct,
         points_awarded = CASE WHEN graded.correct THEN graded.points ELSE 0 END
    FROM (
      SELECT ans2.id,
             q.points,
             CASE q.kind
               WHEN 'short_text' THEN
                 lower(btrim(coalesce(ans2.text_answer, ''))) = lower(btrim(coalesce(q.correct_text, '')))
               ELSE
                 -- selected set must equal the correct set, exactly
                 (SELECT coalesce(array_agg(o.id ORDER BY o.id), '{}')
                    FROM assessment.question_options o
                   WHERE o.question_id = q.id AND o.is_correct)
                 = (SELECT coalesce(array_agg(s ORDER BY s), '{}')
                      FROM unnest(ans2.selected_option_ids) AS s)
             END AS correct
        FROM assessment.attempt_answers ans2
        JOIN assessment.questions q ON q.id = ans2.question_id
       WHERE ans2.attempt_id = p_attempt_id
    ) AS graded
   WHERE ans.id = graded.id;

  SELECT coalesce(sum(ans.points_awarded), 0)
    INTO v_earned
    FROM assessment.attempt_answers ans
   WHERE ans.attempt_id = p_attempt_id;

  -- Unanswered questions still count against the learner.
  SELECT coalesce(sum(q.points), 0)
    INTO v_possible
    FROM assessment.questions q
   WHERE q.quiz_id = v_quiz_id;

  IF v_possible > 0 THEN
    v_percent := round(v_earned::numeric * 100 / v_possible, 2);
  END IF;
  v_passed := v_percent >= v_pass_percent;

  UPDATE assessment.quiz_attempts
     SET points_earned   = v_earned,
         points_possible = v_possible,
         score_percent   = v_percent,
         passed          = v_passed,
         state           = 'graded',
         submitted_at    = coalesce(submitted_at, now())
   WHERE id = p_attempt_id;

  RETURN QUERY SELECT v_earned, v_possible, v_percent, v_passed;
END;
$$;

COMMIT;
