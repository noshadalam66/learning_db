-- ===========================================================================
-- 0001 : the eight databases, and the conventions every later migration follows
-- ---------------------------------------------------------------------------
-- MySQL has no schemas-inside-a-database: a schema *is* a database. So the
-- per-service split that PostgreSQL would express as seven schemas is
-- expressed here as seven databases on one server, plus one more for the
-- cross-service read views.
--
--   identity     -> User Service      (login, profile, roles)
--   catalog      -> Course Service    (course + lesson structure)
--   content      -> Content Service   (articles, video URL metadata)
--   progress     -> Progress Service  (tracking what a learner has watched)
--   assessment   -> Quiz Service      (quizzes, questions, attempts)
--   search       -> Search Service    (denormalised, indexed search documents)
--   analytics    -> Analytics Service (raw behaviour events + rollups)
--   platform     -> shared read views and the migration ledger; owned by nobody
--
-- Each service is the only writer to its own database. Cross-service reads go
-- through the views in `platform` (migration 0009) or over HTTP.
--
-- ---------------------------------------------------------------------------
-- Conventions used throughout, stated once here rather than repeated:
--
-- 1. IDS are CHAR(36) CHARACTER SET ascii, defaulted to (UUID()).
--    ascii rather than utf8mb4 because a utf8mb4 CHAR(36) reserves 144 bytes
--    per value; a uuid only ever contains hex and hyphens. Every foreign key
--    column repeats the same charset, because InnoDB refuses a foreign key
--    between columns whose character sets differ.
--
--    The cost of a random uuid primary key is index locality: inserts scatter
--    across the B-tree instead of appending. The append-heavy log tables
--    (analytics.events, search.query_log) use BIGINT AUTO_INCREMENT instead,
--    for exactly that reason.
--
-- 2. TIMESTAMPS are DATETIME(3) defaulted to (UTC_TIMESTAMP(3)), never
--    TIMESTAMP and never CURRENT_TIMESTAMP.
--
--    DATETIME because TIMESTAMP cannot represent a date past 2038-01-19.
--    UTC_TIMESTAMP because CURRENT_TIMESTAMP returns the *session* time zone -
--    so a client connected with time_zone='+05:30' would silently write local
--    time into a column every other client reads as UTC. UTC_TIMESTAMP is
--    immune to that. For the same reason updated_at is maintained by a trigger
--    rather than by ON UPDATE CURRENT_TIMESTAMP, which has the same session
--    dependency.
--
--    Clients should still connect with time_zone='+00:00'. The defaults above
--    mean forgetting is not corrupting.
--
-- 3. TEXT COLUMNS are utf8mb4 with the server default collation
--    (utf8mb4_0900_ai_ci), which is case- and accent-insensitive. That is what
--    makes identity.users.email behave like PostgreSQL's citext for free:
--    Ada@x.test and ada@x.test collide on the unique index.
--
--    Columns holding a digest or a token are the exception - they are declared
--    ascii/ascii_bin so comparison is exact and byte-for-byte.
--
-- 4. ENUMS are declared inline per column. MySQL has no CREATE TYPE, so the
--    same value set is repeated where it is used; the sets are listed in
--    docs/SCHEMA.md so a change can be applied everywhere it appears.
-- ===========================================================================

CREATE DATABASE IF NOT EXISTS identity   CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS catalog    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS content    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS progress   CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS assessment CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS `search`   CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS analytics  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS platform   CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- The migration ledger. scripts/migrate.sh records a checksum per applied file
-- and refuses to run if a file that already ran has changed.
CREATE TABLE IF NOT EXISTS platform.schema_migrations (
  filename   VARCHAR(255) CHARACTER SET ascii NOT NULL PRIMARY KEY,
  checksum   CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  applied_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3))
) ENGINE=InnoDB;
