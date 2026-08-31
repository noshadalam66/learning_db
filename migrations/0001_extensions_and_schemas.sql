-- ===========================================================================
-- 0001 : Extensions, service schemas and shared enum types
-- ---------------------------------------------------------------------------
-- The platform is split into microservices (learning_apis). Each service owns
-- exactly one PostgreSQL schema and is the only writer for the tables inside
-- it. Cross-service reads happen through the views in 0010 or over HTTP, never
-- by writing into somebody else's schema.
--
--   identity    -> User Service      (login, profile, roles)
--   catalog     -> Course Service    (course + lesson structure)
--   content     -> Content Service   (articles, video URL metadata)
--   progress    -> Progress Service  (tracking what a learner has watched)
--   assessment  -> Quiz Service      (quizzes, questions, attempts)
--   search      -> Search Service    (denormalised, indexed search documents)
--   analytics   -> Analytics Service (raw behaviour events + rollups)
-- ===========================================================================

BEGIN;

-- pgcrypto gives us gen_random_uuid(); citext gives case-insensitive e-mail.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;
-- pg_trgm powers the fuzzy "did you mean" part of the Search Service.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS content;
CREATE SCHEMA IF NOT EXISTS progress;
CREATE SCHEMA IF NOT EXISTS assessment;
CREATE SCHEMA IF NOT EXISTS search;
CREATE SCHEMA IF NOT EXISTS analytics;

COMMENT ON SCHEMA identity   IS 'Owned by User Service: accounts, credentials, roles.';
COMMENT ON SCHEMA catalog    IS 'Owned by Course Service: courses, modules, lessons.';
COMMENT ON SCHEMA content    IS 'Owned by Content Service: articles and video metadata.';
COMMENT ON SCHEMA progress   IS 'Owned by Progress Service: enrolments and lesson progress.';
COMMENT ON SCHEMA assessment IS 'Owned by Quiz Service: quizzes, questions, attempts.';
COMMENT ON SCHEMA search     IS 'Owned by Search Service: denormalised search documents.';
COMMENT ON SCHEMA analytics  IS 'Owned by Analytics Service: behaviour events and rollups.';

-- ---------------------------------------------------------------------------
-- Shared enum types. They live in "public" so every service schema can use
-- them without a cross-schema ownership argument.
-- ---------------------------------------------------------------------------
CREATE TYPE public.account_status  AS ENUM ('pending', 'active', 'suspended', 'deleted');
CREATE TYPE public.publish_status  AS ENUM ('draft', 'in_review', 'published', 'archived');
CREATE TYPE public.course_level    AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE public.lesson_kind     AS ENUM ('video', 'article', 'quiz', 'assignment');
CREATE TYPE public.article_format  AS ENUM ('markdown', 'html');
CREATE TYPE public.video_provider  AS ENUM ('youtube', 'vimeo', 'mux', 'cloudflare', 'bunny', 's3', 'external');
CREATE TYPE public.enrolment_state AS ENUM ('active', 'completed', 'expired', 'cancelled');
CREATE TYPE public.progress_state  AS ENUM ('not_started', 'in_progress', 'completed');
CREATE TYPE public.question_kind   AS ENUM ('single_choice', 'multiple_choice', 'true_false', 'short_text');
CREATE TYPE public.attempt_state   AS ENUM ('in_progress', 'submitted', 'graded', 'abandoned');

-- ---------------------------------------------------------------------------
-- One shared trigger function keeps updated_at honest everywhere.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

COMMIT;
