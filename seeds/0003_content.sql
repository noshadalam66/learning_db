-- ===========================================================================
-- Seed 03 : article bodies and attachments
--
-- This file used to seed video rows as well. It does not any more: the courses
-- teach with prose and a diagram of how the pieces fit together, and the eight
-- lessons that were a video are articles at the end of this file. Migration
-- 0014 removed the rows; content_lesson_videos is still there and still empty.
--
-- What is stored here is the source. An article's Markdown or HTML is the
-- thing we keep; body_html is only ever a render cache.
-- ===========================================================================


INSERT INTO content_lesson_attachments (lesson_id, title, file_url, mime_type, size_bytes, `position`) VALUES
  ('e0000001-0000-4000-8000-000000000004', 'Slides: the route layer',
   'https://files.example-cdn.test/slides/route-layer.pdf', 'application/pdf', 482113, 1),
  ('e0000001-0000-4000-8000-000000000006', 'Repository starter code',
   'https://files.example-cdn.test/code/repository-starter.zip', 'application/zip', 18422, 1),
  ('e0000001-0000-4000-8000-00000000000b', 'Sample EXPLAIN plans',
   'https://files.example-cdn.test/code/explain-plans.sql', 'text/plain', 6210, 1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), file_url = VALUES(file_url),
  mime_type = VALUES(mime_type), size_bytes = VALUES(size_bytes);

-- ---------------------------------------------------------------------------
-- Articles stored as Markdown.
--
-- MySQL has no dollar-quoting, so every body below is an ordinary quoted
-- string: apostrophes are doubled and there are no backslashes anywhere. If
-- you add an article containing a backslash, either double it or run with
-- sql_mode=NO_BACKSLASH_ESCAPES - MySQL treats a backslash as an escape
-- character inside a string literal, which PostgreSQL does not.
--
-- body_html is left NULL for most of these on purpose. It is a render cache,
-- and the Content Service renders from `body` when it is empty - so a row
-- seeded by hand or synced from a CMS is served correctly without anyone
-- having to pre-render it.
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000002',
   'Finding Service Boundaries',
   'markdown',
   '# Finding Service Boundaries

A service boundary is a bet about what will change together. Get it right and a
feature touches one repository. Get it wrong and every release becomes a
three-service coordination problem.

## Follow the data, not the diagram

The most reliable signal is transactional coupling. Ask: **would these two
writes have to happen in the same transaction to be correct?** If yes, they
almost certainly belong in the same service.

Progress updates and quiz grading look related on a whiteboard. In practice a
learner can finish a lesson without touching a quiz, and can fail a quiz five
times without their lesson progress changing. They are separate.

## The seven services in this platform

| Service   | Owns                                  | Database     |
|-----------|---------------------------------------|--------------|
| User      | Accounts, credentials, roles          | `identity`   |
| Course    | Catalogue and lesson structure        | `catalog`    |
| Content   | Article bodies, video URL metadata    | `content`    |
| Progress  | Enrolments, per-lesson completion     | `progress`   |
| Quiz      | Questions, attempts, grading          | `assessment` |
| Search    | The denormalised index                | `search`     |
| Analytics | The behaviour event stream            | `analytics`  |

In MySQL a schema *is* a database, so the split that PostgreSQL would express
as seven schemas is expressed here as seven databases on one server. Each
service is the only writer to its own.

Notice that **Content** owns article text and video pointers but not the lesson
row itself. Course owns the lesson. This is deliberate: the outline of a course
changes when a curriculum designer reorders things, and the body changes when a
writer edits prose. Different people, different release cadence.

## Where it costs you

Two honest costs:

1. **No foreign keys across services.** `catalog_courses.instructor_id` points
   at a user, and InnoDB would happily enforce that across databases - MySQL
   supports cross-database foreign keys. We leave it out anyway, because a
   foreign key there means the two services can never be moved onto separate
   servers. The check moves into application code, where it is easier to forget.
2. **No cross-service transactions.** Enrolling a learner writes to Progress and
   emits an event to Analytics. If the second half fails, you get an enrolment
   with no event. You design for that, or you do not split.

> If you cannot name what you are buying with those two costs, you are not
> ready to split yet. "Everyone else does it" is not an answer.

## A test for a boundary

