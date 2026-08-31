# learning_db

PostgreSQL schema for the learning platform: course information, lesson
structure, user progress, article bodies and video URLs.

It is one of three repositories:

| Repo | What it is |
|---|---|
| **learning_db** | This repo. Migrations, seed data and the schema documentation. |
| [learning_apis](https://github.com/noshadalam66/learning_apis) | Seven Node.js microservices plus a gateway, each in a three-layer architecture. |
| [learning_website](https://github.com/noshadalam66/learning_website) | The PHP front end that consumes the gateway. |

## Quick start

```bash
cp .env.example .env          # then edit the password
docker compose up -d          # or point .env at any PostgreSQL 14+
./scripts/migrate.sh          # apply migrations
./scripts/seed.sh             # load the demo catalogue
./scripts/verify.sh           # assert it all came out right
```

To start over: `./scripts/reset.sh` drops the database and rebuilds it.

## What is in here

```
migrations/   Numbered, immutable SQL. Applied in filename order.
seeds/        Idempotent demo data: 5 users, 3 courses, 16 lessons, 3 quizzes.
scripts/      migrate / seed / reset / verify.
tests/        verify.sql - assertions that run against a live database.
docs/         SCHEMA.md (reference) and DECISIONS.md (why, including the costs).
```

## Seven schemas, one per service

Each microservice owns exactly one schema and is its only writer. Cross-
service reads go through the views in `public`, never by reaching into
another service's tables.

| Schema | Service | Holds |
|---|---|---|
| `identity` | User | Accounts, password hashes, roles, refresh tokens |
| `catalog` | Course | Courses, modules, lessons, categories, reviews |
| `content` | Content | Article bodies, video URL metadata, attachments |
| `progress` | Progress | Enrolments, per-lesson progress, certificates |
| `assessment` | Quiz | Quizzes, questions, attempts, grading |
| `search` | Search | Denormalised search documents, query log |
| `analytics` | Analytics | Behaviour events (partitioned), daily rollups |

## The four things the brief asked for

**Course info** — `catalog.courses`, with category, instructor, level,
pricing, learning outcomes and requirements.

**Lesson structure** — `catalog.courses` → `catalog.modules` →
`catalog.lessons`, each ordered by an explicit `position` whose uniqueness
constraint is deferrable so reordering is a plain `UPDATE`.

**User progress** — `progress.enrolments` for the course-level rollup and
`progress.lesson_progress` for the detail, including
`last_position_seconds` so the video player resumes where the learner
stopped.

**Video URLs, not videos** — `content.lesson_videos` stores a URL, a
provider, an asset id, an HLS manifest, a thumbnail, captions and a
transcript. No media is stored in the database, and `tests/verify.sql`
fails the build if a `bytea` column ever appears in `content` or `catalog`.

## Articles

Stored in `content.articles` as **Markdown or HTML**, with the format on the
row. The read path always serves the rendered `body_html`, so consumers
never branch on format. Every edit snapshots the old body into
`content.article_revisions`.

A headless CMS is supported as an alternative source rather than a different
schema: rows carrying `external_source` / `external_id` were synced from a
CMS and are read-only locally.

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

Applied in filename order, each in its own transaction, recorded in
`public.schema_migrations` with a checksum. **A migration that has run is
immutable** — the runner refuses to continue if an applied file changed.
Add a new file instead.

```
0001_extensions_and_schemas.sql      extensions, the seven schemas, shared enums, touch_updated_at()
0002_identity.sql                    identity: users, roles, refresh and verification tokens
0003_catalog.sql                     catalog: categories, courses, tags, modules, lessons, reviews
0004_content.sql                     content: video URL metadata, articles, revisions, attachments
0005_progress.sql                    progress: enrolments, lesson progress, notes, certificates
0006_assessment.sql                  assessment: quizzes, questions, options, attempts, grade_attempt()
0007_search.sql                      search: weighted tsvector documents, query log, synonyms
0008_analytics.sql                   analytics: partitioned event stream, daily rollups
0009_views_and_roles.sql             cross-service read views, rollup helpers, per-service roles
```

## Verification

`./scripts/verify.sh` runs `tests/verify.sql`, which asserts against a live
database rather than inspecting files. It checks that every schema and table
exists, that seed data landed, that videos are URLs and no binary column has
crept in, that both article formats are present, that the denormalised
counters match their detail rows, that grading produces the expected score,
that search matches both exactly and fuzzily, that analytics events reached a
real monthly partition, and that the CHECK constraints and the partial unique
index actually reject bad rows.

It exits non-zero on the first failure, so CI can call it directly.

## Connecting from the services

The Node services in `learning_apis` read `DATABASE_URL`:

```
DATABASE_URL=postgres://learning:yourpassword@localhost:5432/learning
```

Migration `0009` creates a role per service (`svc_user`, `svc_course`, …)
with write access to its own schema only. Those roles are created `NOLOGIN`;
grant each a password in your own environment if you want the database to
enforce the service boundary rather than trusting the application to.

## Further reading

- [`docs/SCHEMA.md`](docs/SCHEMA.md) — table-by-table reference, the
  denormalised columns and who refreshes them, and the search notes.
- [`docs/DECISIONS.md`](docs/DECISIONS.md) — why one database with seven
  schemas, what dropping cross-service foreign keys really costs, and what
  is deliberately missing.
