-- ===========================================================================
-- 0007 : search  --  owned by the Search Service
--
-- This is the migration that departs furthest from the PostgreSQL original,
-- because MySQL has neither tsvector nor pg_trgm. What replaces them:
--
--   weighting   PostgreSQL stores one weighted tsvector and lets ts_rank read
--               the weights. MySQL cannot weight inside a FULLTEXT index, so
--               each field gets its own index and relevance is a weighted sum
--               of separate MATCH() scores: title x4, subtitle x2, body x1,
--               tags x1. Same intent, computed at query time instead of
--               index time.
--
--   typo        pg_trgm's word_similarity has no MySQL equivalent. The
--   tolerance   fallback is progressive prefix relaxation in BOOLEAN MODE
--               ('microservics' -> 'microserv*'), ranked by a Levenshtein
--               distance function defined below. It is genuinely weaker than
--               trigram similarity - it will not catch a typo in the first
--               few characters - and search.fuzzy_candidates() says so.
--
-- Two FULLTEXT limits worth knowing, both MySQL defaults:
--   * innodb_ft_min_token_size is 3, so one- and two-letter words ("js", "ci")
--     are not indexed at all. The synonym table below is what rescues them.
--   * Common words are not stopped by default in InnoDB, but very common ones
--     score near zero.
-- ===========================================================================

CREATE TABLE search_documents (
  id           CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  entity_type  ENUM('course','lesson','article') NOT NULL,
  entity_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id    CHAR(36) CHARACTER SET ascii NULL,
  title        VARCHAR(300) NOT NULL,
  subtitle     VARCHAR(500) NOT NULL DEFAULT '',
  body         MEDIUMTEXT NOT NULL,
  -- Space-joined rather than JSON: FULLTEXT cannot index a JSON column, and
  -- tags are matched as words, never read back as a list.
  tags_text    VARCHAR(500) NOT NULL DEFAULT '',
  url_path     VARCHAR(500) NOT NULL,
  `language`   VARCHAR(10) NOT NULL DEFAULT 'en',
  level        ENUM('beginner','intermediate','advanced','expert') NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  popularity   INT NOT NULL DEFAULT 0,
  indexed_at   DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_document_entity (entity_type, entity_id),
  KEY ix_documents_course (course_id),
  KEY ix_documents_type (entity_type, is_published),

  -- One index per field so each can be scored separately and weighted, plus a
  -- combined one so the WHERE clause is a single index lookup.
  FULLTEXT KEY ft_title (title),
  FULLTEXT KEY ft_subtitle (subtitle),
  FULLTEXT KEY ft_body (body),
  FULLTEXT KEY ft_tags (tags_text),
  FULLTEXT KEY ft_all (title, subtitle, body, tags_text)
) ENGINE=InnoDB
  COMMENT='Flattened copy of courses, lessons and articles. Rebuilt by search_reindex_all().';

-- What people actually typed. Feeds autocomplete and the "queries with no
-- results" report, which is the most direct signal of a content gap.
CREATE TABLE search_query_log (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id           CHAR(36) CHARACTER SET ascii NULL,
  query_text        VARCHAR(200) NOT NULL,
  result_count      INT NOT NULL DEFAULT 0,
  clicked_entity_id CHAR(36) CHARACTER SET ascii NULL,
  searched_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  KEY ix_query_text (query_text),
  KEY ix_query_time (searched_at DESC),
  KEY ix_query_empty (result_count, query_text)
) ENGINE=InnoDB;

-- Editor-curated synonyms, applied before the query reaches MATCH(). This is
-- also how two-letter terms are rescued from innodb_ft_min_token_size.
CREATE TABLE search_synonyms (
  id         SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  term       VARCHAR(100) NOT NULL,
  expands_to JSON NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_synonym_term (term),
  CONSTRAINT ck_synonym_is_array CHECK (JSON_TYPE(expands_to) = 'ARRAY')
) ENGINE=InnoDB;

DELIMITER $$