Before you commit to one, write the three ugliest queries your product needs.
If any of them requires joining across two proposed services, either the
boundary is wrong or you need a read model. Both are fine answers. Discovering
it after six months of building is not.',
   'A service boundary is a bet about what will change together. How to place one, and the two costs nobody mentions.',
   6, 430, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 58 DAY)),

  ('e0000001-0000-4000-8000-000000000005',
   'Layer Two: The Service Layer',
   'markdown',
   '# Layer Two: The Service Layer

The service layer is where your product actually lives. Everything above it is
transport and everything below it is storage.

## The rule

**A service module must not import anything from `express`, and must not know
what an HTTP status code is.**

That one rule buys you a lot. It means you can call the same function from an
HTTP route, a CLI script, a queue consumer or a test, and get the same
behaviour. It also means the layer is testable without spinning up a server.

```js
// services/progress-service/src/services/progress.service.js
async function completeLesson({ userId, lessonId }) {
  const enrolment = await enrolmentRepository.findByUserAndLesson(userId, lessonId);
  if (!enrolment) {
    throw new NotFoundError(''You are not enrolled in this course'');
  }

  await lessonProgressRepository.markComplete({ enrolmentId: enrolment.id, lessonId });
  await enrolmentRepository.refreshRollup(enrolment.id);

  return enrolmentRepository.findById(enrolment.id);
}
```

`NotFoundError` is a domain error, not an HTTP one. A single error-handling
middleware maps it to 404 at the edge. If you ever call this from a queue
consumer, the same error means "give up, do not retry" - and that mapping
happens in the consumer, not in here.

## What does not belong here

- **SQL.** It goes in a repository. If you find yourself importing a database
  driver into a service file, stop.
- **Request parsing.** By the time you reach this layer, the input is validated
  and shaped.
- **Response formatting.** Return domain objects. The controller decides what
  the wire format looks like.

## Orchestration across services

When a service needs data another service owns, it makes an HTTP call, and that
call goes through a thin client in `src/clients/`. Keeping it there means the
retry policy, the timeout and the request-id header are written once:

```js
const course = await courseClient.getCourse(courseId, { requestId });
```

If `courseClient` throws, you decide here whether the whole operation fails or
whether you can degrade. That decision is business logic, which is why it lives
in the service layer and nowhere else.',
   'Everything above is transport, everything below is storage. One rule keeps the middle honest.',
   5, 360, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 57 DAY)),

  ('e0000001-0000-4000-8000-00000000000a',
   'Keys, Constraints and Honest Data',
   'markdown',
   '# Keys, Constraints and Honest Data

Every constraint you skip is a class of bad row you have agreed to accept.

## Pick a primary key on purpose

`CHAR(36)` defaults of `(UUID())` are the right call when ids travel between
services, because a service can mint one without a round trip. Two costs worth
knowing:

- **Index locality.** Random uuids scatter inserts across the B-tree instead of
  appending to it. For an append-heavy table you only ever read by time - the
  analytics event stream here - `BIGINT AUTO_INCREMENT` is the better trade.
- **Storage.** A `CHAR(36)` in `utf8mb4` reserves 144 bytes, because MySQL
  budgets four bytes per character. A uuid only ever contains hex and hyphens,
  so every id column in this schema is declared `CHARACTER SET ascii` and takes
  36. Foreign key columns must repeat the same charset, or InnoDB refuses the
  constraint outright.

Both key styles appear in this schema on purpose. Compare `analytics_events`
with `catalog_courses`.

## Write the CHECK constraint

A published course must have a publication date. That is not a nice-to-have,
it is what "published" means:

```sql
CONSTRAINT ck_courses_published_has_date
  CHECK (status <> ''published'' OR published_at IS NOT NULL)
```

Two lines, and an entire family of "why is this course showing a blank date"
bugs simply cannot happen. The application can forget. The database will not.

MySQL only started enforcing CHECK constraints in 8.0.16 - before that it
parsed and ignored them, which is worse than not supporting them. Check your
version before relying on one.

## Emulating a partial unique index

Sometimes uniqueness only applies to a subset of rows. A learner may take a quiz
many times, but only one attempt may be open at once. PostgreSQL writes that as
a partial index. MySQL has none, so the trick is a generated column that is
NULL for every other state, because a MySQL unique index permits duplicate
NULLs:

```sql
open_attempt_key VARCHAR(80) GENERATED ALWAYS AS (
  CASE WHEN state = ''in_progress'' THEN CONCAT(quiz_id, '':'', user_id) END
) VIRTUAL,
UNIQUE KEY uq_one_open_attempt (open_attempt_key)
```

`VIRTUAL` rather than `STORED` for a specific reason: MySQL refuses a cascading
foreign key on a column that a stored generated column reads, and `quiz_id`
needs both.

Try to enforce that rule in application code and you will lose a race
eventually. The index cannot lose it.

## Reordering without deferrable constraints

Positions within a module are unique, so reordering lessons produces a
transient duplicate. PostgreSQL solves this with `DEFERRABLE INITIALLY
DEFERRED`, which checks at COMMIT. MySQL checks immediately and has no
equivalent.

The workaround is to park every position in the negative range first, where it
cannot collide with any target value, then write the final numbers:

```sql
UPDATE catalog_lessons SET position = -position WHERE module_id = ?;
-- now write 1..n
```

That is what `catalog_reorder_lessons()` does.

## The one to remember

Nullable columns are a claim that the value is genuinely optional. Most nullable
columns in a young schema are really "we had not decided yet". Decide.',
   'Every constraint you skip is a class of bad row you have agreed to accept. Keys, CHECKs, and emulating what MySQL lacks.',
   7, 470, '33333333-3333-4333-8333-333333333333', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 40 DAY)),

  ('e0000001-0000-4000-8000-00000000000c',
   'Full-Text Search with FULLTEXT Indexes',
   'markdown',
   '# Full-Text Search with FULLTEXT Indexes

Before you add Elasticsearch, find out whether MySQL is already enough. For a
catalogue in the thousands or low millions of documents, it usually is.

## Weighting has to move to query time

A match in a title should beat a match buried in paragraph nine. PostgreSQL
stores one weighted `tsvector` and lets `ts_rank` read the weights back.

MySQL cannot weight inside a FULLTEXT index. So each field gets its own index
and relevance becomes a weighted sum of separate `MATCH()` scores:

```sql
SELECT d.*,
       MATCH(title)     AGAINST(? IN NATURAL LANGUAGE MODE) * 4
     + MATCH(subtitle)  AGAINST(? IN NATURAL LANGUAGE MODE) * 2
     + MATCH(body)      AGAINST(? IN NATURAL LANGUAGE MODE) * 1
     + MATCH(tags_text) AGAINST(? IN NATURAL LANGUAGE MODE) AS score
  FROM search_documents d
 WHERE MATCH(title, subtitle, body, tags_text) AGAINST(? IN NATURAL LANGUAGE MODE)
 ORDER BY score DESC;
```

The `WHERE` clause uses one combined index so the row set is found with a single
lookup; the `SELECT` list then re-scores the survivors per field. Without the
weighting every match is equal and your results feel random.

## Two defaults that will surprise you

**`innodb_ft_min_token_size` is 3.** One- and two-letter words are not indexed
at all, so a search for `js` or `ci` finds nothing no matter how many documents
contain them. Changing it requires rebuilding every FULLTEXT index. The cheaper
fix is a synonym table that rewrites `js` to `javascript` before the query is
built - which is what `search_synonyms` is for.

**Boolean mode does not rank.** `IN BOOLEAN MODE` gives you operators (`+`, `-`,
`*`) but relevance scores that are not comparable to natural-language mode.
Pick one per query and do not mix them in the same ORDER BY.

## Typos: there is no pg_trgm

This is the real gap. PostgreSQL has trigram similarity, and specifically
`word_similarity`, which scores a short query against the best-matching run of
words inside a long title. MySQL has nothing equivalent.

What works instead, in order of usefulness:

1. **Prefix relaxation in boolean mode.** Trim the query and add a star:
   `microservics` becomes `microserv*`, which matches. This catches a typo in
   the *tail* of a word and nothing else.
2. **Edit distance for ranking.** There is no built-in Levenshtein either, so
   `search_levenshtein()` in this schema is a stored function. It is
   O(len(a) x len(b)) per call, so it only ever runs over the small candidate
   set a prefix match already narrowed down - never across the table.
3. **SOUNDEX** for phonetic near-misses. Cheap, and blunt.

Be honest about the result: a typo in the first two characters will not be
caught. If fuzzy matching is a product requirement rather than a nicety, that is
the point at which a dedicated search engine earns its keep.

## Query, then fall back

Run the natural-language match. If it returns nothing, run the relaxed prefix
query and label the results "did you mean". Two cheap queries beat one clever
one, and the second only runs on the rare empty result.',
   'Weighting moves to query time, two MySQL defaults will surprise you, and there is no pg_trgm.',
   8, 520, '33333333-3333-4333-8333-333333333333', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 38 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), excerpt = VALUES(excerpt),
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count);

