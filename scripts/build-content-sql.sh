#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Builds dist/content.sql - seed files only, for adding courses to a database
# that is already live and already has learners in it.
#
# This is the file to import when a new course has been written and the site
# needs it. build-install-sql.sh is for the other occasion: the first import
# into an empty database. Importing that one over a live database would
# re-run every migration and re-seed everything, which is not what you want
# when people have enrolments and quiz attempts in there.
#
#   ./scripts/build-content-sql.sh                 every content seed
#   ./scripts/build-content-sql.sh 0020 0029       just those, inclusive
#
# Either is safe against a live database, and that is not a promise made
# lightly - it is what makes this file importable at all:
#
#   * Every seed inserts with ON DUPLICATE KEY UPDATE, so re-importing one
#     already applied rewrites the same rows rather than failing on a
#     duplicate key or creating a second copy.
#   * No seed contains DROP, TRUNCATE or DELETE FROM. The check below refuses
#     to write the file if one ever does, because this script's whole promise
#     is that importing it cannot lose anything.
#   * FIXTURE SEEDS ARE LEFT OUT. Some seeds exist to give a development
#     database people to look at: demo users, their enrolments, their progress,
#     a graded quiz attempt, a month of analytics events. None of that belongs
#     in a production database, and the first version of this script would have
#     carried all of it there - it excluded 0019 only by accident, because 0019
#     happened to contain a DELETE, while 0001 and 0005 went straight through.
#     They are now recognised by the tables they write to, and skipped.
#   * Each course seed ends by calling catalog_refresh_course_rollup and
#     search_reindex_all, so the counts on the catalogue page and the search
#     index are correct the moment the import finishes. No extra step.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FROM="${1:-}"
TO="${2:-}"

if [ -n "$FROM" ] && [ -z "$TO" ]; then
  echo "error: give two numbers or none - ./scripts/build-content-sql.sh 0020 0029" >&2
  exit 1
fi

# Collect the seeds in range. The numeric prefix is the order they must be
# applied in, and it is also how a range is expressed, so it is read straight
# off the filename rather than kept in a list that would drift.
#
# Rows that belong to a person, rather than to a course. A seed that writes any
# of these is a fixture for development, not content, and is skipped.
#
# identity_user_roles is deliberately NOT in this list: 0006 uses it to grant
# the instructor role to the demo author a course is attributed to, matched by
# e-mail, so on a database without her it inserts nothing at all. Excluding
# every table whose name starts with identity_ would have thrown out the HTML
# course with her.
FIXTURE_TABLES='identity_users|progress_[a-z_]+|assessment_quiz_attempts|assessment_attempt_answers|analytics_[a-z_]+'

is_fixture() {
  sed 's/--.*//' "$1" \
    | grep -qE "^[[:space:]]*(INSERT INTO|REPLACE INTO|UPDATE|DELETE FROM)[[:space:]]+($FIXTURE_TABLES)\b"
}

files=()
skipped=""
for file in seeds/*.sql; do
  number="$(basename "$file" | cut -d_ -f1)"
  if [ -n "$FROM" ]; then
    # String comparison is safe: every prefix is four digits, zero-padded.
    [[ "$number" < "$FROM" || "$number" > "$TO" ]] && continue
  fi
  if is_fixture "$file"; then
    skipped="$skipped $(basename "$file")"
    continue
  fi
  files+=("$file")
done

if [ -n "$skipped" ]; then
  echo "skipping demo fixtures, which do not belong in a live database:" >&2
  for name in $skipped; do echo "  $name" >&2; done
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "error: no content seeds matched${FROM:+ $FROM..$TO}" >&2
  [ -n "$skipped" ] && echo "Everything in that range is a demo fixture." >&2
  exit 1
fi

# The promise at the top of this file, enforced. A seed that dropped or
# emptied a table would make importing this over a live database destructive,
# and the person importing it has no way to know that by looking.
destructive=""
for file in "${files[@]}"; do
  # A statement, not the word. Comments are stripped first, and the keyword has
  # to open a line in upper case - which is how every statement in these seeds
  # is written, and is not how prose inside a string literal reads. Without
  # that last part the Rust course trips this on its own lessons: it teaches
  # Drop, and says so about fifteen times.
  if sed 's/--.*//' "$file" | grep -qE '^[[:space:]]*(DROP|TRUNCATE|DELETE FROM)\b'; then
    destructive="$destructive $(basename "$file")"
  fi
done

if [ -n "$destructive" ]; then
  echo "error: destructive statement in:$destructive" >&2
  echo "This file is imported over live databases. Fix the seed, or import" >&2
  echo "it by hand knowing what it does." >&2
  exit 1
fi

OUT="dist/content.sql"
mkdir -p dist

{
  cat <<HEADER
-- ===========================================================================
-- learning_db : content only
--
-- $(printf '%s' "${#files[@]}") seed file(s): $(basename "${files[0]}") .. $(basename "${files[${#files[@]}-1]}")
--
-- No course count here on purpose: the early seeds insert several courses
-- in one statement, so counting them from the outside gets it wrong - it
-- said 13 when there were 15. The seed list below names the courses, which
-- is what you wanted to know anyway.
--
-- Generated by scripts/build-content-sql.sh - do not edit this file, edit the
-- seeds and regenerate.
--
-- WHAT THIS IS FOR
--
--   Adding courses to a database that is already running the site. It
--   contains no schema: no CREATE TABLE, no migration, and nothing that
--   drops, truncates or deletes. Every insert is ON DUPLICATE KEY UPDATE, so
--   importing it twice changes nothing the second time.
--
--   Enrolments, quiz attempts and progress are untouched.
--
--   For the FIRST import into an empty database, use install.sql instead -
--   this file assumes the tables already exist.
--
-- HOW TO IMPORT
--
--   phpMyAdmin : select the database, Import, choose this file, Go.
--   SSH        : mysql -u USER -p DATABASE < content.sql
--
--   If phpMyAdmin rejects it for size, build a narrower range:
--   ./scripts/build-content-sql.sh 0020 0023
--
-- AFTERWARDS
--
--   Nothing. The course rollups and the search index are rebuilt by the last
--   statements of each seed, so the catalogue counts and search are correct
--   as soon as the import finishes.
-- ===========================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET sql_mode = 'STRICT_ALL_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
HEADER

  for file in "${files[@]}"; do
    printf '\n-- ###########################################################################\n'
    printf -- '-- seed: %s\n' "$(basename "$file")"
    printf -- '-- ###########################################################################\n\n'
    cat "$file"
  done
} > "$OUT"

lines=$(wc -l < "$OUT")
bytes=$(wc -c < "$OUT")
printf 'wrote %s - %s seed(s), %s lines, %.1f KB\n' \
  "$OUT" "${#files[@]}" "$lines" "$(echo "$bytes" | awk '{print $1/1024}')"
