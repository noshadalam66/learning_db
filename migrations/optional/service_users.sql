-- ===========================================================================
-- Optional : one database account per service, each able to write only its
--            own tables.
--
-- NOT part of the numbered migration chain, and not applied by
-- scripts/migrate.sh. Apply it by hand where you want it:
--
--     ./scripts/console.sh < migrations/optional/service_users.sql
--
-- Why it is optional now. When each service owned a database, the boundary was
-- one GRANT per service and the server enforced it. Everything lives in one
-- database today, so the same boundary costs a grant per table - which is what
-- this file is. That is still worth having on a server you control.
--
-- On shared hosting it is not applicable at all: cPanel does not let you issue
-- CREATE USER or GRANT over SQL. Database users are created in the control
-- panel, arrive with the account prefix, and are attached to a database
-- through the UI. Skip this file there; the services connect as one account.
--
-- The accounts are created without a password and locked, so they are unusable
-- until someone sets one:
--     ALTER USER 'svc_user'@'%' IDENTIFIED BY '...';
--     ALTER USER 'svc_user'@'%' ACCOUNT UNLOCK;
-- Leaving them unusable is deliberate. A migration that hands out working
-- credentials is a migration that ships the same password to every install.
-- ===========================================================================

CREATE USER IF NOT EXISTS 'svc_user'@'%'      IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_course'@'%'    IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_content'@'%'   IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_progress'@'%'  IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_quiz'@'%'      IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_search'@'%'    IDENTIFIED WITH caching_sha2_password;
CREATE USER IF NOT EXISTS 'svc_analytics'@'%' IDENTIFIED WITH caching_sha2_password;

ALTER USER 'svc_user'@'%'      ACCOUNT LOCK;
ALTER USER 'svc_course'@'%'    ACCOUNT LOCK;
ALTER USER 'svc_content'@'%'   ACCOUNT LOCK;
ALTER USER 'svc_progress'@'%'  ACCOUNT LOCK;
ALTER USER 'svc_quiz'@'%'      ACCOUNT LOCK;
ALTER USER 'svc_search'@'%'    ACCOUNT LOCK;
ALTER USER 'svc_analytics'@'%' ACCOUNT LOCK;

-- ---------------------------------------------------------------------------
-- Write access to the tables each service owns, and nothing else.
--
-- A grant names one table: MySQL accepts no wildcard there, so the prefix that
-- carries ownership in the table name has to be spelled out row by row. Add a
-- table to a service and its grant belongs here too.
--
-- @DB@ is replaced with the database name by scripts/service-users.sh.
-- ---------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.identity_users               TO 'svc_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.identity_roles               TO 'svc_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.identity_user_roles          TO 'svc_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.identity_refresh_tokens      TO 'svc_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.identity_verification_tokens TO 'svc_user'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_categories     TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_courses        TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_modules        TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_lessons        TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_tags           TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_course_tags    TO 'svc_course'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.catalog_course_reviews TO 'svc_course'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.content_articles           TO 'svc_content'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.content_article_revisions  TO 'svc_content'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.content_lesson_videos      TO 'svc_content'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.content_lesson_attachments TO 'svc_content'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.progress_enrolments      TO 'svc_progress'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.progress_lesson_progress TO 'svc_progress'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.progress_lesson_notes    TO 'svc_progress'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.progress_certificates    TO 'svc_progress'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.assessment_quizzes          TO 'svc_quiz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.assessment_questions        TO 'svc_quiz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.assessment_question_options TO 'svc_quiz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.assessment_quiz_attempts    TO 'svc_quiz'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.assessment_attempt_answers  TO 'svc_quiz'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.search_documents TO 'svc_search'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.search_query_log TO 'svc_search'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.search_synonyms  TO 'svc_search'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.analytics_events               TO 'svc_analytics'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.analytics_daily_course_stats   TO 'svc_analytics'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON `@DB@`.analytics_daily_platform_stats TO 'svc_analytics'@'%';

-- The Search and Analytics services read the tables they summarise.
GRANT SELECT ON `@DB@`.catalog_courses    TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.catalog_modules    TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.catalog_lessons    TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.catalog_tags       TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.catalog_course_tags TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.content_articles   TO 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.assessment_quizzes TO 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.identity_users     TO 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.progress_enrolments      TO 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.progress_lesson_progress TO 'svc_analytics'@'%';

-- Everyone may read the sanctioned cross-service views.
GRANT SELECT ON `@DB@`.v_course_outline TO
  'svc_user'@'%', 'svc_course'@'%', 'svc_content'@'%', 'svc_progress'@'%',
  'svc_quiz'@'%', 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.v_course_cards TO
  'svc_user'@'%', 'svc_course'@'%', 'svc_content'@'%', 'svc_progress'@'%',
  'svc_quiz'@'%', 'svc_search'@'%', 'svc_analytics'@'%';
GRANT SELECT ON `@DB@`.v_learner_course_progress TO
  'svc_user'@'%', 'svc_course'@'%', 'svc_content'@'%', 'svc_progress'@'%',
  'svc_quiz'@'%', 'svc_search'@'%', 'svc_analytics'@'%';

-- The Progress Service calls the catalog rollup procedures after a structure
-- change, and the Quiz Service grades through one of its own.
GRANT EXECUTE ON PROCEDURE `@DB@`.catalog_refresh_course_rollup     TO 'svc_progress'@'%', 'svc_course'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.catalog_refresh_course_rating     TO 'svc_course'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.catalog_reorder_lessons           TO 'svc_course'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.progress_refresh_enrolment_rollup TO 'svc_progress'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.assessment_grade_attempt          TO 'svc_quiz'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.search_reindex_all                TO 'svc_search'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.analytics_rollup_day              TO 'svc_analytics'@'%';
GRANT EXECUTE ON PROCEDURE `@DB@`.analytics_ensure_month_partition  TO 'svc_analytics'@'%';

FLUSH PRIVILEGES;
