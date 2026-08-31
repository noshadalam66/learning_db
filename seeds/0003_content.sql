-- ===========================================================================
-- Seed 03 : video metadata and article bodies
--
-- Note what is and is not here. Videos are rows of URLs pointing at an
-- external host; the media itself never touches Postgres. Articles are the
-- opposite - the Markdown or HTML source is the thing we store.
-- ===========================================================================

BEGIN;

INSERT INTO content.lesson_videos
  (lesson_id, provider, provider_asset_id, video_url, hls_url, thumbnail_url, captions_url,
   duration_seconds, width, height, transcript)
VALUES
  ('e0000001-0000-4000-8000-000000000001', 'mux', 'mux_asset_monolith_01',
   'https://stream.example-cdn.test/v/mux_asset_monolith_01',
   'https://stream.example-cdn.test/hls/mux_asset_monolith_01.m3u8',
   'https://images.example-cdn.test/thumbs/monolith-01.jpg',
   'https://stream.example-cdn.test/cc/monolith-01.en.vtt',
   742, 1920, 1080,
   'A monolith is a single deployable unit. That is the whole definition. It is not a synonym for a mess, and splitting a mess into seven pieces gives you seven messes and a network between them. The question is never whether microservices are good, it is whether your deployment coupling has started costing more than the network hop would.'),

  ('e0000001-0000-4000-8000-000000000004', 'mux', 'mux_asset_routes_04',
   'https://stream.example-cdn.test/v/mux_asset_routes_04',
   'https://stream.example-cdn.test/hls/mux_asset_routes_04.m3u8',
   'https://images.example-cdn.test/thumbs/routes-04.jpg',
   'https://stream.example-cdn.test/cc/routes-04.en.vtt',
   913, 1920, 1080,
   'The route layer has exactly three jobs. Parse and validate the request, call one service method, and turn whatever comes back into a status code and a body. If you can read a business rule in your controller, that rule is in the wrong file.'),

  ('e0000001-0000-4000-8000-000000000006', 'cloudflare', 'cf_repo_layer_06',
   'https://stream.example-cdn.test/v/cf_repo_layer_06',
   'https://stream.example-cdn.test/hls/cf_repo_layer_06.m3u8',
   'https://images.example-cdn.test/thumbs/repository-06.jpg',
   NULL,
   805, 1920, 1080,
   'A repository returns domain objects, not driver rows. The moment a pg Result object escapes into the service layer, swapping the database becomes a rewrite instead of a refactor. Parameterise every query. String concatenation into SQL is how injection happens, and no amount of validation upstream makes it safe.'),

  ('e0000001-0000-4000-8000-000000000007', 'mux', 'mux_gateway_07',
   'https://stream.example-cdn.test/v/mux_gateway_07',
   'https://stream.example-cdn.test/hls/mux_gateway_07.m3u8',
   'https://images.example-cdn.test/thumbs/gateway-07.jpg',
   'https://stream.example-cdn.test/cc/gateway-07.en.vtt',
   1120, 1920, 1080,
   'The gateway verifies the token once and forwards the resulting identity to the services as trusted headers. It also mints a request id and passes it down every hop, which is the difference between a five minute debugging session and a five hour one.'),

  ('e0000001-0000-4000-8000-000000000009', 'youtube', 'dQw4w9WgXcQ',
   'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
   NULL,
   'https://images.example-cdn.test/thumbs/brief-to-tables-09.jpg',
   NULL,
   688, 1280, 720,
   'Read the brief and underline every noun. Course, lesson, learner, quiz, attempt. Most of those nouns become tables. The verbs between them become foreign keys or join tables. It is a crude technique and it gets you eighty percent of a schema.'),

  ('e0000001-0000-4000-8000-00000000000b', 'vimeo', '76979871',
   'https://vimeo.com/76979871',
   'https://stream.example-cdn.test/hls/explain-0b.m3u8',
   'https://images.example-cdn.test/thumbs/explain-0b.jpg',
   'https://stream.example-cdn.test/cc/explain-0b.en.vtt',
   954, 1920, 1080,
   'EXPLAIN ANALYZE gives you estimated rows and actual rows side by side. When those two numbers differ by orders of magnitude, the planner is working from bad statistics and every decision downstream of that node is suspect. Start there, not at the slowest node.'),

  ('e0000001-0000-4000-8000-00000000000e', 'bunny', 'bny_templates_0e',
   'https://stream.example-cdn.test/v/bny_templates_0e',
   'https://stream.example-cdn.test/hls/bny_templates_0e.m3u8',
   'https://images.example-cdn.test/thumbs/templates-0e.jpg',
   NULL,
   612, 1280, 720,
   'PHP started life as a template language and it is still a decent one. The discipline is keeping logic out of the template file: fetch and shape the data first, then include a file whose only job is markup and escaped echoes.'),

  ('e0000001-0000-4000-8000-000000000010', 'mux', 'mux_sessions_10',
   'https://stream.example-cdn.test/v/mux_sessions_10',
   'https://stream.example-cdn.test/hls/mux_sessions_10.m3u8',
   'https://images.example-cdn.test/thumbs/sessions-10.jpg',
   'https://stream.example-cdn.test/cc/sessions-10.en.vtt',
   877, 1920, 1080,
   'A CSRF token proves the request came from a page you rendered. Put it in the session, put it in a hidden field, and compare the two with hash_equals so the comparison is not timing dependent. Cookies need HttpOnly, Secure and SameSite=Lax at minimum.')
