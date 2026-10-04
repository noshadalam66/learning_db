-- ===========================================================================
-- 0014 : diagrams instead of video, and an overview before the introduction
--
-- Two additions and one deletion.
--
-- 1. content_lesson_diagrams
--
-- The platform taught with video. It no longer does: a lesson explains a
-- concept with a diagram of how the pieces fit together - how a page gets its
-- styles, how a request reaches a database and comes back - and those are
-- better as pictures you can read at your own pace than as something you have
-- to scrub through.
--
-- THE DIAGRAM IS DATA, NOT MARKUP, and that is the whole design. The spec
-- column holds nodes and edges; the website draws the SVG from them. Storing
-- SVG instead would mean storing markup that something has to render, and the
-- only safe way to render stored markup is to sanitise it - which is exactly
-- the boundary content_articles already has, maintained once, in one place.
-- Nothing here can become markup, so nothing here needs sanitising.
--
-- 2. catalog_courses.overview
--
-- The course page had a description, split in two by the front end: the first
-- paragraph as a standfirst, the rest as the introduction. That is one piece
-- of writing doing two jobs. The overview is now its own column - what the
-- subject is and why it is worth your time, in a paragraph - and the
-- description is the introduction that follows it.
--
-- It is NULL-able rather than NOT NULL DEFAULT '': MySQL 8 rejects a literal
-- default on TEXT, and an expression default would behave differently on the
-- two engines this schema runs on. A missing overview reads as absent, which
-- is what the page already does with every other optional field.
--
-- 3. The video rows go
--
-- This deletes the eight seeded demo videos. It is deliberate and it is the
-- point of the migration - the lessons that had them are articles now, with
-- bodies of their own - and it is here rather than in content.sql because
-- content.sql promises it cannot lose anything, and that promise is what makes
-- it safe to import over a live database.
--
-- The table itself stays. Nothing writes to it, and an empty table is a
-- capability the platform has and does not use; dropping it would throw away
-- the Search Service's transcript indexing and the player the front end knows
-- how to render, neither of which is in the way.
-- ===========================================================================

CREATE TABLE IF NOT EXISTS content_lesson_diagrams (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- catalog_lessons.id - deliberately not a foreign key, matching every other
  -- cross-service reference in this schema.
  lesson_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  title      VARCHAR(200) NOT NULL DEFAULT '',
  -- Read out in place of the picture. Not optional: a diagram that a screen
  -- reader cannot describe is a lesson with a hole in it.
  alt        VARCHAR(1000) NOT NULL,
  caption    VARCHAR(1000) NOT NULL DEFAULT '',
  -- { "nodes": [...], "edges": [...] } - see views/partials/diagram.php, which
  -- is the only thing that reads it.
  spec       JSON NOT NULL,
  `position` INT NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_diagram_lesson_position (lesson_id, `position`),
  KEY ix_diagram_lesson (lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='One diagram per lesson, as data the site draws rather than stored markup.';

ALTER TABLE catalog_courses
  ADD COLUMN overview TEXT NULL AFTER subtitle;

DELETE FROM content_lesson_videos;
