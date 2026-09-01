#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Sanity-checks a migrated database: every expected database and table exists,
# the seed data is present, and the stored procedures actually work.
# Exits non-zero on the first failure, so CI can call it directly.
# ---------------------------------------------------------------------------
set -euo pipefail

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cd "$ROOT"

mysql_run < tests/verify.sql
echo "All checks passed."
