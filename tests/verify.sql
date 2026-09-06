-- ===========================================================================
-- Post-migration / post-seed checks.
--
-- Every check raises with SIGNAL on failure, so the mysql client exits
-- non-zero and CI notices. Run with: ./scripts/verify.sh
--
-- MySQL has no anonymous DO block, so each group is a temporary procedure that
-- is created, called and dropped.
-- ===========================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS verify_all$$
CREATE PROCEDURE verify_all()
BEGIN
  DECLARE n BIGINT;
  DECLARE m BIGINT;
  DECLARE txt TEXT;

  -- --- the database, and the tables in it ----------------------------------
  -- Everything lives in one database and nothing names it, so the check is
  -- that a database is selected at all - not that it is called anything in
  -- particular. On shared hosting it carries an account prefix.
  IF DATABASE() IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'no database selected - connect with one, or set MYSQL_DATABASE';
  END IF;
  SELECT CONCAT('ok  connected to `', DATABASE(), '`') AS check_result;

  SELECT GROUP_CONCAT(t.tbl) INTO txt
    FROM (
      SELECT 'identity_users' AS tbl
      UNION ALL SELECT 'identity_roles'
      UNION ALL SELECT 'identity_user_roles'
      UNION ALL SELECT 'identity_refresh_tokens'
      UNION ALL SELECT 'identity_verification_tokens'
      UNION ALL SELECT 'catalog_courses'
      UNION ALL SELECT 'catalog_modules'
      UNION ALL SELECT 'catalog_lessons'
      UNION ALL SELECT 'catalog_categories'
      UNION ALL SELECT 'catalog_tags'
      UNION ALL SELECT 'catalog_course_tags'
      UNION ALL SELECT 'catalog_course_reviews'
      UNION ALL SELECT 'content_articles'
      UNION ALL SELECT 'content_lesson_videos'
      UNION ALL SELECT 'content_article_revisions'
      UNION ALL SELECT 'content_lesson_attachments'
      UNION ALL SELECT 'progress_enrolments'
      UNION ALL SELECT 'progress_lesson_progress'
      UNION ALL SELECT 'progress_certificates'
      UNION ALL SELECT 'progress_lesson_notes'
      UNION ALL SELECT 'assessment_quizzes'
      UNION ALL SELECT 'assessment_questions'
      UNION ALL SELECT 'assessment_question_options'
      UNION ALL SELECT 'assessment_quiz_attempts'
      UNION ALL SELECT 'assessment_attempt_answers'
      UNION ALL SELECT 'search_documents'
      UNION ALL SELECT 'search_query_log'
      UNION ALL SELECT 'search_synonyms'
      UNION ALL SELECT 'analytics_events'
      UNION ALL SELECT 'analytics_daily_course_stats'
      UNION ALL SELECT 'analytics_daily_platform_stats'
    ) t
   WHERE NOT EXISTS (SELECT 1 FROM information_schema.tables it
                      WHERE it.table_schema = DATABASE() AND it.table_name = t.tbl);
  IF txt IS NOT NULL THEN
    SET @msg = CONCAT('missing table(s): ', txt);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  SELECT 'ok  all expected tables exist' AS check_result;

  -- --- every id column uses the same charset -------------------------------
  -- InnoDB refuses a foreign key between columns whose character sets differ,
  -- so a stray utf8mb4 id column is a bug that only surfaces much later.
  SELECT COUNT(*) INTO n
    FROM information_schema.columns
   WHERE table_schema = DATABASE()
     AND (column_name = 'id' OR column_name LIKE '%\_id')
     AND data_type = 'char'
     AND character_set_name <> 'ascii';
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'a CHAR id column is not ascii; foreign keys to it will be refused';
  END IF;
  SELECT 'ok  every uuid column is ascii' AS check_result;

  -- --- seed data landed ----------------------------------------------------
  SELECT COUNT(*) INTO n FROM identity_users;
  IF n < 5 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'expected at least 5 seeded users'; END IF;

  SELECT COUNT(*) INTO n FROM catalog_courses WHERE status = 'published';
  IF n < 3 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'expected at least 3 published courses'; END IF;

  SELECT COUNT(*) INTO n FROM catalog_lessons;
  IF n < 10 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'expected at least 10 lessons'; END IF;
  SELECT 'ok  seed data present' AS check_result;

  -- --- videos are URLs, never bytes ---------------------------------------
  SELECT COUNT(*) INTO n FROM content_lesson_videos WHERE video_url NOT REGEXP '^https?://';
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a video row holds something that is not an http URL';
  END IF;

  -- Scoped to the content and catalog tables on purpose. Widening it to the
  -- whole database catches identity_refresh_tokens.ip_address, which is a
  -- VARBINARY because it holds INET6_ATON output and is meant to.
  -- LEFT() rather than LIKE: an underscore is a LIKE wildcard, so 'content_%'
  -- would also match a table called contentXfoo.
  SELECT COUNT(*) INTO n
    FROM information_schema.columns
   WHERE table_schema = DATABASE()
     AND (LEFT(table_name, 8) = 'content_' OR LEFT(table_name, 8) = 'catalog_')
     AND data_type IN ('blob','tinyblob','mediumblob','longblob','binary','varbinary');
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'found a binary column in content/catalog - media must live behind a URL';
  END IF;
  SELECT 'ok  videos are stored as URLs only' AS check_result;

  -- --- articles: both storage formats exercised ---------------------------
  SELECT COUNT(*) INTO n FROM content_articles WHERE format = 'markdown';
  SELECT COUNT(*) INTO m FROM content_articles WHERE format = 'html';
  IF n = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'no Markdown articles seeded'; END IF;
  IF m = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'no HTML articles seeded'; END IF;

  SELECT COUNT(*) INTO n FROM content_articles WHERE TRIM(body) = '';
  IF n > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'an article has an empty body'; END IF;
  SELECT 'ok  articles stored as both markdown and html' AS check_result;

  -- --- plain-text columns really are plain text ---------------------------
  -- catalog_courses.description is rendered as-is by every consumer; only
  -- content_articles carries a format column. Markdown emphasis written into a
  -- description reaches the page as literal asterisks, which is a bug you only
  -- notice by looking. This catches it at build time instead.
  SELECT COUNT(*) INTO n
    FROM catalog_courses
   WHERE description REGEXP '\\*\\*[^*]+\\*\\*'
      OR subtitle REGEXP '\\*\\*[^*]+\\*\\*';
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'a course description contains Markdown - that column is plain text';
  END IF;
  SELECT 'ok  plain-text course copy contains no markdown' AS check_result;

  -- --- every hands-on lesson carries a runnable example --------------------
  -- The front end turns a ```html fence into a code box with a Try yourself
  -- button. A lesson in either hands-on course without one silently loses the
  -- feature. The CSS course uses the same fence: a CSS example is only
  -- meaningful attached to markup, so its examples are HTML documents with a
  -- style block, and they run in the same playground.
  SELECT COUNT(*) INTO n
    FROM catalog_lessons l
    LEFT JOIN content_articles a ON a.lesson_id = l.id
   WHERE l.course_id IN ('c0000001-0000-4000-8000-000000000004',
                         'c0000001-0000-4000-8000-000000000005')
     -- Only the article lessons. A quiz lesson has no article by design; its
     -- runnable code is the scratchpad on the quiz page instead.
     AND l.kind = 'article'
     AND (a.id IS NULL OR a.body NOT LIKE '%```html%');
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'a hands-on lesson has no runnable ```html example';
  END IF;
  SELECT 'ok  every hands-on lesson has a runnable example' AS check_result;

  -- The language courses use the fence of their own language, and the front
  -- end reads the fence to decide which runner the Try yourself button opens.
  -- A JavaScript lesson carrying a ```html fence would open the wrong one, so
  -- check the pairing rather than merely that some fence exists.
  SELECT COUNT(*) INTO n
    FROM catalog_lessons l
    LEFT JOIN content_articles a ON a.lesson_id = l.id
   WHERE l.course_id IN ('c0000001-0000-4000-8000-000000000006',
                         'c0000001-0000-4000-8000-000000000007',
                         'c0000001-0000-4000-8000-000000000008',
                         'c0000001-0000-4000-8000-000000000009',
                         'c0000001-0000-4000-8000-00000000000a')
     AND l.kind = 'article'
     AND (a.id IS NULL
          OR a.body NOT LIKE CONCAT('%```',
               CASE l.course_id
                 WHEN 'c0000001-0000-4000-8000-000000000006' THEN 'javascript'
                 WHEN 'c0000001-0000-4000-8000-000000000007' THEN 'typescript'
                 WHEN 'c0000001-0000-4000-8000-000000000008' THEN 'python'
                 WHEN 'c0000001-0000-4000-8000-000000000009' THEN 'php'
                 ELSE 'ruby'
               END, '%'));
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'a language lesson has no example fenced in its own language';
  END IF;
  SELECT 'ok  every language lesson has a runnable example in its own language' AS check_result;

  -- --- lesson titles are unique across the catalogue -----------------------
  -- A lesson title becomes the page's <title> and its breadcrumb. Three
  -- courses each ending a level with "Level 1 Check: The Basics" gives search
  -- engines three indexed pages that look identical and gives a learner
  -- looking at their own results no way to tell which one they took. The
  -- titles have to carry the subject, not just the level.
  SELECT COUNT(*) INTO n
    FROM (SELECT title FROM catalog_lessons GROUP BY title HAVING COUNT(*) > 1) dupes;
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'two lessons share a title - each one is an indexed page';
  END IF;
  SELECT 'ok  every lesson title is unique' AS check_result;


  -- --- cross-table integrity ----------------------------------------------
  SELECT COUNT(*) INTO n
    FROM catalog_lessons l JOIN catalog_modules mo ON mo.id = l.module_id
   WHERE mo.course_id <> l.course_id;
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a lesson disagrees with its module about the course';
  END IF;

  SELECT COUNT(*) INTO n
    FROM catalog_courses c
   WHERE c.lesson_count <> (SELECT COUNT(*) FROM catalog_lessons l
                             WHERE l.course_id = c.id AND l.status = 'published');
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a course has a stale lesson_count';
  END IF;

  SELECT COUNT(*) INTO n
    FROM assessment_questions q
   WHERE q.kind IN ('single_choice','multiple_choice','true_false')
     AND NOT EXISTS (SELECT 1 FROM assessment_question_options o
                      WHERE o.question_id = q.id AND o.is_correct = 1);
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a choice question has no correct option';
  END IF;
  SELECT 'ok  cross-table integrity holds' AS check_result;

  -- --- progress rollups agree with their detail rows ----------------------
  SELECT COUNT(*) INTO n
    FROM progress_enrolments e
   WHERE e.lessons_completed <> (SELECT COUNT(*) FROM progress_lesson_progress p
                                  WHERE p.enrolment_id = e.id AND p.state = 'completed');
  IF n > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'an enrolment has a stale lessons_completed';
  END IF;
  SELECT 'ok  enrolment rollups match lesson progress' AS check_result;

  -- --- grading really grades ----------------------------------------------
  -- Sam answered Q3 (multiple choice) with only one of two correct options.
  -- Choice scoring is all-or-nothing, so that question must be marked wrong.
  SELECT points_earned, points_possible INTO n, m
    FROM assessment_quiz_attempts WHERE id = 'a2000001-0000-4000-8000-000000000001';

  IF m <> 7 THEN
    SET @msg = CONCAT('expected 7 possible points on the module 1 quiz, got ', IFNULL(m,'NULL'));
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  IF n <> 5 THEN
    SET @msg = CONCAT('expected 5 earned points (2+1+0+1+1), got ', IFNULL(n,'NULL'));
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;

  SELECT is_correct INTO n FROM assessment_attempt_answers
   WHERE attempt_id = 'a2000001-0000-4000-8000-000000000001'
     AND question_id = 'a1000001-0000-4000-8000-000000000003';
  IF n = 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'a partially-correct multiple-choice answer was marked correct';
  END IF;
  SELECT 'ok  grading: 5 of 7 points, all-or-nothing respected' AS check_result;

  -- --- the partial-unique emulation actually bites -------------------------
  SELECT COUNT(*) INTO n
    FROM information_schema.columns
   WHERE table_schema = DATABASE() AND table_name = 'assessment_quiz_attempts'
     AND column_name = 'open_attempt_key' AND extra LIKE '%GENERATED%';
  IF n = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'quiz_attempts.open_attempt_key is not a generated column';
  END IF;
  SELECT 'ok  one-open-attempt rule is enforced by a generated column' AS check_result;

  -- --- search --------------------------------------------------------------
  SELECT COUNT(*) INTO n FROM search_documents;
  IF n = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'search index is empty - did search_reindex_all() run?';
  END IF;

  SELECT COUNT(*) INTO m FROM search_documents
   WHERE MATCH(title, subtitle, body, tags_text)
         AGAINST('microservices' IN NATURAL LANGUAGE MODE);
  IF m = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'search for "microservices" returned nothing';
  END IF;

  -- Weighting must put the course whose *title* matches above a document that
  -- only mentions the word in its body.
  SELECT COUNT(*) INTO m FROM (
    SELECT d.title,
           MATCH(d.title) AGAINST('microservices' IN NATURAL LANGUAGE MODE) * 4
         + MATCH(d.body)  AGAINST('microservices' IN NATURAL LANGUAGE MODE) AS score
      FROM search_documents d
     WHERE MATCH(d.title, d.subtitle, d.body, d.tags_text)
           AGAINST('microservices' IN NATURAL LANGUAGE MODE)
     ORDER BY score DESC LIMIT 1
  ) top
   WHERE top.title LIKE '%Microservices%';
  IF m = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'field weighting is not ranking a title match first';
  END IF;

  -- The typo fallback: prefix relaxation plus edit-distance ranking.
  SELECT COUNT(*) INTO m FROM search_documents
   WHERE MATCH(title, subtitle, body, tags_text) AGAINST('microserv*' IN BOOLEAN MODE);
  IF m = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'the prefix fallback found nothing for "microserv*"';
  END IF;

  IF search_levenshtein('kitten', 'sitting') <> 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'levenshtein() is wrong (kitten/sitting must be 3)';
  END IF;
  IF search_similarity_score('microservices', 'microservics') < 0.9 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'similarity_score() does not rate a one-character typo highly';
  END IF;
  SET @msg = CONCAT('ok  search: ', n, ' documents indexed, weighting and fuzzy fallback both work');
  SELECT @msg AS check_result;

  -- --- analytics -----------------------------------------------------------
  SELECT COUNT(*) INTO n FROM analytics_events;
  IF n = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'no analytics events seeded'; END IF;

  -- Rows in the catch-all partition mean monthly maintenance has stopped.
  SELECT COUNT(*) INTO m FROM analytics_events PARTITION (p_future);
  IF m > 0 THEN
    SET @msg = CONCAT(m, ' event(s) fell into the catch-all partition - a monthly partition is missing');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;

  SELECT COUNT(*) INTO n FROM analytics_daily_platform_stats;
  IF n = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'daily_platform_stats is empty - did rollup_day() run?';
  END IF;
  SELECT 'ok  analytics events partitioned and rolled up' AS check_result;

  -- --- the cross-service views resolve ------------------------------------
  SELECT COUNT(*) INTO n FROM v_course_outline;
  IF n = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'v_course_outline is empty'; END IF;
  SELECT COUNT(*) INTO n FROM v_course_cards;
  IF n = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'v_course_cards is empty'; END IF;
  SELECT COUNT(*) INTO n FROM v_learner_course_progress;
  IF n = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'v_learner_course_progress is empty'; END IF;
  SELECT 'ok  cross-service views return data' AS check_result;
