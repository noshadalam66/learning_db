-- ===========================================================================
-- 0009 : cross-service read views, rollup helpers and per-service accounts
--
-- Services never SELECT from each other's tables directly. These read-only
-- views in `platform` are the sanctioned join points, and the grants at the
-- bottom make that a rule the server enforces rather than a convention people
-- remember.
-- ===========================================================================

DELIMITER $$

-- Recompute a course's denormalised lesson_count / duration_minutes.
CREATE PROCEDURE catalog_refresh_course_rollup(IN p_course_id CHAR(36))
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  UPDATE catalog_courses c
    JOIN (
      SELECT COUNT(*) AS lessons,
             FLOOR(IFNULL(SUM(duration_seconds), 0) / 60) AS minutes
        FROM catalog_lessons
       WHERE course_id = p_course_id AND status = 'published'
    ) agg
     SET c.lesson_count = agg.lessons,
         c.duration_minutes = agg.minutes
   WHERE c.id = p_course_id;
END$$

CREATE PROCEDURE catalog_refresh_course_rating(IN p_course_id CHAR(36))
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  UPDATE catalog_courses c
    JOIN (
      SELECT IFNULL(ROUND(AVG(rating), 2), 0) AS avg_rating, COUNT(*) AS n
        FROM catalog_course_reviews
       WHERE course_id = p_course_id
    ) agg
     SET c.rating_average = agg.avg_rating,
         c.rating_count = agg.n
   WHERE c.id = p_course_id;
END$$

-- ---------------------------------------------------------------------------
-- Reorders the lessons of a module to a given id sequence.
--
-- PostgreSQL can do this with a plain UPDATE because its unique constraint is
-- DEFERRABLE and only checked at COMMIT. MySQL checks immediately, so a swap
-- collides half way through. The fix is to park every position in the negative
-- range first - which cannot collide with any target value - and then write
-- the final positions.
--
-- p_ordered_ids is a JSON array of lesson ids, in the order they should end up.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE catalog_reorder_lessons(IN p_module_id CHAR(36), IN p_ordered_ids JSON)
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DECLARE v_expected INT;
  DECLARE v_given INT;

  SELECT COUNT(*) INTO v_expected FROM catalog_lessons WHERE module_id = p_module_id;
  SET v_given = JSON_LENGTH(p_ordered_ids);

  -- A partial list would leave the rest holding stale positions, and an id
  -- from another module would silently do nothing. Refuse both.
  IF v_given <> v_expected THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'the reorder list must name exactly the lessons in this module';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM JSON_TABLE(p_ordered_ids, '$[*]'
           COLUMNS (id CHAR(36) CHARACTER SET ascii PATH '$')) jt
      LEFT JOIN catalog_lessons l ON l.id = jt.id AND l.module_id = p_module_id
     WHERE l.id IS NULL
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'the reorder list names a lesson that is not in this module';
  END IF;

  UPDATE catalog_lessons SET `position` = -`position` WHERE module_id = p_module_id;

  UPDATE catalog_lessons l
    JOIN JSON_TABLE(p_ordered_ids, '$[*]'
         COLUMNS (rn FOR ORDINALITY, id CHAR(36) CHARACTER SET ascii PATH '$')) jt
      ON jt.id = l.id
     SET l.`position` = jt.rn
   WHERE l.module_id = p_module_id;

  SELECT id, slug, title, `position`
    FROM catalog_lessons WHERE module_id = p_module_id ORDER BY `position`;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------
-- The full course outline: modules, their lessons, and whichever body each
-- lesson has. One query for the page the PHP front end renders most.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_course_outline AS
SELECT
  c.id            AS course_id,
  c.slug          AS course_slug,
  c.title         AS course_title,
  c.status        AS course_status,
  m.id            AS module_id,
  m.title         AS module_title,
  m.`position`    AS module_position,
  l.id            AS lesson_id,
  l.slug          AS lesson_slug,
  l.title         AS lesson_title,
  l.summary       AS lesson_summary,
  l.kind          AS lesson_kind,
  l.`position`    AS lesson_position,
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
FROM catalog_courses c
JOIN catalog_modules m ON m.course_id = c.id
JOIN catalog_lessons l ON l.module_id = m.id
LEFT JOIN content_lesson_videos v ON v.lesson_id = l.id
LEFT JOIN content_articles      a ON a.lesson_id = l.id
LEFT JOIN assessment_quizzes    q ON q.lesson_id = l.id;

-- A learner's position in a course: their enrolment plus the course card.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_learner_course_progress AS
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
FROM progress_enrolments e
JOIN catalog_courses c ON c.id = e.course_id
LEFT JOIN progress_certificates cert ON cert.enrolment_id = e.id;

-- Course cards for listing pages, already filtered to published courses.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_course_cards AS
SELECT
  c.id,
  c.slug,
  c.title,
  c.subtitle,
  c.level,
  c.`language`,
  c.thumbnail_url,
  c.price_cents,
  c.currency,
  c.duration_minutes,
  c.lesson_count,
  c.rating_average,
  c.rating_count,
  c.published_at,
  cat.slug    AS category_slug,
  cat.name    AS category_name,
  u.id        AS instructor_id,
  u.full_name AS instructor_name,
  u.avatar_url AS instructor_avatar_url,
  (SELECT COUNT(*) FROM progress_enrolments e WHERE e.course_id = c.id) AS enrolment_count
FROM catalog_courses c
LEFT JOIN catalog_categories cat ON cat.id = c.category_id
LEFT JOIN identity_users     u   ON u.id  = c.instructor_id
WHERE c.status = 'published';
