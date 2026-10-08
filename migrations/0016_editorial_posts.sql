-- ===========================================================================
-- 0016 : long-form writing that is not a lesson
--
-- Two things are being added to the platform and they are the same shape, so
-- they are one table rather than two.
--
--   A COURSE GUIDE is the long answer to "why should I learn this": what the
--   subject is for, where it is actually used, what has been built with it,
--   what it is like to work in, and what it is worth to somebody deciding how
--   to spend the next three months. It hangs off a course and is the page a
--   search for "what is Python used for" should land on.
--
--   A BLOG POST hangs off nothing. It is whatever is worth writing that is not
--   a lesson and not a guide.
--
-- WHY NOT content_articles
--
-- That table is keyed by lesson_id, UNIQUE, NOT NULL - one article, one lesson,
-- and the index enforces it. A guide belongs to a course and a post belongs to
-- nothing at all, so either would need that column made nullable and its unique
-- key dropped, which would quietly remove the guarantee that a lesson cannot
-- end up with two bodies. The lesson table keeps its invariant; this is a
-- different kind of writing and gets its own.
--
-- WHY ONE TABLE FOR BOTH
--
-- They differ in exactly one field - whether a course_id is set - and are
-- identical in every other respect: a slug, a title, a body in markdown, an
-- excerpt, reading time, a status, a published date. Two tables would mean two
-- repositories, two renderers and two sets of SEO, kept in step by hand. The
-- kind column is the difference, and the CHECK below is what stops it drifting:
-- a guide without a course, or a post with one, is refused.
--
-- THE BODY IS MARKDOWN AND IS RENDERED BY THE CONTENT SERVICE
--
-- Same path as a lesson article, through the same sanitiser. There is no second
-- rendering boundary here and deliberately so - the one place this platform
-- turns stored text into markup stays one place, with one set of tests.
-- ===========================================================================

CREATE TABLE IF NOT EXISTS content_editorial_posts (
  id                   CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),

  kind                 ENUM('course_guide', 'blog_post') NOT NULL,

  -- The URL. ascii because a slug is ascii by construction, and unique because
  -- two posts at one address is a bug that only shows up in production.
  slug                 VARCHAR(200) CHARACTER SET ascii NOT NULL,

  -- catalog_courses.id for a guide, NULL for a post. Deliberately not a foreign
  -- key, matching every other cross-service reference in this schema.
  course_id            CHAR(36) CHARACTER SET ascii NULL,

  title                VARCHAR(300) NOT NULL,
  subtitle             VARCHAR(500) NOT NULL DEFAULT '',
  -- What a search result and a card show. Not derived from the body: the first
  -- 160 characters of an article is almost never the sentence you would choose.
  excerpt              VARCHAR(500) NOT NULL DEFAULT '',
  body                 MEDIUMTEXT NOT NULL,

  -- Counted when the row is written rather than on every read. A guide is
  -- thousands of words and str_word_count over it on each request is work done
  -- a million times to produce the same number.
  word_count           INT NOT NULL DEFAULT 0,
  reading_time_minutes INT NOT NULL DEFAULT 0,

  -- JSON_ARRAY of plain strings, as catalog_courses.learning_outcomes is. Tags
  -- here are editorial rather than catalogue tags, so they are not the
  -- catalog_tags rows - a post can be about something no course covers.
  tags                 JSON NULL,

  -- identity_users.id - deliberately not a foreign key.
  author_id            CHAR(36) CHARACTER SET ascii NULL,
  status               ENUM('draft', 'in_review', 'published', 'archived') NOT NULL DEFAULT 'draft',
  published_at         DATETIME(3) NULL,

  created_at           DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at           DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_editorial_slug (slug),
  -- One guide per course. A second one is a mistake, and this is where it
  -- stops rather than where somebody notices two of them on a page.
  UNIQUE KEY uq_editorial_course_guide (kind, course_id),
  KEY ix_editorial_kind_published (kind, status, published_at DESC),
  KEY ix_editorial_author (author_id),

  -- ---------------------------------------------------------------------
  -- Full text, so a guide and a post are findable in the site's own search.
  --
  -- Declared here rather than added by a later ALTER, and that is not a style
  -- choice: an ALTER TABLE ... ADD FULLTEXT KEY has no IF NOT EXISTS, so a
  -- second import of this file stopped on it with "Duplicate key name". This
  -- file is handed to a person to import in phpMyAdmin, and a person can
  -- import a file twice. Inside CREATE TABLE IF NOT EXISTS the whole statement
  -- is skipped on the second run and there is nothing to collide.
  --
  -- Separate indexes per field rather than one over both, because that is how
  -- search_documents is built: the Search Service weights a title match above
  -- a body match by querying them separately, and matching that here means
  -- these rows can join the same index later without the ranking being
  -- rewritten.
  -- ---------------------------------------------------------------------
  FULLTEXT KEY ft_editorial_title (title),
  FULLTEXT KEY ft_editorial_body (body),

  CONSTRAINT ck_editorial_body_not_blank CHECK (TRIM(body) <> ''),
  CONSTRAINT ck_editorial_slug_not_blank CHECK (TRIM(slug) <> ''),
  CONSTRAINT ck_editorial_published_has_date
    CHECK (status <> 'published' OR published_at IS NOT NULL),
  -- The one rule that makes a single table safe for two things.
  CONSTRAINT ck_editorial_course_matches_kind
    CHECK ((kind = 'course_guide' AND course_id IS NOT NULL)
        OR (kind = 'blog_post' AND course_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Course guides and blog posts. Long-form writing that is not a lesson.';

-- ---------------------------------------------------------------------------
-- updated_at by trigger, for the reason migration 0002 gives: CURRENT_TIMESTAMP
-- returns the session time zone, so a client connected in a non-UTC zone would
-- write local time into a UTC column, and only a trigger can call UTC_TIMESTAMP
-- on update.
--
-- Dropped first so this file can be imported twice. CREATE TABLE IF NOT EXISTS
-- makes the table idempotent and there is no such clause for a trigger.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_editorial_posts_touch;

DELIMITER $$
CREATE TRIGGER trg_editorial_posts_touch
  BEFORE UPDATE ON content_editorial_posts FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP(3);
END$$
DELIMITER ;
