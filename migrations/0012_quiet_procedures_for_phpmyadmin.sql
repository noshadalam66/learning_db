-- ===========================================================================
-- 0012 : a CALL that returns rows cannot be imported through phpMyAdmin
--
-- Three procedures end with a bare SELECT, because a MySQL procedure has no
-- RETURN and a result set is the only way to hand a value back:
--
--   search_reindex_all               the document count
--   assessment_grade_attempt         the score
--   analytics_ensure_month_partition the partition it made
--
-- The seeds call all three. Through the mysql client that is invisible - it
-- drains the result sets for you. Through phpMyAdmin, which is how this
-- database is actually installed on shared hosting, it is fatal: mysqli leaves
-- the connection with rows pending, and the NEXT statement fails with
--
--   #2014 - Commands out of sync; you can't run this command now
--
-- taking down the import of both install.sql and content.sql. Reported from a
-- real cPanel import, and reproduced here by driving the file through mysqli
-- one statement at a time, the way phpMyAdmin does.
--
-- THE SHAPE OF THE FIX
--
-- The logic moves into a silent <name>_quiet procedure. The original name
-- stays, as a thin wrapper that calls the quiet one and then produces exactly
-- the same result set as before - so the API keeps working untouched, which
-- matters because assessment_grade_attempt is the quiz grading path and
-- learning_apis reads that row. The seeds call the quiet variants instead.
--
-- Two wrappers cannot see the originals' local variables, so they re-derive
-- what they report: the grader reads back the columns it just wrote, and the
-- partition maker counts partitions either side of the call.
-- ===========================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS search_reindex_all$$
DROP PROCEDURE IF EXISTS search_reindex_all_quiet$$

CREATE PROCEDURE search_reindex_all_quiet()
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DELETE FROM search_documents;

  INSERT INTO search_documents
    (entity_type, entity_id, course_id, title, subtitle, body, tags_text,
     url_path, `language`, level, is_published, popularity)
  SELECT 'course', c.id, c.id, c.title, c.subtitle,
         CONCAT_WS(' ', c.description,
           -- The outcomes flattened to words. Not JSON_TABLE: MariaDB cannot
           -- use it against a column of the outer query. This is a FULLTEXT
           -- body, so the separators only have to disappear - stripping the
           -- brackets, quotes and commas leaves exactly the words to index.
           REPLACE(REPLACE(REPLACE(REPLACE(
             IFNULL(c.learning_outcomes, '[]'), '[', ''), ']', ''), '"', ''), ',', ' ')),
         IFNULL((SELECT GROUP_CONCAT(t.name SEPARATOR ' ')
                   FROM catalog_course_tags ct
                   JOIN catalog_tags t ON t.id = ct.tag_id
                  WHERE ct.course_id = c.id), ''),
         CONCAT('/course.php?slug=', c.slug),
         c.`language`, c.level, c.status = 'published', c.rating_count
    FROM catalog_courses c;

  INSERT INTO search_documents
    (entity_type, entity_id, course_id, title, subtitle, body, url_path,
     `language`, is_published)
  SELECT 'lesson', l.id, l.course_id, l.title, l.summary,
         IFNULL(v.transcript, ''),
         CONCAT('/lesson.php?course=', c.slug, '&lesson=', l.slug),
         c.`language`,
         (l.status = 'published' AND c.status = 'published')
    FROM catalog_lessons l
    JOIN catalog_courses c ON c.id = l.course_id
    LEFT JOIN content_lesson_videos v ON v.lesson_id = l.id;

  INSERT INTO search_documents
    (entity_type, entity_id, course_id, title, subtitle, body, url_path,
     `language`, is_published)
  SELECT 'article', a.id, l.course_id, a.title, a.excerpt, a.body,
         CONCAT('/lesson.php?course=', c.slug, '&lesson=', l.slug),
         c.`language`, a.status = 'published'
    FROM content_articles a
    JOIN catalog_lessons l ON l.id = a.lesson_id
    JOIN catalog_courses c ON c.id = l.course_id;
END$$

CREATE PROCEDURE search_reindex_all()
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  CALL search_reindex_all_quiet();
  SELECT COUNT(*) AS documents FROM search_documents;
END$$

DROP PROCEDURE IF EXISTS assessment_grade_attempt$$
DROP PROCEDURE IF EXISTS assessment_grade_attempt_quiet$$

CREATE PROCEDURE assessment_grade_attempt_quiet(IN p_attempt_id CHAR(36))
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
END$$

CREATE PROCEDURE assessment_grade_attempt(IN p_attempt_id CHAR(36))
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  CALL assessment_grade_attempt_quiet(p_attempt_id);

  -- The same four columns, with the same names, that the version in 0006
  -- returned from its local variables - read back from the row it just wrote.
  SELECT points_earned, points_possible, score_percent, passed
    FROM assessment_quiz_attempts
   WHERE id = p_attempt_id;
END$$

DROP PROCEDURE IF EXISTS analytics_ensure_month_partition$$
DROP PROCEDURE IF EXISTS analytics_ensure_month_partition_quiet$$

CREATE PROCEDURE analytics_ensure_month_partition_quiet(IN p_month DATE)
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
END$$

CREATE PROCEDURE analytics_ensure_month_partition(IN p_month DATE)
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DECLARE v_before INT DEFAULT 0;
  DECLARE v_after  INT DEFAULT 0;

  -- partitions_created was a local counter in 0008. Counting either side of
  -- the call reproduces it without duplicating the loop that does the work.
  SELECT COUNT(*) INTO v_before
    FROM information_schema.partitions
   WHERE table_schema = DATABASE()
     AND table_name = 'analytics_events'
     AND partition_name IS NOT NULL;

  CALL analytics_ensure_month_partition_quiet(p_month);

  SELECT COUNT(*) INTO v_after
    FROM information_schema.partitions
   WHERE table_schema = DATABASE()
     AND table_name = 'analytics_events'
     AND partition_name IS NOT NULL;

  SELECT CONCAT('p_', DATE_FORMAT(p_month, '%Y_%m')) AS partition_name,
         (v_after - v_before) AS partitions_created;
END$$

DELIMITER ;