-- ---------------------------------------------------------------------------
-- Levenshtein distance.
--
-- MySQL has no built-in edit distance, and this is what ranks the typo
-- fallback. It is O(len(a) x len(b)) per call, so it is only ever applied to
-- the small candidate set that a prefix match already narrowed down - never
-- across the whole table.
-- ---------------------------------------------------------------------------
CREATE FUNCTION search_levenshtein(a VARCHAR(255), b VARCHAR(255))
RETURNS INT
  SQL SECURITY INVOKER
DETERMINISTIC
NO SQL
BEGIN
  DECLARE la, lb, i, j, cost, above, left_cell, diag INT;
  DECLARE row_prev, row_cur VARCHAR(1024);

  SET a = LOWER(IFNULL(a, '')), b = LOWER(IFNULL(b, ''));
  SET la = CHAR_LENGTH(a), lb = CHAR_LENGTH(b);

  IF la = 0 THEN RETURN lb; END IF;
  IF lb = 0 THEN RETURN la; END IF;

  -- Two rolling rows, held as comma-separated lists so no temp table is needed.
  SET row_prev = '';
  SET i = 0;
  WHILE i <= lb DO
    SET row_prev = CONCAT_WS(',', NULLIF(row_prev, ''), i);
    SET i = i + 1;
  END WHILE;

  SET i = 1;
  WHILE i <= la DO
    SET row_cur = CAST(i AS CHAR);
    SET j = 1;
    WHILE j <= lb DO
      SET cost = IF(SUBSTRING(a, i, 1) = SUBSTRING(b, j, 1), 0, 1);
      SET diag      = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(row_prev, ',', j),     ',', -1) AS SIGNED);
      SET above     = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(row_prev, ',', j + 1), ',', -1) AS SIGNED);
      SET left_cell = CAST(SUBSTRING_INDEX(row_cur, ',', -1) AS SIGNED);
      SET row_cur = CONCAT(row_cur, ',', LEAST(above + 1, left_cell + 1, diag + cost));
      SET j = j + 1;
    END WHILE;
    SET row_prev = row_cur;
    SET i = i + 1;
  END WHILE;

  RETURN CAST(SUBSTRING_INDEX(row_prev, ',', -1) AS SIGNED);
END$$

-- ---------------------------------------------------------------------------
-- A similarity score in 0..1, so the Search Service can apply a threshold the
-- way it did with pg_trgm's word_similarity.
-- ---------------------------------------------------------------------------
CREATE FUNCTION search_similarity_score(a VARCHAR(255), b VARCHAR(255))
RETURNS DECIMAL(4,3)
  SQL SECURITY INVOKER
DETERMINISTIC
NO SQL
BEGIN
  DECLARE longest INT;
  SET longest = GREATEST(CHAR_LENGTH(IFNULL(a,'')), CHAR_LENGTH(IFNULL(b,'')));
  IF longest = 0 THEN RETURN 0; END IF;
  RETURN 1 - (search_levenshtein(a, b) / longest);
END$$

-- ---------------------------------------------------------------------------
-- Full rebuild of the index from the owning databases.
--
-- Cheap enough to run on a schedule at this catalogue size; the Search Service
-- also upserts single documents when it receives a change event.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE search_reindex_all()
  SQL SECURITY INVOKER
MODIFIES SQL DATA
BEGIN
  DELETE FROM search_documents;

  INSERT INTO search_documents
    (entity_type, entity_id, course_id, title, subtitle, body, tags_text,
     url_path, `language`, level, is_published, popularity)
  SELECT 'course', c.id, c.id, c.title, c.subtitle,
         CONCAT_WS(' ', c.description,
           IFNULL((SELECT GROUP_CONCAT(jt.v SEPARATOR ' ')
                     FROM JSON_TABLE(c.learning_outcomes, '$[*]'
                          COLUMNS (v VARCHAR(300) PATH '$')) jt), '')),
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

  SELECT COUNT(*) AS documents FROM search_documents;
END$$

DELIMITER ;
