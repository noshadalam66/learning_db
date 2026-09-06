-- ===========================================================================
-- Seed 03 : video metadata and article bodies
--
-- Note what is and is not here. Videos are rows of URLs pointing at an
-- external host; the media itself never touches MySQL. Articles are the
-- opposite - the Markdown or HTML source is the thing we store.
-- ===========================================================================

INSERT INTO content_lesson_videos
  (lesson_id, provider, provider_asset_id, video_url, hls_url, thumbnail_url,
   captions_url, duration_seconds, width, height, transcript)
VALUES
  ('e0000001-0000-4000-8000-000000000001', 'mux', 'mux_asset_monolith_01',
   'https://stream.example-cdn.test/v/mux_asset_monolith_01',
   'https://stream.example-cdn.test/hls/mux_asset_monolith_01.m3u8',
   'https://images.example-cdn.test/thumbs/monolith-01.jpg',
   'https://stream.example-cdn.test/cc/monolith-01.en.vtt', 742, 1920, 1080,
   'A monolith is a single deployable unit. That is the whole definition. It is not a synonym for a mess, and splitting a mess into seven pieces gives you seven messes and a network between them. The question is never whether microservices are good, it is whether your deployment coupling has started costing more than the network hop would.'),

  ('e0000001-0000-4000-8000-000000000004', 'mux', 'mux_asset_routes_04',
   'https://stream.example-cdn.test/v/mux_asset_routes_04',
   'https://stream.example-cdn.test/hls/mux_asset_routes_04.m3u8',
   'https://images.example-cdn.test/thumbs/routes-04.jpg',
   'https://stream.example-cdn.test/cc/routes-04.en.vtt', 913, 1920, 1080,
   'The route layer has exactly three jobs. Parse and validate the request, call one service method, and turn whatever comes back into a status code and a body. If you can read a business rule in your controller, that rule is in the wrong file.'),

  ('e0000001-0000-4000-8000-000000000006', 'cloudflare', 'cf_repo_layer_06',
   'https://stream.example-cdn.test/v/cf_repo_layer_06',
   'https://stream.example-cdn.test/hls/cf_repo_layer_06.m3u8',
   'https://images.example-cdn.test/thumbs/repository-06.jpg', NULL, 805, 1920, 1080,
   'A repository returns domain objects, not driver rows. The moment a raw result set escapes into the service layer, swapping the database becomes a rewrite instead of a refactor. Parameterise every query. String concatenation into SQL is how injection happens, and no amount of validation upstream makes it safe.'),

  ('e0000001-0000-4000-8000-000000000007', 'mux', 'mux_gateway_07',
   'https://stream.example-cdn.test/v/mux_gateway_07',
   'https://stream.example-cdn.test/hls/mux_gateway_07.m3u8',
   'https://images.example-cdn.test/thumbs/gateway-07.jpg',
   'https://stream.example-cdn.test/cc/gateway-07.en.vtt', 1120, 1920, 1080,
   'The gateway verifies the token once and forwards the resulting identity to the services as trusted headers. It also mints a request id and passes it down every hop, which is the difference between a five minute debugging session and a five hour one.'),

  ('e0000001-0000-4000-8000-000000000009', 'youtube', 'dQw4w9WgXcQ',
   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', NULL,
   'https://images.example-cdn.test/thumbs/brief-to-tables-09.jpg', NULL, 688, 1280, 720,
   'Read the brief and underline every noun. Course, lesson, learner, quiz, attempt. Most of those nouns become tables. The verbs between them become foreign keys or join tables. It is a crude technique and it gets you eighty percent of a schema.'),

  ('e0000001-0000-4000-8000-00000000000b', 'vimeo', '76979871',
   'https://vimeo.com/76979871',
   'https://stream.example-cdn.test/hls/explain-0b.m3u8',
   'https://images.example-cdn.test/thumbs/explain-0b.jpg',
   'https://stream.example-cdn.test/cc/explain-0b.en.vtt', 954, 1920, 1080,
   'EXPLAIN ANALYZE gives you estimated rows and actual rows side by side. When those two numbers differ by orders of magnitude, the optimizer is working from bad statistics and every decision downstream of that node is suspect. Start there, not at the slowest node.'),

  ('e0000001-0000-4000-8000-00000000000e', 'bunny', 'bny_templates_0e',
   'https://stream.example-cdn.test/v/bny_templates_0e',
   'https://stream.example-cdn.test/hls/bny_templates_0e.m3u8',
   'https://images.example-cdn.test/thumbs/templates-0e.jpg', NULL, 612, 1280, 720,
   'PHP started life as a template language and it is still a decent one. The discipline is keeping logic out of the template file: fetch and shape the data first, then include a file whose only job is markup and escaped echoes.'),

  ('e0000001-0000-4000-8000-000000000010', 'mux', 'mux_sessions_10',
   'https://stream.example-cdn.test/v/mux_sessions_10',
   'https://stream.example-cdn.test/hls/mux_sessions_10.m3u8',
   'https://images.example-cdn.test/thumbs/sessions-10.jpg',
   'https://stream.example-cdn.test/cc/sessions-10.en.vtt', 877, 1920, 1080,
   'A CSRF token proves the request came from a page you rendered. Put it in the session, put it in a hidden field, and compare the two with hash_equals so the comparison is not timing dependent. Cookies need HttpOnly, Secure and SameSite=Lax at minimum.')
ON DUPLICATE KEY UPDATE video_url = VALUES(video_url);

INSERT INTO content_lesson_attachments (lesson_id, title, file_url, mime_type, size_bytes, `position`) VALUES
  ('e0000001-0000-4000-8000-000000000004', 'Slides: the route layer',
   'https://files.example-cdn.test/slides/route-layer.pdf', 'application/pdf', 482113, 1),
  ('e0000001-0000-4000-8000-000000000006', 'Repository starter code',
   'https://files.example-cdn.test/code/repository-starter.zip', 'application/zip', 18422, 1),
  ('e0000001-0000-4000-8000-00000000000b', 'Sample EXPLAIN plans',
   'https://files.example-cdn.test/code/explain-plans.sql', 'text/plain', 6210, 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);

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
ON DUPLICATE KEY UPDATE title = VALUES(title);

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
ON DUPLICATE KEY UPDATE title = VALUES(title);
