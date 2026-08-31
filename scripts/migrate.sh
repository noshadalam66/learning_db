#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Applies every migration in migrations/ that has not run yet, in filename
# order, each inside its own transaction. Applied files are recorded in
# public.schema_migrations so re-running the script is a no-op.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
[ -f .env ] && set -a && . ./.env && set +a

PSQL=(psql --no-psqlrc --quiet --set ON_ERROR_STOP=1)

"${PSQL[@]}" <<'SQL'
CREATE TABLE IF NOT EXISTS public.schema_migrations (
  filename    text PRIMARY KEY,
  checksum    text NOT NULL,
  applied_at  timestamptz NOT NULL DEFAULT now()
);
SQL

applied=0
for file in migrations/*.sql; do
  name="$(basename "$file")"
  sum="$(sha256sum "$file" | cut -d' ' -f1)"

  recorded="$("${PSQL[@]}" --tuples-only --no-align \
    -c "SELECT checksum FROM public.schema_migrations WHERE filename = '${name}'")"

  if [ -n "$recorded" ]; then
    if [ "$recorded" != "$sum" ]; then
      echo "ERROR: ${name} already applied but its contents changed." >&2
      echo "       Migrations are immutable once applied - add a new file instead." >&2
      exit 1
    fi
    echo "  skip  ${name}"
    continue
  fi

  echo "  apply ${name}"
  "${PSQL[@]}" --file "$file"
  "${PSQL[@]}" -c "INSERT INTO public.schema_migrations (filename, checksum) VALUES ('${name}', '${sum}')" >/dev/null
  applied=$((applied + 1))
done

echo "Done. ${applied} migration(s) applied."
