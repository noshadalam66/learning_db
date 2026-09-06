-- ===========================================================================
-- 0004 : content  --  owned by the Content Service
--
-- Two kinds of lesson body live here:
--   * articles      -> the text itself, stored as Markdown or HTML
--   * lesson_videos -> ONLY the URL and metadata of a video. The video file is
--                      never stored in MySQL; it lives on YouTube / Vimeo /
--                      Mux / Cloudflare Stream / S3+CDN and we keep a pointer.
--
-- tests/verify.sql asserts that no BLOB column ever appears in this database,
-- so "just store the small ones inline" fails the build instead of shipping.
-- ===========================================================================

CREATE TABLE content_lesson_videos (
  id                CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- catalog_lessons.id - deliberately not a foreign key.
  lesson_id         CHAR(36) CHARACTER SET ascii NOT NULL,
  provider          ENUM('youtube','vimeo','mux','cloudflare','bunny','s3','external')
                      NOT NULL DEFAULT 'external',
  provider_asset_id VARCHAR(200) NULL,
  -- The URL of the video, NOT the video itself.
  video_url         VARCHAR(2000) NOT NULL,
  hls_url           VARCHAR(2000) NULL,
  download_url      VARCHAR(2000) NULL,
  thumbnail_url     VARCHAR(2000) NULL,
  captions_url      VARCHAR(2000) NULL,
  -- Plain-text transcript. Indexed by the Search Service, which is how a
  -- search for a phrase spoken in a video finds the lesson.
  transcript        MEDIUMTEXT NULL,
  duration_seconds  INT NOT NULL DEFAULT 0,
  width             INT NULL,
  height            INT NULL,
  created_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at        DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_video_lesson (lesson_id),
  KEY ix_video_provider (provider),

  CONSTRAINT ck_video_url_is_http CHECK (REGEXP_LIKE(video_url, '^https?://')),
  CONSTRAINT ck_video_hls_is_http
    CHECK (hls_url IS NULL OR REGEXP_LIKE(hls_url, '^https?://')),
  CONSTRAINT ck_video_thumb_is_http
    CHECK (thumbnail_url IS NULL OR REGEXP_LIKE(thumbnail_url, '^https?://')),
  CONSTRAINT ck_video_duration_positive CHECK (duration_seconds >= 0)
) ENGINE=InnoDB
  COMMENT='Pointers to externally hosted video. No media is stored in this database.';

-- ---------------------------------------------------------------------------
-- Articles.
--
-- format = 'markdown' -> body holds Markdown, body_html holds the render cache
-- format = 'html'     -> body holds sanitised HTML from a rich editor or a CMS
--
-- Either way the read path serves body_html, so consumers never branch on
-- format. body_html is a cache and may legitimately be NULL: the Content
-- Service renders from body when it is.
--
-- external_source / external_id are set when a row was synced in from a
-- headless CMS. That is what makes "database OR headless CMS" a per-article
-- configuration choice rather than a fork of the schema.
-- ---------------------------------------------------------------------------
CREATE TABLE content_articles (
  id                   CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- catalog_lessons.id - deliberately not a foreign key.
  lesson_id            CHAR(36) CHARACTER SET ascii NOT NULL,
  title                VARCHAR(300) NOT NULL,
  format               ENUM('markdown','html') NOT NULL DEFAULT 'markdown',
  body                 MEDIUMTEXT NOT NULL,
  body_html            MEDIUMTEXT NULL,
  excerpt              VARCHAR(500) NOT NULL DEFAULT '',
  reading_time_minutes INT NOT NULL DEFAULT 0,
  word_count           INT NOT NULL DEFAULT 0,
  revision             INT NOT NULL DEFAULT 1,
  -- identity_users.id - deliberately not a foreign key.
  author_id            CHAR(36) CHARACTER SET ascii NULL,
  status               ENUM('draft','in_review','published','archived') NOT NULL DEFAULT 'draft',
  external_source      VARCHAR(100) NULL,
  external_id          VARCHAR(200) NULL,
  published_at         DATETIME(3) NULL,
  created_at           DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),
  updated_at           DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_article_lesson (lesson_id),
  KEY ix_articles_status (status, published_at DESC),
  KEY ix_articles_author (author_id),
  KEY ix_articles_external (external_source, external_id),

  CONSTRAINT ck_articles_body_not_blank CHECK (TRIM(body) <> ''),
  CONSTRAINT ck_articles_revision_positive CHECK (revision > 0),
  CONSTRAINT ck_articles_published_has_date
    CHECK (status <> 'published' OR published_at IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE content_article_revisions (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  article_id CHAR(36) CHARACTER SET ascii NOT NULL,
  revision   INT NOT NULL,
  format     ENUM('markdown','html') NOT NULL,
  title      VARCHAR(300) NOT NULL,
  body       MEDIUMTEXT NOT NULL,
  edited_by  CHAR(36) CHARACTER SET ascii NULL,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_revision (article_id, revision),
  KEY ix_revisions_article (article_id, revision DESC),

  CONSTRAINT fk_revisions_article FOREIGN KEY (article_id)
    REFERENCES content_articles (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Downloadable extras attached to a lesson. Again: a URL, never the bytes.
CREATE TABLE content_lesson_attachments (
  id         CHAR(36) CHARACTER SET ascii NOT NULL DEFAULT (UUID()),
  -- catalog_lessons.id - deliberately not a foreign key.
  lesson_id  CHAR(36) CHARACTER SET ascii NOT NULL,
  title      VARCHAR(200) NOT NULL,
  file_url   VARCHAR(2000) NOT NULL,
  mime_type  VARCHAR(150) NOT NULL DEFAULT 'application/octet-stream',
  size_bytes BIGINT NULL,
  `position` INT NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT (UTC_TIMESTAMP(3)),

  PRIMARY KEY (id),
  UNIQUE KEY uq_attachment_url (lesson_id, file_url(255)),
  KEY ix_attachments_lesson (lesson_id, `position`),

  CONSTRAINT ck_attachment_url_is_http CHECK (REGEXP_LIKE(file_url, '^https?://')),
  CONSTRAINT ck_attachment_size_positive CHECK (size_bytes IS NULL OR size_bytes >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- Triggers: touch updated_at, and snapshot the previous body before it is
-- overwritten so an author can roll back.
-- ---------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_videos_touch
  BEFORE UPDATE ON content_lesson_videos FOR EACH ROW
BEGIN SET NEW.updated_at = UTC_TIMESTAMP(3); END$$

CREATE TRIGGER trg_articles_snapshot
  BEFORE UPDATE ON content_articles FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP(3);

  IF NOT (NEW.body <=> OLD.body) OR NOT (NEW.title <=> OLD.title) THEN
    INSERT INTO content_article_revisions (article_id, revision, format, title, body, edited_by)
    VALUES (OLD.id, OLD.revision, OLD.format, OLD.title, OLD.body, OLD.author_id);
    SET NEW.revision = OLD.revision + 1;
  END IF;
END$$

DELIMITER ;
