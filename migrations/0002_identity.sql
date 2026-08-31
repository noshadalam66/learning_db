-- ===========================================================================
-- 0002 : identity schema  --  owned by the User Service
-- Login, profile and roles.
-- ===========================================================================

BEGIN;

CREATE TABLE identity.users (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email             citext NOT NULL UNIQUE,
  password_hash     text,                       -- NULL when the account is SSO-only
  full_name         text NOT NULL,
  headline          text,
  bio               text,
  avatar_url        text,
  locale            text NOT NULL DEFAULT 'en',
  timezone          text NOT NULL DEFAULT 'UTC',
  status            public.account_status NOT NULL DEFAULT 'pending',
  email_verified_at timestamptz,
  last_login_at     timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT users_full_name_not_blank CHECK (btrim(full_name) <> ''),
  CONSTRAINT users_avatar_url_is_http  CHECK (avatar_url IS NULL OR avatar_url ~ '^https?://')
);

COMMENT ON TABLE  identity.users               IS 'One row per human account.';
COMMENT ON COLUMN identity.users.password_hash IS 'bcrypt/argon2 digest. Never store plaintext; NULL means SSO-only login.';

CREATE INDEX users_status_idx     ON identity.users (status);
CREATE INDEX users_created_at_idx ON identity.users (created_at DESC);

CREATE TRIGGER users_touch
  BEFORE UPDATE ON identity.users
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Roles: student / instructor / admin, extensible without a migration.
-- ---------------------------------------------------------------------------
CREATE TABLE identity.roles (
  id          smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT ''
);

CREATE TABLE identity.user_roles (
  user_id     uuid     NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
  role_id     smallint NOT NULL REFERENCES identity.roles (id) ON DELETE CASCADE,
  granted_at  timestamptz NOT NULL DEFAULT now(),
  granted_by  uuid REFERENCES identity.users (id) ON DELETE SET NULL,
  PRIMARY KEY (user_id, role_id)
);

CREATE INDEX user_roles_role_idx ON identity.user_roles (role_id);

-- ---------------------------------------------------------------------------
-- Refresh tokens. Only the SHA-256 digest is stored, so a database leak does
-- not hand an attacker usable sessions.
-- ---------------------------------------------------------------------------
CREATE TABLE identity.refresh_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
  token_hash  text NOT NULL UNIQUE,
  user_agent  text,
  ip_address  inet,
  issued_at   timestamptz NOT NULL DEFAULT now(),
  expires_at  timestamptz NOT NULL,
  revoked_at  timestamptz,

  CONSTRAINT refresh_tokens_expiry_after_issue CHECK (expires_at > issued_at)
);

CREATE INDEX refresh_tokens_user_idx    ON identity.refresh_tokens (user_id);
CREATE INDEX refresh_tokens_expiry_idx  ON identity.refresh_tokens (expires_at)
  WHERE revoked_at IS NULL;

-- ---------------------------------------------------------------------------
-- Single-use tokens for "verify your e-mail" and "reset your password".
-- ---------------------------------------------------------------------------
CREATE TABLE identity.verification_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
  purpose     text NOT NULL CHECK (purpose IN ('email_verify', 'password_reset')),
  token_hash  text NOT NULL UNIQUE,
  expires_at  timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX verification_tokens_user_purpose_idx
  ON identity.verification_tokens (user_id, purpose)
  WHERE consumed_at IS NULL;

COMMIT;
