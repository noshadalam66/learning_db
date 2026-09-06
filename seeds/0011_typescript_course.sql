-- ===========================================================================
-- Seed 11 : the TypeScript course, basics -> intermediate -> advanced -> expert
--
-- These lessons carry ```typescript fences. The front end reads that fence and
-- opens the TypeScript compiler, which is genuinely type-checked rather than
-- type-stripped: an example with a deliberate error reports it, with the code
-- and the line, before the code runs.
--
-- That distinction is the point of the course, so several examples below
-- include an error on purpose and say so.
-- ===========================================================================

INSERT INTO catalog_courses
  (id, slug, title, subtitle, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000007',
   'typescript-from-basics-to-expert',
   'TypeScript: From Basics to Expert',
   'Four levels, twelve lessons, fully type-checked in the browser',
   'A complete path through TypeScript in four levels. Level 1, Basic, covers what the type system is for, the types you will annotate every day, and why inference means you write fewer of them than you expect. Level 2, Intermediate, is the shapes real code needs: interfaces and type aliases, unions and narrowing, and generics. Level 3, Advanced, covers utility types, the type-level operators they are built from, and how to describe a function precisely. Level 4, Expert, finishes with conditional and mapped types, template literal types, and the declaration files that make untyped libraries usable.

Every example is checked by the real compiler, not stripped. Break a type on purpose and the error appears with its code and line number before the code runs - which is the only way to learn what the compiler is actually telling you.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '55555555-5555-4555-8555-555555555555',
   'intermediate', 'published',
   'https://images.example-cdn.test/courses/typescript-from-basics-to-expert.jpg', 0,
   JSON_ARRAY('Annotate only what needs annotating, and let inference do the rest',
              'Model a domain with unions the compiler can narrow',
              'Read a compiler error and know which part of it matters',
              'Write a generic that keeps type information instead of losing it',
              'Use the utility types, and build one of your own',
              'Type a third-party library that ships no types'),
   JSON_ARRAY('Comfortable with JavaScript: functions, objects and arrays', 'The JavaScript course, or equivalent experience'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000f'),
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000e'),
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'Level 1 - Basic', 'What the type system is for, and the annotations you will write every day.', 1),
  ('d0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'Level 2 - Intermediate', 'Interfaces, unions and narrowing, and your first generics.', 2),
  ('d0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'Level 3 - Advanced', 'Utility types, the operators behind them, and typing functions precisely.', 3),
  ('d0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'Level 4 - Expert', 'Conditional and mapped types, template literal types, and declaration files.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  ('e0000001-0000-4000-8000-000000000041', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'why-types', 'Why Types, and What They Cost',
   'What the compiler catches, what it cannot, and the one thing that is erased at runtime.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-000000000042', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'the-everyday-types', 'The Everyday Types',
   'Primitives, arrays, objects, and the difference between any, unknown and never.',
   'article', 'published', 2, 600, 1),
  ('e0000001-0000-4000-8000-000000000043', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'inference-and-annotation', 'Inference, and When to Annotate',
   'The compiler already knows most of it. Annotating anyway is how types get out of date.',
   'article', 'published', 3, 600, 0),
  ('e0000001-0000-4000-8000-00000000004d', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-1-check', 'Level 1 Check: Types and Inference',
   'Five questions on what types do, the everyday annotations and inference.',
   'quiz', 'published', 4, 420, 1),

  ('e0000001-0000-4000-8000-000000000044', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'interfaces-and-aliases', 'Interfaces and Type Aliases',
   'Two ways to name a shape, one real difference, and when that difference matters.',
   'article', 'published', 1, 660, 0),
  ('e0000001-0000-4000-8000-000000000045', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'unions-and-narrowing', 'Unions and Narrowing',
   'Modelling "one of these" so the compiler can prove which one you have.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000046', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'generics', 'Generics',
   'Keeping the type information a function was given instead of throwing it away.',
   'article', 'published', 3, 720, 0),
  ('e0000001-0000-4000-8000-00000000004e', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-2-check', 'Level 2 Check: Shapes, Unions and Generics',
   'Five questions on interfaces, narrowing and generics.',
   'quiz', 'published', 4, 480, 0),

  ('e0000001-0000-4000-8000-000000000047', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'utility-types', 'The Utility Types',
   'Partial, Pick, Omit, Record and Readonly - and what each one is actually built from.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000048', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'keyof-typeof-indexed', 'keyof, typeof and Indexed Access',
   'Deriving types from values and from each other, so they cannot drift apart.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000049', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'typing-functions', 'Typing Functions Precisely',
   'Overloads, this, predicates and assertions - describing what a function really does.',
   'article', 'published', 3, 780, 0),
  ('e0000001-0000-4000-8000-00000000004f', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-3-check', 'Level 3 Check: Utility Types and Operators',
   'Five questions on utility types, keyof and typing functions.',
   'quiz', 'published', 4, 540, 0),

  ('e0000001-0000-4000-8000-00000000004a', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'conditional-and-mapped', 'Conditional and Mapped Types',
   'Types that branch and types that transform - how the standard library is written.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000004b', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'template-literal-types', 'Template Literal Types',
   'Types built from string patterns, and the autocomplete they make possible.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-00000000004c', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'declaration-files', 'Declaration Files and Configuration',
   'Typing a library that ships no types, and the tsconfig flags that matter.',
   'article', 'published', 3, 780, 0),
  ('e0000001-0000-4000-8000-000000000050', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'ts-expert-exam', 'Expert Exam: TypeScript',
   'Conditional and mapped types, template literals and declaration files.',
   'quiz', 'published', 4, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000041',
   'Why Types, and What They Cost',
   'markdown',
   '# Why Types, and What They Cost

TypeScript is JavaScript with a compiler that checks your assumptions before
you run anything. It catches a specific class of bug - the kind where a value
is not the shape you believed - and it catches nothing else.

```typescript
// The compiler checks this file before it runs. Everything commented with
// "error" below is a real one - uncomment any of them to see it reported.

interface Order {
  id: number;
  customer: string;
  total: number;
  shippedAt?: Date;        // ? means it may be missing
}