END$$

-- ---------------------------------------------------------------------------
-- Constraints must actually reject bad rows. Each of these is expected to
-- fail; the handler turns a *missing* failure into the error.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS verify_constraints$$
CREATE PROCEDURE verify_constraints()
BEGIN
  DECLARE rejected INT DEFAULT 0;

  START TRANSACTION;

  -- The handler is scoped to this inner block on purpose. Declared at
  -- procedure level it would also swallow the SIGNAL raised by the assertion
  -- below, and the check would silently pass no matter what - which is exactly
  -- what happened the first time this was written.
  BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET rejected = rejected + 1;

  -- 1. A relative video path must be refused.
  INSERT INTO content_lesson_videos (lesson_id, video_url)
  VALUES (UUID(), '/local/file.mp4');

  -- 2. A published course without published_at must be refused.
  INSERT INTO catalog_courses (slug, title, description, instructor_id, status,
                               learning_outcomes, requirements)
  VALUES ('no-date-course', 'No Date', '', UUID(), 'published', JSON_ARRAY(), JSON_ARRAY());

  -- 3. An uppercase slug must be refused.
  INSERT INTO catalog_courses (slug, title, description, instructor_id,
                               learning_outcomes, requirements)
  VALUES ('Bad Slug', 'Bad', '', UUID(), JSON_ARRAY(), JSON_ARRAY());

  -- 4. A second open attempt for the same quiz and learner must be refused.
  INSERT INTO assessment_quiz_attempts (quiz_id, user_id, course_id, attempt_no, state)
  VALUES ('f0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
          'c0000001-0000-4000-8000-000000000001', 90, 'in_progress');
  INSERT INTO assessment_quiz_attempts (quiz_id, user_id, course_id, attempt_no, state)
  VALUES ('f0000001-0000-4000-8000-000000000001', '44444444-4444-4444-8444-444444444444',
          'c0000001-0000-4000-8000-000000000001', 91, 'in_progress');

  -- 5. A lesson whose course disagrees with its module must be refused.
  INSERT INTO catalog_lessons (module_id, course_id, slug, title, `position`)
  VALUES ('d0000001-0000-4000-8000-000000000001', 'c0000001-0000-4000-8000-000000000003',
          'wrong-course', 'Wrong', 99);

  END;

  ROLLBACK;

  IF rejected <> 5 THEN
    SET @msg = CONCAT('expected 5 constraint rejections, got ', rejected);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  SELECT 'ok  check constraints, the unique index and the module guard all reject bad rows'
         AS check_result;
