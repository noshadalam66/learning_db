-- ===========================================================================
-- 0004 : content schema  --  owned by the Content Service
--
-- Two kinds of lesson body live here:
--   * articles      -> the text itself, stored as Markdown or HTML
--   * lesson_videos -> ONLY the URL and metadata of a video. The video file is
--                      never stored in Postgres; it lives on YouTube / Vimeo /
--                      Mux / Cloudflare Stream / S3+CDN and we keep a pointer.
-- ===========================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Video metadata. lesson_id references catalog.lessons logically only (the
-- Course Service owns that table), so it carries no FK.
-- ---------------------------------------------------------------------------
CREATE TABLE content.lesson_videos (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id        uuid NOT NULL UNIQUE,
  provider         public.video_provider NOT NULL DEFAULT 'external',
  provider_asset_id text,                    -- e.g. the YouTube id or Mux playback id
  video_url        text NOT NULL,            -- canonical watch/embed URL
  hls_url          text,                     -- adaptive stream, when the provider has one
  download_url     text,                     -- optional progressive MP4
  thumbnail_url    text,
  captions_url     text,                     -- WebVTT track
  transcript       text,                     -- plain-text transcript, feeds Search
  duration_seconds integer NOT NULL DEFAULT 0,
  width            integer,
  height           integer,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT lesson_videos_url_is_http      CHECK (video_url ~ '^https?://'),
  CONSTRAINT lesson_videos_hls_is_http      CHECK (hls_url IS NULL OR hls_url ~ '^https?://'),
  CONSTRAINT lesson_videos_thumb_is_http    CHECK (thumbnail_url IS NULL OR thumbnail_url ~ '^https?://'),
  CONSTRAINT lesson_videos_duration_positive CHECK (duration_seconds >= 0)
);

COMMENT ON TABLE  content.lesson_videos           IS 'Pointers to externally hosted video. No binary media is ever stored in this database.';
COMMENT ON COLUMN content.lesson_videos.video_url IS 'The URL of the video, NOT the video itself.';

CREATE INDEX lesson_videos_provider_idx ON content.lesson_videos (provider);

CREATE TRIGGER lesson_videos_touch
  BEFORE UPDATE ON content.lesson_videos
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Articles. The current row is the published body; every edit is snapshotted
-- into content.article_revisions so an author can roll back.
--
-- format = 'markdown' -> body holds Markdown, body_html holds the render cache
-- format = 'html'     -> body holds sanitised HTML authored in a rich editor
-- Either way the read path serves body_html, so the PHP front end and any
-- headless-CMS import land on the same contract.
-- ---------------------------------------------------------------------------
CREATE TABLE content.articles (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id            uuid NOT NULL UNIQUE,
  title                text NOT NULL,
  format               public.article_format NOT NULL DEFAULT 'markdown',
  body                 text NOT NULL,
  body_html            text,
  excerpt              text NOT NULL DEFAULT '',
  reading_time_minutes integer NOT NULL DEFAULT 0,
  word_count           integer NOT NULL DEFAULT 0,
  revision             integer NOT NULL DEFAULT 1,
  author_id            uuid,
  status               public.publish_status NOT NULL DEFAULT 'draft',
  external_source      text,     -- set when the body was imported from a headless CMS
  external_id          text,     -- the entry id in that CMS
  published_at         timestamptz,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT articles_body_not_blank CHECK (btrim(body) <> ''),
  CONSTRAINT articles_revision_positive CHECK (revision > 0),
  CONSTRAINT articles_published_has_date
    CHECK (status <> 'published' OR published_at IS NOT NULL)
);

COMMENT ON COLUMN content.articles.body            IS 'Raw article source: Markdown or sanitised HTML depending on format.';
COMMENT ON COLUMN content.articles.body_html       IS 'Rendered HTML cache. Regenerated whenever body changes.';
COMMENT ON COLUMN content.articles.external_source IS 'Name of the headless CMS this entry was synced from, NULL for locally authored articles.';

CREATE INDEX articles_status_idx   ON content.articles (status, published_at DESC);
CREATE INDEX articles_author_idx   ON content.articles (author_id);
CREATE INDEX articles_external_idx ON content.articles (external_source, external_id)
  WHERE external_source IS NOT NULL;

CREATE TRIGGER articles_touch
  BEFORE UPDATE ON content.articles
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

CREATE TABLE content.article_revisions (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id uuid NOT NULL REFERENCES content.articles (id) ON DELETE CASCADE,
  revision   integer NOT NULL,
  format     public.article_format NOT NULL,
  title      text NOT NULL,
  body       text NOT NULL,
  edited_by  uuid,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT article_revisions_unique UNIQUE (article_id, revision)
);

CREATE INDEX article_revisions_article_idx
  ON content.article_revisions (article_id, revision DESC);

-- Snapshot the previous body before it is overwritten.
CREATE OR REPLACE FUNCTION content.snapshot_article_revision()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.body IS DISTINCT FROM OLD.body OR NEW.title IS DISTINCT FROM OLD.title THEN
    INSERT INTO content.article_revisions (article_id, revision, format, title, body, edited_by)
    VALUES (OLD.id, OLD.revision, OLD.format, OLD.title, OLD.body, OLD.author_id);
    NEW.revision := OLD.revision + 1;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER articles_snapshot
  BEFORE UPDATE ON content.articles
  FOR EACH ROW EXECUTE FUNCTION content.snapshot_article_revision();

-- ---------------------------------------------------------------------------
-- Downloadable extras attached to a lesson (slides, cheat sheets, sample code).
-- Again: a URL, never the bytes.
-- ---------------------------------------------------------------------------
CREATE TABLE content.lesson_attachments (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id  uuid NOT NULL,
  title      text NOT NULL,
  file_url   text NOT NULL,
  mime_type  text NOT NULL DEFAULT 'application/octet-stream',
  size_bytes bigint,
  position   integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT lesson_attachments_url_is_http CHECK (file_url ~ '^https?://'),
  CONSTRAINT lesson_attachments_size_positive CHECK (size_bytes IS NULL OR size_bytes >= 0)
);

CREATE INDEX lesson_attachments_lesson_idx ON content.lesson_attachments (lesson_id, position);

COMMIT;