function describe(order: Order): string {
  // shippedAt is Date | undefined, so this must be checked before use.
  //   return order.shippedAt.toISOString();   // error: possibly undefined
  return order.shippedAt
    ? `#${order.id} shipped ${order.shippedAt.getFullYear()}`
    : `#${order.id} not shipped`;
}

console.log(describe({ id: 1, customer: "Aisha", total: 42 }));
console.log(describe({ id: 2, customer: "Kenji", total: 18, shippedAt: new Date() }));

// Each of these is caught before the code runs:
//   describe({ id: 3 });                       // missing properties
//   describe({ id: 4, customer: "x", total: "free" });   // wrong type
//   const n: number = describe(...);           // wrong return type

// --- Types are erased -----------------------------------------------------
// There is nothing left of them at runtime. This is the single most important
// thing to understand about TypeScript.
type Level = "basic" | "expert";
const level: Level = "basic";

// You cannot ask "is this a Level?" at runtime, because Level does not exist
// then. typeof only sees the JavaScript type.
console.log(typeof level);        // "string"

// So data crossing a boundary - a fetch response, a form, JSON.parse - is
// NOT checked by the compiler. It only checks what you told it.
const fromNetwork = JSON.parse(''{"id": "not a number"}'') as Order;
console.log("compiler believed me:", typeof fromNetwork.id);   // "string"
```

## What it catches

- A property that does not exist, or is spelled differently
- A value that might be `null` or `undefined` where you assumed it was not
- An argument in the wrong position, or of the wrong type
- A branch you forgot to handle in a union
- A refactor that missed a call site

That last one is the real payoff. Renaming a field across forty files is a
compiler error in each one, rather than a runtime error in whichever one you
did not test.

## What it does not catch

**Anything at runtime.** Types are erased entirely - there is no type
information in the compiled JavaScript at all. That has one consequence worth
stating plainly: *data from outside your program is unchecked*. A `fetch`
response typed as `User[]` is a promise, not a guarantee. If the API changes,
TypeScript will not notice; your code will fail exactly as it would have in
JavaScript.

Validate at the boundary - with a schema library, or a hand-written type
guard - and let the compiler take over from there.

## What it costs

A build step, a `tsconfig.json`, and the discipline to not reach for `any` the
moment something is awkward. In exchange you get an editor that knows what
everything is, and a class of bug that stops reaching production.

## `strict` is not optional

Every example in this course runs with `strict: true`. Without it,
`strictNullChecks` is off, `null` is assignable to everything, and most of what
you came for does not happen. Turn it on in a new project on day one; in an
existing one, turn it on file by file.',
   'TypeScript is JavaScript with a compiler that checks your assumptions before you run anything. It catches a specific class of bug, and it catches nothing else.',
   6, 560, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000042',
   'The Everyday Types',
   'markdown',
   '# The Everyday Types

The annotations you will write nearly every day, and the three special types
that decide how strict the rest of your code gets to be.

```typescript
// --- Primitives -----------------------------------------------------------
const name: string = "Aisha";
const score: number = 92;          // one number type - no int, no float
const active: boolean = true;
const huge: bigint = 9007199254740993n;
const id: symbol = Symbol("id");

// --- Arrays and tuples ----------------------------------------------------
const scores: number[] = [92, 78];
const names: Array<string> = ["Aisha"];          // the same type, other syntax
const pair: [string, number] = ["Aisha", 92];    // fixed length AND positions
const [who, mark] = pair;                        // who: string, mark: number
console.log(who, mark);

// readonly stops mutation at compile time.
const frozen: readonly number[] = [1, 2];
//   frozen.push(3);                             // error: push does not exist

// --- Objects --------------------------------------------------------------
function greet(user: { name: string; age?: number }): string {
  return user.age ? `${user.name} (${user.age})` : user.name;
}
console.log(greet({ name: "Kenji" }));

// --- Literal types and unions ---------------------------------------------
// A type can be one exact value. Unions of those are how you model an enum
// without needing one.
type Status = "pending" | "shipped" | "cancelled";
const status: Status = "shipped";
//   const wrong: Status = "posted";             // error, and it lists the options
console.log(status);

// --- any, unknown, never --------------------------------------------------
// any turns checking off. Everything is allowed, nothing is caught.
const loose: any = "text";
console.log(loose.whatever.deeply.nested);       // compiles; throws at runtime

// unknown is the safe version: you must narrow it before you can use it.
const safe: unknown = "text";
//   console.log(safe.length);                   // error, and correctly so
if (typeof safe === "string") console.log(safe.length);   // narrowed, fine

// never is the type with no values - what a function that never returns has.
function fail(message: string): never { throw new Error(message); }
console.log(typeof fail);

// --- null and undefined ---------------------------------------------------
// With strict on, these are their own types and are not assignable to others.
let maybe: string | null = null;
//   console.log(maybe.length);                  // error: possibly null
console.log(maybe?.length ?? "was null");
maybe = "now a string";
console.log(maybe.length);                       // narrowed by the assignment
```

## `any` versus `unknown`

`any` is an escape hatch that switches the compiler off for that value **and
everything derived from it**. One `any` in the wrong place quietly disables
checking across a whole call chain.

`unknown` is what `any` should have been. You can hold anything in it, and you
can do nothing with it until you have proved what it is. Use it for
`JSON.parse` results, `catch` bindings and anything crossing a boundary.

```typescript
try { /* ... */ } catch (error) {
  // error is unknown, not any - so this is required, and correct.
  const message = error instanceof Error ? error.message : String(error);
  console.log(message);
}
```

## `never` is more useful than it looks

It is the return type of a function that always throws, and the type of a
variable in a branch the compiler has proved is unreachable. That second use
is how exhaustiveness checking works, and it is the level-two lesson.

## Prefer union literals to enums

```typescript
type Status = "pending" | "shipped";     // erased, works with plain strings
enum StatusEnum { Pending, Shipped }     // emits real JavaScript
```

The union costs nothing at runtime, compares with `===` against plain strings,
and serialises to JSON as itself. A numeric enum does none of those things and
its members are assignable from arbitrary numbers.',
   'The annotations you will write nearly every day, and the three special types that decide how strict the rest of your code gets to be.',
   7, 600, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000043',
   'Inference, and When to Annotate',
   'markdown',
   '# Inference, and When to Annotate

The compiler works out most types on its own. Annotating anyway is not
harmless: an annotation is a claim you now have to keep in step with the code.

```typescript
// --- What is inferred -----------------------------------------------------
const count = 42;                  // 42 - a literal type, because const
let mutable = 42;                  // number - because it can change
const name = "Aisha";              // "Aisha"
const scores = [92, 78];           // number[]
const user = { name: "Kenji", age: 30 };   // { name: string; age: number }

