#!/usr/bin/env bash
# An interactive MySQL shell with the right character set and time zone.
set -euo pipefail
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
mysql_run "$@"
