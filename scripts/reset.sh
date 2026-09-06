#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Drops and recreates the database, then migrates and seeds from scratch.
# Development only - it destroys all data without asking twice.
#
# This is also the only script that issues CREATE DATABASE. Shared hosting does
# not allow that, which is why nothing else depends on it: there the database
# is made in the control panel and named in MYSQL_DATABASE.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

if [ "${ALLOW_RESET:-}" != "yes" ]; then
  echo "This drops the database: ${MYSQL_DATABASE}"
  read -r -p "Continue? [y/N] " reply
  [ "$reply" = "y" ] || { echo "Aborted."; exit 1; }
fi

mysql_server -e "DROP DATABASE IF EXISTS \`${MYSQL_DATABASE}\`"
mysql_server -e "CREATE DATABASE \`${MYSQL_DATABASE}\`
                 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci"

./scripts/migrate.sh
./scripts/seed.sh