// Return types are inferred from the body.
function double(n: number) { return n * 2; }        // returns number
const doubled = double(21);
console.log(doubled.toFixed(1));                     // number methods available

// --- Where annotation is required -----------------------------------------
// Parameters are never inferred from call sites - the compiler will not read
// the whole program to guess. This is the annotation you always write.
function add(a: number, b: number) { return a + b; }
console.log(add(1, 2));

// A variable declared empty has nothing to infer from.
const results: string[] = [];
results.push("first");
console.log(results);

// --- Where annotation is worth it -----------------------------------------
// On an exported function''s return type, so a change inside the body becomes
// an error here rather than a surprise at every call site.
export function parseScore(text: string): number | null {
  const n = Number(text);
  return Number.isFinite(n) ? n : null;
}
console.log(parseScore("92"), parseScore("nope"));

// --- Widening, and how to stop it -----------------------------------------
// An object literal''s properties are widened to string, which is usually
// unhelpful when the value is meant to be one of a few.
const config = { mode: "dark" };            // mode: string
//   const m: "dark" | "light" = config.mode;   // error: string is too wide

// as const freezes it: deeply readonly, and every literal keeps its type.
const frozen = { mode: "dark" } as const;   // mode: "dark"
const modes = ["dark", "light"] as const;   // readonly ["dark", "light"]
console.log(frozen.mode, modes.length);

// That is what makes this work, and it is the most useful thing as const does:
type Mode = typeof modes[number];           // "dark" | "light"
const chosen: Mode = "light";
console.log(chosen);

// --- satisfies ------------------------------------------------------------
// Check a value against a type WITHOUT widening it to that type. The
// annotation would lose the specific keys; satisfies keeps them.
const routes = {
  home: "/",
  courses: "/courses",
} satisfies Record<string, string>;

console.log(routes.home);        // still "/" , not string
//   routes.missing;             // error - the exact keys are still known
```

## The rule

**Annotate the boundaries; let the inside be inferred.**

- Parameters: always (they are never inferred).
- Exported function return types: usually, so an accidental change is caught
  where it happens rather than at every caller.
- Local variables with an initialiser: almost never. `const n: number = 42` adds
  nothing and can now be wrong.

## Why over-annotating hurts

```typescript
const scores: number[] = [92, 78];
```

If someone changes the array to hold objects, the annotation is now a second
place to fix - and until they do, the error appears here rather than where the
mistake was. Inference keeps one source of truth.

## `as` is not a conversion

`value as SomeType` tells the compiler to stop arguing. It does not check
anything and it does not change the value:

```typescript
const n = "42" as unknown as number;
console.log(typeof n);            // "string" - the cast changed nothing
```

Every `as` is a place you have taken responsibility from the compiler. Reach
for a type guard first, and keep the casts you do write next to the boundary
where you validated the data.',
   'The compiler works out most types on its own. Annotating anyway is not harmless: an annotation is a claim you now have to keep in step with the code.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 2 - Intermediate
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000044',
   'Interfaces and Type Aliases',
   'markdown',
   '# Interfaces and Type Aliases

Two ways to name a shape. They overlap almost completely, and the one real
difference decides which you want.

```typescript
interface Learner {
  readonly id: number;        // cannot be reassigned after construction
  name: string;
  score?: number;             // optional
}

type LearnerAlias = {
  readonly id: number;
  name: string;
  score?: number;
};

const a: Learner = { id: 1, name: "Aisha" };
const b: LearnerAlias = { id: 2, name: "Kenji", score: 78 };
console.log(a.name, b.score);
//   a.id = 9;                // error: id is readonly

// --- The real difference: declaration merging ------------------------------
// An interface declared twice merges. A type alias declared twice is an error.
interface Learner { cohort?: string; }        // adds to the one above
const c: Learner = { id: 3, name: "Lena", cohort: "2026" };
console.log(c.cohort);

// That merging is why interfaces are how you extend types you do not own -
// a library''s types, or the global Window.

// --- What only a type alias can do ----------------------------------------
type Status = "pending" | "shipped";            // a union
type Pair = [string, number];                   // a tuple
type Handler = (event: string) => void;         // a function type
type Keys = keyof Learner;                      // derived from another type
const k: Keys = "name";
console.log(k);

// --- Extending ------------------------------------------------------------
interface Tutor extends Learner { subject: string; }
type TutorAlias = LearnerAlias & { subject: string };   // intersection

const t: Tutor = { id: 4, name: "Sam", subject: "CSS" };
console.log(t.subject);

// --- Excess property checking ---------------------------------------------
// A fresh object literal is checked for extra properties. This is a feature -
// it catches typos - and it applies only to literals assigned directly.
//   const typo: Learner = { id: 5, name: "x", scoer: 1 };   // error: scoer

const loose = { id: 5, name: "x", extra: true };
const fine: Learner = loose;     // no error: not a fresh literal
console.log(fine.name);

// --- Index signatures -----------------------------------------------------
// For an object whose keys are not known in advance.
interface Scores { [subject: string]: number; }
const scores: Scores = { css: 92, html: 78 };
console.log(scores.css, scores.anything);   // typed number, may be undefined

