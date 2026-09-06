# Schema reference

One MySQL database holding 32 tables, with a prefix on each table name saying
which microservice owns it. In MySQL a schema *is* a database, so the split that
PostgreSQL would express as seven schemas is expressed here as a naming
convention instead — see [`DECISIONS.md`](DECISIONS.md) for why.

The database is named only in the connection string, so it can be whatever the
host calls it; on shared hosting that is the account prefix plus your name.

For the diagrams, see [`ERD.md`](ERD.md).

```
identity_*     User Service       accounts, credentials, roles
catalog_*      Course Service     courses, modules, lessons, categories, reviews
content_*      Content Service    article bodies, video URL metadata, attachments
progress_*     Progress Service   enrolments, per-lesson progress, certificates
assessment_*   Quiz Service       quizzes, questions, attempts, grading
search_*       Search Service     denormalised search documents, query log
analytics_*    Analytics Service  behaviour events, daily rollups
v_*            (nobody)           cross-service read views
platform_*     (nobody)           schema_migrations, the migration ledger
```

## Conventions

Stated once here rather than repeated in every migration.

**Ids are `CHAR(36) CHARACTER SET ascii` defaulted to `(UUID())`.** ascii rather
than utf8mb4 because a utf8mb4 `CHAR(36)` reserves 144 bytes and a uuid only
ever contains hex and hyphens. Every foreign key column repeats the same
charset — **InnoDB refuses a foreign key between columns whose character sets
differ**, and `tests/verify.sql` fails if a `CHAR` id column is anything but
ascii.

The append-heavy log tables (`analytics_events`, `search_query_log`) use
`BIGINT AUTO_INCREMENT` instead, because random uuids scatter inserts across
the B-tree rather than appending to it.

**Timestamps are `DATETIME(3)` defaulted to `(UTC_TIMESTAMP(3))`** — never
`TIMESTAMP`, never `CURRENT_TIMESTAMP`.

`DATETIME` because `TIMESTAMP` cannot represent a date past 2038-01-19.
`UTC_TIMESTAMP` because `CURRENT_TIMESTAMP` returns the **session** time zone,
so a client connected with `time_zone='+05:30'` would silently write local time
into a column every other client reads as UTC. Clients should still connect with
`time_zone='+00:00'` (the scripts do); the defaults mean forgetting is not
corrupting.

`updated_at` is maintained by a `BEFORE UPDATE` trigger rather than
`ON UPDATE CURRENT_TIMESTAMP`, which has exactly the same session dependency.
There is one such trigger per table with an `updated_at`.

**Text is utf8mb4 with the server default collation** (`utf8mb4_0900_ai_ci`),
which is case- and accent-insensitive. That is what makes
`identity_users.email` behave like PostgreSQL's `citext` for free.
Digest and token columns are the exception — declared `ascii`/`ascii_bin` so
comparison is exact and byte-for-byte.

**Enums are declared inline per column.** MySQL has no `CREATE TYPE`, so the
same value set is repeated where it is used. The sets:

| Concept | Values |
|---|---|
| account status | `pending` `active` `suspended` `deleted` |
| publish status | `draft` `in_review` `published` `archived` |
| course level | `beginner` `intermediate` `advanced` `expert` |
| lesson kind | `video` `article` `quiz` `assignment` |
| article format | `markdown` `html` |
| video provider | `youtube` `vimeo` `mux` `cloudflare` `bunny` `s3` `external` |
| enrolment state | `active` `completed` `expired` `cancelled` |
| progress state | `not_started` `in_progress` `completed` |
| question kind | `single_choice` `multiple_choice` `true_false` `short_text` |
| attempt state | `in_progress` `submitted` `graded` `abandoned` |

Changing one means finding every column that declares it. `docs/ERD.md` lists
where each appears.

## Where cross-service references stop being foreign keys

Within a service's own tables, referential integrity is enforced normally — all
21 foreign keys in this schema stay inside one prefix group. Across a service
boundary there is no constraint, and that is deliberate rather than a MySQL
limitation: every table now shares one database, so a foreign key there would
be trivial to add. It is left out because a foreign key across a service
boundary means those two services can never be moved apart, which is the point
of splitting them.

| Column | Logically points at |
|---|---|
| `catalog_courses.instructor_id` | `identity_users.id` |
| `catalog_course_reviews.user_id` | `identity_users.id` |
| `content_lesson_videos.lesson_id` | `catalog_lessons.id` |
| `content_articles.lesson_id` | `catalog_lessons.id` |
| `content_articles.author_id` | `identity_users.id` |
| `content_lesson_attachments.lesson_id` | `catalog_lessons.id` |
| `progress_enrolments.user_id` / `.course_id` | `identity_users.id` / `catalog_courses.id` |
| `progress_lesson_progress.lesson_id` | `catalog_lessons.id` |
| `assessment_quizzes.course_id` / `.lesson_id` | `catalog_courses.id` / `catalog_lessons.id` |
| `assessment_quiz_attempts.user_id` | `identity_users.id` |
| `search_documents.entity_id` | whichever entity `entity_type` names |
| `analytics_events.*_id` | anything; the stream is intentionally schemaless here |

