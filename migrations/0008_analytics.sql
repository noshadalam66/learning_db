-- ===========================================================================
-- 0008 : analytics  --  owned by the Analytics Service
--
-- A wide, append-only event table plus daily rollups. Partitioned by month so
-- old behaviour data can be dropped or archived with a metadata operation
-- instead of a DELETE that runs for hours and leaves the table bloated.
-- ===========================================================================

CREATE TABLE analytics_events (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  occurred_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  user_id     CHAR(36) CHARACTER SET ascii NULL,
  session_id  VARCHAR(100) CHARACTER SET ascii NULL,
  event_name  VARCHAR(100) CHARACTER SET ascii NOT NULL,
  entity_type VARCHAR(50) CHARACTER SET ascii NULL,
  entity_id   CHAR(36) CHARACTER SET ascii NULL,
  course_id   CHAR(36) CHARACTER SET ascii NULL,
  lesson_id   CHAR(36) CHARACTER SET ascii NULL,
  properties  JSON NOT NULL,
  referrer    VARCHAR(2000) NULL,
  user_agent  VARCHAR(500) NULL,
  -- A salted SHA-256 of the client IP. The raw address is never persisted, and
  -- rotating the salt makes old hashes uncorrelatable - which is the point.
  ip_hash     CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,

  -- MySQL requires every unique key to contain the partitioning column, which
  -- is why occurred_at is part of the primary key rather than id alone.
  PRIMARY KEY (id, occurred_at),
  KEY ix_events_user_time (user_id, occurred_at DESC),
  KEY ix_events_name_time (event_name, occurred_at DESC),
  KEY ix_events_course_time (course_id, occurred_at DESC)
) ENGINE=InnoDB
  COMMENT='Append-only behaviour stream, partitioned monthly by occurred_at.'