// With noUncheckedIndexedAccess on, that last read is number | undefined -
// which is the truthful type and worth turning on.
```

## Which to use

**Interface** for object shapes, especially public API surfaces and anything
you might need to extend or merge into later. The error messages are usually
better, and declaration merging is the only way to add to a type you do not
own.

**Type alias** for everything that is not an object shape: unions, tuples,
function types, and anything computed from another type.

That is close to the whole rule. Teams that pick one and use it for everything
do fine either way; the merging difference is what actually matters.

## Excess property checking, precisely

```typescript
interface Options { retries?: number }
const opts: Options = { retrys: 3 };     // error - caught the typo
const built = { retrys: 3 };
const opts2: Options = built;            // no error
```

The check applies to **fresh object literals** only. That inconsistency is
deliberate: the literal is a place you clearly meant to write those exact
keys, so a stray one is almost certainly a mistake. A variable might
legitimately carry more.

## `readonly` is compile-time only

It disappears at runtime like every other type. It stops *your* code
reassigning the property; it does not freeze the object. `Object.freeze()` is
the runtime version, and the two are worth using together on genuine
constants.',
   'Two ways to name a shape. They overlap almost completely, and the one real difference decides which you want.',
   7, 600, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000045',
   'Unions and Narrowing',
   'markdown',
   '# Unions and Narrowing

A union says "one of these". Narrowing is how the compiler works out which
one you have in a particular branch - and it is the part of TypeScript that
most changes how you model a problem.

```typescript
// --- Narrowing by typeof --------------------------------------------------
function format(value: string | number): string {
  if (typeof value === "string") {
    return value.toUpperCase();     // value is string here
  }
  return value.toFixed(2);          // and number here, by elimination
}
console.log(format("abc"), format(3.14159));

// --- By truthiness, by in, by instanceof ----------------------------------
function lengthOf(value: string | string[] | null): number {
  if (!value) return 0;             // null removed
  return value.length;              // both remaining types have .length
}
console.log(lengthOf(null), lengthOf("four"), lengthOf(["a", "b"]));

// --- Discriminated unions: the important one ------------------------------
// A shared literal field the compiler can switch on. This is the single most
// useful pattern in TypeScript.
type Result =
  | { status: "success"; data: string[] }
  | { status: "error"; message: string }
  | { status: "loading" };

function render(result: Result): string {
  switch (result.status) {
    case "success": return `${result.data.length} items`;   // data exists
    case "error":   return `Failed: ${result.message}`;     // message exists
    case "loading": return "Loading...";
  }
}

console.log(render({ status: "success", data: ["a", "b"] }));
console.log(render({ status: "error", message: "timeout" }));
console.log(render({ status: "loading" }));

// Reaching for the wrong field is an error:
//   case "loading": return result.message;   // error: no such property

// --- Exhaustiveness -------------------------------------------------------
// Assigning to never fails if any case is unhandled. Add a fourth member to
// Result and this line becomes a compile error, pointing at the switch that
// forgot it - which is the refactor safety net you came for.
function assertNever(value: never): never {
  throw new Error(`Unhandled: ${JSON.stringify(value)}`);
}

function renderChecked(result: Result): string {
  switch (result.status) {
    case "success": return "ok";
    case "error":   return "failed";
    case "loading": return "waiting";
    default:        return assertNever(result);
  }
}
console.log(renderChecked({ status: "loading" }));

// --- Type predicates ------------------------------------------------------
// A function whose return type teaches the compiler something.
type Cat = { kind: "cat"; purrs: boolean };
type Dog = { kind: "dog"; barks: boolean };

function isCat(pet: Cat | Dog): pet is Cat {
  return pet.kind === "cat";
}

const pet: Cat | Dog = { kind: "cat", purrs: true };
if (isCat(pet)) console.log("purrs:", pet.purrs);   // narrowed by the predicate
```

## Why a discriminant beats optional fields

```typescript
// Weak: every field optional, nothing enforced.
type Bad = { data?: string[]; message?: string; loading?: boolean };

// Strong: the states are mutually exclusive and the compiler knows it.
type Good = { status: "success"; data: string[] } | { status: "error"; message: string };
```

With `Bad`, `result.data` is always `string[] | undefined` and nothing stops
you constructing an object that is both an error and a success. With `Good`,
each branch has exactly the fields that make sense, and an impossible state
cannot be written down.

## Narrowing is forgotten across a boundary

```typescript
function f(value: string | null) {
  if (value === null) return;
  [1].forEach(() => {
    // Still narrowed here - the callback runs synchronously.
    console.log(value.length);
  });
}
```

That works, but narrowing on a **mutable** variable is discarded whenever the
compiler cannot prove it has not changed - after an `await`, or inside a
callback stored for later. Assign to a `const` first and the narrowing sticks.

## `never` is the exhaustiveness trick

`assertNever(value: never)` compiles only when the compiler has proved every
case is handled, because only then is the remaining type `never`. It is the
mechanism that turns "I added a variant" into a compile error rather than a
silent fall-through.',
   'A union says one of these. Narrowing is how the compiler works out which one you have - and it is the part of TypeScript that most changes how you model a problem.',
   8, 660, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000046',
   'Generics',
   'markdown',
   '# Generics

A generic keeps the type information a function was given, instead of
flattening it. That is the entire idea; everything else is syntax.

```typescript
// --- The problem generics solve -------------------------------------------
function firstAny(items: any[]): any { return items[0]; }
const lostIt = firstAny(["a", "b"]);
//   lostIt.toUpperCase();     // compiles, but nothing is checked any more

// The type goes in and comes back out.
function first<T>(items: readonly T[]): T | undefined { return items[0]; }

const name = first(["Aisha", "Kenji"]);   // string | undefined - inferred
const score = first([92, 78]);            // number | undefined
console.log(name?.toUpperCase(), score?.toFixed(1));

// --- Constraints ----------------------------------------------------------
// extends here means "T must have at least this", not inheritance.
function longest<T extends { length: number }>(a: T, b: T): T {
  return a.length >= b.length ? a : b;
}
console.log(longest("hello", "hi"));
console.log(longest([1, 2, 3], [1]));
//   longest(1, 2);            // error: number has no length

// --- Two parameters that relate to each other -----------------------------
// keyof K means "a key of T", so the return type is the type of that property.
function pluck<T, K extends keyof T>(item: T, key: K): T[K] {
  return item[key];
}

const learner = { name: "Lena", score: 85, active: true };
const n: string = pluck(learner, "name");      // string, not any
const s: number = pluck(learner, "score");     // number
console.log(n, s);
//   pluck(learner, "missing");                // error: not a key

// --- Defaults -------------------------------------------------------------
interface ApiResponse<TData = unknown> {
  ok: boolean;
  data: TData;
}
const response: ApiResponse<string[]> = { ok: true, data: ["a"] };
const unknownShape: ApiResponse = { ok: false, data: null };
console.log(response.data.length, typeof unknownShape.data);

