-- ===========================================================================
-- 0003 : catalog schema  --  owned by the Course Service
-- Course information and lesson structure (course -> module -> lesson).
-- ===========================================================================

BEGIN;

CREATE TABLE catalog.categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id   uuid REFERENCES catalog.categories (id) ON DELETE SET NULL,
  slug        text NOT NULL UNIQUE,
  name        text NOT NULL,
  description text NOT NULL DEFAULT '',
  position    integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT categories_slug_shape CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT categories_not_own_parent CHECK (parent_id IS DISTINCT FROM id)
);

CREATE INDEX categories_parent_idx ON catalog.categories (parent_id, position);

-- ---------------------------------------------------------------------------
-- Courses. instructor_id points at identity.users but is intentionally NOT a
-- foreign key: the User Service owns that table and the Course Service must
-- stay deployable on its own. Referential integrity is enforced in the API
-- layer, which is the normal trade-off in a microservice split.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog.courses (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug             text NOT NULL UNIQUE,
  title            text NOT NULL,
  subtitle         text NOT NULL DEFAULT '',
  description      text NOT NULL DEFAULT '',
  category_id      uuid REFERENCES catalog.categories (id) ON DELETE SET NULL,
  instructor_id    uuid NOT NULL,
  level            public.course_level   NOT NULL DEFAULT 'beginner',
  language         text NOT NULL DEFAULT 'en',
  status           public.publish_status NOT NULL DEFAULT 'draft',
  thumbnail_url    text,
  promo_video_url  text,
  price_cents      integer NOT NULL DEFAULT 0,
  currency         char(3) NOT NULL DEFAULT 'USD',
  duration_minutes integer NOT NULL DEFAULT 0,
  lesson_count     integer NOT NULL DEFAULT 0,
  rating_average   numeric(3,2) NOT NULL DEFAULT 0,
  rating_count     integer NOT NULL DEFAULT 0,
  learning_outcomes text[] NOT NULL DEFAULT '{}',
  requirements      text[] NOT NULL DEFAULT '{}',
  published_at     timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT courses_slug_shape     CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT courses_price_positive CHECK (price_cents >= 0),
  CONSTRAINT courses_rating_range   CHECK (rating_average BETWEEN 0 AND 5),
  CONSTRAINT courses_published_has_date
    CHECK (status <> 'published' OR published_at IS NOT NULL)
);

COMMENT ON COLUMN catalog.courses.instructor_id
  IS 'identity.users.id - deliberately not an FK; the User Service owns that table.';
COMMENT ON COLUMN catalog.courses.duration_minutes
  IS 'Denormalised sum of lesson durations, refreshed by catalog.refresh_course_rollup().';

CREATE INDEX courses_status_published_idx ON catalog.courses (status, published_at DESC);
CREATE INDEX courses_category_idx         ON catalog.courses (category_id);
CREATE INDEX courses_instructor_idx       ON catalog.courses (instructor_id);
CREATE INDEX courses_level_idx            ON catalog.courses (level);
CREATE INDEX courses_title_trgm_idx       ON catalog.courses USING gin (title gin_trgm_ops);

CREATE TRIGGER courses_touch
  BEFORE UPDATE ON catalog.courses
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Free-form tags, many-to-many with courses.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog.tags (
  id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  name text NOT NULL
);

CREATE TABLE catalog.course_tags (
  course_id uuid NOT NULL REFERENCES catalog.courses (id) ON DELETE CASCADE,
  tag_id    uuid NOT NULL REFERENCES catalog.tags (id)    ON DELETE CASCADE,
  PRIMARY KEY (course_id, tag_id)
);

CREATE INDEX course_tags_tag_idx ON catalog.course_tags (tag_id);

-- ---------------------------------------------------------------------------
-- Modules = the chapters/sections of a course.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog.modules (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id   uuid NOT NULL REFERENCES catalog.courses (id) ON DELETE CASCADE,
  title       text NOT NULL,
  summary     text NOT NULL DEFAULT '',
  position    integer NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT modules_position_positive CHECK (position > 0),
  CONSTRAINT modules_unique_position UNIQUE (course_id, position) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX modules_course_idx ON catalog.modules (course_id, position);

CREATE TRIGGER modules_touch
  BEFORE UPDATE ON catalog.modules
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Lessons. course_id is carried alongside module_id so the very common
-- "all lessons of a course, in order" query needs no join, and a trigger keeps
-- the pair consistent.
-- ---------------------------------------------------------------------------
CREATE TABLE catalog.lessons (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id        uuid NOT NULL REFERENCES catalog.modules (id) ON DELETE CASCADE,
  course_id        uuid NOT NULL REFERENCES catalog.courses (id) ON DELETE CASCADE,
  slug             text NOT NULL,
  title            text NOT NULL,
  summary          text NOT NULL DEFAULT '',
  kind             public.lesson_kind    NOT NULL DEFAULT 'video',
  status           public.publish_status NOT NULL DEFAULT 'draft',
  position         integer NOT NULL,
  duration_seconds integer NOT NULL DEFAULT 0,
  is_free_preview  boolean NOT NULL DEFAULT false,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT lessons_slug_shape        CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  CONSTRAINT lessons_position_positive CHECK (position > 0),
  CONSTRAINT lessons_duration_positive CHECK (duration_seconds >= 0),
  CONSTRAINT lessons_unique_slug       UNIQUE (course_id, slug),
  CONSTRAINT lessons_unique_position   UNIQUE (module_id, position) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX lessons_course_idx ON catalog.lessons (course_id, position);
CREATE INDEX lessons_module_idx ON catalog.lessons (module_id, position);
CREATE INDEX lessons_kind_idx   ON catalog.lessons (kind);

CREATE TRIGGER lessons_touch
  BEFORE UPDATE ON catalog.lessons
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- A lesson must belong to the same course as its module.
CREATE OR REPLACE FUNCTION catalog.assert_lesson_matches_module()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  module_course uuid;
BEGIN
  SELECT course_id INTO module_course FROM catalog.modules WHERE id = NEW.module_id;
  IF module_course IS DISTINCT FROM NEW.course_id THEN
    RAISE EXCEPTION 'lesson % belongs to course % but its module belongs to course %',
      NEW.id, NEW.course_id, module_course;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER lessons_module_course_guard
  BEFORE INSERT OR UPDATE OF module_id, course_id ON catalog.lessons
  FOR EACH ROW EXECUTE FUNCTION catalog.assert_lesson_matches_module();

-- ---------------------------------------------------------------------------
-- Course reviews (the source of courses.rating_average / rating_count).
-- ---------------------------------------------------------------------------
CREATE TABLE catalog.course_reviews (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id  uuid NOT NULL REFERENCES catalog.courses (id) ON DELETE CASCADE,
  user_id    uuid NOT NULL,
  rating     smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment    text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT course_reviews_one_per_user UNIQUE (course_id, user_id)
);

CREATE INDEX course_reviews_course_idx ON catalog.course_reviews (course_id, created_at DESC);

CREATE TRIGGER course_reviews_touch
  BEFORE UPDATE ON catalog.course_reviews
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

COMMIT;
