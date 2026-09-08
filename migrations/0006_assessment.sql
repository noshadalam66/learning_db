-- ===========================================================================
-- 0006 : assessment  --  owned by the Quiz Service
-- Quizzes, questions, options, attempts and answers.
-- ===========================================================================

CREATE TABLE assessment_quizzes (
  id                 CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- catalog ids - deliberately not foreign keys.
  course_id          CHAR(36) CHARACTER SET ascii NOT NULL,
  -- NULL means a course-level final exam rather than a lesson quiz.
  lesson_id          CHAR(36) CHARACTER SET ascii NULL,
  title              VARCHAR(200) NOT NULL,
  description        TEXT NOT NULL,
  pass_percent       TINYINT UNSIGNED NOT NULL DEFAULT 70,
  time_limit_seconds INT NULL,
  max_attempts       SMALLINT UNSIGNED NULL,
  shuffle_questions  TINYINT(1) NOT NULL DEFAULT 0,
  shuffle_options    TINYINT(1) NOT NULL DEFAULT 1,
  show_answers       TINYINT(1) NOT NULL DEFAULT 1,
  status             ENUM('draft','in_review','published','archived') NOT NULL DEFAULT 'draft',
  created_at         DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at         DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  -- A NULL lesson_id repeats freely in a MySQL unique index, which is exactly
  -- what we want: many course-level exams, at most one quiz per lesson.
  UNIQUE KEY uq_quiz_one_per_lesson (lesson_id),
  KEY ix_quizzes_course (course_id),
  KEY ix_quizzes_status (status),

  CONSTRAINT ck_quiz_pass_percent_range CHECK (pass_percent BETWEEN 0 AND 100),
  CONSTRAINT ck_quiz_time_limit_positive
    CHECK (time_limit_seconds IS NULL OR time_limit_seconds > 0),
  CONSTRAINT ck_quiz_max_attempts_positive
    CHECK (max_attempts IS NULL OR max_attempts > 0)
) ENGINE=InnoDB;

CREATE TABLE assessment_questions (
  id           CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  quiz_id      CHAR(36) CHARACTER SET ascii NOT NULL,
  kind         ENUM('single_choice','multiple_choice','true_false','short_text')
                 NOT NULL DEFAULT 'single_choice',
  prompt       TEXT NOT NULL,
  explanation  TEXT NOT NULL,
  points       SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  `position`   INT NOT NULL,
  -- Only meaningful for 'short_text'; choice questions carry their answer on
  -- the option rows instead.
  correct_text VARCHAR(500) NULL,
  created_at   DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at   DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_question_position (quiz_id, `position`),

  CONSTRAINT fk_questions_quiz FOREIGN KEY (quiz_id)
    REFERENCES assessment_quizzes (id) ON DELETE CASCADE,
  CONSTRAINT ck_question_points_positive CHECK (points > 0),
  CONSTRAINT ck_question_short_text_has_answer
    CHECK (kind <> 'short_text' OR TRIM(IFNULL(correct_text, '')) <> '')
) ENGINE=InnoDB;

