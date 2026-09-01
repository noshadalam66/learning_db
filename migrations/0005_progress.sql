-- ===========================================================================
-- 0005 : progress  --  owned by the Progress Service
-- Enrolments, per-lesson progress and resume points.
-- ===========================================================================

CREATE TABLE progress.enrolments (
  id                CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- identity.users.id and catalog.courses.id - deliberately not foreign keys.
  user_id           CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  state             ENUM('active','completed','expired','cancelled') NOT NULL DEFAULT 'active',
  -- Denormalised; refreshed by progress.refresh_enrolment_rollup().
  progress_percent  DECIMAL(5,2) NOT NULL DEFAULT 0,
  lessons_completed INT NOT NULL DEFAULT 0,
  lessons_total     INT NOT NULL DEFAULT 0,
  -- "Continue where you left off".
  last_lesson_id    CHAR(36) CHARACTER SET ascii NULL,
  enrolled_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  last_activity_at  DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  completed_at      DATETIME(3) NULL,
  expires_at        DATETIME(3) NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_enrolment_one_per_course (user_id, course_id),
  KEY ix_enrolments_user (user_id, last_activity_at DESC),
  KEY ix_enrolments_course (course_id),
  KEY ix_enrolments_state (state),

  CONSTRAINT ck_enrolment_percent_range CHECK (progress_percent BETWEEN 0 AND 100),
  CONSTRAINT ck_enrolment_completed_has_date
    CHECK (state <> 'completed' OR completed_at IS NOT NULL)
) ENGINE=InnoDB
  COMMENT='A learner registration in a course plus the rolled-up completion figures.';

-- ---------------------------------------------------------------------------
-- Per-lesson progress.
--
-- seconds_watched and last_position_seconds are different numbers on purpose:
-- the first accumulates, the second is the resume point and moves backwards
-- when someone rewinds.
-- ---------------------------------------------------------------------------
CREATE TABLE progress.lesson_progress (
  id                    CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  enrolment_id          CHAR(36) CHARACTER SET ascii NOT NULL,
  user_id               CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id             CHAR(36) CHARACTER SET ascii NOT NULL,
  -- catalog.lessons.id - deliberately not a foreign key.
  lesson_id             CHAR(36) CHARACTER SET ascii NOT NULL,
  state                 ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  seconds_watched       INT NOT NULL DEFAULT 0,
  last_position_seconds INT NOT NULL DEFAULT 0,
  view_count            INT NOT NULL DEFAULT 0,
  first_viewed_at       DATETIME(3) NULL,
  last_viewed_at        DATETIME(3) NULL,
  completed_at          DATETIME(3) NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_progress_one_per_lesson (user_id, lesson_id),
  KEY ix_progress_enrolment (enrolment_id),
  KEY ix_progress_user_course (user_id, course_id),
  KEY ix_progress_completed (course_id, state, completed_at),

  CONSTRAINT fk_progress_enrolment FOREIGN KEY (enrolment_id)
    REFERENCES progress.enrolments (id) ON DELETE CASCADE,
  CONSTRAINT ck_progress_seconds_positive CHECK (seconds_watched >= 0),
  CONSTRAINT ck_progress_position_positive CHECK (last_position_seconds >= 0),
  CONSTRAINT ck_progress_completed_has_date
    CHECK (state <> 'completed' OR completed_at IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE progress.lesson_notes (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  user_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  lesson_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  body       TEXT NOT NULL,
  -- Pins the note to a moment inside the video.
  at_seconds INT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  KEY ix_notes_user_lesson (user_id, lesson_id, at_seconds),

  CONSTRAINT ck_notes_body_not_blank CHECK (TRIM(body) <> '')
) ENGINE=InnoDB;

CREATE TABLE progress.certificates (
  id              CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  enrolment_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  user_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id       CHAR(36) CHARACTER SET ascii NOT NULL,
  -- Random, not sequential: a sequential serial leaks how many certificates
  -- the platform has issued and lets anyone guess another one.
  serial          VARCHAR(64) CHARACTER SET ascii NOT NULL,
  issued_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  certificate_url VARCHAR(2000) NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_certificate_enrolment (enrolment_id),
  UNIQUE KEY uq_certificate_serial (serial),
  KEY ix_certificates_user (user_id, issued_at DESC),

  CONSTRAINT fk_certificate_enrolment FOREIGN KEY (enrolment_id)
    REFERENCES progress.enrolments (id) ON DELETE CASCADE
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER progress.trg_notes_touch
  BEFORE UPDATE ON progress.lesson_notes FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

-- ---------------------------------------------------------------------------
-- Recomputes an enrolment's rolled-up numbers from its lesson rows.
--
-- The Progress Service calls this after every progress write. Keeping the
-- arithmetic in SQL means the totals cannot drift from the detail rows no
-- matter which code path did the write - and tests/verify.sql checks they
-- have not.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE progress.refresh_enrolment_rollup(IN p_enrolment_id CHAR(36))
MODIFIES SQL DATA
BEGIN
  DECLARE v_done  INT DEFAULT 0;
  DECLARE v_rows  INT DEFAULT 0;
  DECLARE v_total INT DEFAULT 0;

  SELECT
    SUM(CASE WHEN state = 'completed' THEN 1 ELSE 0 END),
    COUNT(*)
    INTO v_done, v_rows
    FROM progress.lesson_progress
   WHERE enrolment_id = p_enrolment_id;

  SET v_done = IFNULL(v_done, 0);

  -- lessons_total is supplied by the Course Service at enrolment time and is
  -- the denominator; never let it fall below the number of rows we actually
  -- have, or the percentage could exceed 100.
  SELECT GREATEST(lessons_total, v_rows) INTO v_total
    FROM progress.enrolments WHERE id = p_enrolment_id;

  UPDATE progress.enrolments
     SET lessons_completed = v_done,
         lessons_total     = v_total,
         progress_percent  = CASE WHEN v_total = 0 THEN 0
                                  ELSE ROUND(v_done * 100.0 / v_total, 2) END,
         state = CASE
                   WHEN v_total > 0 AND v_done >= v_total THEN 'completed'
                   -- Un-completing is possible: a course can gain a lesson
                   -- after someone finished it.
                   WHEN state = 'completed' THEN 'active'
                   ELSE state
                 END,
         completed_at = CASE
                          WHEN v_total > 0 AND v_done >= v_total
                            THEN IFNULL(completed_at, UTC_TIMESTAMP(3))
                          ELSE NULL
                        END,
         last_activity_at = UTC_TIMESTAMP(3)
   WHERE id = p_enrolment_id;
END$$

DELIMITER ;
