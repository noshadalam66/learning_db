#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Drops and recreates every database, then migrates and seeds from scratch.
# Development only - it destroys all data without asking twice.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

DATABASES=(identity catalog content progress assessment search analytics platform)

if [ "${ALLOW_RESET:-}" != "yes" ]; then
  echo "This drops: ${DATABASES[*]}"
  read -r -p "Continue? [y/N] " reply
  [ "$reply" = "y" ] || { echo "Aborted."; exit 1; }
fi

for db in "${DATABASES[@]}"; do
  # Backticks because `search` is otherwise ambiguous in some MySQL versions.
  mysql_run -e "DROP DATABASE IF EXISTS \`${db}\`"
done

./scripts/migrate.sh
./scripts/seed.sh