ON CONFLICT (lesson_id) DO NOTHING;

-- lesson_attachments carries no unique constraint, so ON CONFLICT would not
-- protect a re-run. Match on the URL, which is the natural key here.
INSERT INTO content.lesson_attachments (lesson_id, title, file_url, mime_type, size_bytes, position)
SELECT v.lesson_id, v.title, v.file_url, v.mime_type, v.size_bytes, v.position
  FROM (VALUES
    ('e0000001-0000-4000-8000-000000000004'::uuid, 'Slides: the route layer',
     'https://files.example-cdn.test/slides/route-layer.pdf', 'application/pdf', 482113::bigint, 1),
    ('e0000001-0000-4000-8000-000000000006', 'Repository starter code',
     'https://files.example-cdn.test/code/repository-starter.zip', 'application/zip', 18422, 1),
    ('e0000001-0000-4000-8000-00000000000b', 'Sample EXPLAIN plans',
     'https://files.example-cdn.test/code/explain-plans.sql', 'text/plain', 6210, 1)
  ) AS v(lesson_id, title, file_url, mime_type, size_bytes, position)
 WHERE NOT EXISTS (
   SELECT 1 FROM content.lesson_attachments a WHERE a.file_url = v.file_url
 );

-- ---------------------------------------------------------------------------
-- Articles stored as Markdown. body_html is the render cache the Content
-- Service refreshes whenever body changes.
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, body_html, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000002',
   'Finding Service Boundaries',
   'markdown',
$md$# Finding Service Boundaries

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

## The seven services in this course

| Service   | Owns                                  |
|-----------|---------------------------------------|
| User      | Accounts, credentials, roles          |
| Course    | Catalogue and lesson structure        |
| Content   | Article bodies, video URL metadata    |
| Progress  | Enrolments, per-lesson completion     |
| Quiz      | Questions, attempts, grading          |
| Search    | The denormalised index                |
| Analytics | The behaviour event stream            |

Notice that **Content** owns article text and video pointers but not the lesson
row itself. Course owns the lesson. This is deliberate: the outline of a course
changes when a curriculum designer reorders things, and the body changes when a
writer edits prose. Different people, different release cadence.

## Where it costs you

Two honest costs:

1. **No foreign keys across services.** `catalog.courses.instructor_id` points
   at a user, but there is no constraint enforcing it. That check moved into
   application code, where it is easier to forget.
2. **No cross-service transactions.** Enrolling a learner writes to Progress and
   emits an event to Analytics. If the second half fails, you get an enrolment
   with no event. You design for that, or you do not split.

> If you cannot name what you are buying with those two costs, you are not
> ready to split yet. "Everyone else does it" is not an answer.

## A test for a boundary

