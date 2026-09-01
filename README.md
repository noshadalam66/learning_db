# learning_db

MySQL schema for the learning platform: course information, lesson structure,
user progress, article bodies and video URLs.

**New here?** Start with [`docs/ERD.md`](docs/ERD.md) — the diagrams explain the
shape faster than the DDL does. There is a
[visual version](https://claude.ai/code/artifact/9c966486-1cd3-48e3-b168-d8465097a467)
too, and a copy ships as [`docs/erd.html`](docs/erd.html).

One of three repositories:

| Repo | What it is |
|---|---|
| **learning_db** | This repo. Migrations, seed data and the schema documentation. |
| [learning_apis](https://github.com/noshadalam66/learning_apis) | Seven Node.js microservices plus a gateway, each in a three-layer architecture. |
| [learning_website](https://github.com/noshadalam66/learning_website) | The PHP front end that consumes the gateway. |

## Quick start

Requires **MySQL 8.0.16 or newer** — earlier versions parse `CHECK` constraints
and silently ignore them, which would make a third of this schema decorative.

```bash
cp .env.example .env          # then edit the password
docker compose up -d          # or point .env at any MySQL 8.0.16+
./scripts/migrate.sh          # create the databases and apply migrations
./scripts/seed.sh             # load the demo catalogue
./scripts/verify.sh           # assert it all came out right
```

To start over: `./scripts/reset.sh` drops every database and rebuilds them.
`./scripts/console.sh` opens a shell with the right charset and time zone.

## What is in here

```
migrations/   Numbered, immutable SQL. Applied in filename order.
seeds/        Idempotent demo data: 5 users, 3 courses, 16 lessons, 3 quizzes.
scripts/      migrate / seed / reset / verify / console.
tests/        verify.sql - assertions that run against a live database.
docs/         ERD.md (diagrams), SCHEMA.md (reference), DECISIONS.md (why).
```

## Eight databases, one per service

MySQL has no schemas-inside-a-database — a schema *is* a database — so the
per-service split is eight databases on one server. Each service is the only
writer to its own; cross-service reads go through the views in `platform`.

| Database | Service | Holds |
|---|---|---|
| `identity` | User | Accounts, password hashes, roles, refresh tokens |
| `catalog` | Course | Courses, modules, lessons, categories, reviews |
| `content` | Content | Article bodies, video URL metadata, attachments |
| `progress` | Progress | Enrolments, per-lesson progress, certificates |
| `assessment` | Quiz | Quizzes, questions, attempts, grading |
| `search` | Search | Denormalised search documents, query log |
| `analytics` | Analytics | Behaviour events (partitioned), daily rollups |
| `platform` | — | Cross-service read views and the migration ledger |

All 21 foreign keys live **inside** a single database. Nothing crosses a service
boundary — not because MySQL cannot (InnoDB supports cross-database foreign
keys) but because a constraint across a boundary means those two services can
never be moved onto separate servers.

## The four things the brief asked for

**Course info** — `catalog.courses`, with category, instructor, level, pricing,
learning outcomes and requirements.

**Lesson structure** — `catalog.courses` → `catalog.modules` →
`catalog.lessons`, each ordered by an explicit `position`. Because MySQL has no
deferrable constraints, reordering goes through
`catalog.reorder_lessons()`, which stages positions in the negative range first.

**User progress** — `progress.enrolments` for the course-level rollup and
`progress.lesson_progress` for the detail, including `last_position_seconds` so
the video player resumes where the learner stopped.

**Video URLs, not videos** — `content.lesson_videos` stores a URL, a provider,
an asset id, an HLS manifest, a thumbnail, captions and a transcript. No media
is stored in the database, and `tests/verify.sql` fails the build if a `BLOB`,
`BINARY` or `VARBINARY` column ever appears in `content` or `catalog`.

## Articles

Stored in `content.articles` as **Markdown or HTML**, with the format on the
row. The read path always serves the rendered `body_html`, so consumers never
branch on format — and because `body_html` is a *cache* that may be NULL, the
Content Service renders from `body` when it is empty. Every edit snapshots the
old body into `content.article_revisions`.

A headless CMS is supported as an alternative source rather than a different
schema: rows carrying `external_source` / `external_id` were synced from a CMS
and are read-only locally.

## Demo accounts

All seeded accounts use the password `Password123!`. Development only.

| E-mail | Role |
|---|---|
| `admin@learning.test` | admin, instructor |
| `grace@learning.test` | instructor |
| `kenji@learning.test` | instructor |
| `sam@learning.test` | student, part way through two courses |
| `lena@learning.test` | student |

## Migrations

Applied in filename order, recorded in `platform.schema_migrations` with a
checksum. **A migration that has run is immutable** — the runner refuses to
continue if an applied file changed. Add a new file instead.

MySQL has **no transactional DDL**, so a migration that fails half way leaves
the statements before the failure applied. Each file is kept small enough that
re-running it by hand after a fix is realistic.

```
0001_databases_and_conventions.sql   the eight databases, and the id/timestamp conventions
0002_identity.sql                    users, roles, refresh and verification tokens
0003_catalog.sql                     categories, courses, tags, modules, lessons, reviews
0004_content.sql                     video URL metadata, articles, revisions, attachments
0005_progress.sql                    enrolments, lesson progress, notes, certificates
0006_assessment.sql                  quizzes, questions, options, attempts, grade_attempt()
0007_search.sql                      FULLTEXT documents, levenshtein(), reindex_all()
0008_analytics.sql                   partitioned event stream, daily rollups
0009_views_and_grants.sql            cross-service views, reorder_lessons(), service accounts
```

## Verification

`./scripts/verify.sh` runs `tests/verify.sql` against a live database rather
than inspecting files. It checks that every database and table exists, that all
uuid columns are `ascii` (a mismatch silently breaks foreign keys), that seed
data landed, that videos are URLs with no binary column anywhere, that both
article formats are present, that the denormalised counters match their detail
rows, that grading produces exactly 5 of 7 points on the seeded attempt, that
search weighting ranks a title match first and the fuzzy fallback works, that
analytics events reached a real monthly partition, and that five specific bad
rows are actually rejected.

It exits non-zero on the first failure, so CI can call it directly. The
constraint checks are written so that removing a constraint makes the suite
fail — verified by doing exactly that.

## Connecting from the services

The Node services in `learning_apis` read `DATABASE_URL`:

```
DATABASE_URL=mysql://learning:yourpassword@127.0.0.1:3306
```

Note there is no database in the path. A service connects with **no default
database** and fully-qualifies every table, because it also reads the shared
views in `platform`.

Migration `0009` creates an account per service (`svc_user`, `svc_course`, …)
with write access to its own database only. They are created locked and without
a password; unlock and set one in your own environment if you want the server to
enforce the service boundary rather than trusting the application to.

## Further reading

- [`docs/ERD.md`](docs/ERD.md) — the diagrams. Start here.
- [`docs/SCHEMA.md`](docs/SCHEMA.md) — table-by-table reference, the conventions,
  the denormalised columns, and the four places MySQL needed a different
  approach.
- [`docs/DECISIONS.md`](docs/DECISIONS.md) — why seven databases, what dropping
  cross-service foreign keys really costs, and what is deliberately missing.
