-- ===========================================================================
-- 0011 : analytics_rollup_day() must survive a day with no events
--
-- The platform-stats INSERT in 0008 aggregates without a GROUP BY. That is
-- deliberate - it produces exactly one row per day - but it means the query
-- still returns a row when the day's window is empty, and SUM() over zero rows
-- is NULL rather than 0. The row then fails against the NOT NULL columns:
--
--   ERROR 1048 (23000): Column 'lessons_started' cannot be null
--
-- It only fires on a genuinely quiet day, which is why it survived the first
-- pass: seeding on a day that already had events hid it. Rolling up a day with
-- no activity is not an error, it is a fact worth recording, so the fix is to
-- coalesce to zero rather than to skip the row.
--
-- The course-stats INSERT above it is unaffected: it has a GROUP BY, so an
-- empty window produces no rows at all.
-- ===========================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS analytics_rollup_day$$

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

  -- Every aggregate here is coalesced. COUNT already returns 0 over an empty
  -- set; SUM does not, and that asymmetry is the whole bug.
  INSERT INTO analytics_daily_platform_stats
    (day, active_users, lessons_started, lessons_completed, searches, watch_seconds)
  SELECT p_day,
         COUNT(DISTINCT user_id),
         IFNULL(SUM(event_name = 'lesson_started'), 0),
         IFNULL(SUM(event_name = 'lesson_completed'), 0),
         IFNULL(SUM(event_name = 'search_performed'), 0),
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