Every such column carries a `-- deliberately not a foreign key` comment in the
migration that creates it. The API layer validates them before writing, and
`tests/verify.sql` re-checks the integrity constraints no longer can.

## Video: URLs, not files

`content_lesson_videos` stores a pointer and nothing else:

```sql
video_url         VARCHAR(2000) NOT NULL,   -- CHECK REGEXP_LIKE(..., '^https?://')
hls_url           VARCHAR(2000),
download_url      VARCHAR(2000),
thumbnail_url     VARCHAR(2000),
captions_url      VARCHAR(2000),
transcript        MEDIUMTEXT,               -- indexed by the Search Service
provider          ENUM('youtube','vimeo','mux','cloudflare','bunny','s3','external'),
provider_asset_id VARCHAR(200),
duration_seconds  INT
```

There is no `BLOB`, `BINARY` or `VARBINARY` column anywhere in `content` or
`catalog`, and `tests/verify.sql` asserts that — so an accidental "just store
the small ones in the database" patch fails CI rather than shipping.

## Articles: Markdown or HTML

`content_articles` holds the source in `body` and the format in `format`:

- `format = 'markdown'` — `body` is Markdown, `body_html` caches the render.
- `format = 'html'` — `body` is sanitised HTML from a rich-text editor or a CMS.

The read path always serves `body_html`, so consumers never branch on format.
**`body_html` is a cache and may be NULL**; the Content Service renders from
`body` when it is, which is how a row seeded by hand or synced from a CMS is
served correctly without anyone pre-rendering it.

`external_source` / `external_id` are set when a row was synced from a headless
CMS, which makes "database *or* headless CMS" a per-article configuration choice
rather than a fork of the schema. Locally authored articles leave both NULL.

Every edit fires a `BEFORE UPDATE` trigger that copies the previous body into
`content_article_revisions` and increments `revision`, so history is append-only
and a rollback is an ordinary write.

## Denormalised columns and who refreshes them

Six columns are caches. Each has exactly one routine that recomputes it, and the
owning service calls that routine after any write that could invalidate it:

| Column | Refreshed by |
|---|---|
| `catalog_courses.lesson_count`, `.duration_minutes` | `CALL catalog_refresh_course_rollup(course_id)` |
| `catalog_courses.rating_average`, `.rating_count` | `CALL catalog_refresh_course_rating(course_id)` |
| `progress_enrolments.progress_percent`, `.lessons_completed`, `.state` | `CALL progress_refresh_enrolment_rollup(enrolment_id)` |
| `search_documents.*` | `CALL search_reindex_all()` or a single-document upsert |

`tests/verify.sql` checks none of them have drifted. A denormalised column with
three different writers is how these go wrong.

## Stored routines

MySQL procedures have no `RETURN`, so anything that produces a value returns it
as a result set — the API repositories read row 0.

| Routine | Purpose |
|---|---|
| `catalog_refresh_course_rollup(uuid)` | Recomputes `lesson_count` / `duration_minutes` |
| `catalog_refresh_course_rating(uuid)` | Recomputes `rating_average` / `rating_count` |
| `catalog_reorder_lessons(uuid, json)` | Reorders a module's lessons; see below |
| `progress_refresh_enrolment_rollup(uuid)` | Recomputes completion figures |
| `assessment_grade_attempt(uuid)` | Grades a submitted attempt server-side |
| `search_reindex_all()` | Rebuilds `search_documents`, returns the count |
| `search_levenshtein(varchar, varchar)` | Edit distance — function, not procedure |
| `search_similarity_score(varchar, varchar)` | `1 - distance/longest`, in 0..1 |
| `analytics_ensure_month_partition(date)` | Creates monthly partitions up to that month |
| `analytics_rollup_day(date)` | Recomputes both daily rollups for one day |

### Grading lives in SQL on purpose

`assessment_grade_attempt()` marks every answer, sums the points and writes the
result. Correct answers never leave the database to be compared, and there is
exactly one implementation of the marking rules no matter which service or
script triggers a regrade.

Choice questions are **all-or-nothing**: the selected option set must equal the
correct set exactly. The comparison is two sorted `JSON_ARRAYAGG` results
compared as JSON — MySQL's stand-in for PostgreSQL's sorted-array equality.
Partial credit on a multiple-choice question would let a learner select every
option and score. Unanswered questions still count toward `points_possible`.

## Four things MySQL does differently

### 1. Partial unique indexes → a generated column

PostgreSQL expresses "only one attempt may be open at a time" as
`UNIQUE ... WHERE state = 'in_progress'`. MySQL has no partial indexes, so:

```sql
open_attempt_key VARCHAR(80) CHARACTER SET ascii
  GENERATED ALWAYS AS (
    CASE WHEN state = 'in_progress' THEN CONCAT(quiz_id, ':', user_id) END
  ) VIRTUAL,
UNIQUE KEY uq_one_open_attempt (open_attempt_key)
```

A MySQL unique index permits duplicate NULLs, so many graded attempts coexist
while a second open one collides.

It must be `VIRTUAL`, not `STORED`: **MySQL refuses a cascading foreign key on
a column that a stored generated column reads**, and `quiz_id` needs both.

### 2. No DEFERRABLE constraints → stage in the negative range

`(module_id, position)` is unique on `catalog_lessons`, so a reorder passes
through a transient duplicate. PostgreSQL defers the check to `COMMIT`; MySQL
checks immediately. `catalog_reorder_lessons()` parks every position in the
negative range first — where it cannot collide with any target value — then
writes the final numbers:

```sql
UPDATE catalog_lessons SET position = -position WHERE module_id = ?;
-- then write 1..n from a JSON_TABLE of the requested order
```

It also refuses a list that is not exactly the lessons in that module: a partial
list would leave the rest holding stale positions.

### 3. No arrays → JSON

`catalog_courses.learning_outcomes`, `.requirements`,
`assessment_attempt_answers.selected_option_ids` and
`search_synonyms.expands_to` are `JSON` columns with a
`CHECK (JSON_TYPE(col) = 'ARRAY')`. Read them back with `JSON_TABLE`:

```sql
SELECT jt.v FROM JSON_TABLE(c.learning_outcomes, '$[*]'
       COLUMNS (v VARCHAR(300) PATH '$')) jt
```

A comma-joined string would be shorter and would break on the first value
containing a comma. What is lost is a GIN index on membership — a JSON array
cannot be indexed for containment the way `text[]` can.

### 4. Search: no tsvector, no pg_trgm

**Weighting moves to query time.** MySQL cannot weight fields inside a FULLTEXT
index, so each field gets its own index and relevance is a weighted sum:

```sql
SELECT d.*,
       MATCH(d.title)     AGAINST(? IN NATURAL LANGUAGE MODE) * 4
     + MATCH(d.subtitle)  AGAINST(? IN NATURAL LANGUAGE MODE) * 2
     + MATCH(d.body)      AGAINST(? IN NATURAL LANGUAGE MODE) * 1
     + MATCH(d.tags_text) AGAINST(? IN NATURAL LANGUAGE MODE) AS score
  FROM search_documents d
 WHERE MATCH(d.title, d.subtitle, d.body, d.tags_text)
       AGAINST(? IN NATURAL LANGUAGE MODE)
 ORDER BY score DESC;
```

The combined index answers the `WHERE` in one lookup; the per-field ones
re-score the survivors. Five FULLTEXT indexes on one table is not redundancy.

**Two MySQL defaults will surprise you.** `innodb_ft_min_token_size` is 3, so
one- and two-letter words are not indexed at all — `search_synonyms` is what
rescues `js`, `ci`, `db`. And boolean-mode scores are not comparable to
natural-language-mode scores, so do not mix them in one `ORDER BY`.

**The typo fallback is genuinely weaker than pg_trgm.** There is no trigram
similarity and no built-in edit distance. What replaces `word_similarity`:

1. Prefix relaxation in boolean mode — `microservics` → `microserv*`. Catches a
   typo in the tail of a word and nothing else.
2. `search_levenshtein()` for ranking the candidates a prefix match found. It is
   O(len(a) × len(b)) per call, so it must never run across the whole table.
3. `SOUNDEX` for phonetic near-misses. Cheap and blunt.

A typo in the first two characters will not be caught. If fuzzy matching is a
product requirement rather than a nicety, that is the point at which a dedicated
search engine earns its keep.

## Analytics partitioning

`analytics_events` is range-partitioned by month on `occurred_at`.
**MySQL requires the partitioning column in every unique key**, which is why the
primary key is `(id, occurred_at)` rather than `id` alone.

MySQL has no `DEFAULT` partition, so the equivalent is a `MAXVALUE` catch-all
called `p_future` that `analytics_ensure_month_partition()` splits with
`REORGANIZE PARTITION`. Boundaries must be strictly increasing, so months can
only be appended — asking for a month already covered is a no-op, and asking for
one several months ahead fills the gap rather than leaving a hole MySQL would
later refuse to patch.

`tests/verify.sql` fails if any row is sitting in `p_future`, because that means
partition maintenance has stopped running.

Client IPs are stored as a salted SHA-256 in `ip_hash`. The raw address is never
persisted.

## No transactional DDL

PostgreSQL can wrap a migration in a transaction and roll the whole thing back.
MySQL cannot: **a migration that fails half way leaves the statements before the
failure applied.** Keep each file small enough that re-running it by hand after
a fix is realistic, and check `platform_schema_migrations` to see how far the
runner got.
