-- ===========================================================================
-- Seed 12 : quizzes for the TypeScript course
--
-- One per level, attached to the quiz lesson that closes each module. The
-- scratchpad on the quiz page opens on a TypeScript starter, so a learner can
-- paste a question's snippet in and watch the compiler answer it - which for
-- type questions is more convincing than any explanation.
-- ===========================================================================

INSERT INTO assessment.quizzes
  (id, course_id, lesson_id, title, description, pass_percent, time_limit_seconds,
   max_attempts, shuffle_questions, shuffle_options, show_answers, status)
VALUES
  ('f0000001-0000-4000-8000-000000000010',
   'c0000001-0000-4000-8000-000000000007', 'e0000001-0000-4000-8000-00000000004d',
   'Level 1 Check: Types and Inference',
   'What the compiler knows, what it guesses, and where an annotation earns its place. Every question here can be settled by typing it into the scratchpad below.',
   60, 600, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000011',
   'c0000001-0000-4000-8000-000000000007', 'e0000001-0000-4000-8000-00000000004e',
   'Level 2 Check: Shapes, Unions and Generics',
   'Interfaces against aliases, narrowing a union down to one member, and writing a generic that keeps the caller''s type instead of losing it.',
   60, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000012',
   'c0000001-0000-4000-8000-000000000007', 'e0000001-0000-4000-8000-00000000004f',
   'Level 3 Check: Utility Types and Operators',
   'Pick, Omit, Partial and Record, the keyof and typeof operators, and the rules that govern how one function type is assignable to another.',
   70, 720, NULL, 0, 1, 1, 'published'),

  ('f0000001-0000-4000-8000-000000000013',
   'c0000001-0000-4000-8000-000000000007', 'e0000001-0000-4000-8000-000000000050',
   'Expert Exam: TypeScript',
   'Conditional and mapped types, inference inside a conditional, template literal types, and the configuration that decides how much of this the compiler actually enforces.',
   70, 1500, 3, 1, 1, 1, 'published')
ON DUPLICATE KEY UPDATE
  title = VALUES(title), description = VALUES(description),
  pass_percent = VALUES(pass_percent), status = VALUES(status);

INSERT INTO assessment.questions
  (id, quiz_id, kind, prompt, explanation, points, `position`, correct_text)
