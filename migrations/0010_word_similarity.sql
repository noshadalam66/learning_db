-- ===========================================================================
-- 0010 : search.word_similarity()
--
-- similarity_score() compares two strings whole. That is the wrong measure for
-- a typo fallback: a short misspelled query against a long title always scores
-- low no matter how well it matches one word inside it.
--
--   similarity_score('microservics', 'Node.js Microservices from Scratch') = 0.353
--   word_similarity('microservics',  'Node.js Microservices from Scratch') = 0.923
--
-- With a 0.4 threshold the first silently disables the fallback and the second
-- works. This is exactly the distinction PostgreSQL draws between similarity()
-- and word_similarity(), and it is worth naming the functions the same way so
-- the mistake is harder to make twice.
-- ===========================================================================

DELIMITER $$

CREATE FUNCTION `search`.word_similarity(needle VARCHAR(255), haystack VARCHAR(500))
RETURNS DECIMAL(4,3)
DETERMINISTIC
NO SQL
BEGIN
  DECLARE best     DECIMAL(4,3) DEFAULT 0;
  DECLARE current  DECIMAL(4,3);
  DECLARE rest     VARCHAR(500);
  DECLARE word     VARCHAR(255);

  IF needle IS NULL OR haystack IS NULL THEN RETURN 0; END IF;

  -- Normalise separators to single spaces so punctuation does not glue words
  -- together ("Node.js Microservices" must yield two candidates, not one).
  SET rest = TRIM(REGEXP_REPLACE(LOWER(haystack), '[^a-z0-9]+', ' '));
  SET needle = LOWER(TRIM(needle));

  IF rest = '' OR needle = '' THEN RETURN 0; END IF;

  -- Walk the words. A cursor would need a table; splitting a space-separated
  -- string in a loop is the usual MySQL idiom for this.
  WHILE rest <> '' DO
    SET word = SUBSTRING_INDEX(rest, ' ', 1);

    IF word <> '' THEN
      SET current = `search`.similarity_score(needle, word);
      IF current > best THEN SET best = current; END IF;
    END IF;

    IF LOCATE(' ', rest) = 0 THEN
      SET rest = '';
    ELSE
      SET rest = TRIM(SUBSTRING(rest, LOCATE(' ', rest) + 1));
    END IF;
  END WHILE;

  RETURN best;
END$$

DELIMITER ;