-- ---------------------------------------------------------------------------
-- An article stored as HTML rather than Markdown, standing in for something
-- authored in a rich-text editor or synced from a headless CMS. This one also
-- carries a pre-rendered body_html, so both cache states are represented.
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, body_html, excerpt, reading_time_minutes,
   word_count, author_id, status, external_source, external_id, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000000f',
   'Escaping Everything You Echo',
   'html',
   '<h1>Escaping Everything You Echo</h1><p>There is one habit that closes most cross-site scripting holes in a server-rendered application, and it is boring: <strong>escape at the point of output, every time, with no exceptions you have to remember.</strong></p><h2>The function</h2><pre><code>function e(?string $value): string {
    return htmlspecialchars($value ?? &#39;&#39;, ENT_QUOTES | ENT_SUBSTITUTE, &#39;UTF-8&#39;);
}</code></pre><p>Three details in there earn their place. <code>ENT_QUOTES</code> escapes single quotes as well as double, so the function is safe inside a single-quoted attribute. <code>ENT_SUBSTITUTE</code> replaces invalid UTF-8 with a replacement character instead of returning an empty string, which is what turns a malformed byte sequence into a silently blank page. And naming the charset explicitly means you are not relying on an ini setting that differs between your laptop and production.</p><h2>Escape on output, not on input</h2><p>Sanitising on the way in feels tidier and is a trap. The same string might be rendered into HTML, put in a JSON response, written to a log and used in an email subject. Each of those needs different escaping, and a value that was HTML-escaped at input is now wrong in three of the four.</p><p>Store what the user typed. Escape it for the context you are writing it into, at the moment you write it.</p><h2>Context matters</h2><ul><li><strong>HTML text</strong> - <code>htmlspecialchars</code>.</li><li><strong>An attribute</strong> - the same, but the attribute must be quoted.</li><li><strong>A URL parameter</strong> - <code>rawurlencode</code>, not <code>htmlspecialchars</code>.</li><li><strong>Inside a script block</strong> - <code>json_encode</code> with <code>JSON_HEX_TAG | JSON_HEX_AMP</code>. HTML escaping is the wrong tool here and will break your JavaScript while leaving it injectable.</li></ul><h2>The URL case that catches people</h2><p>Escaping a URL does not make it safe to put in an <code>href</code>. A <code>javascript:</code> URL contains no characters that <code>htmlspecialchars</code> touches. Check the scheme instead.</p><p>This matters directly in a learning platform, where instructors supply video and thumbnail URLs. That is user input arriving through a trusted-looking door.</p>',
   '<h1>Escaping Everything You Echo</h1><p>There is one habit that closes most cross-site scripting holes in a server-rendered application, and it is boring: <strong>escape at the point of output, every time, with no exceptions you have to remember.</strong></p>',
   'One boring habit closes most XSS holes: escape at output, per context, every time.',
   5, 330, '22222222-2222-4222-8222-222222222222', 'published',
   'demo-headless-cms', 'entry_7c31f9',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 18 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), excerpt = VALUES(excerpt),
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count);


