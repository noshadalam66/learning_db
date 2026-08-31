# Design decisions

Short notes on the choices that are not obvious from reading the DDL, including
the ones with real costs.

## One database, seven schemas — not seven databases

A textbook microservice split gives each service its own database. This repo
gives each service its own **schema** inside one database, with a separate
PostgreSQL role per service and grants that stop a service writing outside its
own schema.

What that buys:

- One connection string, one backup, one local `docker compose up`.
- The read views in `public` can join across services cheaply, which is what
  makes the course page a single query instead of five HTTP calls.
- Migrating to genuinely separate databases later is a deployment change, not a
  schema rewrite, because no service is written against another's tables.

What it costs, honestly:

- The isolation is enforced by grants, not by the network. A service with the
  wrong credentials could read another's tables. Separate databases make that
  impossible rather than merely denied.
- Everything shares one connection limit and one vacuum budget. A runaway
  analytics query can starve the login path.

For a learning platform at this size that trade is worth it. For a system where
one service must scale independently — usually analytics first — split that one
out and leave the rest.

## No foreign keys across service boundaries

`catalog.courses.instructor_id` holds a user id with no constraint behind it.
This is the standard microservice trade and it is a real loss: nothing stops a
bad deploy writing a course whose instructor does not exist.

The mitigations actually in place:

1. The Course Service validates the instructor through the User Service before
   insert.
2. `tests/verify.sql` checks the integrity that constraints no longer can.
3. Every such column carries a `COMMENT` naming what it points at, so the
   relationship is discoverable from `\d+` rather than tribal knowledge.

## Videos are URLs

Storing media in a relational database is a well-known way to make backups
enormous and restores slow. `content.lesson_videos` holds a URL, a provider, an
asset id and metadata; the bytes live on YouTube, Vimeo, Mux, Cloudflare Stream,
Bunny or S3 behind a CDN.

The schema stores `hls_url` separately from `video_url` because adaptive
streaming and a canonical watch page are different things, and a player needs
the former while a share link needs the latter.

`tests/verify.sql` asserts no `bytea` or `oid` column exists in `content` or
`catalog`, so this stays true under future edits.

## Articles in the database, with a CMS escape hatch

The brief allowed either a database or a headless CMS. This schema does the
first and leaves a documented door to the second: `external_source` and
`external_id` on `content.articles` identify rows synced in from a CMS, and the
Content Service treats a row with `external_source` set as read-only locally.

That means "which one" becomes a per-article configuration question rather than
an architectural fork.

Both `markdown` and `html` are supported because they come from different
authoring tools, not because one is better. Markdown is what an engineer writes
in a pull request; HTML is what a rich-text editor or a CMS emits. Storing the
source format and serving a rendered `body_html` keeps consumers from caring.

**HTML bodies must be sanitised before they are stored.** The database cannot
do this and does not try. The Content Service sanitises on write; if you add
another writer, it has to as well.

## Grading in the database

`assessment.grade_attempt()` is PL/pgSQL rather than JavaScript in the Quiz
Service. Two reasons: correct answers never need to leave the database to be
compared, and a regrade triggered by a script, a migration or a different
service applies exactly the same rules.

The cost is that the marking scheme is now in a migration, so changing it means
a deployment rather than a config flag. Given that changing a marking scheme
retroactively alters people's scores, making it a deliberate deployment is
arguably correct.

## Denormalised counters instead of counting on read

`courses.lesson_count`, `enrolments.progress_percent` and friends are caches of
things that could be computed with a `count(*)`. They exist because the course
listing page would otherwise run a correlated subquery per card.

The discipline that keeps them honest: exactly one function refreshes each one,
the owning service calls it after every write that could invalidate it, and the
verify suite fails if any of them drift. A denormalised column with three
different writers is how these go wrong.

## Partitioned analytics events

`analytics.events` is the only table expected to reach hundreds of millions of
rows. Monthly range partitions mean old data is detached and archived with a
metadata operation instead of a `DELETE` that runs for hours and leaves bloat.

The `DEFAULT` partition is a safety net, not a destination — rows landing there
mean `ensure_month_partition()` has stopped running, and the verify suite treats
any row in it as a failure.

## Migrations are immutable

`scripts/migrate.sh` records a SHA-256 of each applied file and refuses to run
if a file that already ran has changed. Editing an applied migration produces a
database that matches nobody else's. Add a new file instead.

## What is deliberately missing

- **Payments.** `price_cents` exists on a course but nothing charges anyone.
  Payment data has compliance requirements this schema does not attempt to meet.
- **Soft deletes.** There is no `deleted_at`. `identity.users.status` has a
  `deleted` value for account lifecycle, but rows are otherwise really deleted.
  Add soft deletes when there is a product requirement, not preemptively.
- **Row-level security.** Authorisation happens in the API layer. RLS would be
  the stronger option for a multi-tenant deployment and is a reasonable
  extension; it is not here because it would double the reading required to
  understand any query.
