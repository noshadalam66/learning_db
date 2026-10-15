-- ===========================================================================
-- 0019 : a blog post may name a course
--
-- 0016 made one table safe for two kinds of writing with this rule:
--
--   (kind = 'course_guide' AND course_id IS NOT NULL)
--     OR (kind = 'blog_post' AND course_id IS NULL)
--
-- The second half is too strong, and the admin panel is what showed it. A
-- course's last topic now ends with "where to go from here": its guide, and
-- the articles about its subject. An article about semantic markup belongs to
-- the HTML course in exactly that sense - it is not the course's guide, and it
-- is not unrelated to it either - and under the old rule there was nowhere to
-- say so. The INSERT failed with
--
--   CONSTRAINT `ck_editorial_course_matches_kind` failed
--
-- which is the constraint doing its job against a rule that had stopped being
-- true.
--
-- THE HALF THAT STAYS is the half that matters: a guide without a course is
-- not a guide, because the only way to reach one is from the course it belongs
-- to. A blog post's course is now optional - set, and it is listed under that
-- course as well as on the blog; unset, and it is simply an article.
--
-- A NEW MIGRATION rather than an edit to 0016, because migrations here are
-- immutable and 0016 is applied on the live database already. Fix forward.
--
-- No IF EXISTS on the DROP: MySQL 8 has no such clause for a constraint, and
-- the constraint is certainly there - 0016 created it. Run this once.
-- ===========================================================================

ALTER TABLE content_editorial_posts
  DROP CONSTRAINT ck_editorial_course_matches_kind;

ALTER TABLE content_editorial_posts
  ADD CONSTRAINT ck_editorial_guide_has_course
    CHECK (kind <> 'course_guide' OR course_id IS NOT NULL);