-- ---------------------------------------------------------------------------
-- The eight lessons that used to be a video.
--
-- Each one is now what the video said, written down: the same argument, in an
-- order you can skim, with the code visible rather than narrated. The diagram
-- at the top of each comes from seed 30.
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000001',
   'The Monolith You Already Have',
   'markdown',
   'A monolith is a single deployable unit. That is the whole definition. It is not a synonym for a mess, it does not mean the code is badly organised, and it does not mean the team is behind the times. Plenty of monoliths are better engineered than the systems that replaced them.

The confusion matters because of what it does to the decision. If "monolith" means "mess", then splitting is obviously good, and you will split. If it means "one deployment", the question becomes a trade you can actually weigh.

## What splitting actually buys

One thing: independent deployment. Each service ships on its own schedule, owned by whoever wrote it, without a release train that twelve people have to agree on.

Everything else people hope for - better boundaries, clearer ownership, less coupling - is available inside a single deployment, and is cheaper there. Modules with enforced boundaries, separate schemas, separate teams: none of that requires a network.

## What it costs

A function call that could not fail now can.

That sentence is the whole price, and every other cost unpacks from it. A call across a process boundary can time out, can arrive twice, can succeed on one side and fail on the other. So you need timeouts, retries that do not duplicate writes, a request id that survives every hop, and a way to see a single user action across four logs. Your local transaction, which used to be one `BEGIN` and one `COMMIT`, is now a conversation between services that can stop halfway.

None of that is hard, exactly. All of it is work that buys you nothing a customer can see.

## The honest test

Ask what has actually gone wrong lately:

- **Deploys are blocked** on a change in an unrelated part of the system, or a release needs people from three teams in a room. That is deployment coupling, and splitting fixes it.
- **One module needs different hardware** - a GPU, or far more memory than the rest - and you are paying for it everywhere. Splitting fixes that too.
- **The code is tangled and nobody knows who owns what.** Splitting does not fix this. It distributes it. Seven tangled services with a network between them is strictly worse than one tangled application, because now you cannot even read it in one editor.