PARTITION BY RANGE COLUMNS (occurred_at) (
  -- One catch-all to begin with. analytics_ensure_month_partition() splits it
  -- into real months; p_future itself is the safety net that stops an insert
  -- ever failing for want of a partition, and tests/verify.sql fails if rows
  -- are sitting in it, because that means partition maintenance has stopped
  -- running.
  PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE analytics_daily_course_stats (
  day             DATE NOT NULL,
  course_id       CHAR(36) CHARACTER SET ascii NOT NULL,
  views           INT NOT NULL DEFAULT 0,
  unique_learners INT NOT NULL DEFAULT 0,
  enrolments      INT NOT NULL DEFAULT 0,
  completions     INT NOT NULL DEFAULT 0,
  watch_seconds   BIGINT NOT NULL DEFAULT 0,
  quiz_attempts   INT NOT NULL DEFAULT 0,
  quiz_pass_rate  DECIMAL(5,2) NOT NULL DEFAULT 0,
  computed_at     DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (day, course_id),
  KEY ix_daily_course (course_id, day DESC)
) ENGINE=InnoDB;

CREATE TABLE analytics_daily_platform_stats (
  day               DATE NOT NULL,
  active_users      INT NOT NULL DEFAULT 0,
  new_users         INT NOT NULL DEFAULT 0,
  lessons_started   INT NOT NULL DEFAULT 0,
  lessons_completed INT NOT NULL DEFAULT 0,
  searches          INT NOT NULL DEFAULT 0,
  watch_seconds     BIGINT NOT NULL DEFAULT 0,
  computed_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (day)
) ENGINE=InnoDB;

DELIMITER $$

-- ---------------------------------------------------------------------------
-- Creates the monthly partition covering p_month, if it does not exist yet.
--
-- PostgreSQL declarative partitioning lets you attach a new partition beside a
-- DEFAULT one. MySQL has no DEFAULT partition, so the equivalent is to
-- REORGANIZE the catch-all p_future into [new month] + [p_future], which is
-- why this needs dynamic SQL.
--
-- Run from cron on the 25th of each month, or ad hoc via the Analytics Service.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE analytics_ensure_month_partition(IN p_month DATE)
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DECLARE v_target_end DATE;
  DECLARE v_cursor     DATE;
  DECLARE v_next       DATE;
  DECLARE v_name       VARCHAR(64);
  DECLARE v_created    INT DEFAULT 0;

  SET p_month = IFNULL(p_month, DATE(UTC_TIMESTAMP()));
  SET v_target_end = DATE_ADD(DATE_FORMAT(p_month, '%Y-%m-01'), INTERVAL 1 MONTH);

  -- The highest boundary currently defined, ignoring the MAXVALUE catch-all.
  -- partition_description comes back quoted for a RANGE COLUMNS date, hence
  -- the TRIM.
  SELECT MAX(CAST(TRIM(BOTH '''' FROM partition_description) AS DATE))
    INTO v_cursor
    FROM information_schema.partitions
   WHERE table_schema = DATABASE()
     AND table_name = 'analytics_events'
     AND partition_description <> 'MAXVALUE';

  -- Nothing but p_future yet: start at the requested month. The first real
  -- partition then also catches everything older than itself, which is what
  -- RANGE partitioning does with its lowest partition anyway.
  IF v_cursor IS NULL THEN
    SET v_cursor = DATE_FORMAT(p_month, '%Y-%m-01');
  END IF;

  -- Partition boundaries must be strictly increasing, so months can only be
  -- appended. Asking for a month that is already covered is a no-op; asking
  -- for one several months ahead fills the gap rather than leaving a hole
  -- that MySQL would refuse to patch later.
  WHILE v_cursor < v_target_end DO
    SET v_next = DATE_ADD(v_cursor, INTERVAL 1 MONTH);
    SET v_name = CONCAT('p_', DATE_FORMAT(v_cursor, '%Y_%m'));

    SET @ddl = CONCAT(
      'ALTER TABLE analytics_events REORGANIZE PARTITION p_future INTO (',
      'PARTITION ', v_name, " VALUES LESS THAN ('", v_next, "'), ",
      'PARTITION p_future VALUES LESS THAN (MAXVALUE))'
    );
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET v_created = v_created + 1;
    SET v_cursor = v_next;
  END WHILE;

  SELECT CONCAT('p_', DATE_FORMAT(p_month, '%Y_%m')) AS partition_name,
         v_created AS partitions_created;
END$$

-- ---------------------------------------------------------------------------
-- Recomputes both rollups for one day.
--
-- One day at a time, so a late-arriving event only forces that day to be
-- rebuilt rather than the whole history.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE analytics_rollup_day(IN p_day DATE)
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DECLARE v_start DATETIME(3);
  DECLARE v_end   DATETIME(3);

  SET p_day = IFNULL(p_day, DATE_SUB(DATE(UTC_TIMESTAMP()), INTERVAL 1 DAY));
  SET v_start = CAST(p_day AS DATETIME(3));
  SET v_end   = DATE_ADD(v_start, INTERVAL 1 DAY);

  DELETE FROM analytics_daily_course_stats WHERE day = p_day;

  INSERT INTO analytics_daily_course_stats
    (day, course_id, views, unique_learners, watch_seconds, quiz_attempts,
     enrolments, completions)
  SELECT p_day, e.course_id,
         SUM(e.event_name IN ('lesson_viewed','course_viewed')),
         COUNT(DISTINCT e.user_id),
         IFNULL(SUM(CASE WHEN e.event_name = 'video_progress'
                         THEN CAST(JSON_EXTRACT(e.properties, '$.seconds') AS UNSIGNED)
                         ELSE 0 END), 0),
         SUM(e.event_name = 'quiz_submitted'),
         SUM(e.event_name = 'course_enrolled'),
         SUM(e.event_name = 'course_completed')
    FROM analytics_events e
   WHERE e.occurred_at >= v_start AND e.occurred_at < v_end
     AND e.course_id IS NOT NULL
   GROUP BY e.course_id;

  -- The pass rate comes from the assessment database, which holds the graded
  -- truth. Reading it from the event stream would be wrong: events are
  -- best-effort and can be lost.
  UPDATE analytics_daily_course_stats s
    JOIN (
      SELECT course_id,
             ROUND(SUM(passed) * 100.0 / NULLIF(COUNT(*), 0), 2) AS pass_rate
        FROM assessment_quiz_attempts
       WHERE submitted_at >= v_start AND submitted_at < v_end
       GROUP BY course_id
    ) g ON g.course_id = s.course_id
     SET s.quiz_pass_rate = IFNULL(g.pass_rate, 0)
   WHERE s.day = p_day;

  INSERT INTO analytics_daily_platform_stats
    (day, active_users, lessons_started, lessons_completed, searches, watch_seconds)
  SELECT p_day,
         COUNT(DISTINCT user_id),
         SUM(event_name = 'lesson_started'),
         SUM(event_name = 'lesson_completed'),
         SUM(event_name = 'search_performed'),
         IFNULL(SUM(CASE WHEN event_name = 'video_progress'
                         THEN CAST(JSON_EXTRACT(properties, '$.seconds') AS UNSIGNED)
                         ELSE 0 END), 0)
    FROM analytics_events
   WHERE occurred_at >= v_start AND occurred_at < v_end
  ON DUPLICATE KEY UPDATE
    active_users      = VALUES(active_users),
    lessons_started   = VALUES(lessons_started),
    lessons_completed = VALUES(lessons_completed),
    searches          = VALUES(searches),
    watch_seconds     = VALUES(watch_seconds),
    computed_at       = UTC_TIMESTAMP(3);

  UPDATE analytics_daily_platform_stats
     SET new_users = (SELECT COUNT(*) FROM identity_users u
                       WHERE u.created_at >= v_start AND u.created_at < v_end)
   WHERE day = p_day;
END$$

DELIMITER ;
