# Schema reference

Seven PostgreSQL schemas, one per microservice. A service writes only to its
own schema; anything it needs from another service comes from an HTTP call or
from one of the read views in `public`.

```
identity     User Service       accounts, credentials, roles
catalog      Course Service     courses, modules, lessons, categories, reviews
content      Content Service    article bodies, video URL metadata, attachments
progress     Progress Service   enrolments, per-lesson progress, certificates
assessment   Quiz Service       quizzes, questions, attempts, grading
search       Search Service     denormalised search documents, query log
analytics    Analytics Service  behaviour events, daily rollups
```

## The shape of the data

```
catalog.courses
   └── catalog.modules            (ordered chapters)
         └── catalog.lessons      (ordered, kind = video | article | quiz | assignment)
               ├── content.lesson_videos    1:1  URL + metadata, never the file
               ├── content.articles         1:1  Markdown or HTML body
               ├── content.lesson_attachments  1:N  slides, code, PDFs (URLs)
               └── assessment.quizzes       1:1  optional
                     └── assessment.questions
                           └── assessment.question_options

identity.users
   ├── identity.user_roles ── identity.roles
   ├── progress.enrolments ── progress.lesson_progress
   │                       └── progress.certificates
   └── assessment.quiz_attempts ── assessment.attempt_answers
```

## Where cross-service references stop being foreign keys

Inside a schema, referential integrity is enforced normally. Across schemas it
is not, and that is deliberate: `catalog.courses.instructor_id` holds an
`identity.users.id` with no FK behind it, because a foreign key would couple
the Course Service's migrations to the User Service's table.

Every such column is commented in the migration that creates it. The columns
that work this way:

| Column | Logically points at |
|---|---|
| `catalog.courses.instructor_id` | `identity.users.id` |
| `catalog.course_reviews.user_id` | `identity.users.id` |
| `content.lesson_videos.lesson_id` | `catalog.lessons.id` |
| `content.articles.lesson_id` | `catalog.lessons.id` |
| `content.articles.author_id` | `identity.users.id` |
| `progress.enrolments.user_id` / `.course_id` | `identity.users.id` / `catalog.courses.id` |
| `progress.lesson_progress.lesson_id` | `catalog.lessons.id` |
| `assessment.quizzes.course_id` / `.lesson_id` | `catalog.courses.id` / `catalog.lessons.id` |
| `assessment.quiz_attempts.user_id` | `identity.users.id` |
| `search.documents.entity_id` | whichever entity `entity_type` names |
| `analytics.events.*_id` | anything; the stream is intentionally schemaless here |

The API layer validates these before writing. That check is the price of the
split — see `docs/DECISIONS.md`.

## Video: URLs, not files

`content.lesson_videos` stores a pointer and nothing else:

```sql
video_url        text NOT NULL CHECK (video_url ~ '^https?://'),
hls_url          text,
thumbnail_url    text,
captions_url     text,
transcript       text,
provider         public.video_provider,   -- youtube | vimeo | mux | cloudflare | bunny | s3 | external
provider_asset_id text,
duration_seconds integer
```

There is no `bytea` column anywhere in `content` or `catalog`, and
`tests/verify.sql` asserts that, so an accidental "just store the small ones in
the database" patch fails CI rather than shipping.

The `transcript` column is text and is indexed by the Search Service, which is
how a search for a phrase spoken in a video finds the lesson.

## Articles: Markdown or HTML

`content.articles` holds the source in `body` and the format in `format`:

- `format = 'markdown'` — `body` is Markdown, `body_html` caches the render.
- `format = 'html'` — `body` is sanitised HTML from a rich-text editor or a
  headless CMS, and `body_html` is normally the same string.

The read path always serves `body_html`, so consumers never branch on format.

`external_source` and `external_id` are set when a row was synced from a
headless CMS, which is what makes "database *or* headless CMS" a configuration
choice rather than a fork of the schema. Locally authored articles leave both
null.

Every edit snapshots the previous body into `content.article_revisions` via a
`BEFORE UPDATE` trigger and bumps `revision`, so an author can roll back.

## Denormalised columns and who refreshes them