If the third one is your situation, fix the boundaries first, in the monolith, where a bad boundary costs a refactor instead of a migration. If the boundaries turn out to be right, splitting them later is almost mechanical. If they were wrong, you have just found out for free.

## What this course does

It takes a single Express application and pulls it apart, deliberately, with the costs visible as they arrive. Every service here is three layers - routes, services, repositories - and one gateway sits in front of all of them. By the end you will have built the thing, which is the only way to have a real opinion about whether you should.',
   'A monolith is one deployable unit. That is the whole definition - and most of the argument.',
   9, 510, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-000000000004',
   'Layer One: Routes and Controllers',
   'markdown',
   'The route layer has exactly three jobs: parse and validate the request, call one service method, and turn whatever comes back into a status code and a body.

That is a short list, and the discipline is in what it leaves out. If you can read a business rule in a controller, that rule is in the wrong file.

## The shape

```js
// services/course-service/src/controllers/course.controller.js
export async function enrol(req, res) {
  const enrolment = await courseService.enrol({
    courseId: req.valid.params.id,
    actor: req.user,
  });

  res.status(201).json({ data: enrolment });
}
```

Four lines, and three of them are translation. The validation happened in middleware before this ran; the rules live in `courseService.enrol`; the controller knows only that a successful enrolment is a 201.

## Why the rule pays

A service method that knows nothing about HTTP can be called from anywhere: an HTTP route, a CLI script, a queue consumer, a test. The moment a rule moves into the controller, it is reachable from exactly one of those, and the test for it needs a server.

It also decides where errors are translated. The service throws a domain error - `NotFoundError`, `ConflictError` - which says what went wrong in the language of the problem. One error-handling middleware at the edge maps those to status codes. Call the same service from a queue consumer and `NotFoundError` still means "give up, do not retry", without anyone having to know that elsewhere it means 404.

## Validation belongs at the edge

Everything arriving from outside is a string of unknown shape until something has checked it. Doing that in the route layer means every layer below can assume its inputs are the right type and in range:

```js
router.post(
  ''/id/:id/enrolments'',
  requireAuth,
  validate({ params: courseIdParam }),
  courseController.enrol,
);
```

By the time the controller runs, `req.valid.params.id` is a UUID. Not "probably a UUID": the request was rejected otherwise, with a 422 naming the field.

## What goes wrong without it

Two things, reliably.

The first is duplication. A rule written in a controller gets copied into the next controller that needs it, and then the two copies drift. The one in the admin endpoint keeps the check nobody remembered to add to the public one.

The second is that the application becomes untestable without a running server. Every test needs a port, a client and a teardown; the suite takes minutes instead of seconds, so it gets run less, so it catches less.

Both are slow failures. Neither looks like a problem on the day you write the controller.',
   'Parse, validate, call one service method, turn the answer into a status code. Nothing else belongs here.',
   10, 421, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-000000000006',
   'Layer Three: Repositories',
   'markdown',
   'A repository has one job: turn a question about the domain into SQL, run it, and turn the rows back into your own types.

Two rules follow from that, and both are load-bearing.

## It returns domain objects, not driver rows

The moment a raw result set escapes into the service layer, the database stops being swappable. Not because an ORM would have saved you, but because `row.course_id` is now spelled that way in forty places, and the column name is a public interface nobody declared.

```js
function toCourse(row) {
  if (!row) return null;
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    priceCents: row.price_cents,
    publishedAt: row.published_at,
  };
}

export async function findBySlug(slug) {
  return toCourse(await one(
    ''SELECT * FROM catalog_courses WHERE slug = ?'',
    [slug],
  ));
}
```

The mapping function is boring, and that is the point. It is the one place the schema''s naming meets the application''s naming, so renaming a column is a one-line change rather than a search.

## Every query is parameterised

```js
// Wrong, and no amount of validation upstream makes it safe:
const found = await query(`SELECT * FROM users WHERE email = ''${email}''`);

// Right:
const found = await query(''SELECT * FROM users WHERE email = ?'', [email]);
```

The difference is not escaping. With a placeholder the value never becomes part of the statement at all: the database is handed a query and, separately, a value, so there is nothing a quote character could break out of.

People sometimes argue that a validated input is safe to interpolate. It is not an argument worth having, because the parameterised version is shorter.

## What belongs here, and what does not

In: the SQL, the mapping, the transaction boundary when several statements must succeed together, and the translation of a constraint violation into a domain error that means something ("that slug is taken" rather than `ER_DUP_ENTRY`).

Out: anything that decides. If a method is called `createCourseIfInstructorHasQuota`, the quota rule is a service rule that leaked downwards.

