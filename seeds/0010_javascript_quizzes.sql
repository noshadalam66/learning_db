-- ===========================================================================
-- Seed 10 : quizzes for the JavaScript course
--
-- One per level. The scratchpad on each quiz page opens on a JavaScript
-- starter, because starter_for_course() reads the course slug - so a learner
-- unsure about an answer can build the case and watch what it does.
-- ===========================================================================

INSERT INTO assessment.quizzes
  (id, course_id, lesson_id, title, description, pass_percent, time_limit_seconds,
   max_attempts, shuffle_questions, shuffle_options, show_answers, status)
VALUES
  ('f0000001-0000-4000-8000-00000000000c',
   'c0000001-0000-4000-8000-000000000006', 'e0000001-0000-4000-8000-00000000003d',
   'Level 1 Check: Values, Scope and Equality',
   'Types, equality, scope and reference semantics. Every one of these is something you can settle in the scratchpad below the questions.',
   60, 600, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-00000000000d',
   'c0000001-0000-4000-8000-000000000006', 'e0000001-0000-4000-8000-00000000003e',
   'Level 2 Check: Everyday JavaScript',
   'Array methods, destructuring and classes - the vocabulary you will use on every working day.',
   60, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-00000000000e',
   'c0000001-0000-4000-8000-000000000006', 'e0000001-0000-4000-8000-00000000003f',
   'Level 3 Check: Closures and Async',
   'Closures, promises and modules. Several of these are easier to answer by running them than by reasoning about them.',
   70, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-00000000000f',
   'c0000001-0000-4000-8000-000000000006', 'e0000001-0000-4000-8000-000000000040',
   'Expert Exam: JavaScript',
   'The event loop, iterators and generators, and the metaprogramming hooks underneath modern frameworks.',
   70, 1500, 3, 1, 1, 1, 'published')
ON DUPLICATE KEY UPDATE
  title = VALUES(title), description = VALUES(description),
  pass_percent = VALUES(pass_percent), status = VALUES(status);

INSERT INTO assessment.questions
  (id, quiz_id, kind, prompt, explanation, points, `position`, correct_text)
