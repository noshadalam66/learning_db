-- ===========================================================================
-- 0013 : the outline carries each module's summary
--
-- catalog_modules.summary has existed since 0003 and has been written by every
-- course seed since, but nothing could read it: v_course_outline selected the
-- module's id, title and position and stopped there. The course page and the
-- lesson page both read their structure from that view, through the Course
-- Service's findOutline(), so a learner has never seen a word of it.
--
-- The curriculum sidebar is what needs it. A list of four levels named "Level 1
-- - Basic" to "Level 4 - Expert" says nothing about what is inside them; the
-- summary is the sentence that does, and it is already written.
--
-- This is CREATE OR REPLACE VIEW with one column added. A view holds no data,
-- so replacing it rewrites a definition and nothing else - no table is touched,
-- no row is rewritten, and a query that does not ask for module_summary behaves
-- exactly as it did. The column is added next to the other module columns
-- rather than at the end because the view is read by name everywhere, never by
-- position.
-- ===========================================================================

CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_course_outline AS
SELECT
  c.id            AS course_id,
  c.slug          AS course_slug,
  c.title         AS course_title,
  c.status        AS course_status,
  m.id            AS module_id,
  m.title         AS module_title,
  m.summary       AS module_summary,
  m.`position`    AS module_position,
  l.id            AS lesson_id,
  l.slug          AS lesson_slug,
  l.title         AS lesson_title,
  l.summary       AS lesson_summary,
  l.kind          AS lesson_kind,
  l.`position`    AS lesson_position,
  l.duration_seconds,
  l.is_free_preview,
  l.status        AS lesson_status,
  v.video_url,
  v.hls_url,
  v.thumbnail_url AS video_thumbnail_url,
  v.provider      AS video_provider,
  a.id            AS article_id,
  a.format        AS article_format,
  a.reading_time_minutes,
  q.id            AS quiz_id,
  q.title         AS quiz_title,
  q.pass_percent
FROM catalog_courses c
JOIN catalog_modules m ON m.course_id = c.id
JOIN catalog_lessons l ON l.module_id = m.id
LEFT JOIN content_lesson_videos v ON v.lesson_id = l.id
LEFT JOIN content_articles      a ON a.lesson_id = l.id
LEFT JOIN assessment_quizzes    q ON q.lesson_id = l.id;
