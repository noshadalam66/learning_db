# Design decisions

Short notes on the choices that are not obvious from reading the DDL, including
the ones with real costs.

## One database, with the service boundary in the table name

MySQL has no schemas-inside-a-database: a schema *is* a database. The
per-service split was originally seven databases on one server plus `platform`
for the shared views, with a MySQL account per service and grants that stopped
a service writing outside its own.

Everything now lives in **one** database, and the boundary is a prefix on the
table name: `catalog_courses`, `identity_users`, `assessment_quizzes`.

### Why it changed

Shared hosting. On cPanel every database name is prefixed with the account
name, so `catalog` is really `noshadal_catalog`. Eight databases means eight
names to configure, eight sets of grants to click through by hand on every
rebuild, and eight entries against a plan's database quota. Worse, the name is
not knowable at development time, so any statement that qualifies its tables
has to be rewritten at deploy or templated — for ~200 statements.

With one database the name appears once, in the connection string, and every
statement is written unqualified. Moving the app to a host that calls the
database something else is a configuration change and nothing more.

### What it costs, honestly

**Per-service GRANTs no longer come for free.** A grant covers a database or a
single named table — MySQL accepts no wildcard on the table part. So the same
isolation now costs one grant per table, which is what
`migrations/optional/service_users.sql` is. It is optional because it cannot be
applied on shared hosting at all: cPanel does not expose `CREATE USER` or
`GRANT` over SQL.

**The server no longer enforces the boundary by default.** With one account and
one database, nothing stops the Quiz Service writing to `identity_users` except
the code not doing it. That was already close to true — every service connected
as the same user through one pool — but it was at least *possible* to enforce
before, and now it takes deliberate work.

**A dropped database takes everything.** `DROP DATABASE` used to cost one
service its data. It now costs all of them.

### What did not change

Nothing about the shape of the data: 32 tables, 21 foreign keys, 40 check
constraints, 3 views, 11 routines and 13 triggers, all identical. No table
name collided, and no constraint name collided, which is what made the move
mechanical rather than a redesign.

Each service is still the only writer to its own tables, cross-service reads
still go through the `v_` views or over HTTP, and no service is written against
another's tables. Moving a service onto its own database or its own server
later is still a deployment change rather than a schema rewrite — the rule that
made that true was never the database boundary, it was the discipline about who
writes what.

## Running on MariaDB as well as MySQL 8

The schema was written against MySQL 8 and CI still runs it there, but the
deployment target turned out to be MariaDB 11.4 on shared hosting. Four things
MySQL accepts were rejected outright, and each is a genuine difference rather
than a version lag.

**`REGEXP_LIKE()` does not exist in MariaDB.** It has `REGEXP_INSTR`,
`REGEXP_REPLACE` and `REGEXP_SUBSTR`, but not this one, so MariaDB parses it as
a call to a stored function - and stored functions are banned inside a CHECK
constraint. The eight URL and slug constraints now use the `REGEXP` operator,
which both engines have and both allow in a CHECK.

**MariaDB will not index a generated column whose expression reads a column
with an explicit character set.** Every id here is `CHAR(36) CHARACTER SET
ascii`, and `open_attempt_key` was `GENERATED ALWAYS AS (CASE WHEN state =
'in_progress' THEN CONCAT(quiz_id, ':', user_id) END)` with a unique index over
it - the whole point of the column. Making it `PERSISTENT`, converting the
charset, or collating the expression all fail the same way; only dropping the
index makes MariaDB accept it, and the index is the rule.

It is now a plain column maintained by two triggers. The guarantee is unchanged
and still the server's: a unique index, not application code, is what makes a
second open attempt impossible. Only the way the value gets there moved.

**`JSON_TABLE` cannot read a column of the outer query in MariaDB.** Grading
compared the correct and selected option sets by unnesting both into sorted
JSON arrays. It now counts instead: the answer is right when it names as many
options as there are correct ones and every correct one appears among them.
Duplicates make the first test pass and the second fail, so they are still
wrong. The search indexer had the same problem flattening `learning_outcomes`,
and strips the JSON punctuation instead - that column feeds a FULLTEXT index,
where only the words matter.