The test for the boundary is simple. Read the repository with the schema in front of you, and the service with the product brief in front of you. If you need the other document open to understand either file, something is in the wrong layer.',
   'The only layer that writes SQL - and the only one that is allowed to know the schema.',
   10, 378, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-000000000007',
   'Building the Gateway',
   'markdown',
   'The gateway is the only thing the outside world talks to. Everything behind it trusts that it did its job.

That makes it a short list of responsibilities, each of which is painful to add later.

## Verify once

The gateway verifies the caller token and forwards the resulting identity to the service as headers. The service does not re-verify: it trusts those headers because they arrived with an internal token that only the gateway holds.

```js
headers[''x-user-id''] = req.user.id;
headers[''x-user-roles''] = (req.user.roles ?? []).join('','');
headers[INTERNAL_TOKEN_HEADER] = config.INTERNAL_SERVICE_TOKEN;
```

The important half is what gets removed. Those same identity headers are stripped from whatever the client sent:

```js
const STRIPPED_REQUEST_HEADERS = new Set([
  ''host'', ''connection'', ''content-length'',
  ''x-user-id'', ''x-user-email'', ''x-user-roles'',
  INTERNAL_TOKEN_HEADER,
]);
```

Forget that and a client can set `x-user-id` to anybody, and the service - which trusts it - will believe them. The stripping is the security boundary. The forwarding is just convenience.

## One request id, every hop

The gateway mints a request id and passes it to every service it calls. Each service logs it with every line, and returns it in the response.

It is the difference between a five minute debugging session and a five hour one. A user reports an error and quotes an id; one search across every log shows the whole path, in order, including the service that actually failed.

## A service that is down is a 503, not a hang

Every call out of the gateway has a deadline:

```js
const upstream = await fetchImpl(url, {
  method: req.method,
  headers,
  signal: AbortSignal.timeout(config.SERVICE_TIMEOUT_MS),
});
```

Without the timeout, a service that stops answering turns into a browser tab that spins forever and a connection pool that fills up - and once the pool is full, requests to healthy services start failing too. A timeout turns one broken service into one broken route.

What the client gets back should say which thing is unavailable, with the request id attached, so the answer to "is it down for everyone" is one search rather than a guess.

## What the gateway must not become

It routes, it authenticates, it observes. It does not know what a course is.

The moment domain logic appears in the gateway, every service''s deployment is coupled to the gateway''s again - which is the coupling the split was meant to remove. The one exception in this codebase is the composite endpoints, which fan out to four services for a single page; they are read-only, every part of them degrades to null, and they are confined to one file for exactly this reason.',
   'One front door: verify the token once, mint a request id, and make a service that is down look like a 503 rather than a hang.',
   12, 432, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-000000000009',
   'From Brief to Tables',
   'markdown',
   'Read the brief and underline every noun. Course, lesson, learner, quiz, attempt, certificate. Most of those become tables. The verbs between them - a learner *enrols on* a course, an attempt *belongs to* a quiz - become foreign keys or join tables.

It is a crude technique and it gets you eighty percent of a schema in twenty minutes. The remaining twenty percent is what this module is actually about.

## One fact, one place

The rule behind normalisation, stated without the word: every fact should be stored exactly once.

If a course''s title appears in `catalog_courses` and again in every `progress_enrolments` row, then renaming a course means finding every copy. Miss one and the database now holds two different answers to the same question, and nothing can tell you which is right.

So: the enrolment stores a `course_id`, and the title is read from the course. One fact, one place.

## Where the rule is broken on purpose

```sql
CREATE TABLE catalog_courses (
  id               CHAR(36) NOT NULL,
  title            VARCHAR(200) NOT NULL,
  -- Denormalised; refreshed by catalog_refresh_course_rollup().
  duration_minutes INT NOT NULL DEFAULT 0,
  lesson_count     INT NOT NULL DEFAULT 0,
  ...
);
```

`lesson_count` is a fact stored twice: here, and implicitly in the rows of `catalog_lessons`. That is deliberate. The catalogue page shows a lesson count for every course in a list of fifty, and counting lessons fifty times per page view is a cost paid on every request to save a maintenance problem that happens when a lesson is added.

The thing that makes it safe is that one named procedure owns the refresh. Denormalisation with no single owner is just data that drifts.

## Constraints are part of the design

The schema is the last place that can say no, and the only one that cannot be bypassed:

```sql
CONSTRAINT ck_modules_position_positive CHECK (`position` <> 0),
CONSTRAINT fk_modules_course FOREIGN KEY (course_id)
  REFERENCES catalog_courses (id) ON DELETE CASCADE,
UNIQUE KEY uq_modules_position (course_id, `position`)
```

