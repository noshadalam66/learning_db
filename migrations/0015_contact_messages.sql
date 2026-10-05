-- ===========================================================================
-- 0015 : somewhere for a contact message to land
--
-- The contact page used to be a list of addresses. It now has a form, and a
-- form needs a table - otherwise a visitor fills it in, presses Send, and the
-- message goes nowhere while the page says thank you.
--
-- WHY A TABLE RATHER THAN AN EMAIL
--
-- Sending mail from a shared host is unreliable in a way that is invisible to
-- the sender: the message is accepted, queued, and silently dropped by a
-- receiving server that does not like the IP it came from. A row cannot be
-- silently dropped. The operator reads this table, and a message that arrived
-- is a message that is still there a week later.
--
-- WHAT IS AND IS NOT STORED
--
-- The name, address, topic and message the sender typed, and nothing they did
-- not. The remote address is NOT stored: it is hashed, with the application's
-- own secret, and only the hash is kept. That is enough to rate-limit a sender
-- and to recognise a flood from one source, and it is not enough to identify
-- anybody from the table alone - which is the right trade for data a visitor
-- never chose to give us. See the privacy policy, which says so.
--
-- user_id is filled in when a signed-in person writes, so a reply can be
-- matched to an account. It is deliberately not a foreign key, matching every
-- other cross-service reference in this schema, and it is NULL for the far
-- more common case of somebody who is not signed in.
--
-- WHY THE STATUS COLUMN
--
-- A support inbox with no state is a support inbox where the same message gets
-- answered twice and the one underneath it gets missed. Four states are
-- enough: new, read, answered, spam. Nothing in the application writes any of
-- them except 'new' - the operator moves a row along by hand, in phpMyAdmin,
-- which is the whole interface this needs until it does not.
-- ===========================================================================

CREATE TABLE IF NOT EXISTS support_contact_messages (
  id           CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),

  -- What the sender typed. The lengths are generous but finite: a column with
  -- no ceiling is a column somebody eventually pastes a novel into.
  name         VARCHAR(150) NOT NULL,
  email        VARCHAR(320) NOT NULL,
  -- Which address the message would otherwise have gone to - support,
  -- editorial, privacy, legal, security or general. Stored as the key rather
  -- than the address, because the addresses are configurable and the key is
  -- what the form offered.
  topic        VARCHAR(40) NOT NULL DEFAULT 'general',
  subject      VARCHAR(200) NOT NULL DEFAULT '',
  message      TEXT NOT NULL,

  -- identity_users.id, when the sender was signed in. Not a foreign key, for
  -- the reason every other cross-service reference here is not one.
  user_id      CHAR(36) CHARACTER SET ascii NULL,

  -- A keyed hash of the remote address, never the address. Fixed width because
  -- it is a hash, ascii because it is hex.
  ip_hash      CHAR(64) CHARACTER SET ascii NULL,
  -- Truncated by the application. Useful for telling a browser from a script,
  -- useless for anything else.
  user_agent   VARCHAR(255) NULL,

  status       ENUM('new', 'read', 'answered', 'spam') NOT NULL DEFAULT 'new',
  -- Whatever the operator wants to write next to a message. Nothing in the
  -- application reads it.
  notes        TEXT NULL,

  created_at   DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at   DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  -- The inbox view: newest first, and newest first within a status.
  KEY ix_contact_created (created_at),
  KEY ix_contact_status_created (status, created_at),
  -- The rate limit asks "how many from this hash since that time", which is
  -- exactly this index.
  KEY ix_contact_ip_created (ip_hash, created_at),
  KEY ix_contact_user (user_id),

  -- Belt and braces against a caller that skipped validation. The service
  -- checks all three before it inserts; this is what makes it true anyway.
  CONSTRAINT ck_contact_name CHECK (CHAR_LENGTH(TRIM(name)) >= 1),
  CONSTRAINT ck_contact_email CHECK (email LIKE '%_@_%.__%'),
  CONSTRAINT ck_contact_message CHECK (CHAR_LENGTH(TRIM(message)) >= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Messages sent from the contact page. Read by a person, not by the application.';

-- ---------------------------------------------------------------------------
-- updated_at by trigger, not by ON UPDATE CURRENT_TIMESTAMP - the convention
-- every table in this schema follows, and migration 0002 explains why:
-- CURRENT_TIMESTAMP returns the session time zone, so a client connected in a
-- non-UTC zone would write local time into a UTC column. UTC_TIMESTAMP does
-- not have that problem, and only a trigger can call it on update.
--
-- It matters here because this is the one table a person edits by hand. Moving
-- a message from 'new' to 'answered' in phpMyAdmin should record when, and
-- phpMyAdmin's session is whatever time zone the server was configured with.
-- ---------------------------------------------------------------------------
-- Dropped first so the file can be imported twice.
--
-- CREATE TABLE IF NOT EXISTS makes the table idempotent; CREATE TRIGGER has no
-- such clause, so without this line a second import of this file stops with
-- "Trigger already exists". scripts/migrate.sh applies each migration once and
-- would never meet that, but this one is handed to a person to import in
-- phpMyAdmin, and a person can import a file twice.
DROP TRIGGER IF EXISTS trg_contact_messages_touch;

DELIMITER $$
CREATE TRIGGER trg_contact_messages_touch
  BEFORE UPDATE ON support_contact_messages FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP(3);
END$$
DELIMITER ;
