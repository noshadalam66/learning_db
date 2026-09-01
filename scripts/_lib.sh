#!/usr/bin/env bash
# Shared helpers. Sourced by the other scripts, not run directly.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
[ -f "$ROOT/.env" ] && set -a && . "$ROOT/.env" && set +a

MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"

# Every connection sets time_zone to UTC. The schema defaults to UTC_TIMESTAMP
# regardless, so forgetting is not corrupting - but NOW() and CURRENT_TIMESTAMP
# in an ad-hoc query would otherwise return the server's local time.
MYSQL_INIT="SET time_zone='+00:00', sql_mode='STRICT_ALL_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'"

mysql_run() {
  # The password goes through MYSQL_PWD rather than --password, so it does not
  # appear in `ps` output and mysql stops warning about it on every call.
  MYSQL_PWD="$MYSQL_PASSWORD" mysql \
    --host="$MYSQL_HOST" --port="$MYSQL_PORT" --user="$MYSQL_USER" \
    --default-character-set=utf8mb4 \
    --init-command="$MYSQL_INIT" \
    "$@"
}

# Same, but tab-separated and without column headers - for scripting.
mysql_value() {
  mysql_run --batch --skip-column-names "$@"
}
