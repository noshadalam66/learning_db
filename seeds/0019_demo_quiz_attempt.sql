-- ===========================================================================
-- Seed 19 : a graded, failed attempt on the HTML Level 1 quiz
--
-- The profile page lists a learner's graded quiz results, best attempt per
-- quiz. Until this file existed the only graded attempts in the seed belonged
-- to the Node.js fixture course, and the best of those passed - so a freshly
-- seeded database had nothing to show for a real course and nothing at all in
-- the failed state.
--
-- The website smoke suite asserted on both, and passed only because a
-- development database accumulates attempts from earlier runs. On a clean
-- reset those assertions failed. This seeds what they were always assuming.
--
-- It has to be a separate file rather than part of 0005, because the quiz it
-- references is created in 0008 and seeds run in filename order.
--
-- Attempt 2, not 1: seed 0005 already leaves an in-progress attempt 1 on this
-- quiz to exercise the one-open-attempt rule, and (quiz, user, attempt_no) is
-- unique. Re-running must also reset submitted_at, or the second run flips the
-- existing row to 'submitted' with a null date and trips
-- ck_attempt_submitted_has_date.
-- ===========================================================================

INSERT INTO assessment_quiz_attempts
  (id, quiz_id, user_id, course_id, attempt_no, state, started_at, submitted_at)
VALUES
  ('a2000001-0000-4000-8000-000000000002', 'f0000001-0000-4000-8000-000000000004',
   '44444444-4444-4444-8444-444444444444', 'c0000001-0000-4000-8000-000000000004',
   2, 'submitted', DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 12 DAY),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 12 DAY))
ON DUPLICATE KEY UPDATE
  state = VALUES(state), submitted_at = VALUES(submitted_at);

-- Two of five right, worth 3 of 10 points: below the 60% pass mark, so the
-- profile has a genuinely failed row to render.
DELETE FROM assessment_attempt_answers
 WHERE attempt_id = 'a2000001-0000-4000-8000-000000000002';

INSERT INTO assessment_attempt_answers (attempt_id, question_id, selected_option_ids, text_answer)
SELECT 'a2000001-0000-4000-8000-000000000002', v.question_id,
       IFNULL(
         (SELECT JSON_ARRAYAGG(o.id) FROM assessment_question_options o
           WHERE o.question_id = v.question_id AND o.is_correct = v.want_correct),
         JSON_ARRAY()
       ),
       v.text_answer
  FROM (
    -- Right.
    SELECT 'a1000001-0000-4000-8000-000000000101' AS question_id, 1 AS want_correct,
           NULL AS text_answer
    -- Wrong.
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000102', 0, NULL
    -- Wrong: every incorrect option, so all-or-nothing scores zero.
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000103', 0, NULL
    -- Right.
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000104', 1, NULL
    -- Wrong: a short_text answer that is not the expected one.
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000105', NULL, 'target'
  ) v;

-- Graded by the same procedure the Quiz Service calls, so the stored score is
-- one the application would actually produce.
CALL assessment_grade_attempt('a2000001-0000-4000-8000-000000000002');