**`utf8mb4_0900_ai_ci` is MySQL-only.** Nothing in the migrations names a
collation, so this only ever mattered for the generated dump, which now carries
`utf8mb4_general_ci` - present on both.

What this does not mean is that the two are interchangeable. It means this
schema installs on both, which is checked: CI runs MySQL 8, and the MariaDB
side was verified by installing MariaDB and running the full suite against it.

## No foreign keys across service boundaries

`catalog_courses.instructor_id` holds a user id with no constraint behind it.

Worth being clear that this is a **choice, not a MySQL limitation**: InnoDB
supports foreign keys across databases on the same server, and one here would
work today. It is left out because a foreign key across a service boundary means
those two services can never be moved onto separate servers — the exact
flexibility the split was bought for.

It is still a real loss: nothing stops a bad deploy writing a course whose
instructor does not exist.

The mitigations actually in place:

1. The Course Service validates the instructor through the User Service before
   insert.
2. `tests/verify.sql` checks the integrity that constraints no longer can.
3. Every such column carries a `-- deliberately not a foreign key` comment in
   the migration, and `docs/ERD.md` lists all of them in one table.

## Videos are URLs

Storing media in a relational database is a well-known way to make backups
enormous and restores slow — and MySQL makes it especially tempting, since
`LONGBLOB` will hold 4GB without complaint. `content_lesson_videos` holds a URL,
a provider, an asset id and metadata; the bytes live on YouTube, Vimeo, Mux,
Cloudflare Stream, Bunny or S3 behind a CDN.

The schema stores `hls_url` separately from `video_url` because adaptive
streaming and a canonical watch page are different things, and a player needs
the former while a share link needs the latter.

`tests/verify.sql` asserts no `BLOB`, `BINARY` or `VARBINARY` column exists in
`content` or `catalog`, so this stays true under future edits.

## Articles in the database, with a CMS escape hatch

The brief allowed either a database or a headless CMS. This schema does the
first and leaves a documented door to the second: `external_source` and
`external_id` on `content_articles` identify rows synced in from a CMS, and the
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

`assessment_grade_attempt()` is a MySQL stored procedure rather than JavaScript
in the Quiz Service. Two reasons: correct answers never need to leave the database to be
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

`analytics_events` is the only table expected to reach hundreds of millions of
rows. Monthly range partitions mean old data is dropped or archived with a
metadata operation instead of a `DELETE` that runs for hours and leaves the
table bloated.

MySQL has no `DEFAULT` partition, so the safety net is a `MAXVALUE` catch-all
that `ensure_month_partition()` splits with `REORGANIZE PARTITION`. It is a
safety net, not a destination — rows landing there mean partition maintenance
has stopped running, and the verify suite treats any row in it as a failure.

Two MySQL constraints shaped this table: the partitioning column must appear in
every unique key (hence the composite primary key), and partition boundaries
must be strictly increasing (hence a procedure that can only append months, and
fills gaps rather than leaving holes it could not patch later).

## Migrations are immutable, and not atomic

`scripts/migrate.sh` records a SHA-256 of each applied file and refuses to run
if a file that already ran has changed. Editing an applied migration produces a
database that matches nobody else's. Add a new file instead.

The part MySQL makes worse: **there is no transactional DDL.** PostgreSQL can
wrap a migration in a transaction and roll the whole thing back on failure;
MySQL commits each DDL statement as it goes, so a migration that fails half way
leaves everything before the failure applied. The mitigation is keeping each
file small enough that re-running it by hand after a fix is realistic — not a
solution, just the honest best available.

## What is deliberately missing

- **Payments.** `price_cents` exists on a course but nothing charges anyone.
  Payment data has compliance requirements this schema does not attempt to meet.
- **Soft deletes.** There is no `deleted_at`. `identity_users.status` has a
  `deleted` value for account lifecycle, but rows are otherwise really deleted.
  Add soft deletes when there is a product requirement, not preemptively.
- **Row-level security.** Authorisation happens in the API layer. MySQL has no
  RLS at all — the nearest equivalent is forcing every read through a definer
  view, which doubles the reading required to understand any query. Not worth it
  here; worth revisiting for a genuinely multi-tenant deployment.