// --- Generic classes ------------------------------------------------------
class Box<T> {
  #items: T[] = [];
  add(item: T): this { this.#items.push(item); return this; }
  all(): readonly T[] { return this.#items; }
}

const box = new Box<string>().add("one").add("two");
console.log(box.all());
//   box.add(3);               // error: number is not string

// --- Where inference needs help -------------------------------------------
// Usually the compiler infers T from the arguments. When there are none, say
// it explicitly.
const empty = new Box<number>();
console.log(empty.all().length);
```

## Naming

`T` is conventional for one parameter, and fine. With more than one, name
them: `<TData, TError>` reads better than `<T, U>` in a signature someone else
has to use. The `T` prefix distinguishes a type parameter from a concrete type
at a glance.

## `extends` means "assignable to"

```typescript
<T extends string>          // T is string, or a literal like "a"
<T extends { id: number }>  // T has at least an id
<T extends unknown[]>       // T is some array
```

It constrains, it does not inherit. Inside the function you may use anything
the constraint guarantees, and nothing else.

## When not to use one

A type parameter that appears exactly once in a signature is doing nothing:

```typescript
function log<T>(value: T): void {}       // pointless
function log(value: unknown): void {}    // says the same thing, more clearly
```

The value of a generic is the *relationship* it expresses - between an
argument and a return, or between two arguments. If there is no relationship,
there is no generic.

## The one that pays for itself

```typescript
function pluck<T, K extends keyof T>(item: T, key: K): T[K]
```

Three type parameters working together to say: give me an object and one of
its keys, and I will give you back exactly the type of that property. That is
the shape most useful generics have.',
   'A generic keeps the type information a function was given, instead of flattening it. That is the entire idea; everything else is syntax.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 3 - Advanced
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000047',
   'The Utility Types',
   'markdown',
   '# The Utility Types

A handful of built-in types that transform other types. They save real work,
and every one of them is written in TypeScript you could have written
yourself - which is the level-four lesson.

```typescript
interface Learner {
  id: number;
  name: string;
  email: string;
  score: number;
  cohort?: string;
}

// --- Partial: every property optional -------------------------------------
// The natural type of an update payload.
function update(id: number, changes: Partial<Learner>): void {
  console.log("updating", id, "with", Object.keys(changes));
}
update(1, { score: 95 });
//   update(1, { scoer: 95 });        // error - still checked

// --- Required: the opposite -----------------------------------------------
type CompleteLearner = Required<Learner>;   // cohort is now mandatory

// --- Pick and Omit --------------------------------------------------------
type LearnerSummary = Pick<Learner, "id" | "name">;
type LearnerWithoutEmail = Omit<Learner, "email">;

const summary: LearnerSummary = { id: 1, name: "Aisha" };
console.log(summary);

// Pick lists what you keep; Omit lists what you drop. Prefer Pick when the
// kept set is small and stable - adding a field to Learner then does not
// silently add it to the summary.

// --- Readonly -------------------------------------------------------------
type FrozenLearner = Readonly<Learner>;
const frozen: FrozenLearner = { id: 2, name: "Kenji", email: "k@x.test", score: 78 };
//   frozen.score = 80;               // error

// --- Record ---------------------------------------------------------------
// An object with known keys and a uniform value type.
type Level = "basic" | "intermediate" | "advanced";
const counts: Record<Level, number> = { basic: 0, intermediate: 0, advanced: 0 };
//   const missing: Record<Level, number> = { basic: 0 };   // error: two missing
counts.basic += 1;
console.log(counts);

// --- Exclude, Extract, NonNullable ----------------------------------------
type NotBasic = Exclude<Level, "basic">;          // "intermediate" | "advanced"
type OnlyBasic = Extract<Level, "basic">;         // "basic"
type Defined = NonNullable<string | null>;        // string
const l: NotBasic = "advanced";
console.log(l);

// --- ReturnType and Parameters --------------------------------------------
// Derived from a function, so they cannot drift out of step with it.
function makeLearner(name: string, score: number) {
  return { id: Date.now(), name, score };
}
type MadeLearner = ReturnType<typeof makeLearner>;
type MakeArgs = Parameters<typeof makeLearner>;   // [string, number]

const made: MadeLearner = makeLearner("Lena", 85);
const args: MakeArgs = ["Sam", 61];
console.log(made.name, makeLearner(...args).name);

// --- Awaited --------------------------------------------------------------
async function fetchScore(): Promise<number> { return 92; }
type Score = Awaited<ReturnType<typeof fetchScore>>;   // number, not Promise
const score: Score = 92;
console.log(score);
```

## Composing them

They combine, and that is where the value is:

```typescript
type NewLearner = Omit<Learner, "id">;                    // before it is saved
type PatchLearner = Partial<Omit<Learner, "id">>;         // an update payload
type PublicLearner = Readonly<Pick<Learner, "id" | "name">>;
```

Each of those is derived from `Learner`. Add a field to the interface and all
three follow; there is nothing to keep in step by hand.

## `Partial` is not free

`Partial<T>` makes **every** field optional, including ones your code depends
on. It is right for a patch payload and wrong as a way to avoid filling in an
object - if the object genuinely needs three of five fields,
`Pick` plus `Partial` says so:

```typescript
type Draft = Pick<Learner, "name" | "email"> & Partial<Pick<Learner, "score">>;
```

## `Omit` does not check the key exists

```typescript
type Oops = Omit<Learner, "emial">;   // no error - just omits nothing
```

`Omit` accepts any key, including a typo, and silently does nothing. `Pick`
does check, which is another reason to prefer it. If you want a checked
`Omit`, constrain it yourself:

```typescript
type StrictOmit<T, K extends keyof T> = Omit<T, K>;
```',
   'A handful of built-in types that transform other types. They save real work, and every one is written in TypeScript you could have written yourself.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000048',
   'keyof, typeof and Indexed Access',
   'markdown',
   '# keyof, typeof and Indexed Access

Three operators that derive a type from something that already exists. Between
them they remove nearly every case where two things have to be kept in step by
hand.

```typescript
// --- typeof: the type of a value ------------------------------------------
// Note this is the TYPE-level typeof, not the runtime one.
const defaults = {
  retries: 3,
  timeout: 1000,
  verbose: false,
};

type Config = typeof defaults;      // { retries: number; timeout: number; verbose: boolean }
const custom: Config = { retries: 5, timeout: 500, verbose: true };
console.log(custom);

// --- keyof: the keys of a type, as a union --------------------------------
type ConfigKey = keyof Config;      // "retries" | "timeout" | "verbose"
const key: ConfigKey = "timeout";
console.log(key);

// --- Indexed access: the type of one property -----------------------------
type Timeout = Config["timeout"];           // number
type Any = Config[keyof Config];            // number | boolean
const t: Timeout = 250;
console.log(t);

// --- The three together ---------------------------------------------------
// A setter that only accepts a real key and the right type for it.
function set<K extends ConfigKey>(config: Config, key: K, value: Config[K]): Config {
  return { ...config, [key]: value };
}

console.log(set(defaults, "retries", 5));
//   set(defaults, "retries", "five");    // error: string is not number
//   set(defaults, "nope", 1);            // error: not a key

// --- as const, and why it matters here ------------------------------------
// Without as const the array is string[] and the derived type is just string.
const levels = ["basic", "intermediate", "advanced"] as const;
type Level = typeof levels[number];         // "basic" | "intermediate" | "advanced"

const chosen: Level = "advanced";
//   const wrong: Level = "expert";        // error, and it lists the options
console.log(chosen, levels.includes(chosen));

// One array, and a type derived from it. Add a level to the array and the
// type follows - there is no second list to update.

// --- Deriving from a lookup table -----------------------------------------
const routes = {
  home: "/",
  courses: "/courses",
  playground: "/playground.php",
} as const;

type RouteName = keyof typeof routes;       // "home" | "courses" | "playground"
type RoutePath = typeof routes[RouteName];  // "/" | "/courses" | "/playground.php"

function go(name: RouteName): RoutePath { return routes[name]; }
console.log(go("courses"));
//   go("about");                           // error - caught at compile time

// --- Arrays and tuples ----------------------------------------------------
type Scores = number[];
type Score = Scores[number];                // number - the element type

const pair = ["Aisha", 92] as const;
type Name = typeof pair[0];                 // "Aisha"
console.log(pair[0]);
```

## The pattern worth stealing

**One runtime value, every type derived from it.**

```typescript
const STATUSES = ["pending", "shipped", "cancelled"] as const;
type Status = typeof STATUSES[number];
```

You now have a real array to iterate, validate against and render, and a union
type that can never disagree with it. The alternative - a `type` and a separate
array - is two lists that drift apart the first time someone adds a value to
one of them.

## `typeof` means two different things

```typescript
console.log(typeof value);        // runtime: a string like "object"
type T = typeof value;            // compile time: the type of that value
```

Same keyword, entirely different operators, told apart by whether you are in a
type position. Confusing at first and consistent once you notice.

## `keyof any` and index signatures

`keyof` on a type with an index signature gives you the index type, not a
union of literals:

```typescript
type Loose = { [key: string]: number };
type LooseKeys = keyof Loose;      // string | number
```

That `| number` is not a bug: JavaScript object keys are strings, and a
numeric key is converted to one, so both are legitimate ways in.',
   'Three operators that derive a type from something that already exists. Between them they remove nearly every case where two things have to be kept in step by hand.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000049',
   'Typing Functions Precisely',
   'markdown',
   '# Typing Functions Precisely

Most functions need nothing but parameter types. The ones that do need more -
because their return depends on their input, or because they prove something -
have specific tools for it.

```typescript
// --- Type predicates ------------------------------------------------------
// The return type teaches the compiler something it could not work out.
function isString(value: unknown): value is string {
  return typeof value === "string";
}

const mixed: unknown[] = ["a", 1, "b", null];
const strings = mixed.filter(isString);     // string[], not unknown[]
console.log(strings.map((s) => s.toUpperCase()));

// Without the predicate, filter cannot narrow and this would not compile.

// --- Assertion functions --------------------------------------------------
// Narrows for everything AFTER the call, rather than inside an if.
function assertDefined<T>(value: T, name: string): asserts value is NonNullable<T> {
  if (value === null || value === undefined) {
    throw new Error(`${name} is required`);
  }
}

function greet(name: string | null) {
  assertDefined(name, "name");
  return name.toUpperCase();      // narrowed to string from here on
}
console.log(greet("Aisha"));

// --- Overloads ------------------------------------------------------------
// When the return type depends on the arguments in a way a union cannot say.
function parse(input: string): string[];
function parse(input: string, asNumbers: true): number[];
function parse(input: string, asNumbers = false): string[] | number[] {
  const parts = input.split(",").map((p) => p.trim());
  return asNumbers ? parts.map(Number) : parts;
}

const words = parse("a, b, c");           // string[]
const numbers = parse("1, 2, 3", true);   // number[]
console.log(words.join("|"), numbers.reduce((a, b) => a + b, 0));

// The implementation signature is not callable from outside - only the
// overloads above it are.

// --- this ---------------------------------------------------------------
// A fake first parameter, erased at runtime, that types what this must be.
interface Button { label: string; }
function describeButton(this: Button): string { return `Button: ${this.label}`; }
console.log(describeButton.call({ label: "Save" }));

// --- Function types and optional parameters -------------------------------
type Comparator<T> = (a: T, b: T) => number;
const byLength: Comparator<string> = (a, b) => a.length - b.length;
console.log(["ccc", "a", "bb"].sort(byLength));

// A callback may accept FEWER parameters than it is given, which is why
// array.map(parseInt) is a classic bug: parseInt takes a radix as its
// second argument and map passes the index.
console.log(["1", "2", "3"].map((s) => parseInt(s, 10)));

// --- Rest and tuples ------------------------------------------------------
function log(level: "info" | "error", ...parts: string[]): void {
  console.log(`[${level}]`, parts.join(" "));
}
log("info", "user", "signed", "in");
```

## Predicate versus assertion

```typescript
function isCat(x: Pet): x is Cat        // narrows inside an if
function assertCat(x: Pet): asserts x is Cat   // narrows for the rest of the scope
```

Use a predicate when the caller should decide what to do; use an assertion
when there is nothing sensible to do but throw. An assertion function must
have an explicit return type annotation - inference cannot produce `asserts`.

## Overloads are a last resort

They are unchecked against each other, and the implementation signature can
disagree with them without the compiler noticing:

```typescript
function f(x: string): number;
function f(x: unknown): unknown { return x; }   // lies, and compiles
```

Try a union return, a generic, or a discriminated argument first. Reach for
overloads when the relationship genuinely cannot be expressed otherwise -
which is rarer than it first looks.

## The `parseInt` trap

`["1", "2", "3"].map(parseInt)` gives `[1, NaN, NaN]`, because `map` passes
the index as the second argument and `parseInt` reads it as the radix. The
type system does not catch it: a callback taking more parameters than the
caller supplies is an error, but taking *exactly* what is supplied is not.
This is one the compiler cannot save you from.',
   'Most functions need nothing but parameter types. The ones that need more - because their return depends on their input, or because they prove something - have specific tools for it.',
   8, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 4 - Expert
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000004a',
   'Conditional and Mapped Types',
   'markdown',
   '# Conditional and Mapped Types

Types that branch, and types that transform. Together they are how the whole
standard library is written, and once you can read them the utility types stop
being magic.

```typescript
// --- Conditional types ----------------------------------------------------
// A ternary at the type level.
type IsString<T> = T extends string ? "yes" : "no";
type A = IsString<"hello">;      // "yes"
type B = IsString<42>;           // "no"

const a: A = "yes";
console.log(a);

// --- infer: capturing part of a type --------------------------------------
// "If T looks like an array of something, give me that something."
type ElementOf<T> = T extends readonly (infer U)[] ? U : never;
type Score = ElementOf<number[]>;              // number
type Mixed = ElementOf<(string | boolean)[]>;  // string | boolean

// This is exactly how ReturnType is written:
type MyReturnType<T> = T extends (...args: never[]) => infer R ? R : never;
function makeId() { return { id: 1, at: new Date() }; }
type Id = MyReturnType<typeof makeId>;
const made: Id = { id: 1, at: new Date() };
console.log(made.id);

// --- Distribution over unions ---------------------------------------------
// A naked type parameter distributes: the condition runs once per member.
type ToArray<T> = T extends unknown ? T[] : never;
type Distributed = ToArray<string | number>;      // string[] | number[]

// Wrapping in a tuple switches distribution off.
type NoDistribute<T> = [T] extends [unknown] ? T[] : never;
type Together = NoDistribute<string | number>;    // (string | number)[]

const one: Distributed = ["a", "b"];
const two: Together = ["a", 1];
console.log(one, two);

// That distribution is how Exclude works, and it is one line:
type MyExclude<T, U> = T extends U ? never : T;
type Level = "basic" | "advanced" | "expert";
type Senior = MyExclude<Level, "basic">;          // "advanced" | "expert"
const s: Senior = "expert";
console.log(s);

// --- Mapped types ---------------------------------------------------------
// Walk the keys of a type and produce a new one.
interface Learner { id: number; name: string; score: number; }

type MyPartial<T> = { [K in keyof T]?: T[K] };
type MyReadonly<T> = { readonly [K in keyof T]: T[K] };

// Modifiers can be removed as well as added, with -.
type Mutable<T> = { -readonly [K in keyof T]: T[K] };
type Concrete<T> = { [K in keyof T]-?: T[K] };

const patch: MyPartial<Learner> = { score: 95 };
console.log(patch);

// --- Remapping keys with as -----------------------------------------------
// Rename keys as you map them.
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

type LearnerGetters = Getters<Learner>;   // getId, getName, getScore

const getters: LearnerGetters = {
  getId: () => 1,
  getName: () => "Aisha",
  getScore: () => 92,
};
console.log(getters.getName(), getters.getScore());

// Filtering, by mapping unwanted keys to never.
type OnlyNumbers<T> = {
  [K in keyof T as T[K] extends number ? K : never]: T[K];
};
type Numeric = OnlyNumbers<Learner>;      // { id: number; score: number }
const numeric: Numeric = { id: 1, score: 92 };
console.log(numeric);
```

## Reading one from the inside out

```typescript
type Getters<T> = { [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K] };
```

- `[K in keyof T]` - for each key of T
- `as \`get${...}\`` - rename it
- `Capitalize<string & K>` - K narrowed to string, first letter upper-cased
- `: () => T[K]` - the value is a function returning the original type

Four small pieces. They are always four small pieces.

## Distribution is the part that surprises people

A conditional type with a **naked** type parameter distributes over a union -
it runs once per member and unions the results. Wrapping either side in a
tuple prevents it. That single rule explains why `Exclude` works, and why a
conditional type sometimes returns a union you did not expect.

## When to stop

Type-level programming is genuinely powerful and genuinely expensive: it slows
the compiler, and the error messages it produces are famously bad. A type your
colleagues cannot read is a liability whatever it proves.

The honest threshold: reach for these when writing a **library** whose users
benefit, or when a mapped type removes a real synchronisation burden. For
application code, a plain interface is almost always the better answer.',
   'Types that branch, and types that transform. Together they are how the whole standard library is written, and once you can read them the utility types stop being magic.',
   9, 700, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-00000000004b',
   'Template Literal Types',
   'markdown',
   '# Template Literal Types

String types built from patterns. They turn a stringly-typed API into one the
editor can autocomplete, and they are the reason modern libraries can type
things that used to be `string`.

```typescript
// --- The basics -----------------------------------------------------------
type Level = "basic" | "advanced";
type Greeting = `Hello, ${Level}`;      // "Hello, basic" | "Hello, advanced"

const g: Greeting = "Hello, advanced";
//   const bad: Greeting = "Hello, expert";   // error
console.log(g);

// Combining two unions multiplies them out.
type Colour = "red" | "green";
type Shade = "light" | "dark";
type Swatch = `${Shade}-${Colour}`;     // four members
const swatch: Swatch = "dark-red";
console.log(swatch);

// --- The built-in string manipulators -------------------------------------
type Upper = Uppercase<"hello">;        // "HELLO"
type Lower = Lowercase<"HELLO">;        // "hello"
type Cap = Capitalize<"hello">;         // "Hello"
type Uncap = Uncapitalize<"Hello">;     // "hello"
const c: Cap = "Hello";
console.log(c);

// --- Event handlers, typed --------------------------------------------------
interface Events { click: MouseEvent; keydown: KeyboardEvent; }

type HandlerName = `on${Capitalize<keyof Events & string>}`;   // "onClick" | "onKeydown"

type Handlers = {
  [K in keyof Events as `on${Capitalize<K & string>}`]?: (event: Events[K]) => void;
};

const handlers: Handlers = {
  onClick: (event) => console.log("clicked at", event.clientX),
};
console.log(Object.keys(handlers));

// --- Parsing a string at the type level -----------------------------------
// infer works inside a template literal, which is how route params get typed.
type ParamOf<T> = T extends `${string}:${infer Param}/${string}`
  ? Param
  : T extends `${string}:${infer Param}`
    ? Param
    : never;

type CourseParam = ParamOf<"/courses/:slug">;          // "slug"
type LessonParam = ParamOf<"/courses/:slug/lessons">;  // "slug"

const p: CourseParam = "slug";
console.log(p);

// --- A typed path builder -------------------------------------------------
const routes = {
  course: "/courses/:slug",
  lesson: "/courses/:slug/lessons/:lesson",
} as const;

type RouteName = keyof typeof routes;

function path<K extends RouteName>(name: K, params: Record<string, string>): string {
  return (routes[name] as string).replace(/:(\\w+)/g, (_, key) => params[key] ?? "");
}

console.log(path("course", { slug: "typescript-from-basics-to-expert" }));
console.log(path("lesson", { slug: "javascript", lesson: "closures" }));
```

## Where they earn their place

**CSS-in-JS and design tokens.** `` `--${string}` `` types a custom property.
`` `${number}px` `` types a length.

**Event names.** The `on${Capitalize<K>}` pattern above generates a whole
handler interface from an event map, with autocomplete for every name.

**Routes.** Extracting `:params` from a path string means a typo in a route
name or a missing parameter is a compile error rather than a broken link.

**SQL and query builders.** Some libraries parse a query string at the type
level and give you a typed result row. Extraordinary, and worth knowing it is
possible rather than attempting it yourself.

## The cost is real

Every combination is expanded eagerly. `` `${Shade}-${Colour}` `` with ten of
each is a hundred members; with four unions of ten it is ten thousand, and the
compiler will tell you it has given up. The limit is around a hundred thousand
members, and you can reach it faster than you expect.

## When not to

If the set of strings is small and known, write the union out:

```typescript
type Size = "small" | "medium" | "large";              // clear
type Size = `${"s" | "m" | "l"}${"" | "-wide"}`;       // clever, and worse
```

Template literal types pay off when the strings are *derived* from something
else - a key, a route, an event map. When they are just a list, a list is
better.',
   'String types built from patterns. They turn a stringly-typed API into one the editor can autocomplete.',
   8, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-00000000004c',
   'Declaration Files and Configuration',
   'markdown',
   '# Declaration Files and Configuration

How to use a library that ships no types, how to extend one that does, and the
handful of `tsconfig` flags that decide how much the compiler actually does
for you.

```typescript
// A .d.ts file contains types and no implementation - it is erased entirely.
// This playground is one file, so the declarations below are shown as code
// rather than imported, but the syntax is exactly what you would write.

// --- Declaring a module that ships no types -------------------------------
//   // types/legacy-chart.d.ts
//   declare module "legacy-chart" {
//     export interface ChartOptions { width: number; height: number; }
//     export default function render(el: HTMLElement, options: ChartOptions): void;
//   }
//
// Then: import render from "legacy-chart";   // fully typed

// --- Augmenting a module you do not own -----------------------------------
//   // types/express.d.ts
//   import "express";
//   declare module "express" {
//     interface Request { user?: { id: string; roles: string[] }; }
//   }
//
// This is why interfaces merge: it is the mechanism that makes this possible.

// --- Extending the global scope -------------------------------------------
//   declare global {
//     interface Window { analytics?: { track(event: string): void }; }
//   }
//
// Inside a module, declare global is required - a bare declaration would
// only be visible in that file.

// --- Runtime validation at the boundary -----------------------------------
// Declarations describe what you believe. Nothing checks it. Anything from
// outside the program needs a real guard.
interface Learner { id: number; name: string; }

function isLearner(value: unknown): value is Learner {
  return (
    typeof value === "object" && value !== null &&
    "id" in value && typeof (value as Learner).id === "number" &&
    "name" in value && typeof (value as Learner).name === "string"
  );
}

const fromNetwork: unknown = JSON.parse(''{"id": 1, "name": "Aisha"}'');
const bad: unknown = JSON.parse(''{"id": "one"}'');

console.log(isLearner(fromNetwork) ? `valid: ${fromNetwork.name}` : "invalid");
console.log(isLearner(bad) ? "valid" : "invalid - caught before it spread");

// Compare: an unchecked cast believes anything.
const believed = bad as Learner;
console.log("compiler believed:", typeof believed.id);   // "string"
```

## The tsconfig flags that matter

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true
  }
}
```

**`strict`** is the one that matters. It turns on `strictNullChecks`,
`noImplicitAny` and six others. Without it most of this course does not apply.

**`noUncheckedIndexedAccess`** makes `array[0]` return `T | undefined`, which
is the truth. It is noisy on existing code and it catches a real class of bug.

**`exactOptionalPropertyTypes`** distinguishes "absent" from "present and
undefined". Subtle, and it matters when you spread objects.

**`skipLibCheck`** skips type checking of `.d.ts` files in dependencies. On by
default in new projects; it trades a little safety for a lot of build time,
and the errors it hides are almost always in someone else''s types.

## Where declarations come from

1. **Bundled with the package** - `"types"` in its package.json. The common case.
2. **DefinitelyTyped** - `npm i -D @types/thing`. Community-maintained, so
   check it matches the version you have.
3. **Yours** - a `.d.ts` in a folder listed under `typeRoots` or just included
   in the project.

For a small untyped dependency, writing the three functions you actually use
is often faster than finding a stale `@types` package.

## The honest limit

A declaration file is a **claim**, not a check. If it says a function returns
`string` and it returns `null` on Tuesdays, the compiler will not notice and
your code will crash exactly as JavaScript would have. Types describe
intentions at the boundary; guards enforce them.',
   'How to use a library that ships no types, how to extend one that does, and the handful of tsconfig flags that decide how much the compiler does for you.',
   8, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content_articles.revision + 1;

CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000007');