Application validation is a usability feature: it gives a good error message in the right language. Database constraints are a correctness feature: they hold when a migration script, an admin console or a direct `UPDATE` at two in the morning goes round the application entirely.

Write both. They are not alternatives.

## Choosing types, briefly

Three decisions that are expensive to change later:

- **Identifiers.** A `CHAR(36)` UUID can be generated anywhere, which matters when several services write; a `BIGINT` auto-increment is smaller and faster to join, but centralises generation.
- **Money.** Integer minor units - `price_cents INT` - never a float. A float cannot represent 0.10 exactly, and the error compounds across a sum.
- **Time.** Store UTC, always, and convert at the edge. A `DATETIME` without a timezone that is sometimes local is a bug that only appears twice a year.',
   'Underline the nouns. Most of them are tables. The verbs between them are your foreign keys.',
   10, 467, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-00000000000b',
   'Reading EXPLAIN Output',
   'markdown',
   '`EXPLAIN` shows you the plan the optimiser picked, before you wait for the query to run. `EXPLAIN ANALYZE` runs it and shows what actually happened.

Most people read the output looking for the slow part. Read the row counts instead: the time is downstream of them.

## The number that matters

```sql
EXPLAIN SELECT * FROM catalog_lessons WHERE course_id = ''c0000001-...'';
```

```
id  select_type  table            type   key                rows   Extra
1   SIMPLE       catalog_lessons  ref    ix_lessons_course  12     NULL
```

`type: ref` with a key named means an index was used. `rows: 12` is the optimiser''s estimate of how many rows it will have to look at.

Now the same query without the index:

```
id  select_type  table            type   key    rows    Extra
1   SIMPLE       catalog_lessons  ALL    NULL   208     Using where
```

`type: ALL` is a full table scan, `key: NULL` says no index was used, and `rows` is the whole table. At 208 rows nobody notices. At eight million the page times out, and the query did not change - the data did.

## When the estimate is a lie

`EXPLAIN ANALYZE` gives estimated and actual rows side by side:

```
-> Index lookup on l using ix_lessons_course  (cost=4.2 rows=12) (actual time=0.03..0.09 rows=1180 loops=1)
```

Estimated 12, actual 1180. The optimiser was working from stale statistics, and every decision it made downstream of that node - join order, whether to use an index at all - was made on a wrong number.

That is where to look first when a query is slow for no visible reason. `ANALYZE TABLE` refreshes the statistics; if the gap persists, the data is skewed in a way the sampled statistics cannot see.

## What an index can and cannot serve

A composite index on `(course_id, position)` serves:

- `WHERE course_id = ?`
- `WHERE course_id = ? ORDER BY position`
- `WHERE course_id = ? AND position > ?`

and does not serve `WHERE position > ?` on its own. An index is usable left to right, like a phone book sorted by surname then first name: useless for finding everyone called Ahmed.

`Using filesort` in the Extra column means the sort could not be served by an index and the rows are being sorted after the fact. `Using temporary` means an intermediate table was materialised. Neither is fatal; both are worth knowing about before they are on a million rows.

## The order to work in

1. Find the query, with the slow query log or your APM - not by reading the code and guessing.
2. `EXPLAIN` it, and read the row counts.
3. Fix the access path: add the index, or change the query so an existing one can be used.
4. Measure again. An index that was not used is a write cost with no read benefit.',
   'Read the row count first. The time follows from it.',
   11, 465, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-00000000000e',
   'Templates Without a Framework',
   'markdown',
   'PHP started life as a template language and it is still a decent one. You do not need Twig or Blade to render a page well; you need one rule, kept.

**Fetch and shape the data first. Then include a file whose only job is markup and escaped output.**

## The two files

The page decides what it needs:

```php
<?php
declare(strict_types=1);

require __DIR__ . ''/src/bootstrap.php'';

$slug = query_string(''slug'', '''', 120);
$page = api_get(''/api/pages/course/'' . rawurlencode($slug));

render(''course'', [
    ''title''   => $page[''course''][''title''] ?? ''Course'',
    ''course''  => $page[''course''] ?? [],
    ''modules'' => $page[''course''][''modules''] ?? [],
]);
```

The template renders it:

```php
<h1><?= e($course[''title''] ?? '''') ?></h1>

<?php foreach ($modules as $module): ?>
  <section>
    <h2><?= e($module[''title''] ?? '''') ?></h2>
    <ul>
      <?php foreach ($module[''lessons''] ?? [] as $lesson): ?>
        <li><?= e($lesson[''title''] ?? '''') ?></li>
      <?php endforeach; ?>
    </ul>
  </section>
<?php endforeach; ?>
```

