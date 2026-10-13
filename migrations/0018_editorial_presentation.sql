-- ===========================================================================
-- 0018 : how an editorial post is presented
--
-- content_editorial_posts (0016) holds a guide or a blog post and says nothing
-- about how it looks, which was right until the admin panel gained the ability
-- to write one. Four columns: a picture at the top, and the two typographic
-- choices the panel offers.
--
-- A SEPARATE MIGRATION rather than an edit to 0016, because migrations here are
-- immutable and 0016 may already be applied. Fix forward.
--
-- NO CSS IS STORED IN ANY OF THESE, and that is the whole design rather than a
-- detail. font_family holds a token - 'sans', 'serif', 'mono' - which the front
-- end maps to a stack it already owns. font_weight holds a number.
--
-- The alternative, a VARCHAR that the page drops into a style attribute, is a
-- stylesheet injection: a value of
--
--   sans-serif } .site-header { display: none } .x {
--
-- escapes the declaration it was meant to sit in and rewrites the rest of the
-- page. Escaping that correctly means writing a CSS parser. A token cannot
-- carry the attack at all, because nothing from the database reaches the style
-- sheet - only the decision of which of three stacks to use.
--
-- The CHECK on font_weight is belt and braces next to the application's own
-- validation. MariaDB enforces it; MySQL 8 does too. A weight outside 100..900
-- is meaningless to a browser and would silently fall back to normal, which
-- looks like the setting not working rather than like a bad value.
-- ===========================================================================

ALTER TABLE content_editorial_posts
  ADD COLUMN hero_image_url VARCHAR(2000) NULL AFTER subtitle,
  ADD COLUMN hero_image_alt VARCHAR(300) NULL AFTER hero_image_url,
  ADD COLUMN font_family VARCHAR(16) NULL AFTER tags,
  ADD COLUMN font_weight SMALLINT UNSIGNED NULL AFTER font_family;

-- Named, so a failure says which rule was broken rather than naming the table.
ALTER TABLE content_editorial_posts
  ADD CONSTRAINT ck_editorial_font_weight
    CHECK (font_weight IS NULL OR (font_weight BETWEEN 100 AND 900));

ALTER TABLE content_editorial_posts
  ADD CONSTRAINT ck_editorial_font_family
    CHECK (font_family IS NULL OR font_family IN ('sans', 'serif', 'mono'));
