#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Applies migrations/optional/service_users.sql - one locked database account
# per service, granted only the tables that service owns.
#
# Optional, and not applicable on shared hosting, where CREATE USER and GRANT
# are not available over SQL. See the header of the SQL file.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

# The grants have to name the database, and its name is only known here.
sed "s/@DB@/${MYSQL_DATABASE}/g" migrations/optional/service_users.sql | mysql_run

echo "Service accounts created and granted, locked and without passwords."
echo "Set one before use:  ALTER USER 'svc_user'@'%' IDENTIFIED BY '...';"
