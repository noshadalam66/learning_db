#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Drops and recreates the database, then migrates and seeds it from scratch.
# Development only - it destroys all data without asking twice.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
[ -f .env ] && set -a && . ./.env && set +a

: "${PGDATABASE:?PGDATABASE must be set}"
ADMIN_DB="${ADMIN_DB:-postgres}"

if [ "${ALLOW_RESET:-}" != "yes" ]; then
  read -r -p "Drop and recreate database '${PGDATABASE}'? [y/N] " reply
  [ "$reply" = "y" ] || { echo "Aborted."; exit 1; }
fi

psql --dbname "$ADMIN_DB" --no-psqlrc --quiet --set ON_ERROR_STOP=1 <<SQL
DROP DATABASE IF EXISTS ${PGDATABASE} WITH (FORCE);
CREATE DATABASE ${PGDATABASE};
SQL

./scripts/migrate.sh
./scripts/seed.sh