VALUES
  -- Level 1
  ('a1000001-0000-4000-8000-0000000001c1', 'f0000001-0000-4000-8000-000000000010', 'single_choice',
   'What happens to a TypeScript type annotation when the code is compiled and run?',
   'It is erased. Types exist only for the compiler; the emitted JavaScript has no trace of them, which is why you cannot check a type at runtime and why a type error never becomes a runtime check on its own.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001c2', 'f0000001-0000-4000-8000-000000000010', 'single_choice',
   'let count = 0; What type does TypeScript infer, and what would const count = 0 infer instead?',
   'number for let, and the literal type 0 for const. A const binding can never change, so the compiler narrows it to the one value it holds. That widening rule is why a const passed where a union is expected often just works.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001c3', 'f0000001-0000-4000-8000-000000000010', 'multiple_choice',
   'Which of these are genuine reasons to write an explicit annotation rather than let inference do the work? Select all that apply.',
   'Function parameters have nothing to infer from, an empty array would otherwise be any[], and an exported function''s return type is worth pinning so a careless change inside it becomes an error there rather than at every call site. Annotating a variable that is initialised on the same line just repeats what the compiler already knows.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001c4', 'f0000001-0000-4000-8000-000000000010', 'true_false',
   'Using any and using unknown both let you assign a value of any type into the variable.',
   'True - the difference is what happens next. Both accept anything on the way in, but unknown refuses every operation until you narrow it, while any silently allows all of them. That is exactly why unknown is the safe landing spot for parsed JSON.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001c5', 'f0000001-0000-4000-8000-000000000010', 'short_text',
   'Which compiler flag turns on the whole family of strictness checks at once, including strictNullChecks and noImplicitAny? Give the flag name exactly as it appears in tsconfig.json.',
   'strict. Turning it on is a single line in tsconfig.json and is the difference between a type checker that catches null bugs and one that mostly agrees with you.',
   2, 5, 'strict'),

  -- Level 2
  ('a1000001-0000-4000-8000-0000000001d1', 'f0000001-0000-4000-8000-000000000011', 'single_choice',
   'What can an interface do that a type alias cannot?',
   'Declaration merging - two interfaces with the same name in the same scope combine into one. That is how you add a property to a third-party type. A type alias with a duplicate name is a hard error.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001d2', 'f0000001-0000-4000-8000-000000000011', 'single_choice',
   'You have type Shape = Circle | Square, both carrying a kind property with a distinct literal type. What does checking if (shape.kind === "circle") do to the type of shape inside that block?',
   'It narrows shape to Circle. A shared property whose type is a different literal in each member makes the union discriminated, and an equality check on it is enough for the compiler to eliminate the other members.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001d3', 'f0000001-0000-4000-8000-000000000011', 'single_choice',
   'What is the difference between function first(items: unknown[]) and function first<T>(items: T[]) as far as the caller is concerned?',
   'The generic keeps the element type. The first returns unknown and forces the caller to narrow it back; the second returns exactly what went in. A generic is a relationship between the argument and the result, not a way to accept anything.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001d4', 'f0000001-0000-4000-8000-000000000011', 'multiple_choice',
   'Which of these narrow a union correctly in TypeScript? Select all that apply.',
   'typeof works for the primitives, instanceof for classes, the in operator for distinguishing object shapes by a property, and a function returning value is Duck is a user-defined type guard. A plain boolean-returning function narrows nothing - the compiler has no way to connect its result to the argument.',
   3, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001d5', 'f0000001-0000-4000-8000-000000000011', 'true_false',
   'Adding a default case that assigns the value to never turns a missed union member into a compile-time error.',
   'It does. Once every known member is handled the value is narrowed to never, so the assignment succeeds. Add a member to the union later and the value is no longer never - the assignment breaks, and the compiler points straight at the switch you forgot to update.',
   2, 5, NULL),

  -- Level 3
  ('a1000001-0000-4000-8000-0000000001e1', 'f0000001-0000-4000-8000-000000000012', 'single_choice',
   'What is the difference between Pick<User, "id" | "name"> and Omit<User, "id" | "name">?',
   'Pick keeps only the listed keys; Omit keeps everything except them. Pick is checked against the real keys, so a typo is an error - Omit accepts keys that do not exist, which is the one place it will quietly not do what you meant.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001e2', 'f0000001-0000-4000-8000-000000000012', 'single_choice',
   'const roles = ["admin", "editor"] as const; What is typeof roles[number]?',
   '"admin" | "editor". The as const freezes the array to a tuple of literal types, and indexing it with number gives the union of its elements - one value list that produces both the runtime array and the type.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001e3', 'f0000001-0000-4000-8000-000000000012', 'multiple_choice',
   'Which statements about Partial<T> are true? Select all that apply.',
   'It makes every property optional, one level deep only, and it is a mapped type you could write yourself in a line. It does not make anything readonly - that is Readonly<T> - and it will happily accept an empty object, which is why it is the wrong type for a create payload.',
   3, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001e4', 'f0000001-0000-4000-8000-000000000012', 'single_choice',
   'Why is a callback of type () => void satisfied by a function that returns a number?',
   'A void return type means the caller ignores the result, so returning something extra is harmless. It is what lets you pass a method like arr.push straight into forEach without wrapping it.',
   2, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001e5', 'f0000001-0000-4000-8000-000000000012', 'true_false',
   'Record<string, User> tells the compiler that any key you read from the object will give you a User.',
   'That is exactly what it says, and it is why the value is not User | undefined even for a key that is not there. Turn on noUncheckedIndexedAccess, or use a Map, if you want the lookup to admit it might miss.',
   2, 5, NULL),

  -- Level 4
  ('a1000001-0000-4000-8000-0000000001f1', 'f0000001-0000-4000-8000-000000000013', 'single_choice',
   'type Res<T> = T extends string ? "yes" : "no". What is Res<string | number>?',
   '"yes" | "no". A conditional type over a naked type parameter distributes across the union: it is evaluated once per member and the results are unioned. Wrapping both sides in a tuple, [T] extends [string], switches that off.',
   2, 1, NULL),

  ('a1000001-0000-4000-8000-0000000001f2', 'f0000001-0000-4000-8000-000000000013', 'single_choice',
   'What does the infer keyword do inside a conditional type?',
   'It declares a type variable that the compiler fills in by matching the shape - the mechanism behind ReturnType, Awaited and Parameters. You are asking the compiler to pull a piece out of a type rather than naming it yourself.',
   2, 2, NULL),

  ('a1000001-0000-4000-8000-0000000001f3', 'f0000001-0000-4000-8000-000000000013', 'single_choice',
   'In a mapped type, what does the as clause add - as in { [K in keyof T as `get${Capitalize<K & string>}`]: () => T[K] }?',
   'It renames the key. Without as, a mapped type reuses each key as it is; with it you compute a new key, which is how a template literal type turns a shape into a set of getter names the compiler can check.',
   2, 3, NULL),

  ('a1000001-0000-4000-8000-0000000001f4', 'f0000001-0000-4000-8000-000000000013', 'multiple_choice',
   'A .d.ts file is the right tool for which of these? Select all that apply.',
   'Describing a JavaScript library that ships no types, declaring a global your bundler injects, and augmenting an existing module''s types are all declaration-file work. Shipping the implementation is not - a .d.ts holds types only, and a value declared in one that has no runtime counterpart is a crash waiting for the first import.',
   3, 4, NULL),

  ('a1000001-0000-4000-8000-0000000001f5', 'f0000001-0000-4000-8000-000000000013', 'true_false',
   'Setting skipLibCheck to true in tsconfig.json means your own code is checked less strictly.',
   'It does not. skipLibCheck skips type checking inside .d.ts files - other people''s declarations, which you cannot fix anyway. Your own source is checked exactly as before, and the build is usually a good deal faster.',
   2, 5, NULL)