VALUES
  -- Level 1
  ('a1000001-0000-4000-8000-000000000181', 'f0000001-0000-4000-8000-00000000000c', 'single_choice',
   'What does typeof null return?',
   '"object". It is a bug from the first implementation in 1995, kept because fixing it would break the web. Check for null with value === null, never with typeof.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000182', 'f0000001-0000-4000-8000-00000000000c', 'single_choice',
   'const count = 0; What does count || 10 evaluate to, and what does count ?? 10 evaluate to?',
   '10 and 0. || falls through on any falsy value, and 0 is falsy - which is almost never what you meant for a number. ?? only falls through on null or undefined.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000183', 'f0000001-0000-4000-8000-00000000000c', 'multiple_choice',
   'Which of these values are falsy? Select all that apply.',
   'Exactly eight values are falsy: false, 0, -0, 0n, the empty string, null, undefined and NaN. An empty array and an empty object are both truthy, which is the pair that catches people - use .length or Object.keys().length instead.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000184', 'f0000001-0000-4000-8000-00000000000c', 'true_false',
   'Declaring an object with const prevents its properties from being changed.',
   'It does not. const stops the binding being reassigned, not the value being mutated. Object.freeze() stops mutation, and only one level deep.',
   1, 4, NULL),

  ('a1000001-0000-4000-8000-000000000185', 'f0000001-0000-4000-8000-00000000000c', 'short_text',
   'A for loop pushes three arrow functions returning the loop variable. With var they all return 3; with the other keyword they return 0, 1 and 2. Which keyword? Give it in lower case.',
   'let. var is function-scoped, so all three closures share one binding. let creates a fresh binding on each iteration, which is what gives each closure its own value.',
   2, 5, 'let'),

  -- Level 2
  ('a1000001-0000-4000-8000-000000000191', 'f0000001-0000-4000-8000-00000000000d', 'single_choice',
   'What does [10, 9, 100, 1].sort() return?',
   '[1, 10, 100, 9]. With no comparator, sort converts every element to a string and compares those, so "100" sorts before "9". Pass (a, b) => a - b for numbers.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-000000000192', 'f0000001-0000-4000-8000-00000000000d', 'single_choice',
   'Why should you always pass the initial value to reduce?',
   'Without it, reduce uses the first element as the accumulator - which changes the accumulator type on a one-element array and throws a TypeError on an empty one.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-000000000193', 'f0000001-0000-4000-8000-00000000000d', 'multiple_choice',
   'Which of these array methods change the array they are called on? Select all that apply.',
   'sort, reverse and splice all mutate. map, filter and slice return a new array. toSorted and toReversed are the non-mutating versions of the first two, which is what [...array].sort() used to be for.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-000000000194', 'f0000001-0000-4000-8000-00000000000d', 'single_choice',
   'function f({ a } = {}) {} - what does the = {} prevent?',
   'A TypeError when f() is called with no argument. You cannot destructure undefined, so without the default the call throws instead of using the defaults inside the pattern.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-000000000195', 'f0000001-0000-4000-8000-00000000000d', 'true_false',
   'A #private field in a class can still be read with bracket notation from outside.',
   'It cannot. Unlike a leading underscore, which is a convention, # is enforced by the language: the field is invisible to bracket access, to Object.keys and to JSON.stringify.',
   1, 5, NULL),

  -- Level 3
  ('a1000001-0000-4000-8000-0000000001a1', 'f0000001-0000-4000-8000-00000000000e', 'single_choice',
   'A closure captures a variable. If two closures capture the same variable and one of them changes it, what does the other see?',
   'The new value. A closure keeps the variable itself, not a copy of its value. That sharing is the feature in a counter factory and the bug in the classic var loop - the same mechanism either way.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001a2', 'f0000001-0000-4000-8000-00000000000e', 'single_choice',
   'You have an array of ids and an async fetchOne(id). What is the difference between awaiting inside a for loop and Promise.all(ids.map(fetchOne))?',
   'The loop runs them one at a time; Promise.all starts them all together. For ten requests of 100ms that is one second against roughly one hundred milliseconds. The loop is right only when each step depends on the last, or when you are deliberately rate-limiting.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001a3', 'f0000001-0000-4000-8000-00000000000e', 'single_choice',
   'Which combinator never rejects, and reports what happened to every promise?',
   'Promise.allSettled. It resolves to an array of { status, value } or { status, reason } objects. Promise.all rejects on the first failure, race settles on the first of either kind, and any resolves on the first success.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001a4', 'f0000001-0000-4000-8000-00000000000e', 'true_false',
   'try { riskyAsyncFn(); } catch (e) {} will catch an error thrown inside that async function.',
   'It will not. An async function never throws synchronously - it returns a rejected promise. Without await, the try block finishes before the rejection happens, and the result is an unhandled rejection.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001a5', 'f0000001-0000-4000-8000-00000000000e', 'single_choice',
   'You import the same module from ten different files. How many times does its top-level code run?',
   'Once. The module registry caches by resolved URL, which makes a module a natural singleton - and means top-level side effects happen at a time you do not control.',
   2, 5, NULL),

  -- Level 4
  ('a1000001-0000-4000-8000-0000000001b1', 'f0000001-0000-4000-8000-00000000000f', 'single_choice',
   'A script logs "A", schedules setTimeout(log "D", 0), resolves a promise logging "C", then logs "B". What order do they print in?',
   'A, B, C, D. All synchronous code runs first, then the entire microtask queue - promise callbacks - and only then the first macrotask. setTimeout(fn, 0) means "queue this as a macrotask", not "run this now".',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001b2', 'f0000001-0000-4000-8000-00000000000f', 'single_choice',
   'Why can a recursive chain of microtasks freeze a page when a slow function might not?',
   'The microtask queue is drained completely before the loop moves on. A microtask that queues another microtask means the queue never empties, so rendering and macrotasks never get a turn. A slow function at least finishes.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001b3', 'f0000001-0000-4000-8000-00000000000f', 'multiple_choice',
   'Which of these use the iterator protocol? Select all that apply.',
   'for...of, spread and array destructuring all go through [Symbol.iterator], which is why implementing it on your own type makes all of them work at once. Object.keys does not - it reads own enumerable string keys directly.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001b4', 'f0000001-0000-4000-8000-00000000000f', 'single_choice',
   'Why should a Proxy trap call the matching Reflect method rather than doing the operation directly?',
   'Reflect gives the default behaviour with the correct receiver. Writing obj[key] = value inside a set trap skips setters further up the prototype chain and passes the wrong this; Reflect.set also returns the boolean a set trap is required to return.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001b5', 'f0000001-0000-4000-8000-00000000000f', 'true_false',
   'Spreading an infinite generator into an array is fine as long as you only read the first few items.',
   'It is not. Spread asks the iterator for everything, so it never terminates. Laziness only helps if the consumer stops taking - wrap it in a take(iterable, n) generator instead.',
   2, 5, NULL)