END$$

-- ---------------------------------------------------------------------------
-- Article edits are versioned, and reordering survives the lack of DEFERRABLE.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS verify_behaviour$$
CREATE PROCEDURE verify_behaviour()
BEGIN
  DECLARE v_id CHAR(36) CHARACTER SET ascii;
  DECLARE v_before INT;
  DECLARE v_after INT;
  DECLARE v_snapshots INT;
  DECLARE v_order TEXT;

  START TRANSACTION;

  SELECT id, revision INTO v_id, v_before
    FROM content_articles ORDER BY created_at LIMIT 1;

  UPDATE content_articles SET body = CONCAT(body, '\n\nAppended by the verify suite.')
   WHERE id = v_id;

  SELECT revision INTO v_after FROM content_articles WHERE id = v_id;
  SELECT COUNT(*) INTO v_snapshots FROM content_article_revisions WHERE article_id = v_id;

  IF v_after <> v_before + 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'the article revision did not advance';
  END IF;
  IF v_snapshots = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'no revision snapshot was written';
  END IF;
  SELECT 'ok  article edits snapshot into article_revisions' AS check_result;

  -- Reverse a module's lessons. Without the negative-staging trick in
  -- catalog_reorder_lessons() this collides on the unique (module_id, position).
  CALL catalog_reorder_lessons(
    'd0000001-0000-4000-8000-000000000002',
    JSON_ARRAY('e0000001-0000-4000-8000-000000000006',
               'e0000001-0000-4000-8000-000000000005',
               'e0000001-0000-4000-8000-000000000004')
  );

  SELECT GROUP_CONCAT(slug ORDER BY `position`) INTO v_order
    FROM catalog_lessons WHERE module_id = 'd0000001-0000-4000-8000-000000000002';

  IF v_order <> 'repository-layer,service-layer,routes-controllers-layer' THEN
    SET @msg = CONCAT('reorder produced the wrong order: ', v_order);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
  SELECT 'ok  lessons reorder without deferrable constraints' AS check_result;

  ROLLBACK;
END$$

DELIMITER ;

CALL verify_all();
CALL verify_constraints();
CALL verify_behaviour();

DROP PROCEDURE verify_all;
DROP PROCEDURE verify_constraints;
DROP PROCEDURE verify_behaviour;
