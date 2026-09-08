-- ===========================================================================
-- 0003 : catalog  --  owned by the Course Service
-- Course information and lesson structure (course -> module -> lesson).
-- ===========================================================================

CREATE TABLE catalog_categories (
  id          CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  parent_id   CHAR(36) CHARACTER SET ascii NULL,
  slug        VARCHAR(120) NOT NULL,
  name        VARCHAR(150) NOT NULL,
  description VARCHAR(1000) NOT NULL DEFAULT '',
  `position`  INT NOT NULL DEFAULT 0,
  created_at  DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  KEY ix_categories_parent (parent_id, `position`),

  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id)
    REFERENCES catalog_categories (id) ON DELETE SET NULL,
  -- "A category is not its own parent" cannot be a CHECK here: MySQL refuses a
  -- check constraint on a column that carries a foreign key referential action
  -- (ON DELETE SET NULL, above). It is enforced by a trigger at the end of this
  -- migration instead.
  CONSTRAINT ck_categories_slug_shape
    CHECK (slug REGEXP '^[a-z0-9]+(-[a-z0-9]+)*$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Courses.
--
-- instructor_id holds an identity_users.id but carries NO foreign key. MySQL
-- would happily enforce one across databases - InnoDB supports that - and the
-- omission is deliberate: a foreign key here would mean the Course Service and
-- the User Service can never be moved onto separate servers. That is the
-- standard microservice trade, and the price is that the check moves into
-- application code. Every such column is commented the same way.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog_courses (
  id                CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  slug              VARCHAR(120) NOT NULL,
  title             VARCHAR(200) NOT NULL,
  subtitle          VARCHAR(300) NOT NULL DEFAULT '',
  description       TEXT NOT NULL,
  category_id       CHAR(36) CHARACTER SET ascii NULL,
  -- identity_users.id - deliberately not a foreign key (see above).
  instructor_id     CHAR(36) CHARACTER SET ascii NOT NULL,
  level             ENUM('beginner','intermediate','advanced','expert') NOT NULL DEFAULT 'beginner',
  `language`        VARCHAR(10) NOT NULL DEFAULT 'en',
  status            ENUM('draft','in_review','published','archived') NOT NULL DEFAULT 'draft',
  thumbnail_url     VARCHAR(2000) NULL,
  promo_video_url   VARCHAR(2000) NULL,
  price_cents       INT NOT NULL DEFAULT 0,
  currency          CHAR(3) CHARACTER SET ascii NOT NULL DEFAULT 'USD',
  -- Denormalised; refreshed by catalog_refresh_course_rollup().
  duration_minutes  INT NOT NULL DEFAULT 0,
  lesson_count      INT NOT NULL DEFAULT 0,
  -- Denormalised; refreshed by catalog_refresh_course_rating().
  rating_average    DECIMAL(3,2) NOT NULL DEFAULT 0,
  rating_count      INT NOT NULL DEFAULT 0,
  -- MySQL has no array type. A JSON array is the closest thing, and unlike a
  -- comma-joined string it survives a value that contains a comma.
  learning_outcomes JSON NOT NULL,
  requirements      JSON NOT NULL,
  published_at      DATETIME(3) NULL,
  created_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_courses_slug (slug),
  KEY ix_courses_status_published (status, published_at DESC),
  KEY ix_courses_category (category_id),
  KEY ix_courses_instructor (instructor_id),
  KEY ix_courses_level (level),
  FULLTEXT KEY ft_courses_title (title),

  CONSTRAINT fk_courses_category FOREIGN KEY (category_id)
    REFERENCES catalog_categories (id) ON DELETE SET NULL,
  CONSTRAINT ck_courses_slug_shape
    CHECK (slug REGEXP '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT ck_courses_price_positive CHECK (price_cents >= 0),
  CONSTRAINT ck_courses_rating_range CHECK (rating_average BETWEEN 0 AND 5),
  CONSTRAINT ck_courses_outcomes_is_array CHECK (JSON_TYPE(learning_outcomes) = 'ARRAY'),
  CONSTRAINT ck_courses_requirements_is_array CHECK (JSON_TYPE(requirements) = 'ARRAY'),
  -- "Published" means there is a publication date. Four lines here removes an
  -- entire family of blank-date bugs the application can no longer cause.
  CONSTRAINT ck_courses_published_has_date
    CHECK (status <> 'published' OR published_at IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE catalog_tags (
  id   CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  slug VARCHAR(120) NOT NULL,
  name VARCHAR(120) NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_tags_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE catalog_course_tags (
  course_id CHAR(36) CHARACTER SET ascii NOT NULL,
  tag_id    CHAR(36) CHARACTER SET ascii NOT NULL,

  PRIMARY KEY (course_id, tag_id),
  KEY ix_course_tags_tag (tag_id),

  CONSTRAINT fk_course_tags_course FOREIGN KEY (course_id)
    REFERENCES catalog_courses (id) ON DELETE CASCADE,
  CONSTRAINT fk_course_tags_tag FOREIGN KEY (tag_id)
    REFERENCES catalog_tags (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Modules = the chapters of a course.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog_modules (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  course_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  title      VARCHAR(200) NOT NULL,
  summary    VARCHAR(2000) NOT NULL DEFAULT '',
  `position` INT NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  -- MySQL has no DEFERRABLE constraints, so a reorder cannot pass through a
  -- transient duplicate the way it can in PostgreSQL. catalog_reorder_lessons()
  -- works around that by staging positions in the negative range first.
  UNIQUE KEY uq_modules_position (course_id, `position`),

  CONSTRAINT fk_modules_course FOREIGN KEY (course_id)
    REFERENCES catalog_courses (id) ON DELETE CASCADE,
  CONSTRAINT ck_modules_position_positive CHECK (`position` <> 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Lessons. course_id is carried alongside module_id so the very common
-- "all lessons of a course, in order" query needs no join; a trigger keeps the
-- pair honest.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog_lessons (
  id               CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  module_id        CHAR(36) CHARACTER SET ascii NOT NULL,
  course_id        CHAR(36) CHARACTER SET ascii NOT NULL,
  slug             VARCHAR(120) NOT NULL,
  title            VARCHAR(200) NOT NULL,
  summary          VARCHAR(2000) NOT NULL DEFAULT '',
  kind             ENUM('video','article','quiz','assignment') NOT NULL DEFAULT 'video',
  status           ENUM('draft','in_review','published','archived') NOT NULL DEFAULT 'draft',
  `position`       INT NOT NULL,
  duration_seconds INT NOT NULL DEFAULT 0,
  is_free_preview  TINYINT(1) NOT NULL DEFAULT 0,
  created_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at       DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_lessons_slug (course_id, slug),
  UNIQUE KEY uq_lessons_position (module_id, `position`),
  KEY ix_lessons_course (course_id, `position`),
  KEY ix_lessons_kind (kind),

  CONSTRAINT fk_lessons_module FOREIGN KEY (module_id)
    REFERENCES catalog_modules (id) ON DELETE CASCADE,
  CONSTRAINT fk_lessons_course FOREIGN KEY (course_id)
    REFERENCES catalog_courses (id) ON DELETE CASCADE,
  CONSTRAINT ck_lessons_slug_shape
    CHECK (slug REGEXP '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT ck_lessons_position_positive CHECK (`position` <> 0),
  CONSTRAINT ck_lessons_duration_positive CHECK (duration_seconds >= 0)
) ENGINE=InnoDB;

CREATE TABLE catalog_course_reviews (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  course_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  -- identity_users.id - deliberately not a foreign key.
  user_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  rating     TINYINT UNSIGNED NOT NULL,
  comment    TEXT NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_review_one_per_user (course_id, user_id),
  KEY ix_reviews_course (course_id, created_at DESC),

  CONSTRAINT fk_reviews_course FOREIGN KEY (course_id)
    REFERENCES catalog_courses (id) ON DELETE CASCADE,
  CONSTRAINT ck_reviews_rating_range CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_categories_no_self_parent_ins
  BEFORE INSERT ON catalog_categories FOR EACH ROW
BEGIN
  IF NEW.parent_id IS NOT NULL AND NEW.parent_id = NEW.id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a category cannot be its own parent';
  END IF;
END$$

CREATE TRIGGER trg_categories_no_self_parent_upd
  BEFORE UPDATE ON catalog_categories FOR EACH ROW
BEGIN
  IF NEW.parent_id IS NOT NULL AND NEW.parent_id = NEW.id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'a category cannot be its own parent';
  END IF;
END$$

CREATE TRIGGER trg_courses_touch
  BEFORE UPDATE ON catalog_courses FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

CREATE TRIGGER trg_modules_touch
  BEFORE UPDATE ON catalog_modules FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

CREATE TRIGGER trg_reviews_touch
  BEFORE UPDATE ON catalog_course_reviews FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

-- A lesson must belong to the same course as its module. Two triggers, because
-- MySQL has no single trigger for "insert or update".
CREATE TRIGGER trg_lessons_touch_ins
  BEFORE INSERT ON catalog_lessons FOR EACH ROW
BEGIN
  DECLARE module_course CHAR(36) CHARACTER SET ascii;
  SELECT course_id INTO module_course FROM catalog_modules WHERE id = NEW.module_id;
  IF module_course IS NULL OR module_course <> NEW.course_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lesson.course_id does not match the course of its module';
  END IF;
END$$

CREATE TRIGGER trg_lessons_touch_upd
  BEFORE UPDATE ON catalog_lessons FOR EACH ROW
BEGIN
  DECLARE module_course CHAR(36) CHARACTER SET ascii;
  SET NEW.updated_at = UTC_TIMESTAMP(3);
  SELECT course_id INTO module_course FROM catalog_modules WHERE id = NEW.module_id;
  IF module_course IS NULL OR module_course <> NEW.course_id THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lesson.course_id does not match the course of its module';
  END IF;
END$$

DELIMITER ;
