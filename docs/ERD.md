# Entity-relationship diagrams

If you read one thing here, read **The spine**. Everything else in the schema
hangs off it.

> There is also a **[visual version](https://claude.ai/code/artifact/9c966486-1cd3-48e3-b168-d8465097a467)**
> of this page — same content, drawn rather than described. A copy ships in the
> repo as [`docs/erd.html`](erd.html); open it directly in a browser.

- [The spine](#the-spine) — the chain every other table refers to
- [Seven owners, one server](#seven-owners-one-server) — where the foreign keys stop
- [identity](#identity--user-service) · [catalog](#catalog--course-service) ·
  [content](#content--content-service) · [progress](#progress--progress-service) ·
  [assessment](#assessment--quiz-service) · [search](#search--search-service) ·
  [analytics](#analytics--analytics-service)
- [Following one action](#following-one-action)

---

## The spine

A course holds ordered modules; a module holds ordered lessons; a lesson has
**exactly one kind of body**, and which kind is named by `lessons.kind`.

```mermaid
erDiagram
    COURSES  ||--o{ MODULES : "has ordered"
    MODULES  ||--o{ LESSONS : "has ordered"
    LESSONS  ||--o| LESSON_VIDEOS : "kind = video"
    LESSONS  ||--o| ARTICLES      : "kind = article"
    LESSONS  ||--o| QUIZZES       : "kind = quiz"
    LESSONS  ||--o{ LESSON_ATTACHMENTS : "downloads"

    COURSES {
        char36 id PK
        varchar slug UK
        varchar title
        char36 instructor_id "identity_users - no FK"
        enum status "draft|in_review|published|archived"
        int lesson_count "cached"
        int duration_minutes "cached"
    }
    MODULES {
        char36 id PK
        char36 course_id FK
        varchar title
        int position UK "unique per course"
    }
    LESSONS {
        char36 id PK
        char36 module_id FK
        char36 course_id FK "denormalised, trigger-checked"
        varchar slug UK "unique per course"
        enum kind "video|article|quiz|assignment"
        int position UK "unique per module"
        int duration_seconds
        bool is_free_preview
    }
    LESSON_VIDEOS {
        char36 id PK
        char36 lesson_id UK "no FK - different service"
        enum provider "youtube|vimeo|mux|..."
        varchar video_url "the URL, never the file"
        varchar hls_url
        text transcript "indexed by Search"
    }
    ARTICLES {
        char36 id PK
        char36 lesson_id UK "no FK - different service"
        enum format "markdown|html"
        mediumtext body "the source"
        mediumtext body_html "render cache, may be NULL"
        varchar external_source "set when synced from a CMS"
    }
    QUIZZES {
        char36 id PK
        char36 lesson_id UK "NULL = course-level exam"
        tinyint pass_percent
        smallint max_attempts "NULL = unlimited"
    }
    LESSON_ATTACHMENTS {
        char36 id PK
        char36 lesson_id
        varchar file_url "a URL, never the bytes"
    }
```

Three things to notice:

1. **`lessons.course_id` is redundant** — you could reach the course through
   `module_id`. It is carried anyway so "all lessons of a course, in order"
   needs no join, and a trigger refuses any row where the two disagree.
2. **A lesson's body lives in another service.** `lesson_videos`, `articles`
   and `quizzes` all point at `lessons.id` with **no foreign key**, because
   they are owned by different services.
3. **Video rows hold URLs.** There is no binary column anywhere in `content`,
   and `tests/verify.sql` fails the build if one appears.

---

## Seven owners, one server

Everything lives in one database. The per-service split is carried by a prefix
on the table name, and the groupings below are that convention.

```mermaid
flowchart TB
    subgraph identity["identity — User Service"]
        users[users]
        roles[roles]
    end
    subgraph catalog["catalog — Course Service"]
        courses[courses]
        lessons[lessons]
    end
    subgraph content["content — Content Service"]
        articles[articles]
        videos[lesson_videos]
    end
    subgraph progress["progress — Progress Service"]
        enrolments[enrolments]
        lesson_progress[lesson_progress]
    end
    subgraph assessment["assessment — Quiz Service"]
        quizzes[quizzes]
        attempts[quiz_attempts]
    end
    subgraph search["search — Search Service"]
        documents[documents]
    end
    subgraph analytics["analytics — Analytics Service"]
        events[events]
    end

    courses -. "instructor_id (no FK)" .-> users
    articles -. "lesson_id (no FK)" .-> lessons
    videos -. "lesson_id (no FK)" .-> lessons
    enrolments -. "user_id, course_id (no FK)" .-> courses
    lesson_progress -. "lesson_id (no FK)" .-> lessons
    quizzes -. "lesson_id (no FK)" .-> lessons
    attempts -. "user_id (no FK)" .-> users
    documents -. "rebuilt from" .-> courses
    events -. "ids only, no FK" .-> lessons
```

**Every dotted line is a reference with no constraint behind it.** All 21 real
foreign keys in this schema live *inside* one database:

| Database | Foreign keys within it |
|---|---|
| `identity` | 4 |
| `catalog` | 7 |
| `content` | 1 |
| `progress` | 2 |
| `assessment` | 5 |
| `search`, `analytics` | 0 — both are derived stores |

InnoDB *would* enforce a cross-database foreign key; MySQL supports them. The
omission is deliberate: a foreign key across a service boundary means those two
services can never be moved onto separate servers. See
[`DECISIONS.md`](DECISIONS.md).

---

## identity — User Service

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : "granted as"
    USERS ||--o{ REFRESH_TOKENS : "has sessions"
    USERS ||--o{ VERIFICATION_TOKENS : "has pending"

    USERS {
        char36 id PK
        varchar email UK "case-insensitive collation"
        varchar password_hash "bcrypt; NULL = SSO only"
        varchar full_name
        enum status "pending|active|suspended|deleted"
        datetime email_verified_at
        datetime last_login_at
    }
    ROLES {
        smallint id PK
        varchar name UK "student|instructor|admin"
    }
    USER_ROLES {
        char36 user_id PK "also FK to users"
        smallint role_id PK "also FK to roles"
        char36 granted_by FK
    }
    REFRESH_TOKENS {
        char36 id PK
        char36 user_id FK
        char64 token_hash UK "SHA-256 only, never the token"
        varbinary ip_address "INET6_ATON"
        datetime expires_at
        datetime revoked_at "NULL = live"
    }
    VERIFICATION_TOKENS {
        char36 id PK
        char36 user_id FK
        enum purpose "email_verify|password_reset"
        char64 token_hash UK
        datetime consumed_at "single use"
    }
```

`email` needs no `citext` equivalent: MySQL's default `utf8mb4_0900_ai_ci`
collation is already case-insensitive, so `Ada@x.test` and `ada@x.test` collide
on the unique index.

---

## catalog — Course Service

```mermaid
erDiagram
    CATEGORIES ||--o{ COURSES : classifies
    CATEGORIES ||--o{ CATEGORIES : "parent of"
    COURSES ||--o{ MODULES : contains
    COURSES ||--o{ LESSONS : "contains (denormalised)"
    MODULES ||--o{ LESSONS : contains
    COURSES ||--o{ COURSE_TAGS : tagged
    TAGS    ||--o{ COURSE_TAGS : tags
    COURSES ||--o{ COURSE_REVIEWS : "rated by"

    CATEGORIES {
        char36 id PK
        char36 parent_id FK "self-referencing"
        varchar slug UK
        int position
    }
    COURSES {
        char36 id PK
        varchar slug UK
        char36 category_id FK
        char36 instructor_id "no FK"
        enum level "beginner|intermediate|advanced|expert"
        enum status
        int price_cents
        json learning_outcomes "MySQL has no array type"
        json requirements
        decimal rating_average "cached"
        int rating_count "cached"
        datetime published_at "required when published"
    }
    COURSE_REVIEWS {
        char36 id PK
        char36 course_id FK
        char36 user_id "no FK"
        tinyint rating "1..5"
    }
    TAGS {
        char36 id PK
        varchar slug UK
    }
```

The four cached columns — `lesson_count`, `duration_minutes`, `rating_average`,
`rating_count` — each have exactly one procedure that recomputes them
(`catalog_refresh_course_rollup`, `catalog_refresh_course_rating`), and
`tests/verify.sql` fails if they drift from the rows they summarise.

---

## content — Content Service

```mermaid
erDiagram
    ARTICLES ||--o{ ARTICLE_REVISIONS : "snapshots into"

    ARTICLES {
        char36 id PK
        char36 lesson_id UK "no FK"
        enum format "markdown|html"
        mediumtext body
        mediumtext body_html "cache; rendered on read if NULL"
        int revision "bumped by trigger"
        varchar external_source "CMS name, or NULL"
        varchar external_id
        enum status
    }
    ARTICLE_REVISIONS {
        char36 id PK
        char36 article_id FK
        int revision UK "unique per article"
        mediumtext body "the previous body"
    }
    LESSON_VIDEOS {
        char36 id PK
        char36 lesson_id UK "no FK"
        enum provider
        varchar video_url "CHECK ^https?://"
        varchar hls_url
        varchar captions_url
        mediumtext transcript
        int duration_seconds
    }
    LESSON_ATTACHMENTS {
        char36 id PK
        char36 lesson_id "no FK"
        varchar file_url "CHECK ^https?://"
        bigint size_bytes
    }
```

Editing an article fires a `BEFORE UPDATE` trigger that copies the old body
into `article_revisions` and increments `revision`, so history is append-only
and a rollback is a normal write rather than a restore.

---

## progress — Progress Service

```mermaid
erDiagram
    ENROLMENTS ||--o{ LESSON_PROGRESS : "detail rows"
    ENROLMENTS ||--o| CERTIFICATES : "earns"

    ENROLMENTS {
        char36 id PK
        char36 user_id "no FK"
        char36 course_id "no FK"
        enum state "active|completed|expired|cancelled"
        decimal progress_percent "cached"
        int lessons_completed "cached"
        int lessons_total "denominator, from Course Service"
        char36 last_lesson_id "continue where you left off"
    }
    LESSON_PROGRESS {
        char36 id PK
        char36 enrolment_id FK
        char36 lesson_id "no FK; UNIQUE with user_id"
        enum state "not_started|in_progress|completed"
        int seconds_watched "accumulates"
        int last_position_seconds "resume point; can go backwards"
        int view_count
    }
    CERTIFICATES {
        char36 id PK
        char36 enrolment_id UK "also FK to enrolments"
        varchar serial UK "random, not sequential"
    }
    LESSON_NOTES {
        char36 id PK
        char36 user_id
        char36 lesson_id
        text body
        int at_seconds "pinned to a moment in the video"
    }
```

`seconds_watched` and `last_position_seconds` are deliberately different
numbers. The first accumulates across rewatches; the second is where the player
resumes, and moves *backwards* when someone rewinds.

---

## assessment — Quiz Service

```mermaid
erDiagram
    QUIZZES ||--o{ QUESTIONS : contains
    QUESTIONS ||--o{ QUESTION_OPTIONS : "offers"
    QUIZZES ||--o{ QUIZ_ATTEMPTS : "sat as"
    QUIZ_ATTEMPTS ||--o{ ATTEMPT_ANSWERS : records
    QUESTIONS ||--o{ ATTEMPT_ANSWERS : "answered by"

    QUIZZES {
        char36 id PK
        char36 course_id "no FK"
        char36 lesson_id UK "NULL = course exam"
        tinyint pass_percent
        int time_limit_seconds "NULL = untimed"
        smallint max_attempts "NULL = unlimited"
        bool show_answers
    }
    QUESTIONS {
        char36 id PK
        char36 quiz_id FK
        enum kind "single_choice|multiple_choice|true_false|short_text"
        text prompt
        text explanation "shown only after submission"
        smallint points
        int position UK
        varchar correct_text "short_text only"
    }
    QUESTION_OPTIONS {
        char36 id PK
        char36 question_id FK
        varchar body
        bool is_correct "never sent to a learner pre-submit"
        int position UK
    }
    QUIZ_ATTEMPTS {
        char36 id PK
        char36 quiz_id FK
        char36 user_id "no FK"
        smallint attempt_no UK "unique per quiz+user"
        enum state "in_progress|submitted|graded|abandoned"
        decimal score_percent
        bool passed
        varchar open_attempt_key UK "generated; NULL unless in_progress"
    }
    ATTEMPT_ANSWERS {
        char36 id PK
        char36 attempt_id FK
        char36 question_id FK
        json selected_option_ids "MySQL has no array type"
        varchar text_answer
        bool is_correct "set by grade_attempt()"
        int points_awarded
    }
```

`open_attempt_key` is how a **partial unique index** is emulated. PostgreSQL
would write `UNIQUE ... WHERE state = 'in_progress'`; MySQL has no such thing,
so a generated column evaluates to `NULL` for every other state — and a MySQL
unique index permits duplicate `NULL`s. Many graded attempts coexist; a second
open one collides.

It is `VIRTUAL`, not `STORED`, because MySQL refuses a cascading foreign key on
a column that a stored generated column reads, and `quiz_id` needs both.

---

## search — Search Service

```mermaid
erDiagram
    DOCUMENTS {
        char36 id PK
        enum entity_type "course|lesson|article"
        char36 entity_id UK "with entity_type"
        char36 course_id
        varchar title "FULLTEXT, weight x4"
        varchar subtitle "FULLTEXT, weight x2"
        mediumtext body "FULLTEXT, weight x1"
        varchar tags_text "FULLTEXT, weight x1"
        varchar url_path "where a hit links to"
        bool is_published
        int popularity "tie-breaker"
    }
    QUERY_LOG {
        bigint id PK
        char36 user_id
        varchar query_text
        int result_count "0 = a content gap"
        char36 clicked_entity_id
    }
    SYNONYMS {
        smallint id PK
        varchar term UK
        json expands_to
    }
```

`documents` is a flattened copy rebuilt by `search_reindex_all()`. It has no
foreign keys by design — it is a derived store, and a stale row is a reindex
away from being fixed.

The five `FULLTEXT` indexes are not redundant: the combined one answers the
`WHERE`, and the per-field ones let the `SELECT` re-score each field so a title
match outranks a body match. MySQL cannot weight inside an index the way a
PostgreSQL `tsvector` can, so weighting moves to query time.

---

## analytics — Analytics Service

```mermaid
erDiagram
    EVENTS {
        bigint id PK "with occurred_at"
        datetime occurred_at PK "partition key"
        char36 user_id
        varchar event_name
        char36 course_id
        char36 lesson_id
        json properties
        char64 ip_hash "salted; raw IP never stored"
    }
    DAILY_COURSE_STATS {
        date day PK
        char36 course_id PK
        int views
        int unique_learners
        bigint watch_seconds
        decimal quiz_pass_rate "from assessment, not from events"
    }
    DAILY_PLATFORM_STATS {
        date day PK
        int active_users
        int new_users
        bigint watch_seconds
    }
```

`events` is the only table expected to reach hundreds of millions of rows, and
the only one using `BIGINT AUTO_INCREMENT` rather than a uuid — random uuids
scatter inserts across the B-tree, which is the wrong trade for an append-only
log.

MySQL requires the partitioning column in every unique key, which is why the
primary key is `(id, occurred_at)` rather than `id` alone.

---

## Following one action

*Sam finishes lesson 5 of the microservices course.* One `PUT` through the
gateway, and here is every row that moves:

```mermaid
sequenceDiagram
    participant API as Progress Service
    participant LP as progress_lesson_progress
    participant EN as progress_enrolments
    participant CE as progress_certificates
    participant AN as analytics_events

    API->>LP: UPSERT (user_id, lesson_id)<br/>seconds_watched += delta<br/>state = 'completed'
    API->>EN: last_lesson_id = lesson 5
    API->>EN: CALL refresh_enrolment_rollup(enrolment_id)
    Note over EN: recount completed rows,<br/>recompute progress_percent,<br/>flip state if all done
    alt enrolment just became complete
        API->>CE: INSERT certificate (random serial)
    end
    API-->>AN: emit lesson_completed (fire-and-forget)
    Note over AN: an analytics outage must never<br/>slow down a learner
```

Two details worth keeping:

- The detail write and the rollup happen in **one transaction**, so no reader
  ever sees an updated lesson row beside a stale summary.
- The analytics emit is **not** awaited. Events can be lost, which is precisely
  why nothing authoritative is ever reconstructed from the event stream — the
  drop-off report reads `progress`, not `analytics_events`.
