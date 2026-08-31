#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Loads the demo dataset. Every seed file is idempotent (ON CONFLICT DO
# NOTHING / DO UPDATE), so this is safe to re-run.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
[ -f .env ] && set -a && . ./.env && set +a

for file in seeds/*.sql; do
  echo "  seed  $(basename "$file")"
  psql --no-psqlrc --quiet --set ON_ERROR_STOP=1 --file "$file"
done

echo "Seed data loaded."