Four columns are caches. Each has exactly one function that recomputes it, and
the owning service calls that function after any write that could invalidate it:

| Column | Refreshed by |
|---|---|
| `catalog.courses.lesson_count`, `.duration_minutes` | `catalog.refresh_course_rollup(course_id)` |
| `catalog.courses.rating_average`, `.rating_count` | `catalog.refresh_course_rating(course_id)` |
| `progress.enrolments.progress_percent`, `.lessons_completed`, `.state` | `progress.refresh_enrolment_rollup(enrolment_id)` |
| `search.documents.*` | `search.reindex_all()` or a single-document upsert |

`tests/verify.sql` checks that none of them have drifted from the detail rows.

## Stored functions

| Function | Purpose |
|---|---|
| `public.touch_updated_at()` | Trigger behind every `updated_at` column |
| `catalog.assert_lesson_matches_module()` | A lesson's `course_id` must equal its module's |
| `content.snapshot_article_revision()` | Versions article bodies on edit |
| `progress.refresh_enrolment_rollup(uuid)` | Recomputes completion figures |
| `assessment.grade_attempt(uuid)` | Grades a submitted attempt server-side |
| `search.reindex_all()` | Rebuilds `search.documents`, returns the count |
| `search.join_tags(text[])` | Immutable `array_to_string`, needed by a generated column |
| `analytics.ensure_month_partition(date)` | Creates the monthly partition |
| `analytics.rollup_day(date)` | Recomputes both daily rollups for one day |

### Grading lives in SQL on purpose

`assessment.grade_attempt()` marks every answer, sums the points and writes the
result. Keeping it here means correct answers never have to be sent to the
browser, and there is exactly one implementation of the marking rules no matter
which service or script triggers a regrade.

Choice questions are **all-or-nothing**: the selected option set must equal the
correct option set exactly. Partial credit on a multiple-choice question would
let a learner select every option and score. Unanswered questions still count
toward `points_possible`.

## Search

One flat table, `search.documents`, covering courses, lessons and articles. The
`tsvector` is a stored generated column with weighting: title `A`, subtitle `B`,
body `C`, tags `D`, so `ts_rank` puts a title match above a body match.

Two indexes, two jobs:

- `gin (search_vector)` answers the real query.
- `gin (title gin_trgm_ops)` catches typos.

For the typo fallback, use `word_similarity(query, title)`, **not**
`similarity()`. `similarity()` scores the query against the entire title, so a
short misspelling inside a long title always scores low — `'postgrs'` against
`'PostgreSQL for Application Developers'` scores 0.18 with `similarity` and 0.75
with `word_similarity`.

## Analytics

`analytics.events` is append-only and range-partitioned by month on
`occurred_at`, with a `DEFAULT` partition so an insert can never fail for want
of one. `ensure_month_partition()` carves out real months ahead of time; the
verify suite fails if any row is sitting in the default partition, because that
means partition maintenance has stopped running.

Client IPs are stored as a salted hash in `ip_hash`. The raw address is never
persisted.

## Column-level notes worth knowing

- **uuid vs bigint.** Entities that travel between services use `uuid` with
  `gen_random_uuid()`, so a service can mint an id without a round trip. The
  append-heavy log tables (`analytics.events`, `search.query_log`) use `bigint
  GENERATED ALWAYS AS IDENTITY` instead, because random uuids scatter inserts
  across the B-tree.
- **`citext` for e-mail.** `identity.users.email` is `citext`, so
  `Ada@x.test` and `ada@x.test` are the same account and the unique index
  enforces it.
- **Deferrable position constraints.** `(module_id, position)` on lessons is
  `DEFERRABLE INITIALLY DEFERRED`, so reordering lessons is a plain `UPDATE`
  rather than a delete-and-reinsert dance. Note that PostgreSQL will not use a
  deferrable constraint as an `ON CONFLICT` arbiter — the seeds guard those
  inserts with `NOT EXISTS` instead.
- **Partial unique index for open attempts.** `quiz_attempts_one_open_idx`
  allows many attempts but only one `in_progress` per (quiz, user). Enforcing
  that in application code loses to a race eventually; the index does not.
