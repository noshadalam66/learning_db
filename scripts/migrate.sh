#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Applies every migration in migrations/ that has not run yet, in filename
# order. Applied files are recorded in platform_schema_migrations with a
# checksum, so re-running is a no-op and editing an applied file is refused.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

# The database itself is not created here. On shared hosting you cannot issue
# CREATE DATABASE at all, so it is made in the control panel and named in
# MYSQL_DATABASE; scripts/reset.sh creates it for local development.
if ! mysql_run -e "SELECT 1" >/dev/null 2>&1; then
  echo "ERROR: cannot connect to database '${MYSQL_DATABASE}'." >&2
  echo "       Create it first (scripts/reset.sh does, locally) or set" >&2
  echo "       MYSQL_DATABASE to the name your host gave you." >&2
  exit 1
fi

# The ledger lives in the first migration, so bootstrap just enough to query it.
mysql_run <<'SQL'
CREATE TABLE IF NOT EXISTS platform_schema_migrations (
  filename   VARCHAR(255) CHARACTER SET ascii NOT NULL PRIMARY KEY,
  checksum   CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  applied_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3))
) ENGINE=InnoDB;
SQL

applied=0
for file in migrations/*.sql; do
  name="$(basename "$file")"
  sum="$(sha256sum "$file" | cut -d' ' -f1)"

  recorded="$(mysql_value -e \
    "SELECT checksum FROM platform_schema_migrations WHERE filename = '${name}'")"

  if [ -n "$recorded" ]; then
    if [ "$recorded" != "$sum" ]; then
      echo "ERROR: ${name} already applied but its contents changed." >&2
      echo "       Migrations are immutable once applied - add a new file instead." >&2
      exit 1
    fi
    echo "  skip  ${name}"
    continue
  fi

  echo "  apply ${name}"
  # MySQL has no transactional DDL: a migration that fails half way leaves the
  # statements before the failure applied. Keep each file small enough that
  # re-running by hand after a fix is realistic.
  mysql_run < "$file"
  mysql_run -e "INSERT INTO platform_schema_migrations (filename, checksum)
                VALUES ('${name}', '${sum}')"
  applied=$((applied + 1))
done

echo "Done. ${applied} migration(s) applied."