No queries, no API calls, no decisions beyond "is there anything to show". A template that fetches is a template you cannot test, cannot cache and cannot read.

## Why the alternative syntax

`foreach:` and `endforeach;` rather than braces, in templates only. In a file that alternates between markup and code every few lines, a closing brace tells you nothing about what it closes; `endforeach` does. It is the one place the style earns its keep.

## Escaping is not optional, and it has a direction

```php
function e(?string $value): string
{
    return htmlspecialchars($value ?? '''', ENT_QUOTES | ENT_SUBSTITUTE, ''UTF-8'');
}
```

`ENT_QUOTES` covers both quote characters, so the function is safe inside an attribute as well as in text. `ENT_SUBSTITUTE` replaces invalid UTF-8 rather than returning an empty string, which is how an escaping function silently blanks a field.

Escape at the point of output, every time, and never "once on the way in". Data escaped on input is wrong in every context except the one you guessed, and you cannot tell by looking at it whether it has already been done.

A URL in an attribute needs more than `e()`: a value starting `javascript:` is a working link, and HTML escaping does not touch it. Check the scheme:

```php
function safe_url(?string $url): string
{
    $url = trim((string) $url);
    $scheme = strtolower((string) parse_url($url, PHP_URL_SCHEME));
    return in_array($scheme, [''http'', ''https''], true) ? e($url) : '''';
}
```

## A layout, and partials

One header file, one footer file, and a `partial()` helper that includes a view with a scoped array of variables. That is the entire templating system this site uses, and it renders every page you are looking at.',
   'PHP started life as a template language. The discipline is keeping logic out of the template.',
   9, 419, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY)),

  ('e0000001-0000-4000-8000-000000000010',
   'Sessions and CSRF Tokens',
   'markdown',
   'Two mechanisms, often confused, doing different jobs. A session identifies the browser across requests. A CSRF token proves that a particular request came from a page you rendered.

You need both, and one does not substitute for the other.

## The session cookie

```php
session_set_cookie_params([
    ''lifetime'' => 0,
    ''path''     => ''/'',
    ''httponly'' => true,
    ''secure''   => $isHttps,
    ''samesite'' => ''Lax'',
]);
session_start();
```

- **HttpOnly** keeps the cookie out of `document.cookie`, so an XSS bug cannot read the session id and post it elsewhere. It does not prevent the XSS; it limits what the XSS can take.
- **Secure** stops the cookie travelling over plain HTTP.
- **SameSite=Lax** stops the browser attaching it to most cross-site requests - which blunts CSRF, but does not close it, because `Lax` still sends the cookie on a top-level navigation.

## Fixation, and the one line that prevents it

An attacker who can set a session id in your browser before you log in will share your session afterwards. The fix is one line, in exactly one place:

```php
// Immediately after authentication succeeds, before anything is written
// into the session.
session_regenerate_id(true);
```

The old id stops being valid. Whatever the attacker planted is now worthless.

## The token

```php
function csrf_token(): string
{
    if (empty($_SESSION[''csrf''])) {
        $_SESSION[''csrf''] = bin2hex(random_bytes(32));
    }
    return $_SESSION[''csrf''];
}

function csrf_field(): string
{
    return ''<input type="hidden" name="_csrf" value="'' . e(csrf_token()) . ''">'';
}

function require_csrf(): void
{
    $sent = (string) ($_POST[''_csrf''] ?? '''');
    if ($sent === '''' || !hash_equals(csrf_token(), $sent)) {
        http_response_code(419);
        exit(''Your session expired. Go back and try again.'');
    }
}
```

Three details are doing real work:

- **`random_bytes`**, not `rand` or `uniqid`. The token has to be unguessable; a predictable token is no token.
- **`hash_equals`**, not `===`. String comparison returns as soon as it finds a difference, so how long it takes leaks how much of the prefix was right. `hash_equals` always compares the whole string.
- **The token lives in the session**, server side. A token in a cookie that is compared to a token in a form proves only that the browser sent both, which is exactly what the attacker''s browser will do.

## Why this works

A form on `evil.example` can post to your `/transfer` endpoint, and the browser will attach your cookies. What it cannot do is read your page, so it cannot know the token. The check fails and the request is rejected.

Which is why the token must never be reachable cross-origin: not in a URL that leaks through `Referer`, not in a response your CORS policy lets another site read.

## Where to put the check

In one place, before any state change, not in every handler. Every POST goes through it; a handler that forgets is not possible, because no handler is doing the checking.',
   'The cookie says who you are. The token says this form came from a page we rendered.',
   11, 469, '22222222-2222-4222-8222-222222222222', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 9 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), excerpt = VALUES(excerpt),
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count);
