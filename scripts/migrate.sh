#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Applies every migration in migrations/ that has not run yet, in filename
# order. Applied files are recorded in platform.schema_migrations with a
# checksum, so re-running is a no-op and editing an applied file is refused.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

# The ledger lives in the first migration, so bootstrap just enough to query it.
mysql_run <<'SQL'
CREATE DATABASE IF NOT EXISTS platform
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TABLE IF NOT EXISTS platform.schema_migrations (
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
    "SELECT checksum FROM platform.schema_migrations WHERE filename = '${name}'")"

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
  mysql_run -e "INSERT INTO platform.schema_migrations (filename, checksum)
                VALUES ('${name}', '${sum}')"
  applied=$((applied + 1))
done

echo "Done. ${applied} migration(s) applied."
