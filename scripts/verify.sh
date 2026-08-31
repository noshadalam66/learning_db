#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Sanity-checks a migrated database: every expected schema and table exists,
# the seed data is present, and the stored procedures actually work.
# Exits non-zero on the first failure, so CI can call it directly.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
[ -f .env ] && set -a && . ./.env && set +a

psql --no-psqlrc --quiet --set ON_ERROR_STOP=1 --file tests/verify.sql
echo "All checks passed."
