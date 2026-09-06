-- ===========================================================================
-- 0002 : identity  --  owned by the User Service
-- Login, profile and roles.
-- ===========================================================================

CREATE TABLE identity_users (
  id                CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- The default utf8mb4_0900_ai_ci collation is case-insensitive, so the
  -- unique index below makes Ada@x.test and ada@x.test the same account.
  email             VARCHAR(320) NOT NULL,
  -- bcrypt/argon2 digest. NULL means the account is SSO-only.
  password_hash     VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NULL,
  full_name         VARCHAR(150) NOT NULL,
  headline          VARCHAR(200) NULL,
  bio               TEXT NULL,
  avatar_url        VARCHAR(2000) NULL,
  locale            VARCHAR(10) NOT NULL DEFAULT 'en',
  timezone          VARCHAR(64) NOT NULL DEFAULT 'UTC',
  status            ENUM('pending','active','suspended','deleted') NOT NULL DEFAULT 'pending',
  email_verified_at DATETIME(3) NULL,
  last_login_at     DATETIME(3) NULL,
  created_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY ix_users_status (status),
  KEY ix_users_created (created_at DESC),

  CONSTRAINT ck_users_name_not_blank CHECK (TRIM(full_name) <> ''),
  CONSTRAINT ck_users_avatar_is_http
    CHECK (avatar_url IS NULL OR REGEXP_LIKE(avatar_url, '^https?://'))
) ENGINE=InnoDB COMMENT='One row per human account.';

CREATE TABLE identity_roles (
  id          SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name        VARCHAR(50) NOT NULL,
  description VARCHAR(255) NOT NULL DEFAULT '',

  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_name (name)
) ENGINE=InnoDB;

CREATE TABLE identity_user_roles (
  user_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  role_id    SMALLINT UNSIGNED NOT NULL,
  granted_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  granted_by CHAR(36) CHARACTER SET ascii NULL,

  PRIMARY KEY (user_id, role_id),
  KEY ix_user_roles_role (role_id),
  KEY ix_user_roles_granted_by (granted_by),

  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id)
    REFERENCES identity_users (id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id)
    REFERENCES identity_roles (id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_granted_by FOREIGN KEY (granted_by)
    REFERENCES identity_users (id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Refresh tokens. Only the SHA-256 digest is stored, so a database leak does
-- not hand an attacker usable sessions. ascii_bin so the comparison is exact.
-- ---------------------------------------------------------------------------
CREATE TABLE identity_refresh_tokens (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  user_id    CHAR(36) CHARACTER SET ascii NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  user_agent VARCHAR(500) NULL,
  -- VARBINARY(16) holds both IPv4 and IPv6 via INET6_ATON(), which is MySQL's
  -- equivalent of PostgreSQL's inet type.
  ip_address VARBINARY(16) NULL,
  issued_at  DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  expires_at DATETIME(3) NOT NULL,
  revoked_at DATETIME(3) NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_refresh_token_hash (token_hash),
  KEY ix_refresh_user (user_id),
  KEY ix_refresh_live (expires_at, revoked_at),

  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id)
    REFERENCES identity_users (id) ON DELETE CASCADE,
  CONSTRAINT ck_refresh_expiry_after_issue CHECK (expires_at > issued_at)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Single-use tokens for "verify your e-mail" and "reset your password".
-- ---------------------------------------------------------------------------
CREATE TABLE identity_verification_tokens (
  id          CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  user_id     CHAR(36) CHARACTER SET ascii NOT NULL,
  purpose     ENUM('email_verify','password_reset') NOT NULL,
  token_hash  CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  expires_at  DATETIME(3) NOT NULL,
  consumed_at DATETIME(3) NULL,
  created_at  DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_verification_token_hash (token_hash),
  KEY ix_verification_user_purpose (user_id, purpose, consumed_at),

  CONSTRAINT fk_verification_user FOREIGN KEY (user_id)
    REFERENCES identity_users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- updated_at is maintained by a trigger, not by ON UPDATE CURRENT_TIMESTAMP.
-- CURRENT_TIMESTAMP returns the session time zone, so a client connected in
-- a non-UTC zone would write local time into a UTC column. UTC_TIMESTAMP does
-- not have that problem, and only a trigger can call it on update.
-- ---------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_users_touch
  BEFORE UPDATE ON identity_users FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP(3);
END$$
DELIMITER ;