ON DUPLICATE KEY UPDATE
  prompt = VALUES(prompt), explanation = VALUES(explanation),
  points = VALUES(points), correct_text = VALUES(correct_text);

DELETE FROM assessment.question_options
 WHERE question_id IN (
   SELECT id FROM assessment.questions
    WHERE quiz_id IN ('f0000001-0000-4000-8000-000000000010',
                      'f0000001-0000-4000-8000-000000000011',
                      'f0000001-0000-4000-8000-000000000012',
                      'f0000001-0000-4000-8000-000000000013'));

INSERT INTO assessment.question_options (question_id, body, is_correct, `position`)
SELECT v.question_id, v.body, v.is_correct, v.pos
  FROM (
    SELECT 'a1000001-0000-4000-8000-0000000001c1' AS question_id, 'It is erased - the emitted JavaScript has no trace of it' AS body, 1 AS is_correct, 1 AS pos
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c1', 'It becomes a runtime check that throws on the wrong type', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c1', 'It is stored in a sidecar file the runtime reads', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c1', 'It is kept as a comment for debuggers', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c2', 'number for let, and the literal type 0 for const', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c2', 'number for both', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c2', 'The literal type 0 for both', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c2', 'any for let, and number for const', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c3', 'A function parameter, which has nothing to infer from', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c3', 'An empty array, which would otherwise be any[]', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c3', 'The return type of an exported function', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c3', 'A local initialised on the same line as its declaration', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c4', 'True', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001c4', 'False', 0, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d1', 'Merge with another declaration of the same name', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d1', 'Describe an object shape', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d1', 'Be extended by another interface', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d1', 'Take type parameters', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d2', 'It narrows shape to Circle for the rest of the block', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d2', 'Nothing - you still need a cast to reach Circle''s properties', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d2', 'It narrows shape to never', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d2', 'It widens shape to unknown', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d3', 'The generic returns the element type; the unknown[] version returns unknown', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d3', 'They are identical after compilation, so there is no difference', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d3', 'The generic accepts fewer argument types', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d3', 'The generic is checked at runtime', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d4', 'typeof value === "string"', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d4', 'value instanceof Date', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d4', '"quack" in value', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d4', 'A helper returning boolean rather than value is Duck', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d5', 'True', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001d5', 'False', 0, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e1', 'Pick keeps only the listed keys; Omit keeps everything else', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e1', 'Pick makes them optional; Omit makes them required', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e1', 'Pick works on interfaces; Omit works on type aliases', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e1', 'They are aliases of each other', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e2', 'The union "admin" | "editor"', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e2', 'string', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e2', 'string[]', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e2', 'number', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e3', 'It makes every property optional', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e3', 'It applies one level deep only', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e3', 'It is a mapped type you could write yourself', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e3', 'It also makes every property readonly', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e4', 'A void return means the caller ignores the result, so extra values are harmless', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e4', 'It is a bug in the compiler', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e4', 'number is assignable to void', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e4', 'Only under a non-strict tsconfig', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e5', 'True', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001e5', 'False', 0, 2

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f1', '"yes" | "no" - the conditional distributes over the union', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f1', '"no", because the whole union is not a string', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f1', '"yes", because one member is a string', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f1', 'never', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f2', 'It declares a type variable the compiler fills in by matching the shape', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f2', 'It guesses a type at runtime', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f2', 'It suppresses an error in the branch', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f2', 'It is a synonym for extends', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f3', 'It renames the key the mapped type produces', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f3', 'It casts the value type', 0, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f3', 'It makes the property optional', 0, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f3', 'It filters out keys but cannot rename them', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f4', 'Describing a JavaScript library that ships no types', 1, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f4', 'Declaring a global your bundler injects', 1, 2
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f4', 'Augmenting the types of an existing module', 1, 3
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f4', 'Shipping the implementation of a helper function', 0, 4

    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f5', 'True', 0, 1
    UNION ALL SELECT 'a1000001-0000-4000-8000-0000000001f5', 'False', 1, 2
  ) v;

CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000007');
CALL `search`.reindex_all();