CREATE TABLE assessment_question_options (
  id          CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  question_id CHAR(36) CHARACTER SET ascii NOT NULL,
  body        VARCHAR(1000) NOT NULL,
  is_correct  TINYINT(1) NOT NULL DEFAULT 0,
  `position`  INT NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_option_position (question_id, `position`),
  -- Grading only ever asks for the correct ones.
  KEY ix_options_correct (question_id, is_correct),

  CONSTRAINT fk_options_question FOREIGN KEY (question_id)
    REFERENCES assessment_questions (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Attempts.
--
-- PostgreSQL expresses "only one attempt may be open at a time" as a partial
-- unique index. MySQL has no partial indexes, so the same rule is enforced by
-- a generated column that is NULL for every state except 'in_progress' - and
-- a MySQL unique index permits duplicate NULLs. Many graded attempts coexist;
-- a second open one collides.
-- ---------------------------------------------------------------------------
CREATE TABLE assessment_quiz_attempts (
  id              CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  quiz_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  -- identity_users.id - deliberately not a foreign key.
  user_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id       CHAR(36) CHARACTER SET ascii NOT NULL,
  attempt_no      SMALLINT UNSIGNED NOT NULL,
  state           ENUM('in_progress','submitted','graded','abandoned') NOT NULL DEFAULT 'in_progress',
  points_earned   INT NOT NULL DEFAULT 0,
  points_possible INT NOT NULL DEFAULT 0,
  score_percent   DECIMAL(5,2) NOT NULL DEFAULT 0,
  passed          TINYINT(1) NOT NULL DEFAULT 0,
  started_at      DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  submitted_at    DATETIME(3) NULL,
  expires_at      DATETIME(3) NULL,

  -- VIRTUAL, not STORED: MySQL refuses a cascading foreign key on a column
  -- that a *stored* generated column reads, and quiz_id needs both. A virtual
  -- column can still carry a unique index, so the rule is enforced either way.
  -- Holds quiz_id:user_id while an attempt is open, NULL once it is not, so
  -- the unique index below permits one open attempt per learner per quiz and
  -- any number of finished ones.
  --
  -- Maintained by triggers rather than declared GENERATED, because MariaDB
  -- refuses to index a generated column whose expression reads a column with
  -- an explicit character set - and every id here is CHARACTER SET ascii. The
  -- index is what enforces the rule either way; the triggers only compute the
  -- value, so the guarantee is still the server's rather than the
  -- application's.
  open_attempt_key VARCHAR(80) CHARACTER SET ascii NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_attempt_no (quiz_id, user_id, attempt_no),
  UNIQUE KEY uq_one_open_attempt (open_attempt_key),
  KEY ix_attempts_user (user_id, started_at DESC),
  KEY ix_attempts_quiz (quiz_id, state),
  KEY ix_attempts_course (course_id),

  CONSTRAINT fk_attempts_quiz FOREIGN KEY (quiz_id)
    REFERENCES assessment_quizzes (id) ON DELETE CASCADE,
  CONSTRAINT ck_attempt_no_positive CHECK (attempt_no > 0),
  CONSTRAINT ck_attempt_score_range CHECK (score_percent BETWEEN 0 AND 100),
  CONSTRAINT ck_attempt_submitted_has_date
    CHECK (state IN ('in_progress','abandoned') OR submitted_at IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE assessment_attempt_answers (
  id                  CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  attempt_id          CHAR(36) CHARACTER SET ascii NOT NULL,
  question_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  -- A JSON array of option ids. MySQL has no array type; JSON keeps the values
  -- separable, which a comma-joined string would not guarantee.
  selected_option_ids JSON NOT NULL,
  text_answer         VARCHAR(500) NULL,
  is_correct          TINYINT(1) NOT NULL DEFAULT 0,
  points_awarded      INT NOT NULL DEFAULT 0,
  answered_at         DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_answer_one_per_question (attempt_id, question_id),
  KEY ix_answers_question (question_id),

  CONSTRAINT fk_answers_attempt FOREIGN KEY (attempt_id)
    REFERENCES assessment_quiz_attempts (id) ON DELETE CASCADE,
  CONSTRAINT fk_answers_question FOREIGN KEY (question_id)
    REFERENCES assessment_questions (id) ON DELETE CASCADE,
  CONSTRAINT ck_answer_selected_is_array CHECK (JSON_TYPE(selected_option_ids) = 'ARRAY')
) ENGINE=InnoDB;

DELIMITER $$

-- open_attempt_key is what uq_one_open_attempt indexes. Both triggers set it,
-- because an attempt can be opened by an INSERT and closed by an UPDATE.
CREATE TRIGGER trg_attempts_open_key_ins
BEFORE INSERT ON assessment_quiz_attempts FOR EACH ROW
  SET NEW.open_attempt_key =
    CASE WHEN NEW.state = 'in_progress'
         THEN CONCAT(NEW.quiz_id, ':', NEW.user_id) END$$

CREATE TRIGGER trg_attempts_open_key_upd
BEFORE UPDATE ON assessment_quiz_attempts FOR EACH ROW
  SET NEW.open_attempt_key =
    CASE WHEN NEW.state = 'in_progress'
         THEN CONCAT(NEW.quiz_id, ':', NEW.user_id) END$$

CREATE TRIGGER trg_quizzes_touch
  BEFORE UPDATE ON assessment_quizzes FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

CREATE TRIGGER trg_questions_touch
  BEFORE UPDATE ON assessment_questions FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

-- ---------------------------------------------------------------------------
-- Grades a submitted attempt, server-side.
--
-- Keeping the marking scheme in the database means correct answers never have
-- to travel to the browser to be compared, and a regrade triggered by any
-- caller applies exactly the same rules.
--
-- Choice questions are ALL-OR-NOTHING: the selected set must equal the correct
-- set exactly. Partial credit on a multiple-choice question would let a learner
-- select every option and score. Unanswered questions still count toward
-- points_possible.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE assessment_grade_attempt(IN p_attempt_id CHAR(36))
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DECLARE v_quiz_id      CHAR(36) CHARACTER SET ascii;
  DECLARE v_pass_percent TINYINT UNSIGNED;
  DECLARE v_earned       INT DEFAULT 0;
  DECLARE v_possible     INT DEFAULT 0;
  DECLARE v_percent      DECIMAL(5,2) DEFAULT 0;
  DECLARE v_passed       TINYINT(1) DEFAULT 0;

  SELECT a.quiz_id, q.pass_percent
    INTO v_quiz_id, v_pass_percent
    FROM assessment_quiz_attempts a
    JOIN assessment_quizzes q ON q.id = a.quiz_id
   WHERE a.id = p_attempt_id;

  IF v_quiz_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'attempt not found';
  END IF;

  -- Mark every answer of this attempt.
  UPDATE assessment_attempt_answers ans
    JOIN assessment_questions q ON q.id = ans.question_id
     SET ans.is_correct = (
           CASE q.kind
             WHEN 'short_text' THEN
               LOWER(TRIM(IFNULL(ans.text_answer, ''))) = LOWER(TRIM(IFNULL(q.correct_text, '')))
             ELSE
                 -- Set equality without JSON_TABLE, which MariaDB cannot use
                 -- against a column of the outer query. The selected set equals
                 -- the correct set when it is the same size and every correct
                 -- option appears in it - duplicates in the answer make the
                 -- sizes agree but the second count fall short, so they fail.
                 JSON_LENGTH(ans.selected_option_ids) = (
                   SELECT COUNT(*) FROM assessment_question_options o
                    WHERE o.question_id = q.id AND o.is_correct = 1
                 )
                 AND (
                   SELECT COUNT(*) FROM assessment_question_options o
                    WHERE o.question_id = q.id AND o.is_correct = 1
                      AND JSON_CONTAINS(ans.selected_option_ids, JSON_QUOTE(o.id))
                 ) = (
                   SELECT COUNT(*) FROM assessment_question_options o
                    WHERE o.question_id = q.id AND o.is_correct = 1
                 )
           END
         ),
         ans.points_awarded = (
           CASE
             WHEN (
               CASE q.kind
                 WHEN 'short_text' THEN
                   LOWER(TRIM(IFNULL(ans.text_answer, ''))) = LOWER(TRIM(IFNULL(q.correct_text, '')))
                 ELSE
                 -- Set equality without JSON_TABLE, which MariaDB cannot use
                   -- against a column of the outer query. The selected set equals
                   -- the correct set when it is the same size and every correct
                   -- option appears in it - duplicates in the answer make the
                   -- sizes agree but the second count fall short, so they fail.
                   JSON_LENGTH(ans.selected_option_ids) = (
                     SELECT COUNT(*) FROM assessment_question_options o
                      WHERE o.question_id = q.id AND o.is_correct = 1
                   )
                   AND (
                     SELECT COUNT(*) FROM assessment_question_options o
                      WHERE o.question_id = q.id AND o.is_correct = 1
                        AND JSON_CONTAINS(ans.selected_option_ids, JSON_QUOTE(o.id))
                   ) = (
                     SELECT COUNT(*) FROM assessment_question_options o
                      WHERE o.question_id = q.id AND o.is_correct = 1
                   )
               END
             ) THEN q.points
             ELSE 0
           END
         )
   WHERE ans.attempt_id = p_attempt_id;

  SELECT IFNULL(SUM(points_awarded), 0) INTO v_earned
    FROM assessment_attempt_answers WHERE attempt_id = p_attempt_id;

  -- Unanswered questions still count against the learner.
  SELECT IFNULL(SUM(points), 0) INTO v_possible
    FROM assessment_questions WHERE quiz_id = v_quiz_id;

  IF v_possible > 0 THEN
    SET v_percent = ROUND(v_earned * 100.0 / v_possible, 2);
  END IF;
  SET v_passed = (v_percent >= v_pass_percent);

  UPDATE assessment_quiz_attempts
     SET points_earned   = v_earned,
         points_possible = v_possible,
         score_percent   = v_percent,
         passed          = v_passed,
         state           = 'graded',
         submitted_at    = IFNULL(submitted_at, UTC_TIMESTAMP(3))
   WHERE id = p_attempt_id;

  -- MySQL procedures have no RETURN, so the result comes back as a result set.
  SELECT v_earned AS points_earned, v_possible AS points_possible,
         v_percent AS score_percent, v_passed AS passed;
END$$

DELIMITER ;