Before you commit to one, write the three ugliest queries your product needs.
If any of them requires joining across two proposed services, either the
boundary is wrong or you need a read model. Both are fine answers. Discovering
it after six months of building is not.
$md$,
'<h1>Finding Service Boundaries</h1><p>A service boundary is a bet about what will change together. Get it right and a feature touches one repository. Get it wrong and every release becomes a three-service coordination problem.</p><h2>Follow the data, not the diagram</h2><p>The most reliable signal is transactional coupling. Ask: <strong>would these two writes have to happen in the same transaction to be correct?</strong> If yes, they almost certainly belong in the same service.</p><p>Progress updates and quiz grading look related on a whiteboard. In practice a learner can finish a lesson without touching a quiz, and can fail a quiz five times without their lesson progress changing. They are separate.</p><h2>The seven services in this course</h2><table><thead><tr><th>Service</th><th>Owns</th></tr></thead><tbody><tr><td>User</td><td>Accounts, credentials, roles</td></tr><tr><td>Course</td><td>Catalogue and lesson structure</td></tr><tr><td>Content</td><td>Article bodies, video URL metadata</td></tr><tr><td>Progress</td><td>Enrolments, per-lesson completion</td></tr><tr><td>Quiz</td><td>Questions, attempts, grading</td></tr><tr><td>Search</td><td>The denormalised index</td></tr><tr><td>Analytics</td><td>The behaviour event stream</td></tr></tbody></table><p>Notice that <strong>Content</strong> owns article text and video pointers but not the lesson row itself. Course owns the lesson. This is deliberate: the outline of a course changes when a curriculum designer reorders things, and the body changes when a writer edits prose. Different people, different release cadence.</p><h2>Where it costs you</h2><p>Two honest costs:</p><ol><li><strong>No foreign keys across services.</strong> <code>catalog.courses.instructor_id</code> points at a user, but there is no constraint enforcing it. That check moved into application code, where it is easier to forget.</li><li><strong>No cross-service transactions.</strong> Enrolling a learner writes to Progress and emits an event to Analytics. If the second half fails, you get an enrolment with no event. You design for that, or you do not split.</li></ol><blockquote><p>If you cannot name what you are buying with those two costs, you are not ready to split yet. &quot;Everyone else does it&quot; is not an answer.</p></blockquote><h2>A test for a boundary</h2><p>Before you commit to one, write the three ugliest queries your product needs. If any of them requires joining across two proposed services, either the boundary is wrong or you need a read model. Both are fine answers. Discovering it after six months of building is not.</p>',
   'A service boundary is a bet about what will change together. How to place one, and the two costs nobody mentions.',
   6, 430,
   '22222222-2222-4222-8222-222222222222', 'published', now() - interval '58 days'),

  ('e0000001-0000-4000-8000-000000000005',
   'Layer Two: The Service Layer',
   'markdown',
$md$# Layer Two: The Service Layer

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
    throw new NotFoundError('You are not enrolled in this course');
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

- **SQL.** It goes in a repository. If you find yourself importing `pg` into a
  service file, stop.
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
in the service layer and nowhere else.
$md$,
   NULL,
   'Everything above is transport, everything below is storage. One rule keeps the middle honest.',
   5, 360,
   '22222222-2222-4222-8222-222222222222', 'published', now() - interval '57 days'),

  ('e0000001-0000-4000-8000-00000000000a',
   'Keys, Constraints and Honest Data',
   'markdown',
$md$# Keys, Constraints and Honest Data

Every constraint you skip is a class of bad row you have agreed to accept.

## Pick a primary key on purpose

`uuid` defaults with `gen_random_uuid()` are the right call when ids travel
between services, because a service can mint one without a round trip. The cost
is index locality: random uuids scatter inserts across the B-tree. For an
append-heavy table that you only ever read by time - the analytics event stream
here - a bigint identity is the better trade.

Both appear in this schema on purpose. Look at `analytics.events` and compare it
to `catalog.courses`.

## Write the CHECK constraint

A published course must have a publication date. That is not a nice-to-have,
it is what "published" means:

```sql
CONSTRAINT courses_published_has_date
  CHECK (status <> 'published' OR published_at IS NOT NULL)
```

Four lines, and an entire family of "why is this course showing a blank date"
bugs simply cannot happen. The application can forget. The database will not.

## Partial unique indexes

Sometimes uniqueness only applies to a subset of rows. A learner may take a quiz
many times, but only one attempt may be open at once:

```sql
CREATE UNIQUE INDEX quiz_attempts_one_open_idx
  ON assessment.quiz_attempts (quiz_id, user_id)
  WHERE state = 'in_progress';
```

Try to enforce that in application code and you will lose a race eventually. The
index cannot lose it.

## Deferrable constraints for reordering

Positions within a module are unique, but reordering lessons temporarily
produces duplicates mid-transaction. `DEFERRABLE INITIALLY DEFERRED` means the
check runs at COMMIT, when the ordering is consistent again - so a reorder is a
plain UPDATE instead of a delete-and-reinsert dance.

## The one to remember

Nullable columns are a claim that the value is genuinely optional. Most nullable
columns in a young schema are really "we had not decided yet". Decide.
$md$,
   NULL,
   'Every constraint you skip is a class of bad row you have agreed to accept. Keys, CHECKs and partial unique indexes.',
   6, 400,
   '33333333-3333-4333-8333-333333333333', 'published', now() - interval '40 days'),

  ('e0000001-0000-4000-8000-00000000000c',
   'Full-Text Search with tsvector',
   'markdown',
$md$# Full-Text Search with tsvector

Before you add Elasticsearch, find out whether Postgres is already enough. For a
catalogue in the thousands or low millions of documents, it usually is.

## Weighting matters more than the index

A match in a title should beat a match buried in paragraph nine. `setweight`
gives you four bands, A through D:

```sql
search_vector tsvector GENERATED ALWAYS AS (
     setweight(to_tsvector('english', coalesce(title, '')),    'A')
  || setweight(to_tsvector('english', coalesce(subtitle, '')), 'B')
  || setweight(to_tsvector('english', coalesce(body, '')),     'C')
  || setweight(to_tsvector('english', coalesce(join_tags(tags), '')), 'D')
) STORED
```

Then `ts_rank` reads those weights when it scores. Without them every match is
equal and your results feel random.

## Generated columns need immutable expressions

That block will be rejected if any function in it is merely `STABLE`.
`array_to_string` is one - it is marked stable because it must handle element
types whose output function is stable. For a `text[]` it genuinely is immutable,
so wrap it and declare the truth:

```sql
CREATE FUNCTION join_tags(tags text[]) RETURNS text
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $fn$ SELECT array_to_string(tags, ' ') $fn$;
```

Do this only when the function really is immutable for the types you pass. Lying
to the planner corrupts indexes.

## Two indexes, two jobs

```sql
CREATE INDEX documents_vector_idx ON search.documents USING gin (search_vector);
CREATE INDEX documents_title_trgm_idx ON search.documents USING gin (title gin_trgm_ops);
```

The first answers real queries. The second catches typos: `pg_trgm` similarity
finds "postgresql" when someone types "postgrs", which `to_tsquery` never will
because the misspelling stems to a different lexeme.

## Query, then fall back

Run the tsquery. If it returns nothing, run the trigram similarity query and
label the results "did you mean". Two cheap queries beat one clever one, and the
second only runs on the rare empty result.
$md$,
   NULL,
   'Weighting, immutability rules for generated columns, and a trigram fallback for typos.',
   7, 470,
   '33333333-3333-4333-8333-333333333333', 'published', now() - interval '38 days')
