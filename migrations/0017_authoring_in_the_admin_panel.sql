-- ===========================================================================
-- 0017 : what a course needs to be written in the admin panel
--
-- Until now a course arrived as a seed file: written here, built into
-- content.sql, imported by hand. That works for one person with a text editor
-- and does not work for anyone else, so courses move into the admin panel and
-- this migration adds the handful of things the panel needs that the schema
-- did not already have.
--
-- MOST OF IT WAS ALREADY THERE, which is why this file is short. Course groups
-- are catalog_categories. A course's title, introduction and image are title,
-- overview and thumbnail_url. The non-selectable headings in the left menu are
-- catalog_modules; the topics under them are catalog_lessons; a topic's prose
-- and example code are the body of its content_article. An exercise is an
-- assessment_quiz whose questions are already allowed to be single_choice or
-- multiple_choice, with is_correct per option - so "one answer or several" is
-- a question kind, not a schema change.
--
-- WHAT WAS MISSING is below: somewhere to put the starter code for a topic's
-- compiler, somewhere to put a topic's image, a switch for whether a topic
-- takes comments, and somewhere to keep the comments.
--
-- ONE MIGRATION FOR THE WHOLE FEATURE, including the parts not built yet.
-- Migrations are immutable here, so a second one would be needed for every
-- piece that followed; a column that is NULL until something writes to it
-- costs nothing while it waits.
--
-- IF YOU RUN THIS TWICE you will get #1060, duplicate column name. That is the
-- second run telling you the first one worked, and nothing is damaged by it -
-- scripts/migrate.sh records what it has applied so it never happens there,
-- but a hand import through phpMyAdmin has no such record.
--
-- The ALTERs deliberately do not say ADD COLUMN IF NOT EXISTS, which would
-- make the second run silent. That syntax is MariaDB's, production is MariaDB,
-- and CI is MySQL 8.0 - where it is a syntax error. A migration that passes on
-- the server nobody tests on and fails on the one everybody does is worse than
-- a duplicate-column notice.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- A compiler on a topic, and on the course itself.
--
-- The playground already runs code for every language on the site. What it
-- cannot do is start from something: a topic that says "try changing the
-- heading" needs the heading to already be there. These two columns are what
-- the admin types into the "compiler" box - the code the editor opens with.
--
-- The language is stored beside it rather than taken from the course, because
-- a course on HTML still wants a CSS example, and the runner is chosen per
-- snippet. NULL in either means no compiler on that topic, which is the
-- default and is what "optional" means here.
-- ---------------------------------------------------------------------------
ALTER TABLE catalog_lessons
  ADD COLUMN playground_language VARCHAR(20) NULL AFTER duration_seconds,
  ADD COLUMN playground_starter MEDIUMTEXT NULL AFTER playground_language;

ALTER TABLE catalog_courses
  ADD COLUMN playground_language VARCHAR(20) NULL AFTER promo_video_url,
  ADD COLUMN playground_starter MEDIUMTEXT NULL AFTER playground_language;

-- ---------------------------------------------------------------------------
-- An image on a topic.
--
-- content_lesson_attachments already exists and is the right place for a file
-- somebody downloads - a worksheet, a starter project. It is the wrong place
-- for the one picture that belongs inside the lesson, because a lesson has at
-- most one of those and the page needs to find it without a join that may
-- return three rows in an order nobody set.
--
-- The alt text is a separate column and not optional in spirit: an image with
-- no alt is invisible to a screen reader and to anybody whose connection drops
-- it. The panel asks for it; the column allows NULL only so that a decorative
-- image can be marked as such by storing an empty string.
-- ---------------------------------------------------------------------------
ALTER TABLE catalog_lessons
  ADD COLUMN image_url VARCHAR(2000) NULL AFTER playground_starter,
  ADD COLUMN image_alt VARCHAR(300) NULL AFTER image_url;

ALTER TABLE catalog_courses
  ADD COLUMN thumbnail_alt VARCHAR(300) NULL AFTER thumbnail_url;

-- ---------------------------------------------------------------------------
-- Whether a topic takes comments.
--
-- Off by default, and deliberately so. Comments are a moderation commitment
-- rather than a feature: an abandoned comment thread under a lesson is worse
-- than no thread, and every page that accepts public text is a page somebody
-- will try to put a link in. The admin turns it on per topic, where they
-- actually want the conversation.
-- ---------------------------------------------------------------------------
ALTER TABLE catalog_lessons
  ADD COLUMN comments_enabled TINYINT(1) NOT NULL DEFAULT 0 AFTER is_free_preview;

-- ---------------------------------------------------------------------------
-- The comments themselves.
--
-- Signed-in learners only - author_id is NOT NULL and references a real user -
-- because an anonymous comment box on a public page is a spam destination with
-- extra steps, and the site already has accounts.
--
-- status carries the moderation queue rather than a separate table. 'visible'
-- is the normal state; 'hidden' is a moderator's decision and keeps the row so
-- the decision can be undone; 'removed' is the author deleting their own. The
-- row is never actually deleted, so a thread does not reshuffle under the
-- people reading it.
--
-- parent_id allows one level of reply. It is not a tree: threads that nest
-- without limit need collapsing, depth limits and a renderer to match, and
-- none of that earns its place under a lesson on HTML tables.
--
-- TWO CHARSETS, on purpose, and the table does not get to inherit either.
--
-- The table default is utf8mb4: inheriting the database default is how a
-- comment containing an emoji - which is most comments - gets #1366 on a
-- cPanel database created latin1.
--
-- The id columns are ascii, which is the convention set out in 0001: a
-- utf8mb4 CHAR(36) reserves 144 bytes for 36 hex characters. It is also not
-- optional here. Every id this table points at is CHAR(36) CHARACTER SET
-- ascii, and a foreign key between columns of different collations is refused
-- outright - errno 150, "foreign key constraint is incorrectly formed", which
-- names no column and is why this comment exists.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS content_lesson_comments (
  id CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  lesson_id CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id CHAR(36) CHARACTER SET ascii NOT NULL,
  parent_id CHAR(36) CHARACTER SET ascii NULL,
  author_id CHAR(36) CHARACTER SET ascii NOT NULL,
  body VARCHAR(4000) NOT NULL,
  status ENUM('visible', 'hidden', 'removed') NOT NULL DEFAULT 'visible',
  edited_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  -- The one query the lesson page runs: this lesson's visible comments, oldest
  -- first. Covering it in the index order means no filesort on a hot path.
  KEY idx_comments_lesson (lesson_id, status, created_at),
  KEY idx_comments_course (course_id, created_at),
  KEY idx_comments_author (author_id, created_at),
  KEY idx_comments_parent (parent_id),
  CONSTRAINT fk_comments_lesson FOREIGN KEY (lesson_id)
    REFERENCES catalog_lessons (id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_course FOREIGN KEY (course_id)
    REFERENCES catalog_courses (id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_author FOREIGN KEY (author_id)
    REFERENCES identity_users (id) ON DELETE CASCADE,
  -- A reply dies with the comment it answers, which is the only sane reading
  -- of a reply whose question is gone.
  CONSTRAINT fk_comments_parent FOREIGN KEY (parent_id)
    REFERENCES content_lesson_comments (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
