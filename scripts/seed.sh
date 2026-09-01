#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Loads the demo dataset. Every seed file is idempotent, so this is safe to
# re-run.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

for file in seeds/*.sql; do
  echo "  seed  $(basename "$file")"
  mysql_run < "$file" > /dev/null
done

echo "Seed data loaded."
