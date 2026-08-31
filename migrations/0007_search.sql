-- ===========================================================================
-- 0007 : search schema  --  owned by the Search Service
--
-- One denormalised document table covering every searchable entity, with a
-- generated tsvector and a GIN index. Weighting: A=title, B=subtitle/summary,
-- C=body, D=tags. Trigram indexes back the fuzzy fallback so a typo like
-- "postgrs" still finds "PostgreSQL".
-- ===========================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- array_to_string() is only marked STABLE because it has to cope with element
-- types whose output function is stable. For a text[] and a constant delimiter
-- it genuinely is immutable, and the generated column below needs it to be, so
-- we wrap it and say so.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION search.join_tags(tags text[])
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
RETURNS NULL ON NULL INPUT
AS $$ SELECT array_to_string(tags, ' ') $$;

CREATE TABLE search.documents (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type   text NOT NULL CHECK (entity_type IN ('course', 'lesson', 'article')),
  entity_id     uuid NOT NULL,
  course_id     uuid,
  title         text NOT NULL,
  subtitle      text NOT NULL DEFAULT '',
  body          text NOT NULL DEFAULT '',
  tags          text[] NOT NULL DEFAULT '{}',
  url_path      text NOT NULL,
  language      text NOT NULL DEFAULT 'en',
  level         public.course_level,
  is_published  boolean NOT NULL DEFAULT true,
  popularity    integer NOT NULL DEFAULT 0,
  indexed_at    timestamptz NOT NULL DEFAULT now(),

  search_vector tsvector GENERATED ALWAYS AS (
      setweight(to_tsvector('english', coalesce(title, '')),    'A')
   || setweight(to_tsvector('english', coalesce(subtitle, '')), 'B')
   || setweight(to_tsvector('english', coalesce(body, '')),     'C')
   || setweight(to_tsvector('english', coalesce(search.join_tags(tags), '')), 'D')
  ) STORED,

  CONSTRAINT documents_unique_entity UNIQUE (entity_type, entity_id)
);

COMMENT ON TABLE search.documents IS 'Flattened copy of courses, lessons and articles, rebuilt by search.reindex_all().';

CREATE INDEX documents_vector_idx  ON search.documents USING gin (search_vector);
CREATE INDEX documents_title_trgm_idx ON search.documents USING gin (title gin_trgm_ops);
CREATE INDEX documents_tags_idx    ON search.documents USING gin (tags);
CREATE INDEX documents_course_idx  ON search.documents (course_id);
CREATE INDEX documents_type_idx    ON search.documents (entity_type) WHERE is_published;

-- ---------------------------------------------------------------------------
-- What people actually typed. Feeds autocomplete and the Analytics Service's
-- "queries with no results" report.
-- ---------------------------------------------------------------------------
CREATE TABLE search.query_log (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      uuid,
  query_text   text NOT NULL,
  result_count integer NOT NULL DEFAULT 0,
  clicked_entity_id uuid,
  searched_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX query_log_text_idx ON search.query_log USING gin (query_text gin_trgm_ops);
CREATE INDEX query_log_time_idx ON search.query_log (searched_at DESC);
CREATE INDEX query_log_empty_idx ON search.query_log (query_text) WHERE result_count = 0;

-- ---------------------------------------------------------------------------
-- Editor-curated synonyms, applied by the Search Service before it builds the
-- tsquery ("js" -> "javascript").
-- ---------------------------------------------------------------------------
CREATE TABLE search.synonyms (
  id      smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  term    text NOT NULL UNIQUE,
  expands_to text[] NOT NULL
);

-- ---------------------------------------------------------------------------
-- Full rebuild of the index from the owning schemas. Cheap enough to run on a
-- schedule for a catalogue of this size; the Search Service also upserts single
-- documents when it receives a change event.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION search.reindex_all()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  n integer;
BEGIN
  TRUNCATE search.documents;

  INSERT INTO search.documents
    (entity_type, entity_id, course_id, title, subtitle, body, tags, url_path, language, level, is_published, popularity)
  SELECT 'course',
         c.id,
         c.id,
         c.title,
         c.subtitle,
         c.description || ' ' || array_to_string(c.learning_outcomes, ' '),
         coalesce((SELECT array_agg(t.name)
                     FROM catalog.course_tags ct
                     JOIN catalog.tags t ON t.id = ct.tag_id
                    WHERE ct.course_id = c.id), '{}'),
         '/course.php?slug=' || c.slug,
         c.language,
         c.level,
         c.status = 'published',
         c.rating_count
    FROM catalog.courses c;

  INSERT INTO search.documents
    (entity_type, entity_id, course_id, title, subtitle, body, url_path, language, is_published)
  SELECT 'lesson',
         l.id,
         l.course_id,
         l.title,
         l.summary,
         coalesce(v.transcript, ''),
         '/lesson.php?course=' || c.slug || '&lesson=' || l.slug,
         c.language,
         l.status = 'published' AND c.status = 'published'
    FROM catalog.lessons l
    JOIN catalog.courses c ON c.id = l.course_id
    LEFT JOIN content.lesson_videos v ON v.lesson_id = l.id;

  INSERT INTO search.documents
    (entity_type, entity_id, course_id, title, subtitle, body, url_path, language, is_published)
  SELECT 'article',
         a.id,
         l.course_id,
         a.title,
         a.excerpt,
         a.body,
         '/lesson.php?course=' || c.slug || '&lesson=' || l.slug,
         c.language,
         a.status = 'published'
    FROM content.articles a
    JOIN catalog.lessons l ON l.id = a.lesson_id
    JOIN catalog.courses c ON c.id = l.course_id;

  GET DIAGNOSTICS n = ROW_COUNT;
  SELECT count(*) INTO n FROM search.documents;
  RETURN n;
END;
$$;

COMMENT ON FUNCTION search.reindex_all() IS 'Rebuilds search.documents from catalog and content. Returns the document count.';

COMMIT;