ON DUPLICATE KEY UPDATE
  prompt = VALUES(prompt), explanation = VALUES(explanation),
  points = VALUES(points), correct_text = VALUES(correct_text);

DELETE FROM assessment.question_options
 WHERE question_id IN (
   SELECT id FROM assessment.questions
    WHERE quiz_id IN ('f0000001-0000-4000-8000-00000000000c',
                      'f0000001-0000-4000-8000-00000000000d',
                      'f0000001-0000-4000-8000-00000000000e',
                      'f0000001-0000-4000-8000-00000000000f'));

INSERT INTO assessment.question_options (question_id, body, is_correct, `position`)
SELECT v.question_id, v.body, v.is_correct, v.pos
  FROM (
    SELECT 'a1000001-0000-4000-8000-000000000181' AS question_id, '"object" - a bug from 1995, kept for compatibility' AS body, 1 AS is_correct, 1 AS pos
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000181', '"null"', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000181', '"undefined"', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000181', 'It throws a TypeError', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000182', '10 and 0', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000182', '0 and 10', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000182', '10 and 10', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000182', '0 and 0', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000183', '0', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000183', 'The empty string', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000183', 'NaN', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000183', 'An empty array', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000184', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000184', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000191', '[1, 10, 100, 9] - it compares them as strings', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000191', '[1, 9, 10, 100]', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000191', '[100, 10, 9, 1]', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000191', 'The original order, unchanged', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000192', 'Without it, an empty array throws and a one-element array changes type', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000192', 'It is required by the syntax', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000192', 'It makes reduce run faster', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000192', 'It is only needed for objects', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000193', 'sort', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000193', 'reverse', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000193', 'splice', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000193', 'map', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000194', 'A TypeError when the function is called with no argument', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000194', 'The properties being mutated', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000194', 'Extra properties being passed in', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000194', 'Nothing - it is stylistic', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000195', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-000000000195', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a1', 'The new value - a closure keeps the variable, not a copy', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a1', 'The value as it was when the closure was created', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a1', 'undefined', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a1', 'It depends on whether the closure is an arrow function', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a2', 'The loop runs them one at a time; Promise.all starts them all together', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a2', 'They behave identically', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a2', 'Promise.all runs them one at a time', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a2', 'The loop is faster because it reuses one connection', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a3', 'Promise.allSettled', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a3', 'Promise.all', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a3', 'Promise.race', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a3', 'Promise.any', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a4', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a4', 'False', 1, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a5', 'Once - the module registry caches it by resolved URL', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a5', 'Ten times, once per import', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a5', 'Once per importing directory', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001a5', 'It depends on whether the import is dynamic', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b1', 'A, B, C, D', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b1', 'A, B, D, C', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b1', 'A, C, B, D', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b1', 'A, D, C, B', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b2', 'The microtask queue is drained fully before anything else runs, so it never empties', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b2', 'Microtasks run on a separate thread that can deadlock', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b2', 'Promises allocate memory that is never freed', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b2', 'It cannot - microtasks always yield between each one', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b3', 'for...of', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b3', 'Spreading with ...', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b3', 'Array destructuring', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b3', 'Object.keys', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b4', 'Reflect gives the default behaviour with the correct receiver', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b4', 'Reflect is faster', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b4', 'Reflect is required syntax inside a trap', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b4', 'It makes the proxy immutable', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b5', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001b5', 'False', 1, 2
  ) v;

CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000006');
CALL `search`.reindex_all();