ON CONFLICT (lesson_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- An article stored as HTML rather than Markdown, standing in for something
-- authored in a rich-text editor or synced from a headless CMS.
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, body_html, excerpt, reading_time_minutes, word_count,
   author_id, status, external_source, external_id, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000000f',
   'Escaping Everything You Echo',
   'html',
   '<h1>Escaping Everything You Echo</h1><p>There is one habit that closes most cross-site scripting holes in a server-rendered application, and it is boring: <strong>escape at the point of output, every time, with no exceptions you have to remember.</strong></p><h2>The function</h2><pre><code>function e(?string $value): string {
    return htmlspecialchars($value ?? &#39;&#39;, ENT_QUOTES | ENT_SUBSTITUTE, &#39;UTF-8&#39;);
}</code></pre><p>Three details in there earn their place. <code>ENT_QUOTES</code> escapes single quotes as well as double, so the function is safe inside a single-quoted attribute. <code>ENT_SUBSTITUTE</code> replaces invalid UTF-8 with a replacement character instead of returning an empty string, which is what turns a malformed byte sequence into a silently blank page. And naming the charset explicitly means you are not relying on an ini setting that differs between your laptop and production.</p><h2>Escape on output, not on input</h2><p>Sanitising on the way in feels tidier and is a trap. The same string might be rendered into HTML, put in a JSON response, written to a log and used in an email subject. Each of those needs different escaping, and a value that was HTML-escaped at input is now wrong in three of the four.</p><p>Store what the user typed. Escape it for the context you are writing it into, at the moment you write it.</p><h2>Context matters</h2><ul><li><strong>HTML text</strong> - <code>htmlspecialchars</code>.</li><li><strong>An attribute</strong> - the same, but the attribute must be quoted. <code>&lt;a href=&lt;?= e($url) ?&gt;&gt;</code> is exploitable no matter how you escape it.</li><li><strong>A URL parameter</strong> - <code>rawurlencode</code>, not <code>htmlspecialchars</code>.</li><li><strong>Inside a &lt;script&gt; block</strong> - <code>json_encode</code> with <code>JSON_HEX_TAG | JSON_HEX_AMP</code>. HTML escaping is the wrong tool here and will break your JavaScript while leaving it injectable.</li></ul><h2>The URL case that catches people</h2><p>Escaping a URL does not make it safe to put in an <code>href</code>. <code>javascript:alert(1)</code> contains no characters that <code>htmlspecialchars</code> touches. Check the scheme:</p><pre><code>function safe_url(?string $url): string {
    $url = trim($url ?? &#39;&#39;);
    return preg_match(&#39;~^https?://~i&#39;, $url) ? $url : &#39;#&#39;;
}</code></pre><p>This matters directly in a learning platform, where instructors supply video and thumbnail URLs. That is user input arriving through a trusted-looking door.</p>',
   '<h1>Escaping Everything You Echo</h1><p>There is one habit that closes most cross-site scripting holes in a server-rendered application, and it is boring: <strong>escape at the point of output, every time, with no exceptions you have to remember.</strong></p>',
   'One boring habit closes most XSS holes: escape at output, per context, every time.',
   5, 330,
   '22222222-2222-4222-8222-222222222222', 'published', 'demo-headless-cms', 'entry_7c31f9', now() - interval '18 days')
ON CONFLICT (lesson_id) DO NOTHING;

COMMIT;
