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
  (id, slug, title, subtitle, overview, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000007',
   'typescript-from-basics-to-expert',
   'TypeScript: From Basics to Expert',
   'Four levels, twelve lessons, fully type-checked in the browser',
   'TypeScript is JavaScript with a type system bolted on top and removed again before the code runs. You write annotations, a compiler checks them, and what ships is ordinary JavaScript with the types erased.

The trade is explicit, which is the reason to be honest about it. You pay a build step, some learning, and the occasional argument with the compiler. You get a class of bug caught at the moment you type it rather than in production, and an editor that actually knows what a value is - rename, go-to-definition and autocomplete stop being guesses.

It is now the default for new JavaScript projects of any size, and most well-used libraries ship their own types. That makes it less a choice than a thing to be fluent in, which is why this course starts with what the type system is for rather than with a list of syntax.',
   'A complete path through TypeScript in four levels. Level 1, Basic, covers what the type system is for, the types you will annotate every day, and why inference means you write fewer of them than you expect. Level 2, Intermediate, is the shapes real code needs: interfaces and type aliases, unions and narrowing, and generics. Level 3, Advanced, covers utility types, the type-level operators they are built from, and how to describe a function precisely. Level 4, Expert, finishes with conditional and mapped types, template literal types, and the declaration files that make untyped libraries usable.

You should be comfortable with JavaScript before starting: TypeScript adds a type system to a language this course assumes you can already write. If you have used TypeScript only as JavaScript with annotations, Level 1 will be quick and Level 3 is where the course begins to tell you things you cannot get from the autocomplete.

Three lessons and a Level Check quiz per level, with an Expert Exam at the end. Every example is checked by the real compiler rather than stripped of its types, so breaking one on purpose shows you the actual error, with its code and its line number, before the code runs - which is the only way to learn what the compiler is telling you.

Every example is checked by the real compiler, not stripped. Break a type on purpose and the error appears with its code and line number before the code runs - which is the only way to learn what the compiler is actually telling you.

By the end you will be able to type a real codebase rather than annotate it: narrow a union so the compiler proves which branch you are in, write a generic that stays readable, derive one type from another instead of maintaining both, and write the declaration file that makes an untyped dependency usable.',
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
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000f'),
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000e'),
  ('c0000001-0000-4000-8000-000000000007', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'Level 1 - Basic',
   'What the type system is for, and what it costs. The first lesson is honest about the trade - what you get, and the build step and the annotations you pay for it with. Then the types you will write every day, and finally inference, which is the reason you write far fewer annotations than you expect, once you know where the compiler can work it out for itself.', 1),
  ('d0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'Level 2 - Intermediate',
   'The shapes real code needs. Interfaces and type aliases, and the question of which to use; unions with the narrowing that proves which case you are in, which is where TypeScript starts catching bugs rather than describing code; and your first generics, written as something readable rather than a wall of single letters.', 2),
  ('d0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'Level 3 - Advanced',
   'Describing types in terms of other types. The utility types first, as the tools you reach for; then keyof, typeof and indexed access, which are what those tools are built from, so a type can be derived from a value rather than kept in step with it by hand; and finally typing functions precisely, including overloads and this.', 3),
  ('d0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'Level 4 - Expert',
   'The type level as a language of its own. Conditional types and mapped types let a type be computed from another; template literal types do the same to strings, which is how a library types event names it has never seen; and declaration files plus compiler configuration are how all of it meets code you did not write.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  ('e0000001-0000-4000-8000-000000000041', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'why-types', 'Why Types, and What They Cost',
   'TypeScript is JavaScript with a compiler that checks your assumptions before you run anything. It catches one specific class of bug - the kind where a value is not the shape you believed - and it catches nothing else, because every type is erased at runtime.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-000000000042', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'the-everyday-types', 'The Everyday Types',
   'The annotations you will write nearly every day, and the three special types that decide how strict the rest of your code gets to be. The difference between any, unknown and never is the part worth reading twice.',
   'article', 'published', 2, 600, 1),
  ('e0000001-0000-4000-8000-000000000043', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'inference-and-annotation', 'Inference, and When to Annotate',
   'The compiler works out most types on its own, and annotating anyway is not harmless: an annotation is a claim you now have to keep in step with the code. Where inference is enough, and where an annotation earns its place.',
   'article', 'published', 3, 600, 0),
  ('e0000001-0000-4000-8000-00000000004d', 'd0000001-0000-4000-8000-000000000014', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-1-check', 'Level 1 Check: Types and Inference',
   'Five questions on what the compiler knows, what it guesses, and where an annotation earns its place rather than going stale. Every question here can be settled by typing it into the scratchpad below.',
   'quiz', 'published', 4, 420, 1),

  ('e0000001-0000-4000-8000-000000000044', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'interfaces-and-aliases', 'Interfaces and Type Aliases',
   'Two ways to name a shape. They overlap almost completely, and the one real difference - whether a later declaration can add to it - decides which you want, which is why libraries and application code tend to choose differently.',
   'article', 'published', 1, 660, 0),
  ('e0000001-0000-4000-8000-000000000045', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'unions-and-narrowing', 'Unions and Narrowing',
   'A union says one of these. Narrowing is how the compiler works out which one you have in a particular branch, and it is the part of TypeScript that most changes how you model a problem - a discriminated union instead of optional fields.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000046', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'generics', 'Generics',
   'A generic keeps the type information a function was given instead of flattening it. That is the entire idea; everything else is syntax, including the constraints that let you say what you need from a type without pinning it down.',
   'article', 'published', 3, 720, 0),
  ('e0000001-0000-4000-8000-00000000004e', 'd0000001-0000-4000-8000-000000000015', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-2-check', 'Level 2 Check: Shapes, Unions and Generics',
   'Five questions on interfaces against aliases, narrowing a union down to one member, and writing a generic that keeps the caller type instead of losing it on the way through.',
   'quiz', 'published', 4, 480, 0),

  ('e0000001-0000-4000-8000-000000000047', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'utility-types', 'The Utility Types',
   'A handful of built-in types that transform other types. They save real work, and every one of them is written in TypeScript you could have written yourself - Partial, Pick, Omit, Record and Readonly, with what each is actually made of.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000048', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'keyof-typeof-indexed', 'keyof, typeof and Indexed Access',
   'Three operators that derive a type from something that already exists. Between them they remove nearly every case where two things have to be kept in step by hand, which is the case where they eventually drift apart.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-000000000049', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'typing-functions', 'Typing Functions Precisely',
   'Most functions need nothing but parameter types. The ones that need more - because the return depends on the input, or because the call proves something about its argument - have specific tools: overloads, this types, predicates and assertions.',
   'article', 'published', 3, 780, 0),
  ('e0000001-0000-4000-8000-00000000004f', 'd0000001-0000-4000-8000-000000000016', 'c0000001-0000-4000-8000-000000000007',
   'ts-level-3-check', 'Level 3 Check: Utility Types and Operators',
   'Five questions on Pick, Omit, Partial and Record, the keyof and typeof operators, and the rules that govern when one function type is assignable to another. The parameter question catches most people.',
   'quiz', 'published', 4, 540, 0),

  ('e0000001-0000-4000-8000-00000000004a', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'conditional-and-mapped', 'Conditional and Mapped Types',
   'Types that branch, and types that transform. Together they are how the whole standard library is written, and once you can read them the utility types stop being magic and become code you could have written yourself.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000004b', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'template-literal-types', 'Template Literal Types',
   'String types built from patterns. They turn a stringly-typed API into one the editor can autocomplete, and they are the reason a modern library can give a precise type to something that used to be plain string.',
   'article', 'published', 2, 720, 0),
  ('e0000001-0000-4000-8000-00000000004c', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'declaration-files', 'Declaration Files and Configuration',
   'How to use a library that ships no types, how to extend one that does, and the handful of tsconfig flags that decide how much the compiler actually does for you. strict is one flag that turns on several.',
   'article', 'published', 3, 780, 0),
  ('e0000001-0000-4000-8000-000000000050', 'd0000001-0000-4000-8000-000000000017', 'c0000001-0000-4000-8000-000000000007',
   'ts-expert-exam', 'Expert Exam: TypeScript',
   'Twenty questions over the whole course: conditional and mapped types, inference inside a conditional, template literal types, and the configuration that decides how much of this the compiler really enforces.',
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
   '# Why Types

TypeScript is JavaScript with a compile-time checker bolted on. It changes nothing at run time - the types are erased before the code ships. What it buys is a second reader who checks every line you wrote against every line that calls it, instantly, every time you save.

## What it catches

```typescript
interface User {
  id: number;
  name: string;
  email?: string;
}

function greet(user: User): string {
  // Error: Property ''nmae'' does not exist on type ''User''. Did you mean ''name''?
  //   return "Hello " + user.nmae;
  return "Hello " + user.name;
}

// Error: Argument of type ''{ id: string; name: string; }'' is not assignable.
//   greet({ id: "7", name: "Aisha" });
console.log(greet({ id: 7, name: "Aisha" }));
```

Three categories cover almost everything a type checker finds in practice.

**Typos in property names.** The single most common JavaScript bug, and the one that costs the most, because `user.nmae` is `undefined` rather than an error and the failure surfaces three functions later.

**Wrong shapes at a boundary.** A function expecting a `User` and given a row from the database that happens to have `user_id` instead of `id`.

**Forgetting the empty case.** This is the one worth the price of admission on its own:

```typescript
interface User { id: number; name: string; email?: string; }

function findUser(id: number, users: User[]): User | undefined {
  return users.find((u) => u.id === id);
}

const users: User[] = [{ id: 1, name: "Aisha" }];
const found = findUser(2, users);

// Error: ''found'' is possibly ''undefined''.
//   console.log(found.name);

console.log(found?.name ?? "not found");
```

`strictNullChecks` turns "this returns undefined sometimes" from a thing you have to remember into a thing the compiler will not let you forget. In a codebase of any size that is the difference between a handful of `Cannot read properties of undefined` reports a week and none.

## What it does not catch

Types describe what you *claimed*, not what is true. Everything crossing a boundary is a claim:

```typescript
interface User { id: number; name: string; }

async function load(): Promise<User> {
  const response = await fetch("/api/user");
  // A lie, and the compiler believes it. The server could return
  // anything at all and this line asserts it is a User.
  return (await response.json()) as User;
}
```

`response.json()` returns `any`. The `as User` is an assertion, not a check - nothing validates it. The same hole opens at every boundary: `JSON.parse`, `localStorage.getItem`, a form value, a `process.env` variable, an untyped library.

The fix is to validate once, where the data arrives:

```typescript
interface User { id: number; name: string; }

function isUser(value: unknown): value is User {
  return (
    typeof value === "object" && value !== null &&
    "id" in value && typeof (value as { id: unknown }).id === "number" &&
    "name" in value && typeof (value as { name: unknown }).name === "string"
  );
}

function parseUser(raw: unknown): User {
  if (!isUser(raw)) throw new TypeError("not a user");
  return raw;
}

console.log(parseUser({ id: 1, name: "Aisha" }).name);   // Aisha
```

In real projects a schema library such as Zod or Valibot writes that function and derives the type from it, so the validator and the type cannot drift apart. The principle is the same: **parse at the edge, and trust types inside**.

Types also do not catch logic. A function that returns `number` and returns the wrong number compiles perfectly. Types narrow the space of possible bugs; they do not empty it, and they are not a substitute for tests.

## What it costs

Honest accounting, because the cost is real:

- **A build step**, where JavaScript had none. `tsc`, or a bundler that strips types, or Node''s own type stripping.
- **Dependency types.** Most packages ship their own now; the ones that do not need `@types/...` or a declaration you write.
- **Time arguing with the compiler.** Mostly early on, and mostly because of patterns that were ambiguous anyway.
- **Occasional genuine awkwardness.** Some correct JavaScript is hard to type, and you will reach for `as` or `any` to get past it.

What you get back is refactoring you can trust. Renaming a field across forty files becomes a mechanical operation the editor performs and the compiler verifies, rather than a grep and a prayer.

## strict is not optional

```typescript
// tsconfig.json, the part that matters:
//
//   {
//     "compilerOptions": {
//       "strict": true,
//       "noUncheckedIndexedAccess": true,
//       "noImplicitOverride": true,
//       "exactOptionalPropertyTypes": true,
//       "verbatimModuleSyntax": true
//     }
//   }
```

`strict` turns on eight flags at once. Two of them do nearly all the work:

- **`strictNullChecks`** - `null` and `undefined` are not members of every type. Without it, `string` silently includes `null` and the compiler cannot warn you about the single most common run-time error in JavaScript.
- **`noImplicitAny`** - a parameter with no annotation and no inferable type is an error rather than a silent `any`.

Of the extra flags, `noUncheckedIndexedAccess` is the one most worth turning on and the one that annoys people most:

```typescript
const names = ["a", "b"];

// With noUncheckedIndexedAccess, this is string | undefined, because
// index 10 is a perfectly legal thing to ask for and gives undefined.
const first = names[0];
console.log(first?.toUpperCase());

// The intended-index case has an honest escape hatch:
const definitely = names.at(0) ?? "";
console.log(definitely.toUpperCase());
```

It is correct - `names[10]` really is `undefined` at run time - and it finds real bugs in loops with computed indices. Turn it on at the start of a project; retrofitting it to a large one is a week of work.

Turning `strict` on later is far harder than starting with it, because every file written without it has accumulated assumptions. Start strict, always.

## A worked example

```typescript
// A small module, typed the way a real one should be: validated at
// the edge, precise inside, and no `any` anywhere.

type Status = "draft" | "published" | "archived";

interface Lesson {
  readonly id: number;
  readonly title: string;
  readonly status: Status;
  readonly minutes: number;
}

// The boundary. `unknown` forces a check before anything is read.
function parseLesson(raw: unknown): Lesson | null {
  if (typeof raw !== "object" || raw === null) return null;
  const row = raw as Record<string, unknown>;

  const statuses: readonly Status[] = ["draft", "published", "archived"];
  const status = row.status;

  if (typeof row.id !== "number") return null;
  if (typeof row.title !== "string" || row.title.trim() === "") return null;
  if (typeof status !== "string" || !statuses.includes(status as Status)) return null;
  if (typeof row.minutes !== "number" || row.minutes < 0) return null;

  return {
    id: row.id,
    title: row.title,
    status: status as Status,
    minutes: row.minutes,
  };
}

const RAW: unknown[] = [
  { id: 1, title: "Selectors", status: "published", minutes: 7 },
  { id: 2, title: "The box model", status: "published", minutes: 7 },
  { id: "3", title: "Bad id", status: "published", minutes: 5 },
  { id: 4, title: "Drafting", status: "nonsense", minutes: 6 },
  { id: 5, title: "Container queries", status: "draft", minutes: 6 },
];

// flatMap doubles as a filter: [] drops, [x] keeps.
const lessons: Lesson[] = RAW.flatMap((raw) => {
  const lesson = parseLesson(raw);
  return lesson ? [lesson] : [];
});

console.log(lessons.length);                  // 3 - two rows rejected

// Inside, everything is known, so none of this needs a guard.
const published = lessons.filter((l) => l.status === "published");
const totalMinutes = published.reduce((sum, l) => sum + l.minutes, 0);

console.log(published.map((l) => l.title));   // [''Selectors'', ''The box model'']
console.log(totalMinutes);                    // 14

// Exhaustiveness: add a fourth Status and this stops compiling,
// which is the compiler telling you where to go and fix things.
function describe(status: Status): string {
  switch (status) {
    case "draft": return "not visible yet";
    case "published": return "live";
    case "archived": return "retired";
    default: {
      const unreachable: never = status;
      return unreachable;
    }
  }
}

for (const lesson of lessons) {
  console.log(lesson.title + ": " + describe(lesson.status));
}

// readonly is compile-time only. This is an error:
//   lessons[0].title = "changed";
// ...and this is not, because the array itself is not readonly:
console.log(Object.isFrozen(lessons[0]));     // false
```

That last pair of lines is the honest footnote on the whole language. `readonly` stops *you* writing an assignment; it does nothing at run time, and `Object.freeze` is what actually prevents mutation. TypeScript is a checker, not a guarantee.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A wrong shape got through at run time | `as` at a boundary; validate instead |
| Everything is `any` and nothing is checked | `strict` is off, or a dependency has no types |
| `Object is possibly ''undefined''` on an index | `noUncheckedIndexedAccess`; it is right |
| Types pass, behaviour is wrong | Types are not tests |
| `tsc` is slow on a large project | Enable `incremental`, or use project references |
| A dependency has no types | `@types/...`, or a one-line `declare module` |
| `strict` produced hundreds of errors | Retrofitting; fix file by file with overrides |
| A `readonly` field changed anyway | It is compile-time only; use `Object.freeze` |

## A check you can run

Take one function in your codebase that can return nothing and change its return type from `User` to `User | undefined`. Then run `tsc --noEmit`.

The errors you get are the complete list of places that assume it always succeeds - which is to say, the complete list of places that will throw when it does not. Every one is a real bug that was already there. That list, produced in seconds without running anything, is the entire argument for types in one experiment.
',
   'TypeScript is JavaScript with a compiler that checks your assumptions before you run anything. It catches a specific class of bug, and it catches nothing else.', 8, 1604,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000042',
   'The Everyday Types',
   'markdown',
   '# The Types You Will Actually Write

Most TypeScript is a small vocabulary used well. This lesson is that vocabulary, plus the three decisions - `any` versus `unknown`, enums versus unions, when `never` helps - that separate a codebase that is checked from one that only looks checked.

## The primitives, and the ones that are not

```typescript
const name: string = "Aisha";
const age: number = 29;              // one number type, like JavaScript
const big: bigint = 9007199254740993n;
const active: boolean = true;
const nothing: null = null;
const missing: undefined = undefined;
const key: symbol = Symbol("id");

// Lowercase, always. String, Number and Boolean are the wrapper
// objects and are never what you want.
```

Arrays, tuples and objects:

```typescript
const names: string[] = ["a", "b"];
const also: Array<string> = ["a", "b"];          // identical

const pair: [number, string] = [1, "one"];       // a tuple: fixed length
const named: [x: number, y: number] = [3, 4];    // labelled, for readability
const rest: [string, ...number[]] = ["sum", 1, 2, 3];

const user: { id: number; name: string } = { id: 1, name: "Aisha" };
const lookup: Record<string, number> = { a: 1, b: 2 };
const loose: { [key: string]: number } = { a: 1 };   // the same thing
```

A tuple is an array whose length and per-position types are fixed. Use one when the positions mean different things - a `[key, value]` pair, a `useState`-style return - and an array when they are all the same kind.

Literal types, which are the ones that do the most work:

```typescript
type Status = "draft" | "published" | "archived";
type Dice = 1 | 2 | 3 | 4 | 5 | 6;
type Flag = `--${string}`;

const status: Status = "draft";
// Error: Type ''"nonsense"'' is not assignable to type ''Status''.
//   const bad: Status = "nonsense";

// const widens to the literal type; let widens to the base type.
const fixed = "draft";               // type is "draft"
let loose2 = "draft";                // type is string
```

That `const`/`let` difference matters more than it looks:

```typescript
type Status = "draft" | "published";

function publish(status: Status): void { console.log(status); }

const config = { status: "draft" };  // status is widened to string
// Error: Type ''string'' is not assignable to type ''Status''.
//   publish(config.status);

const fixedConfig = { status: "draft" } as const;   // status is "draft"
publish(fixedConfig.status);
```

`as const` freezes an object literal into its narrowest possible type, making every property `readonly` and every value a literal. It is the fix for "why is this a `string` when I clearly wrote `"draft"`".

## any versus unknown

```typescript
function useAny(value: any): number {
  return value.whatever.nested.property;   // compiles. will throw.
}

function useUnknown(value: unknown): number {
  // Error: ''value'' is of type ''unknown''.
  //   return value.whatever;
  if (typeof value === "object" && value !== null && "length" in value) {
    return typeof value.length === "number" ? value.length : 0;
  }
  return 0;
}

console.log(useUnknown([1, 2, 3]));   // 3
console.log(useUnknown("no"));        // 0
```

`any` switches the checker off for that value and everything it touches. `unknown` says "I do not know yet" and forces a narrowing before any use. They are the same amount of knowledge and opposite amounts of safety.

Use `unknown` for anything arriving from outside: `JSON.parse`, a `fetch` body, a `catch` parameter, a message from a worker. Use `any` for nothing, in new code. When you must silence the checker, `any` with a comment explaining why is at least honest; `unknown` with a type guard is better.

```typescript
try {
  JSON.parse("not json");
} catch (error) {
  // `error` is `unknown` under useUnknownInCatchVariables (part of strict).
  const message = error instanceof Error ? error.message : String(error);
  console.log(message.slice(0, 20));
}
```

## never is more useful than it looks

`never` is the type with no values. A function returning `never` cannot return at all - it throws or loops forever.

```typescript
function fail(message: string): never {
  throw new Error(message);
}

type Status = "draft" | "published" | "archived";

function label(status: Status): string {
  switch (status) {
    case "draft": return "Draft";
    case "published": return "Live";
    case "archived": return "Archived";
    default:
      // If a fourth status is added, `status` is no longer `never`
      // here and this line stops compiling - pointing at every switch
      // that needs updating.
      return assertNever(status);
  }
}

function assertNever(value: never): never {
  throw new Error("unhandled: " + JSON.stringify(value));
}

console.log(label("published"));     // Live
```

That is the exhaustiveness check, and it is the single most valuable pattern in the language. It converts "someone will remember to update the other six switches" into a compile error with a file and a line number.

`never` also appears as the result of an impossible narrowing, which is how the compiler tells you a branch cannot happen:

```typescript
function check(value: string | number): void {
  if (typeof value === "string") {
    console.log(value.length);
  } else if (typeof value === "number") {
    console.log(value.toFixed(2));
  } else {
    // value is never here - all cases are covered
    console.log(value);
  }
}
check("ab");
```

## void, undefined and the return type you should usually omit

```typescript
function log(message: string): void {
  console.log(message);
}

// void means "the return value is not meant to be used", which is
// subtly different from "returns undefined": a void-returning
// signature accepts a function that returns something.
const numbers = [1, 2, 3];
const sink: Array<(n: number) => void> = [];
sink.push((n) => numbers.push(n));    // push returns number; allowed
console.log(sink.length);             // 1
```

That allowance exists so `arr.forEach(x => doSomethingReturningAValue(x))` works, and it is the right trade.

In practice, **omit the return type on most functions** and let it be inferred. Annotate it when the function is exported, when inference produces something unhelpfully wide, or when you want the compiler to check the body against your intent rather than the other way round.

## Prefer union literals to enums

```typescript
// An enum. It exists at run time, generates an object, and its
// members are nominally typed - so two enums with the same values
// are not interchangeable.
enum StatusEnum {
  Draft = "draft",
  Published = "published",
}

// A union of literals. Erased completely, assignable from a plain
// string literal, and narrowable by the compiler.
type Status = "draft" | "published";

const a: Status = "draft";                    // just works
const b: StatusEnum = StatusEnum.Draft;       // needs the import
console.log(a, b);
```

Four reasons to prefer the union:

- **It erases.** No run-time object, no bundle cost, nothing to import.
- **It is assignable from a plain string**, so JSON parses straight into it after validation.
- **It narrows** in switches and conditionals, which drives the exhaustiveness check above.
- **It is structural**, like the rest of the language, rather than nominal.

When you do need the values at run time, derive them from the type rather than the other way round:

```typescript
const STATUSES = ["draft", "published", "archived"] as const;
type Status = (typeof STATUSES)[number];      // "draft" | "published" | "archived"

function isStatus(value: string): value is Status {
  return (STATUSES as readonly string[]).includes(value);
}

console.log(STATUSES.length, isStatus("draft"), isStatus("x"));   // 3 true false
```

One array, and both the run-time list and the compile-time type come from it. They cannot drift.

## A worked example

```typescript
const LEVELS = ["debug", "info", "warn", "error"] as const;
type Level = (typeof LEVELS)[number];

interface Entry {
  readonly level: Level;
  readonly message: string;
  readonly at: number;
  readonly context?: Readonly<Record<string, string | number | boolean>>;
}

// A tuple, because the positions mean different things.
type Threshold = [level: Level, enabled: boolean];

function severity(level: Level): number {
  // Index of the level in LEVELS, which is its severity by construction.
  return LEVELS.indexOf(level);
}

function format(entry: Entry): string {
  const context = entry.context
    ? " " + Object.entries(entry.context).map(([k, v]) => k + "=" + String(v)).join(" ")
    : "";
  return "[" + entry.level.toUpperCase().padEnd(5) + "] " + entry.message + context;
}

function describe(level: Level): string {
  switch (level) {
    case "debug": return "for us";
    case "info": return "for the record";
    case "warn": return "worth a look";
    case "error": return "act now";
    default: {
      const unreachable: never = level;
      return unreachable;
    }
  }
}

// unknown at the edge, Entry inside.
function parseEntry(raw: unknown): Entry | null {
  if (typeof raw !== "object" || raw === null) return null;
  const row = raw as Record<string, unknown>;
  const level = row.level;

  if (typeof level !== "string") return null;
  if (!(LEVELS as readonly string[]).includes(level)) return null;
  if (typeof row.message !== "string") return null;
  if (typeof row.at !== "number") return null;

  return { level: level as Level, message: row.message, at: row.at };
}

const RAW: unknown[] = [
  { level: "info", message: "started", at: 1 },
  { level: "error", message: "failed to connect", at: 2 },
  { level: "verbose", message: "not a level", at: 3 },
  { level: "debug", message: "cache miss", at: 4 },
];

const entries = RAW.flatMap((raw) => {
  const entry = parseEntry(raw);
  return entry ? [entry] : [];
});

console.log(entries.length);                  // 3 - ''verbose'' rejected

const threshold: Threshold = ["info", true];
const shown = entries.filter((e) => severity(e.level) >= severity(threshold[0]));

for (const entry of shown) {
  console.log(format(entry) + "  (" + describe(entry.level) + ")");
}
// [INFO ] started  (for the record)
// [ERROR] failed to connect  (act now)

// The run-time list and the compile-time type came from one array,
// so adding a level to LEVELS breaks `describe` until it is handled.
console.log([...LEVELS].map(severity));       // [0, 1, 2, 3]
```

The shape to take away is the pairing at the top: one `as const` array, one derived union type, one validator. Everything downstream - the severity ordering, the exhaustive switch, the parser - is generated from or checked against that single declaration.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A literal widened to `string` | `let` or an object property; use `as const` |
| `any` spread through a whole file | One `any` at a boundary; use `unknown` |
| A `switch` silently missed a new case | No `never` exhaustiveness check |
| An enum had to be imported everywhere | Use a union of literals instead |
| `catch (error)` would not compile | `error` is `unknown`; narrow with `instanceof` |
| `Record<string, X>` allowed any key | That is what it means; use a union key type |
| `String`, `Number` were not assignable | Wrapper objects; use the lowercase primitives |
| `Object is possibly undefined` on `arr[i]` | `noUncheckedIndexedAccess`; use `.at()` or a guard |

## A check you can run

```typescript
const STATUSES = ["draft", "published"] as const;
type Status = (typeof STATUSES)[number];

function label(status: Status): string {
  switch (status) {
    case "draft": return "Draft";
    case "published": return "Live";
    default: {
      const unreachable: never = status;
      return unreachable;
    }
  }
}
console.log(label("draft"));
```

Add `"archived"` to `STATUSES` and run `tsc --noEmit`. You get one error, on the `never` line, saying `Type ''"archived"'' is not assignable to type ''never''` - which is the compiler telling you precisely where the gap is.

Now delete the `default` block entirely and add the status again. It compiles, and `label("archived")` returns `undefined` at run time. Those five lines are the whole difference between a union that is checked and one that merely looks checked.
',
   'The annotations you will write nearly every day, and the three special types that decide how strict the rest of your code gets to be.', 9, 1881,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000043',
   'Inference, and When to Annotate',
   'markdown',
   '# Inference and Annotation

TypeScript infers most types for you. Knowing when to let it, when to help it, and what `as` actually does is the difference between a codebase that reads cleanly and one buried in redundant annotations - or, worse, in assertions that hide real errors.

## What is inferred, and how well

```typescript
const count = 42;                   // 42 - a literal, because const
let total = 42;                     // number - because let may change
const name = "Aisha";               // "Aisha"
const names = ["a", "b"];           // string[]
const mixed = [1, "a"];             // (string | number)[]
const user = { id: 1, name: "x" };  // { id: number; name: string }
const nothing = null;               // null, widened to any without strict

function double(n: number) {        // return type inferred as number
  return n * 2;
}

const tuple = [1, "a"] as const;    // readonly [1, "a"]
console.log(count, total, names.length, user.id, double(2), tuple[1]);
```

Two widening rules do most of the work. A `const` holding a primitive keeps its **literal** type; a `let` widens to the base type, because it may be reassigned. And an object literal''s properties always widen, even under `const`, because the object is mutable:

```typescript
const config = { mode: "fast" };    // mode: string, NOT "fast"
config.mode = "slow";               // which is why - this is legal

const frozen = { mode: "fast" } as const;   // mode: "fast", readonly
console.log(config.mode, frozen.mode);
```

That second one is the fix for the most common inference complaint: "why is this a `string` when I clearly wrote a literal".

## The rule

**Annotate the inputs. Let the outputs be inferred.**

```typescript
// Good: parameters annotated (they must be), return inferred.
function totalMinutes(lessons: { minutes: number }[]) {
  return lessons.reduce((sum, l) => sum + l.minutes, 0);
}

// Noise: the annotations add nothing a reader could not see.
const count: number = 42;
const names: string[] = ["a", "b"];
const doubled: number[] = [1, 2].map((n: number): number => n * 2);

console.log(totalMinutes([{ minutes: 7 }]), count, names.length, doubled[0]);
```

Parameters are the exception because there is nothing to infer from - a function is checked against its own signature, not against its callers. Everything else usually has a value to infer from.

Four cases where annotating the return type earns its place:

```typescript
type Status = "draft" | "published";

// 1. The inferred type would be wider than you mean.
function next(current: Status): Status {
  return current === "draft" ? "published" : "draft";   // infers string without this
}

// 2. It is exported, and you want the contract fixed at the definition.
export function parse(input: string): number[] {
  return input.split(",").map(Number);
}

// 3. The function is recursive, where inference can give up.
function depth(node: { children?: typeof node[] }): number {
  return 1 + Math.max(0, ...(node.children ?? []).map(depth));
}

// 4. You want the body checked against your intent rather than the
//    other way round - so a mistake is reported here, not at a caller.
function toRecord(pairs: [string, number][]): Record<string, number> {
  return Object.fromEntries(pairs);
}

console.log(next("draft"), parse("1,2").length, depth({}), toRecord([["a", 1]]).a);
```

## Why over-annotating hurts

It is not only noise. A redundant annotation can be *wrong in a way the compiler accepts*, and it blocks narrowing:

```typescript
const statuses: string[] = ["draft", "published"];
// statuses is string[], so this is not checkable against a union:
//   const s: "draft" | "published" = statuses[0];   // Error

const better = ["draft", "published"] as const;
const s: "draft" | "published" = better[0];          // fine
console.log(s);
```

It also goes stale. An annotation that says `string[]` on a function that now returns `readonly string[]` is a lie the compiler will happily keep for you, until something downstream breaks in a confusing way.

The honest cost of inference is that hovering is how you read the type, which needs an editor. That is a real trade, and it is why exported signatures are worth annotating even when inference would do.

## as is not a conversion

```typescript
const value: unknown = "hello";

// An assertion: "trust me, it is a string". Nothing is checked, nothing
// is converted. If it were a number, this compiles and throws later.
const text = value as string;
console.log(text.toUpperCase());         // HELLO, because it really was

const sneaky: unknown = 42;
const lie = sneaky as string;
// console.log(lie.toUpperCase());       // compiles; throws at run time
console.log(typeof lie);                 // number
```

`as` tells the compiler to stop checking. It is not `Number(x)`, it is not a cast, and it generates no code at all.

TypeScript refuses assertions between unrelated types, which is a small safety net:

```typescript
// Error: Conversion of type ''string'' to type ''number'' may be a mistake.
//   const n = "abc" as number;

// The double assertion that defeats it. If you write this, write a
// comment next to it saying why.
const n = "abc" as unknown as number;
console.log(typeof n);                   // string - the type is a fiction
```

Three places `as` is legitimate:

```typescript
// 1. Narrowing a literal that the compiler widened.
const mode = "fast" as const;

// 2. Building an object you will fill in, where the empty start is
//    genuinely not yet the final type.
type Counts = Record<"a" | "b", number>;
const counts = {} as Counts;
counts.a = 1;
counts.b = 2;

// 3. A DOM query, where the compiler cannot know the element type.
//    (In a browser; here it is just the shape of the idea.)
//    const input = document.querySelector("#name") as HTMLInputElement;

console.log(mode, counts.a + counts.b);
```

And the non-null assertion `!`, which is `as NonNullable<T>` in one character:

```typescript
const map = new Map<string, number>([["a", 1]]);

// `!` says "I know this is there". It is unchecked, like `as`.
console.log(map.get("a")! + 1);          // 2

// Usually better: handle the missing case, and say what you meant.
const value = map.get("b");
console.log(value === undefined ? "absent" : value + 1);   // absent
```

Treat `!` as a comment that says "I checked this elsewhere" and that the compiler cannot verify. In a long-lived codebase the elsewhere eventually moves.

## satisfies: the operator that checks without widening

`satisfies` is the answer to the problem `as` was being misused for. It checks a value against a type **without replacing the inferred type with it**.

```typescript
type Config = Record<string, string | number | boolean>;

// With `as`: checked, but the type is widened to Config, so
// `withAs.port` is string | number | boolean.
const withAs = { host: "localhost", port: 5432, tls: false } as Config;

// With `satisfies`: checked AND the literal type survives.
const withSatisfies = {
  host: "localhost",
  port: 5432,
  tls: false,
} satisfies Config;

console.log(withSatisfies.port.toFixed(0));      // allowed: it is a number
console.log(typeof withAs.port);                 // the value is the same
// Error with `as` only:
//   withAs.port.toFixed(0);
```

Be precise about what survives, because this is widely misstated. `satisfies` makes the target the *contextual* type rather than the declared one, so each property is inferred against the matching part of the target. Against a union such as `string | number | boolean`, `port` picks `number` - a real narrowing that `as` would have thrown away. Against a plain `string`, a string literal still widens to `string`, because that is what the context asked for.

To keep the literals as well, combine the two:

```typescript
type Level = "debug" | "info" | "error";

const WIDE = { debug: "grey", info: "blue", error: "red" } satisfies Record<Level, string>;
const EXACT = { debug: "grey", info: "blue", error: "red" } as const satisfies Record<Level, string>;

const wide: string = WIDE.error;        // string - the context was `string`
const exact: "red" = EXACT.error;       // "red"  - as const won
console.log(wide, exact);
```

`as const satisfies X` is the combination worth remembering: narrowest possible value types, checked against a contract, and a missing key still reported at the declaration.

The common use is a lookup table that must cover a union:

```typescript
type Level = "debug" | "info" | "error";

const COLOURS = {
  debug: "grey",
  info: "blue",
  error: "red",
} as const satisfies Record<Level, string>;

// A missing key is an error here, at the declaration:
//   Property ''error'' is missing in type ... satisfies Record<Level, string>
// ...and so is a key that is not a Level, which a plain annotation of
// `Record<string, string>` would have allowed.

const errorColour: "red" = COLOURS.error;
console.log(errorColour, Object.keys(COLOURS).length);     // red 3
```

Prefer `satisfies` over `as` and over a type annotation whenever you want both the check and the narrow type - which is most of the time for configuration objects, lookup tables and route maps.

## A worked example

```typescript
// A configuration module, written the way inference wants it: almost
// nothing annotated, one `satisfies` doing the checking, and the types
// of everything downstream derived rather than declared.

type Level = "debug" | "info" | "warn" | "error";

interface ServiceSpec {
  readonly url: string;
  readonly timeoutMs: number;
  readonly retries: number;
  readonly level: Level;
}

// satisfies, not `as` and not a `: Record<...>` annotation. Each value
// keeps its literal type, so `SERVICES.content.url` is the exact
// string and `keyof typeof SERVICES` is the exact union of names.
const SERVICES = {
  content: { url: "http://localhost:4003", timeoutMs: 5000, retries: 3, level: "info" },
  search: { url: "http://localhost:4005", timeoutMs: 2000, retries: 1, level: "warn" },
  support: { url: "http://localhost:4008", timeoutMs: 8000, retries: 2, level: "debug" },
} as const satisfies Record<string, ServiceSpec>;

// Derived, not declared: adding a service to the object above extends
// this union automatically.
type ServiceName = keyof typeof SERVICES;

// Inferred return types throughout; only the parameters are annotated.
function describe(name: ServiceName) {
  const spec = SERVICES[name];
  return name + " -> " + spec.url + " (" + spec.timeoutMs + "ms, " +
    spec.retries + " retries, " + spec.level + ")";
}

function slowest() {
  const entries = Object.entries(SERVICES) as [ServiceName, ServiceSpec][];
  return entries.reduce((worst, entry) =>
    entry[1].timeoutMs > worst[1].timeoutMs ? entry : worst);
}

// Generic in the key, with an annotated return, so the result is that
// service''s own level rather than the union of all of them. This is
// one of the four cases where annotating the return earns its place:
// inference inside a generic body is deliberately conservative and
// gives the whole union.
function levelOf<K extends ServiceName>(name: K): (typeof SERVICES)[K]["level"] {
  return SERVICES[name].level;
}

function budgetMs(name: ServiceName) {
  const spec = SERVICES[name];
  // timeoutMs and retries are numbers - `satisfies` checked them
  // against ServiceSpec without replacing their inferred types.
  return spec.timeoutMs * (spec.retries + 1);
}

for (const name of Object.keys(SERVICES) as ServiceName[]) {
  console.log(describe(name));
}
// content -> http://localhost:4003 (5000ms, 3 retries, info)
// search -> http://localhost:4005 (2000ms, 1 retries, warn)
// support -> http://localhost:4008 (8000ms, 2 retries, debug)

console.log(slowest()[0]);                       // support
console.log(budgetMs("content"));                // 20000

// The literal types survived, which `: Record<string, ServiceSpec>`
// would have erased:
const contentUrl: "http://localhost:4003" = SERVICES.content.url;
const contentLevel: "info" = levelOf("content");
console.log(contentUrl.endsWith("4003"), contentLevel);     // true info

// And a typo in a service name is a compile error rather than
// undefined at run time:
//   describe("serach");
//   Error: Argument of type ''"serach"'' is not assignable to
//   parameter of type ''"content" | "search" | "support"''.
```

Count the annotations. Four function parameters, one interface, one `as const satisfies`. Everything else - the union of names, the return types, the literal URL and level - is derived, and a change to the object at the top propagates everywhere without a single edit.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A literal widened to `string` | `let`, or an object property; use `as const` |
| An object''s type is wider than written | The annotation widened it; use `satisfies` |
| `as` hid a real error | It disables checking; it does not convert |
| `x!` threw at run time | The non-null assertion was unchecked |
| A return type is `any` | Something in the body is `any`; find it |
| An exported function''s type changed silently | Annotate exported return types |
| `Record<K, V>` rejected an incremental build | Build into `{} as Record<...>`, or a partial |
| `Object.keys` gave `string[]` | By design; assert to `(keyof T)[]` if you know |

## A check you can run

```typescript
const routes = {
  home: "/",
  course: "/courses/:slug",
} as Record<string, string>;

const checked = {
  home: "/",
  course: "/courses/:slug",
} satisfies Record<string, string>;

const exact = {
  home: "/",
  course: "/courses/:slug",
} as const satisfies Record<string, string>;

type A = keyof typeof routes;      // string
type B = keyof typeof checked;     // "home" | "course"
type C = typeof exact.home;        // "/"
```

Assign each to something specific and watch which compile. `A` is `string`, so `routes.anything` is legal and a typo is silent. `B` is the exact union of the two names. `C` is the literal path.

All three lines check the same object against the same type. `as` threw the keys away, `satisfies` kept them, and `as const satisfies` kept the values too. That is the ladder, and `as` on a configuration object is almost always the wrong rung.
',
   'The compiler works out most types on its own. Annotating anyway is not harmless: an annotation is a claim you now have to keep in step with the code.', 11, 2211,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

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

Two ways to name a shape, overlapping almost entirely. The differences are small, real, and worth knowing once so you can stop thinking about them.

## The two forms

```typescript
interface User {
  id: number;
  name: string;
  email?: string;              // optional: string | undefined
  readonly createdAt: Date;    // assignable at construction, not after
}

type UserAlias = {
  id: number;
  name: string;
  email?: string;
  readonly createdAt: Date;
};

const user: User = { id: 1, name: "Aisha", createdAt: new Date(0) };
const same: UserAlias = user;          // interchangeable - structural typing
console.log(same.name);                // Aisha
```

TypeScript''s type system is **structural**: two types are compatible when their shapes are compatible, regardless of their names or where they came from. A `User` and a `UserAlias` with the same members are the same type as far as the checker is concerned.

## What only a type alias can do

```typescript
type Status = "draft" | "published";        // a union
type Pair = [number, string];               // a tuple
type Handler = (event: string) => void;     // a function type
type Keys = keyof { a: 1; b: 2 };           // "a" | "b"
type Maybe<T> = T | null;                   // anything that is not an object
type Flag = `--${string}`;                  // a template literal type

const s: Status = "draft";
const p: Pair = [1, "one"];
const h: Handler = (e) => console.log(e);
const k: Keys = "a";
const m: Maybe<number> = null;
const f: Flag = "--verbose";
console.log(s, p, k, m, f);
h("x");
```

An `interface` can only describe an object shape (including a callable or constructable one). Everything above that is not an object needs an alias.

## What only an interface can do

**Declaration merging.** Two interfaces with the same name in the same scope combine:

```typescript
interface Window {
  myAppVersion: string;
}
interface Window {
  myAppBuild: number;
}

declare const w: Window;
console.log(w.myAppVersion, w.myAppBuild);     // both exist
```

That is how you extend `Window`, `process.env` or a third-party library''s types from your own code. A type alias cannot be reopened - redeclaring it is a duplicate identifier error.

**`implements` on a class** works with both, but `extends` on an interface produces better error messages and is checked eagerly, whereas an intersection of aliases is checked lazily and can silently produce `never`:

```typescript
interface Base { id: number }
interface Extended extends Base { name: string }

type BaseAlias = { id: number };
type ExtendedAlias = BaseAlias & { name: string };

const a: Extended = { id: 1, name: "x" };
const b: ExtendedAlias = { id: 1, name: "x" };
console.log(a.id, b.name);

// The lazy-intersection trap: this is a valid type that nothing can
// satisfy, and the error appears at the USE rather than here.
type Impossible = { id: number } & { id: string };
// Error: Type ''number'' is not assignable to type ''never''.
//   const impossible: Impossible = { id: 1 };
```

An `interface extends` with a conflicting member is an error on the declaration, where you want it. An `&` with a conflicting member produces `never` for that property and complains later, somewhere else.

## Which to use

The practical rule, which most style guides now agree on:

- **`interface` for object shapes that other code implements or extends** - public API surfaces, class contracts, anything a consumer may want to augment.
- **`type` for everything else** - unions, tuples, function types, mapped and conditional types, and short local shapes.

Do not agonise. For a plain object shape they are interchangeable, the performance difference is irrelevant below enormous scale, and changing one to the other is a mechanical edit.

## Excess property checking, precisely

```typescript
interface Options { width: number; height?: number }

function render(options: Options): void {
  console.log(options.width);
}

// Error: Object literal may only specify known properties, and
// ''colour'' does not exist in type ''Options''.
//   render({ width: 10, colour: "red" });

// But this is fine - the object is not a fresh literal.
const opts = { width: 10, colour: "red" };
render(opts);
```

That asymmetry confuses everyone once. Structural typing says an object with *more* properties is assignable to a type with fewer - `opts` has everything `Options` needs. Excess property checking is a special extra rule that applies **only to object literals written directly at the call site**, because there the extra property is almost certainly a typo or a misunderstanding rather than a deliberate wider object.

When you genuinely want extra properties, say so:

```typescript
interface Options { width: number; height?: number; [extra: string]: unknown }

function render(options: Options): void { console.log(options.width); }

render({ width: 10, colour: "red" });        // now allowed
```

## Optional versus undefined, and exactOptionalPropertyTypes

```typescript
interface A { name?: string }                 // may be absent
interface B { name: string | undefined }      // must be present, may be undefined

const a1: A = {};                             // fine
const b1: B = { name: undefined };            // fine
// Error: Property ''name'' is missing.
//   const b2: B = {};

console.log("name" in a1, "name" in b1);      // false true
```

`?` means the key may be missing. `| undefined` means the key must be there. The difference matters for anything that iterates keys - `Object.keys`, a spread, a serialiser - and for a `PATCH` endpoint, where "absent" and "explicitly null" are different instructions.

`exactOptionalPropertyTypes` tightens `?` so that it does not also allow an explicit `undefined`:

```typescript
// With the flag on:
//   interface A { name?: string }
//   const a: A = { name: undefined };   // Error
//   const a: A = {};                    // fine
```

Turn it on. It is the difference between "this field was not sent" and "this field was sent as nothing", which is exactly the distinction an update endpoint lives or dies by.

## readonly is compile-time only

```typescript
interface Config {
  readonly host: string;
  readonly ports: readonly number[];
}

const config: Config = { host: "localhost", ports: [80, 443] };

// Error: Cannot assign to ''host'' because it is a read-only property.
//   config.host = "other";
// Error: Property ''push'' does not exist on type ''readonly number[]''.
//   config.ports.push(8080);

// But nothing stopped this, because readonly is erased:
const loose = config as { host: string };
loose.host = "changed";
console.log(config.host);                     // changed
console.log(Object.isFrozen(config));         // false
```

`readonly` on an array removes the mutating methods - `push`, `pop`, `sort`, `splice` - from the type. It does not freeze anything. For a genuine run-time guarantee you need `Object.freeze`, and for deep immutability you need to freeze recursively or not share the object at all.

`readonly` is still worth writing. It documents intent and catches the accidental assignment, which is the overwhelming majority of real mutations.

## A worked example

```typescript
// A plugin system: an interface for the contract others implement, and
// aliases for everything that is not an object shape.

type LogLevel = "debug" | "info" | "warn" | "error";
type Listener = (level: LogLevel, message: string) => void;
type Unsubscribe = () => void;

interface Plugin {
  readonly name: string;
  readonly version: string;
  setup(host: Host): void | Promise<void>;
  teardown?(): void;
}

interface Host {
  log(level: LogLevel, message: string): void;
  on(listener: Listener): Unsubscribe;
  readonly plugins: readonly Plugin[];
}

// Declaration merging: a plugin package can add its own options to the
// host''s config without the host knowing about it.
interface HostConfig {
  verbose?: boolean;
}
interface HostConfig {
  cacheDir?: string;
}

function createHost(config: HostConfig = {}): Host {
  const listeners = new Set<Listener>();
  const plugins: Plugin[] = [];
  const threshold: LogLevel = config.verbose ? "debug" : "info";
  const order: readonly LogLevel[] = ["debug", "info", "warn", "error"];

  const host: Host = {
    log(level, message) {
      if (order.indexOf(level) < order.indexOf(threshold)) return;
      for (const listener of [...listeners]) listener(level, message);
    },
    on(listener) {
      listeners.add(listener);
      return () => { listeners.delete(listener); };
    },
    get plugins() { return plugins; },
  };

  return Object.assign(host, {
    register(plugin: Plugin): void {
      plugins.push(plugin);
      void plugin.setup(host);
    },
  });
}

const captured: string[] = [];
const host = createHost({ verbose: true, cacheDir: "/tmp" });
const off = host.on((level, message) => captured.push(level + ": " + message));

const timing: Plugin = {
  name: "timing",
  version: "1.0.0",
  setup(h) { h.log("debug", "timing ready"); },
  teardown() { /* nothing to release */ },
};

(host as Host & { register(p: Plugin): void }).register(timing);

host.log("info", "hello");
host.log("debug", "noisy");
off();
host.log("error", "after unsubscribe");

console.log(captured);
// [''debug: timing ready'', ''info: hello'', ''debug: noisy'']
console.log(host.plugins.map((p) => p.name));          // [''timing'']
console.log(host.plugins.length);                      // 1

// readonly on the array stops this at compile time:
//   host.plugins.push(timing);
// ...but the underlying array is the same object, so readonly is a
// promise about the view, not about the data.
```

The division is the point. `Plugin` and `Host` are interfaces because other packages implement and extend them. `LogLevel`, `Listener` and `Unsubscribe` are aliases because a union and two function types cannot be interfaces. `HostConfig` is an interface specifically so a plugin can merge into it.

## When it goes wrong

| Symptom | Cause |
|---|---|
| "Object literal may only specify known properties" | Excess property check on a fresh literal |
| The same object passed fine via a variable | Excess checking applies only to literals |
| `Duplicate identifier` on a type alias | Aliases cannot merge; use an interface |
| A property became `never` | An intersection with conflicting members |
| `{}` was missing a required field | `?` was meant, not `| undefined` |
| `readonly` did not prevent a change | It is erased; use `Object.freeze` |
| `Window.myThing` does not exist | Needs an `interface Window` merge in scope |
| An interface could not describe a union | Only an alias can |

## A check you can run

```typescript
interface Options { width: number }
function render(options: Options): void { console.log(options.width); }

const literal = { width: 10, colour: "red" };
render(literal);
```

That compiles. Now inline the variable - `render({ width: 10, colour: "red" })` - and it does not.

Exactly the same values, exactly the same types, and one compiles. Once you have seen that, excess property checking stops being a mystery and becomes what it is: a targeted lint for the one case where an extra property is almost always a mistake.
',
   'Two ways to name a shape. They overlap almost completely, and the one real difference decides which you want.', 9, 1720,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000045',
   'Unions and Narrowing',
   'markdown',
   '# Unions and Narrowing

A union says a value is one of several things. Narrowing is how the compiler works out which one it is in a given branch. Together they replace most of the defensive checking that JavaScript code is made of, and they make illegal states impossible to represent.

## The narrowing operations

The compiler follows ordinary JavaScript checks and narrows the type accordingly. You do not write anything special; you write the check you would have written anyway.

```typescript
function describe(value: string | number | boolean | null): string {
  if (value === null) return "nothing";              // literal equality
  if (typeof value === "string") return value.toUpperCase();   // typeof
  if (typeof value === "number") return value.toFixed(2);
  return value ? "yes" : "no";                       // boolean by elimination
}

console.log(describe(null), describe("hi"), describe(1.5), describe(true));
// nothing HI 1.50 yes
```

Six operations narrow, and between them they cover everything:

```typescript
class Dog { bark() { return "woof"; } }
class Cat { meow() { return "meow"; } }

function speak(animal: Dog | Cat): string {
  // instanceof, for classes
  return animal instanceof Dog ? animal.bark() : animal.meow();
}

function read(value: { a: string } | { b: number }): string {
  // the `in` operator, for object shapes
  return "a" in value ? value.a : String(value.b);
}

function length(value: string | string[]): number {
  // Array.isArray, a built-in type predicate
  return Array.isArray(value) ? value.length : value.length;
}

function trim(value: string | undefined): string {
  // a truthiness check narrows out null and undefined
  return value ? value.trim() : "";
}

console.log(speak(new Dog()), read({ a: "x" }), length(["a"]), trim(undefined));
// woof x 1 ''''
```

Truthiness is the one to be careful with: it also narrows out `""`, `0` and `NaN`, which may be values you wanted.

```typescript
function width(value: number | undefined): number {
  if (value) return value;        // 0 falls through - probably a bug
  return 100;
}

function betterWidth(value: number | undefined): number {
  if (value !== undefined) return value;   // 0 survives
  return 100;
}

console.log(width(0), betterWidth(0));     // 100 0
```

## Discriminated unions

The pattern this lesson exists for. Give every member of the union a common property with a different literal type, and the compiler can tell them apart from one check.

```typescript
type Result =
  | { status: "loading" }
  | { status: "success"; data: string[]; fetchedAt: number }
  | { status: "error"; error: Error; retryable: boolean };

function render(result: Result): string {
  switch (result.status) {
    case "loading":
      return "Loading...";
    case "success":
      // `data` and `fetchedAt` exist here, and nowhere else.
      return result.data.length + " items";
    case "error":
      return (result.retryable ? "Retrying: " : "Failed: ") + result.error.message;
    default: {
      const unreachable: never = result;
      return unreachable;
    }
  }
}

console.log(render({ status: "loading" }));
console.log(render({ status: "success", data: ["a", "b"], fetchedAt: 1 }));
console.log(render({ status: "error", error: new Error("boom"), retryable: true }));
// Loading...
// 2 items
// Retrying: boom
```

## Why a discriminant beats optional fields

Compare the same idea written with optional properties:

```typescript
interface LooseResult {
  loading?: boolean;
  data?: string[];
  error?: Error;
}

function renderLoose(result: LooseResult): string {
  if (result.loading) return "Loading...";
  if (result.error) return "Failed: " + result.error.message;
  // `data` is still `string[] | undefined` here. The compiler cannot
  // know that "not loading and no error" implies data.
  return (result.data?.length ?? 0) + " items";
}

// And every illegal state is representable:
const nonsense: LooseResult = { loading: true, error: new Error("?"), data: [] };
console.log(renderLoose(nonsense));        // Loading...
```

Three things the discriminated version gets that this does not. The compiler **narrows** on the discriminant, so `data` is non-optional in the success branch. Illegal combinations are **unrepresentable** - there is no way to construct a `Result` that is both loading and failed. And the exhaustiveness check **catches new cases**: add `{ status: "cancelled" }` and the `never` line stops compiling.

The discriminant does not have to be a string. A boolean works for two cases, and a numeric literal works too:

```typescript
type Outcome =
  | { ok: true; value: number }
  | { ok: false; reason: string };

function unwrap(outcome: Outcome): number {
  if (outcome.ok) return outcome.value;
  throw new Error(outcome.reason);
}

console.log(unwrap({ ok: true, value: 42 }));      // 42
```

That shape - a two-member union on a boolean - is the Result type that a lot of codebases use instead of throwing.

## Narrowing is forgotten across a boundary

The compiler''s narrowing is per-scope and per-reference. Two things reset it.

**A function call in between**, for a mutable binding:

```typescript
let value: string | undefined = "hello";

function clear(): void { value = undefined; }

if (value !== undefined) {
  clear();
  // The compiler does NOT re-check: it still thinks value is string.
  // This compiles and throws at run time.
  //   console.log(value.toUpperCase());
  console.log(typeof value);
}
```

This is a known unsoundness, and the defence is simple: copy to a `const` first.

```typescript
let mutable: string | undefined = "hello";

const value = mutable;
if (value !== undefined) {
  console.log(value.toUpperCase());        // safe: const cannot change
}
```

**A callback**, because the compiler cannot know when it runs:

```typescript
interface Row { id: number; label?: string }

function process(rows: Row[]): string[] {
  return rows
    .filter((row) => row.label !== undefined)
    // `label` is STILL `string | undefined` here: filter''s type does
    // not tell the compiler anything about the surviving elements.
    .map((row) => row.label ?? "");
}

console.log(process([{ id: 1, label: "a" }, { id: 2 }]));    // [''a'']
```

The fix is a type predicate on the filter, which is what the next lesson is about:

```typescript
interface Row { id: number; label?: string }
type Labelled = Row & { label: string };

function hasLabel(row: Row): row is Labelled {
  return row.label !== undefined;
}

function process(rows: Row[]): string[] {
  return rows.filter(hasLabel).map((row) => row.label.toUpperCase());
}

console.log(process([{ id: 1, label: "a" }, { id: 2 }]));    // [''A'']
```

Note that `row.label` needs no `??` in the second version. The predicate told the compiler what the filter guarantees.

## never is the exhaustiveness trick

```typescript
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "square"; side: number }
  | { kind: "rectangle"; width: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.side ** 2;
    case "rectangle": return shape.width * shape.height;
    default: {
      // If a fourth shape is added, `shape` is that shape here rather
      // than `never`, and this assignment fails to compile.
      const unreachable: never = shape;
      throw new Error("unhandled shape: " + JSON.stringify(unreachable));
    }
  }
}

console.log(area({ kind: "circle", radius: 1 }).toFixed(4));       // 3.1416
console.log(area({ kind: "rectangle", width: 2, height: 3 }));     // 6
```

Put that `default` block in every switch over a union. It costs four lines and it converts "someone will remember" into a compile error with a line number.

## A worked example

```typescript
// A state machine for a form submission, where every transition is
// checked and no illegal state can be built.

type FormState =
  | { phase: "editing"; values: Record<string, string>; dirty: boolean }
  | { phase: "validating"; values: Record<string, string> }
  | { phase: "submitting"; values: Record<string, string>; attempt: number }
  | { phase: "saved"; id: number; at: number }
  | { phase: "failed"; values: Record<string, string>; errors: readonly string[] };

type Event =
  | { type: "change"; field: string; value: string }
  | { type: "submit" }
  | { type: "validated"; ok: boolean; errors?: readonly string[] }
  | { type: "response"; ok: true; id: number }
  | { type: "response"; ok: false; message: string }
  | { type: "retry" };

function reduce(state: FormState, event: Event): FormState {
  switch (state.phase) {
    case "editing":
      if (event.type === "change") {
        return {
          phase: "editing",
          values: { ...state.values, [event.field]: event.value },
          dirty: true,
        };
      }
      if (event.type === "submit") {
        return { phase: "validating", values: state.values };
      }
      return state;

    case "validating":
      if (event.type === "validated") {
        return event.ok
          ? { phase: "submitting", values: state.values, attempt: 1 }
          : { phase: "failed", values: state.values, errors: event.errors ?? [] };
      }
      return state;

    case "submitting":
      if (event.type === "response") {
        // `ok` discriminates the two response shapes, so `id` and
        // `message` are each available in exactly one branch.
        return event.ok
          ? { phase: "saved", id: event.id, at: Date.now() }
          : { phase: "failed", values: state.values, errors: [event.message] };
      }
      return state;

    case "failed":
      if (event.type === "retry") {
        return { phase: "submitting", values: state.values, attempt: 2 };
      }
      if (event.type === "change") {
        return {
          phase: "editing",
          values: { ...state.values, [event.field]: event.value },
          dirty: true,
        };
      }
      return state;

    case "saved":
      return state;               // terminal

    default: {
      const unreachable: never = state;
      return unreachable;
    }
  }
}

function label(state: FormState): string {
  switch (state.phase) {
    case "editing": return state.dirty ? "unsaved changes" : "no changes";
    case "validating": return "checking...";
    case "submitting": return "saving (attempt " + state.attempt + ")";
    case "saved": return "saved as #" + state.id;
    case "failed": return "failed: " + state.errors.join("; ");
    default: {
      const unreachable: never = state;
      return unreachable;
    }
  }
}

const events: Event[] = [
  { type: "change", field: "title", value: "Hello" },
  { type: "submit" },
  { type: "validated", ok: true },
  { type: "response", ok: false, message: "server unavailable" },
  { type: "retry" },
  { type: "response", ok: true, id: 42 },
];

let state: FormState = { phase: "editing", values: {}, dirty: false };
console.log(label(state));

for (const event of events) {
  state = reduce(state, event);
  console.log(event.type.padEnd(10) + " -> " + label(state));
}
// no changes
// change     -> unsaved changes
// submit     -> checking...
// validated  -> saving (attempt 1)
// response   -> failed: server unavailable
// retry      -> saving (attempt 2)
// response   -> saved as #42

// Illegal states are not merely discouraged - they do not type-check:
//   const bad: FormState = { phase: "saved", values: {} };
//   Error: Property ''id'' is missing.
```

Read the `submitting` branch again. `event.ok` is a boolean discriminant across two members of `Event`, so `event.id` exists in one branch and `event.message` in the other, with no optional fields and no `!` anywhere. That is the whole technique.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A field is still optional after a check | No discriminant; the compiler cannot infer the link |
| Narrowing was lost after a function call | Copy to a `const` first |
| `filter` did not narrow the element type | Needs a `value is T` predicate |
| `0` or `""` took the fallback branch | A truthiness check; compare explicitly |
| A new union member broke nothing | No `never` exhaustiveness check |
| `in` narrowing failed | The property is optional in both members |
| `instanceof` failed across realms | Two copies of the class; use a discriminant |
| Both branches of a union are accessible | The members are structurally identical |

## A check you can run

Take any type in your codebase with two or more optional fields that are really alternatives - `data?` and `error?`, say - and rewrite it as a discriminated union.

Then run `tsc --noEmit`. Every error is a place that was reading one field without having established the other was absent. In a form or a data-fetching layer that is usually four or five places, each of which could produce `undefined is not an object` on a bad day. The rewrite takes ten minutes and the errors it surfaces were all already bugs.
',
   'A union says one of these. Narrowing is how the compiler works out which one you have - and it is the part of TypeScript that most changes how you model a problem.', 10, 1929,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000046',
   'Generics',
   'markdown',
   '# Generics

A generic is a type with a parameter. It lets one function or type describe a relationship - "whatever goes in, that comes out" - instead of being written once per concrete type or abandoned to `any`.

## The problem they solve

```typescript
// One function per type. Multiply by every type you have.
function firstString(values: string[]): string | undefined { return values[0]; }
function firstNumber(values: number[]): number | undefined { return values[0]; }

// One function, no types. Everything downstream is any.
function firstAny(values: any[]): any { return values[0]; }

// One function, full types, and the relationship is preserved.
function first<T>(values: readonly T[]): T | undefined { return values[0]; }

const s = first(["a", "b"]);            // string | undefined
const n = first([1, 2]);                // number | undefined
console.log(s?.toUpperCase(), n?.toFixed(1));
```

`T` is bound at the call site, by inference, from the argument. You rarely write `first<string>([...])` - the compiler works it out.

## Naming

`T` is conventional for a single, meaningless parameter, and it is fine. For anything with more than one, use a name:

```typescript
// Hard to read.
function pick<T, U, V>(a: T, b: U, c: V): [T, U, V] { return [a, b, c]; }

// Easier.
function indexBy<Item, Key extends string | number>(
  items: readonly Item[],
  getKey: (item: Item) => Key,
): Map<Key, Item> {
  return new Map(items.map((item) => [getKey(item), item]));
}

const byId = indexBy([{ id: 1, name: "a" }, { id: 2, name: "b" }], (x) => x.id);
console.log(byId.get(2)?.name);         // b
console.log(pick(1, "a", true));        // [1, ''a'', true]
```

The convention that reads best in practice: `T` alone, and descriptive names - `Item`, `Key`, `Value`, `Result` - as soon as there are two.

## extends means "assignable to"

`extends` in a generic constraint does not mean inheritance. It means "must be assignable to", which is the structural question.

```typescript
interface HasId { id: number }

function byId<T extends HasId>(items: readonly T[], id: number): T | undefined {
  return items.find((item) => item.id === id);
}

// Works for anything with an id, and the FULL type survives.
const found = byId([{ id: 1, name: "Aisha", email: "a@example.com" }], 1);
console.log(found?.name, found?.email);          // Aisha a@example.com

// Error: Property ''id'' is missing in type ''{ name: string; }''.
//   byId([{ name: "no id" }], 1);
```

The constraint buys two things: inside the function you may use `item.id`, and outside it the caller keeps `name` and `email` - which `(items: HasId[]) => HasId | undefined` would have thrown away.

Common constraints:

```typescript
function lengthOf<T extends { length: number }>(value: T): number {
  return value.length;
}
console.log(lengthOf("abc"), lengthOf([1, 2]));           // 3 2

function keysOf<T extends object>(value: T): (keyof T)[] {
  return Object.keys(value) as (keyof T)[];
}
console.log(keysOf({ a: 1, b: 2 }));                      // [''a'', ''b'']

function get<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
const user = { id: 1, name: "Aisha" };
console.log(get(user, "name").toUpperCase());             // AISHA
// Error: Argument of type ''"nope"'' is not assignable to ''"id" | "name"''.
//   get(user, "nope");
```

That last one - `K extends keyof T`, returning `T[K]` - is the single most useful generic shape in the language. It makes property access by a dynamic key fully type-safe.

## Defaults, and when to give one

```typescript
interface Response<Data = unknown, Meta = Record<string, string>> {
  data: Data;
  meta: Meta;
  status: number;
}

const loose: Response = { data: "anything", meta: {}, status: 200 };
const tight: Response<string[], { page: number }> = {
  data: ["a"],
  meta: { page: 1 },
  status: 200,
};

console.log(typeof loose.data, tight.data.length, tight.meta.page);
```

A default makes the common case short. Make the default `unknown` rather than `any` so the loose version is still checked.

## Generic classes and interfaces

```typescript
class Cache<Key, Value> {
  readonly #entries = new Map<Key, { value: Value; at: number }>();

  constructor(private readonly ttlMs: number) {}

  set(key: Key, value: Value, now = Date.now()): this {
    this.#entries.set(key, { value, at: now });
    return this;                      // `this` type, so subclasses chain
  }

  get(key: Key, now = Date.now()): Value | undefined {
    const entry = this.#entries.get(key);
    if (!entry) return undefined;
    if (now - entry.at > this.ttlMs) {
      this.#entries.delete(key);
      return undefined;
    }
    return entry.value;
  }

  get size(): number { return this.#entries.size; }
}

const cache = new Cache<string, number[]>(1000);
cache.set("a", [1, 2]).set("b", [3]);
console.log(cache.get("a")?.length, cache.size);          // 2 2
console.log(cache.get("a", Date.now() + 2000));           // undefined - expired
console.log(cache.size);                                  // 1 - and evicted
```

The `this` return type on `set` is worth noticing: it is not `Cache<Key, Value>` but "whatever class this actually is", so a subclass''s `set` still returns the subclass and chaining keeps working.

## When not to use one

A type parameter that appears **once** in a signature is not doing anything.

```typescript
// Pointless: T is used in one place, so it is just `unknown`.
function logIt<T>(value: T): void { console.log(value); }

// The same thing, honestly.
function logIt2(value: unknown): void { console.log(value); }

// Also pointless: the parameter is unconstrained and discarded.
function parse<T>(json: string): T { return JSON.parse(json) as T; }
```

That last one is worse than pointless - it is a lie that looks like safety. The caller writes `parse<User>(text)` and gets an object the compiler believes is a `User` with nothing having checked it. Return `unknown` and make them validate:

```typescript
function parseJson(json: string): unknown { return JSON.parse(json); }
```

The rule of thumb: **a type parameter must appear at least twice**, relating two things. Once in a parameter and once in the return, or twice among the parameters. If it appears once, replace it with `unknown` or a concrete type.

## The one that pays for itself

```typescript
function groupBy<Item, Key extends PropertyKey>(
  items: readonly Item[],
  getKey: (item: Item) => Key,
): Record<Key, Item[]> {
  const out = {} as Record<Key, Item[]>;
  for (const item of items) {
    const key = getKey(item);
    (out[key] ??= []).push(item);
  }
  return out;
}

const lessons = [
  { title: "Selectors", level: "basic" as const },
  { title: "Grid", level: "intermediate" as const },
  { title: "The box model", level: "basic" as const },
];

const grouped = groupBy(lessons, (l) => l.level);
console.log(Object.keys(grouped));                  // [''basic'', ''intermediate'']
console.log(grouped.basic.map((l) => l.title));     // [''Selectors'', ''The box model'']
```

`grouped.basic` is typed, because `Key` was inferred as the literal union `"basic" | "intermediate"` rather than `string`. Two type parameters, each appearing twice, and the result is a record whose keys the compiler knows.

## Inference, and when to help it

```typescript
function merge<A extends object, B extends object>(a: A, b: B): A & B {
  return { ...a, ...b };
}

const merged = merge({ id: 1 }, { name: "Aisha" });
console.log(merged.id, merged.name);                // 1 Aisha

// Inference flows left to right, so an earlier argument can fix a
// later one''s type.
function mapValues<T, R>(
  obj: Record<string, T>,
  fn: (value: T, key: string) => R,
): Record<string, R> {
  return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, fn(v, k)]));
}

const doubled = mapValues({ a: 1, b: 2 }, (v) => v * 2);
console.log(doubled.a);                             // 2 - R inferred as number

// When inference gets it wrong, name the parameter explicitly rather
// than reaching for `as`.
const widened = mapValues<number, string>({ a: 1 }, (v) => String(v));
console.log(widened.a.toUpperCase());               // ''1''
```

## A worked example

```typescript
// A small typed event bus. One generic map of event names to payloads,
// and everything else is derived from it - so adding an event is one
// line and the compiler finds every handler that needs updating.

type EventMap = {
  "lesson:viewed": { lessonId: number; seconds: number };
  "lesson:completed": { lessonId: number; score?: number };
  "course:enrolled": { courseId: number; userId: number };
};

type Handler<E extends keyof EventMap> = (payload: EventMap[E]) => void;
type Unsubscribe = () => void;

class Bus<Events extends Record<string, unknown>> {
  readonly #handlers = new Map<keyof Events, Set<(payload: never) => void>>();

  on<E extends keyof Events>(event: E, handler: (payload: Events[E]) => void): Unsubscribe {
    const set = this.#handlers.get(event) ?? new Set();
    set.add(handler as (payload: never) => void);
    this.#handlers.set(event, set);
    return () => { set.delete(handler as (payload: never) => void); };
  }

  emit<E extends keyof Events>(event: E, payload: Events[E]): number {
    const set = this.#handlers.get(event);
    if (!set) return 0;
    for (const handler of [...set]) (handler as (p: Events[E]) => void)(payload);
    return set.size;
  }

  get events(): (keyof Events)[] {
    return [...this.#handlers.keys()];
  }
}

const bus = new Bus<EventMap>();
const log: string[] = [];

// `payload` needs no annotation: it is inferred from the event name.
const offViewed = bus.on("lesson:viewed", (payload) => {
  log.push("viewed " + payload.lessonId + " for " + payload.seconds + "s");
});

bus.on("lesson:completed", (payload) => {
  log.push("completed " + payload.lessonId + " scoring " + (payload.score ?? 0));
});

bus.on("course:enrolled", (payload) => {
  log.push("user " + payload.userId + " enrolled on " + payload.courseId);
});

console.log(bus.emit("lesson:viewed", { lessonId: 7, seconds: 120 }));     // 1
bus.emit("lesson:completed", { lessonId: 7 });
bus.emit("course:enrolled", { courseId: 3, userId: 42 });

offViewed();
console.log(bus.emit("lesson:viewed", { lessonId: 8, seconds: 5 }));       // 0

console.log(log);
// [''viewed 7 for 120s'', ''completed 7 scoring 0'', ''user 42 enrolled on 3'']
console.log(bus.events.length);                                            // 3

// Every one of these is a compile error, and each is a bug the
// untyped version would have shipped:
//   bus.emit("lesson:viewed", { lessonId: 7 });          // seconds missing
//   bus.emit("lesson:viewd", { lessonId: 7, seconds: 1 }); // typo in the name
//   bus.on("lesson:viewed", (p) => p.courseId);           // wrong payload field
```

That is the shape worth remembering: **one type that maps names to payloads, and a class generic over that map**. The handler''s parameter type, the emit payload type and the set of valid names all come from the single `EventMap` declaration, so they cannot drift apart.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A generic inferred `unknown` | No argument to infer from; pass it explicitly |
| A literal widened to `string` | Add `as const`, or constrain with `extends string` |
| `T` behaves like `any` | It appears once; it is not relating anything |
| `parse<User>()` returned an unvalidated object | A single-use parameter is an assertion |
| The full argument type was lost | The parameter is the constraint, not a generic |
| `Record<K, V>` rejected a partial build | Build into a partial and assert once at the end |
| A subclass''s chained call returned the base | Return `this` rather than the class name |
| `keyof T` is `string | number | symbol` | `T` is unconstrained; add `extends object` |

## A check you can run

Find a function in your codebase whose parameter is an interface and whose return type is that same interface - `(user: User) => User`, say. Make it generic: `<T extends User>(user: T) => T`.

Then call it with an object that has extra fields and use one of those fields on the result. Before the change it does not compile, because the return type was narrowed to `User`. After it, it does.

That is what the constraint form buys: the function can require what it needs while the caller keeps everything they had. Once you have seen the difference on one function you will start writing them this way by default.
',
   'A generic keeps the type information a function was given, instead of flattening it. That is the entire idea; everything else is syntax.', 9, 1869,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

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
   '# The Built-in Utility Types

TypeScript ships about twenty type-level functions. A handful are used constantly, the rest occasionally, and two of them have sharp edges worth knowing before you reach for them.

## The ones you will use daily

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: "admin" | "editor" | "viewer";
}

type PartialUser = Partial<User>;         // every property optional
type RequiredUser = Required<PartialUser>;// every property required
type ReadonlyUser = Readonly<User>;       // every property readonly

type Credentials = Pick<User, "email" | "role">;   // keep these
type PublicUser = Omit<User, "email">;             // drop these

type ById = Record<number, User>;                  // a map type
type Role = User["role"];                          // indexed access

const credentials: Credentials = { email: "a@example.com", role: "admin" };
const publicUser: PublicUser = { id: 1, name: "Aisha", role: "viewer" };
const patch: PartialUser = { name: "Changed" };

console.log(credentials.role, publicUser.name, patch.name);
```

`Pick` and `Omit` are the two you will reach for most. The rule for choosing: **`Pick` when the list of things to keep is shorter, `Omit` when the list to drop is shorter** - and prefer `Pick` when the type may gain fields later, because `Omit` silently lets new fields through.

```typescript
interface User { id: number; name: string; email: string; passwordHash: string }

// If User gains `secretToken`, this leaks it.
type Unsafe = Omit<User, "passwordHash">;

// If User gains `secretToken`, this does not.
type Safe = Pick<User, "id" | "name">;

const safe: Safe = { id: 1, name: "Aisha" };
console.log(safe.name);
```

For anything that leaves your system - an API response, a log line - use `Pick`. The allow-list is the safe default, exactly as it is in every other security context.

## Union utilities

```typescript
type Status = "draft" | "published" | "archived" | "deleted";

type Visible = Exclude<Status, "deleted" | "archived">;   // "draft" | "published"
type Gone = Extract<Status, "deleted" | "archived">;      // "deleted" | "archived"

type Maybe = string | null | undefined;
type Definitely = NonNullable<Maybe>;                     // string

const visible: Visible = "draft";
const definitely: Definitely = "x";
console.log(visible, definitely.length);
```

`Exclude` and `Extract` operate on unions, not on object keys. `Omit` and `Pick` operate on object keys. Mixing them up is the commonest confusion here:

```typescript
interface User { id: number; name: string }

type A = Omit<User, "id">;        // { name: string }   - a type
type B = Exclude<keyof User, "id">;  // "name"           - a union of keys
const a: A = { name: "x" };
const b: B = "name";
console.log(a.name, b);
```

## Function utilities

```typescript
function createLesson(title: string, minutes: number, draft = true) {
  return { id: Math.round(minutes), title, minutes, draft };
}

type Args = Parameters<typeof createLesson>;       // [string, number, (boolean | undefined)?]
type Lesson = ReturnType<typeof createLesson>;     // { id: number; title: string; ... }
type FirstArg = Args[0];                           // string

async function load(): Promise<string[]> { return ["a"]; }
type Loaded = Awaited<ReturnType<typeof load>>;    // string[]

const args: Args = ["Selectors", 7];
const lesson: Lesson = createLesson(...args);
const loaded: Loaded = ["a"];
console.log(lesson.title, loaded.length);
```

`ReturnType<typeof fn>` is how you avoid declaring a type twice when a factory function already defines the shape. `Awaited` unwraps a promise, recursively, which matters for a function returning `Promise<Promise<T>>`.

Also useful, and less known:

```typescript
class Repository {
  constructor(public readonly table: string, private readonly pool: number) {}
}

type RepoArgs = ConstructorParameters<typeof Repository>;   // [string, number]
type Repo = InstanceType<typeof Repository>;                // Repository

const repoArgs: RepoArgs = ["lessons", 5];
const repo: Repo = new Repository(...repoArgs);
console.log(repo.table);

// String utilities, mostly for template literal types.
type Upper = Uppercase<"get">;             // "GET"
type Capped = Capitalize<"name">;          // "Name"
const method: Upper = "GET";
const capped: Capped = "Name";
console.log(method, capped);
```

## Composing them

The utilities compose, and that is where they earn their place:

```typescript
interface Lesson {
  id: number;
  title: string;
  summary: string;
  minutes: number;
  status: "draft" | "published";
  authorId: number;
}

// What a create endpoint accepts: everything except the generated id.
type CreateLesson = Omit<Lesson, "id">;

// What an update endpoint accepts: the id, plus any subset of the rest.
type UpdateLesson = Pick<Lesson, "id"> & Partial<Omit<Lesson, "id">>;

// What a list endpoint returns: a few fields, all readonly.
type LessonSummary = Readonly<Pick<Lesson, "id" | "title" | "minutes">>;

// A patch where every field may also be explicitly null, to clear it.
type NullablePatch = { [K in keyof Omit<Lesson, "id">]?: Lesson[K] | null };

const create: CreateLesson = {
  title: "Selectors", summary: "", minutes: 7, status: "draft", authorId: 1,
};
const update: UpdateLesson = { id: 1, minutes: 9 };
const summary: LessonSummary = { id: 1, title: "Selectors", minutes: 7 };
const clear: NullablePatch = { summary: null };

console.log(create.title, update.minutes, summary.title, clear.summary);
```

Four related types, one source of truth. Adding a field to `Lesson` updates all of them, and the compiler finds every place that now needs it.

## Partial is not free

```typescript
interface Settings { host: string; port: number; tls: boolean }

function connect(settings: Partial<Settings>): string {
  // Every field is now `X | undefined`, so every use needs a default
  // or a check. Partial moves the work to the consumer.
  const host = settings.host ?? "localhost";
  const port = settings.port ?? 3306;
  const tls = settings.tls ?? false;
  return host + ":" + port + (tls ? " (tls)" : "");
}

console.log(connect({ port: 5432 }));      // localhost:5432
```

That is the right shape for an options parameter. It is the wrong shape for internal state: a `Partial<State>` passed around means every reader must handle every field being absent, and the "it is definitely set by now" knowledge lives in comments rather than types.

When some fields are required and some are not, say so rather than reaching for `Partial`:

```typescript
interface Settings { host: string; port: number; tls: boolean }

type Options = Pick<Settings, "host"> & Partial<Omit<Settings, "host">>;

function connect(options: Options): string {
  return options.host + ":" + (options.port ?? 3306);
}

console.log(connect({ host: "db.local" }));         // db.local:3306
// Error: Property ''host'' is missing.
//   connect({ port: 5432 });
```

`Partial` is also shallow. A nested object stays required all the way down:

```typescript
interface Config { db: { host: string; port: number }; debug: boolean }

type Shallow = Partial<Config>;
// db is optional, but if present it must be COMPLETE.
const ok: Shallow = { debug: true };
const alsoOk: Shallow = { db: { host: "x", port: 1 } };
// Error: Property ''port'' is missing.
//   const bad: Shallow = { db: { host: "x" } };

console.log(ok.debug, alsoOk.db?.host);
```

A deep version needs writing, and is in the mapped-types lesson.

## Omit does not check the key exists

```typescript
interface User { id: number; name: string }

// No error. "emial" is not a key of User, and Omit silently does
// nothing - leaving a type identical to User.
type Oops = Omit<User, "emial">;

const oops: Oops = { id: 1, name: "x" };
console.log(oops.name);
```

`Omit<T, K>` is defined with `K extends keyof any`, not `K extends keyof T`, deliberately - so it can be used on unions where a key exists in only some members. The cost is that a typo is silent.

The fix, if you want it checked, is one line:

```typescript
interface User { id: number; name: string }

type StrictOmit<T, K extends keyof T> = Omit<T, K>;

type Good = StrictOmit<User, "name">;
// Error: Type ''"emial"'' does not satisfy the constraint ''"id" | "name"''.
//   type Bad = StrictOmit<User, "emial">;

const good: Good = { id: 1 };
console.log(good.id);
```

`Pick` does check, because it is defined with `K extends keyof T`. That asymmetry is another reason to prefer `Pick`.

## A worked example

```typescript
// One domain type, and every API shape derived from it - which is how
// a request body, a response and a database row stay in step.

interface Lesson {
  id: number;
  courseId: number;
  slug: string;
  title: string;
  summary: string;
  minutes: number;
  status: "draft" | "published" | "archived";
  createdAt: string;
  updatedAt: string;
}

type Generated = "id" | "createdAt" | "updatedAt";

type CreateRequest = Omit<Lesson, Generated>;
type UpdateRequest = Partial<Omit<Lesson, Generated | "courseId" | "slug">>;
type ListItem = Readonly<Pick<Lesson, "id" | "slug" | "title" | "minutes" | "status">>;
type DetailResponse = Readonly<Lesson> & { readonly url: string };

type Paged<T> = {
  readonly items: readonly T[];
  readonly page: number;
  readonly total: number;
};

function toListItem(lesson: Lesson): ListItem {
  return {
    id: lesson.id, slug: lesson.slug, title: lesson.title,
    minutes: lesson.minutes, status: lesson.status,
  };
}

function toDetail(lesson: Lesson): DetailResponse {
  return { ...lesson, url: "/courses/" + lesson.courseId + "/" + lesson.slug };
}

function applyUpdate(lesson: Lesson, patch: UpdateRequest): Lesson {
  // Object.entries loses the types, so the spread is the honest way:
  // every key in patch is a key of Lesson with a compatible value.
  return { ...lesson, ...patch, updatedAt: "2026-10-07T00:00:00Z" };
}

const stored: Lesson = {
  id: 1, courseId: 5, slug: "selectors", title: "Selectors",
  summary: "How the browser matches a rule.", minutes: 7,
  status: "published", createdAt: "2026-01-01T00:00:00Z",
  updatedAt: "2026-01-01T00:00:00Z",
};

const create: CreateRequest = {
  courseId: 5, slug: "the-box-model", title: "The box model",
  summary: "Four boxes, one of which you have been getting wrong.",
  minutes: 7, status: "draft",
};

const patch: UpdateRequest = { minutes: 9, status: "published" };
const updated = applyUpdate(stored, patch);

const page: Paged<ListItem> = {
  items: [toListItem(stored), toListItem(updated)],
  page: 1,
  total: 2,
};

console.log(create.title);                        // The box model
console.log(updated.minutes, updated.status);     // 9 published
console.log(updated.updatedAt !== stored.updatedAt);   // true
console.log(page.items.map((i) => i.slug));       // [''selectors'', ''selectors'']
console.log(toDetail(updated).url);               // /courses/5/selectors

// Each of these is a compile error, and each is a real API bug:
//   const bad1: CreateRequest = { ...create, id: 99 };     // client-set id
//   const bad2: UpdateRequest = { slug: "renamed" };       // immutable field
//   page.items[0].title = "changed";                       // readonly response
```

The `Generated` alias at the top is the small move that makes this work. Naming the set of server-controlled fields once means `CreateRequest` and `UpdateRequest` both exclude them, and adding a fourth generated field is a one-word edit.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Omit` with a typo''d key did nothing | It does not constrain the key; use a strict wrapper |
| A new field leaked into a public response | `Omit` is a deny-list; use `Pick` |
| `Partial` did not make nested fields optional | It is shallow; write a deep version |
| Every field needed a `??` after `Partial` | That is what it means; require what is required |
| `Exclude` did nothing on an object type | It works on unions; use `Omit` for keys |
| `Required` did not remove `undefined` from a value | It removes `?`, not `| undefined` |
| `ReturnType` gave `Promise<T>` | Wrap it in `Awaited` |
| A readonly response was still mutated | `readonly` is compile-time only |

## A check you can run

```typescript
interface User { id: number; name: string; passwordHash: string }

type PublicA = Omit<User, "passwordHash">;
type PublicB = Pick<User, "id" | "name">;

const a: PublicA = { id: 1, name: "x" };
const b: PublicB = { id: 1, name: "x" };
console.log(a.name, b.name);
```

Both compile and both look equivalent. Now add `sessionToken: string` to `User` and run `tsc --noEmit`.

`PublicB` is unchanged. `PublicA` now has a session token in it, and the compiler says nothing, because adding a field to a deny-list type is exactly what a deny-list permits. That difference is invisible until the day it matters, which is the argument for making `Pick` your default.
',
   'A handful of built-in types that transform other types. They save real work, and every one is written in TypeScript you could have written yourself.', 10, 1933,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000048',
   'keyof, typeof and Indexed Access',
   'markdown',
   '# keyof, typeof and Indexed Access

Three small operators that turn a value into a type, a type into its keys, and a key into the type it holds. Together they let you derive types from the data you already have, so the two cannot drift apart.

## typeof means two different things

```typescript
const user = { id: 1, name: "Aisha", tags: ["a"] };

// In an expression: the JavaScript operator, returning a string.
console.log(typeof user);                // "object"

// In a type position: the TypeScript operator, giving the type of a value.
type User = typeof user;
// { id: number; name: string; tags: string[] }

const other: User = { id: 2, name: "Sam", tags: [] };
console.log(other.name);
```

The two are unrelated except in spelling. `typeof x` in a type position is a compile-time query: "what type did the compiler infer for `x`". It works on any value - a variable, a function, a class, an imported module.

```typescript
function load(id: number): { id: number; title: string } {
  return { id, title: "x" };
}

type Loader = typeof load;               // (id: number) => { id: number; title: string }
type Loaded = ReturnType<typeof load>;   // { id: number; title: string }
type Arg = Parameters<typeof load>[0];   // number

const alias: Loader = load;
const result: Loaded = alias(1);
const arg: Arg = 2;
console.log(result.title, arg);
```

## keyof gives the keys as a union

```typescript
interface Lesson {
  id: number;
  title: string;
  minutes: number;
}

type LessonKey = keyof Lesson;           // "id" | "title" | "minutes"

const key: LessonKey = "title";
console.log(key);

// On a Record, keyof gives the key type.
type Scores = Record<"a" | "b", number>;
type ScoreKey = keyof Scores;            // "a" | "b"

// On an array, keyof includes every array method name, which is
// almost never what you want.
type ArrayKey = keyof string[];          // number | "length" | "push" | ...
const ak: ArrayKey = "length";
console.log(ak);
```

For an array you usually want the element type, which is indexed access by `number`:

```typescript
const LEVELS = ["basic", "intermediate", "advanced"] as const;
type Level = (typeof LEVELS)[number];    // "basic" | "intermediate" | "advanced"

const level: Level = "basic";
console.log(level, LEVELS.length);
```

That combination - `as const` on an array, then `(typeof X)[number]` - is the single most useful idiom in this lesson. One declaration gives you both the run-time list and the compile-time union, and they cannot disagree.

## Indexed access: T[K]

```typescript
interface Lesson {
  id: number;
  title: string;
  author: { name: string; email: string };
  tags: string[];
}

type Id = Lesson["id"];                      // number
type Author = Lesson["author"];              // { name: string; email: string }
type AuthorName = Lesson["author"]["name"];  // string
type Tag = Lesson["tags"][number];           // string
type Either = Lesson["id" | "title"];        // number | string

const tag: Tag = "css";
const either: Either = 1;
console.log(tag, either);
```

Indexed access uses square brackets with a **type** inside, not a value. `Lesson["id"]` is the type of the `id` property; `Lesson.id` is not valid type syntax.

## The pattern worth stealing

```typescript
function get<T extends object, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const lesson = { id: 1, title: "Selectors", minutes: 7 };

const title = get(lesson, "title");      // string
const minutes = get(lesson, "minutes");  // number
console.log(title.toUpperCase(), minutes.toFixed(0));

// Error: Argument of type ''"nope"'' is not assignable to parameter of
// type ''"id" | "title" | "minutes"''.
//   get(lesson, "nope");
```

Three pieces, each doing one job. `K extends keyof T` restricts the key to one that exists. `T[K]` says the return type is whatever that key holds. And inference binds both at the call site, so nothing needs writing out.

The same shape handles setting, and a path of two keys:

```typescript
function set<T extends object, K extends keyof T>(obj: T, key: K, value: T[K]): T {
  return { ...obj, [key]: value };
}

function getIn<T extends object, K1 extends keyof T, K2 extends keyof T[K1]>(
  obj: T, k1: K1, k2: K2,
): T[K1][K2] {
  return obj[k1][k2];
}

const row = { id: 1, author: { name: "Aisha", email: "a@example.com" } };
console.log(set(row, "id", 2).id);              // 2
console.log(getIn(row, "author", "name"));      // Aisha
// Error: value must match the key''s type.
//   set(row, "id", "two");
```

## keyof any and index signatures

```typescript
type AnyKey = keyof any;                 // string | number | symbol
// PropertyKey is the built-in alias for exactly that.

function indexBy<T, K extends PropertyKey>(
  items: readonly T[],
  getKey: (item: T) => K,
): Record<K, T> {
  const out = {} as Record<K, T>;
  for (const item of items) out[getKey(item)] = item;
  return out;
}

const byId = indexBy([{ id: 1, n: "a" }, { id: 2, n: "b" }], (x) => x.id);
console.log(byId[2].n);                  // b
```

An index signature changes what `keyof` gives you, and it is worth knowing before you add one:

```typescript
interface Loose {
  id: number;
  [extra: string]: unknown;
}

type LooseKey = keyof Loose;             // string | number
// Not "id" - the index signature swallows the specific keys.

const lk: LooseKey = "anything";
console.log(lk);
```

That is why an index signature is a blunt instrument. It makes every string a valid key, which also means a typo is a valid key. Prefer a `Record<Union, V>` with a specific union, or a `Map`, when you know the keys.

## Deriving one type from another

The practical payoff is that a change in one place propagates:

```typescript
const FIELDS = {
  title: { label: "Title", required: true, maxLength: 120 },
  summary: { label: "Summary", required: false, maxLength: 400 },
  minutes: { label: "Minutes", required: true, maxLength: 3 },
} as const;

type FieldName = keyof typeof FIELDS;                  // "title" | "summary" | "minutes"
type Field = (typeof FIELDS)[FieldName];
type Values = { [K in FieldName]: string };

function validate(values: Values): string[] {
  const problems: string[] = [];
  for (const name of Object.keys(FIELDS) as FieldName[]) {
    const field = FIELDS[name];
    const value = values[name];
    if (field.required && value.trim() === "") problems.push(field.label + " is required");
    if (value.length > field.maxLength) problems.push(field.label + " is too long");
  }
  return problems;
}

console.log(validate({ title: "Hello", summary: "", minutes: "7" }));      // []
console.log(validate({ title: "", summary: "", minutes: "1234" }));
// [''Title is required'', ''Minutes is too long'']

// Add a field to FIELDS and `Values` gains it, `validate` checks it,
// and every caller constructing a Values object fails to compile until
// it is supplied. One edit, and the compiler finds the rest.
```

## A worked example

```typescript
// A typed form layer, where the single source of truth is a plain
// object and every type below is derived from it.

const SCHEMA = {
  title: { kind: "string", label: "Title", required: true },
  minutes: { kind: "number", label: "Minutes", required: true },
  published: { kind: "boolean", label: "Published", required: false },
  summary: { kind: "string", label: "Summary", required: false },
} as const;

type Schema = typeof SCHEMA;
type FieldName = keyof Schema;
type Kind = Schema[FieldName]["kind"];            // "string" | "number" | "boolean"

// Map each declared kind to the TypeScript type it means.
type KindToType = { string: string; number: number; boolean: boolean };

// The form''s value type, derived field by field.
type FormValues = {
  [K in FieldName]: KindToType[Schema[K]["kind"]];
};

function getField<K extends FieldName>(name: K): Schema[K] {
  return SCHEMA[name];
}

function getValue<K extends FieldName>(values: FormValues, name: K): FormValues[K] {
  return values[name];
}

function setValue<K extends FieldName>(
  values: FormValues, name: K, value: FormValues[K],
): FormValues {
  return { ...values, [name]: value };
}

function describe(values: FormValues): string[] {
  const names = Object.keys(SCHEMA) as FieldName[];
  return names.map((name) => {
    const field = SCHEMA[name];
    const value = values[name];
    const mark = field.required ? "*" : " ";
    return mark + " " + field.label.padEnd(10) + " " + field.kind.padEnd(8) + " " + String(value);
  });
}

let values: FormValues = {
  title: "Selectors and the cascade",
  minutes: 7,
  published: false,
  summary: "",
};

// Each of these is checked against the kind declared in SCHEMA.
values = setValue(values, "minutes", 9);
values = setValue(values, "published", true);
// Error: Argument of type ''string'' is not assignable to parameter of type ''number''.
//   values = setValue(values, "minutes", "nine");

for (const line of describe(values)) console.log(line);
// * Title      string   Selectors and the cascade
// * Minutes    number   9
//   Published  boolean  true
//   Summary    string

// The return types are exact, not a union.
const minutes: number = getValue(values, "minutes");
const title: string = getValue(values, "title");
console.log(minutes.toFixed(0), title.length);          // 9 25

// And the field metadata keeps its literal types too.
const titleField = getField("title");
const requiredTitle: true = titleField.required;
console.log(requiredTitle, titleField.kind);            // true string
```

Follow the chain once and the whole lesson is in it. `typeof SCHEMA` turns the value into a type. `keyof Schema` turns that type into its field names. `Schema[K]["kind"]` reads the declared kind out of one field. `KindToType[...]` maps that string to a real type. And `setValue`''s `FormValues[K]` parameter means passing a string where the schema says `number` is a compile error - from one object literal, with no duplicate declarations anywhere.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `keyof` gave `string | number` | An index signature swallowed the specific keys |
| `keyof T[]` listed array methods | Use `T[number]` for the element type |
| `typeof x` returned a string | That is the JavaScript operator; you are in a value position |
| `Lesson.id` is not valid in a type | Use `Lesson["id"]` |
| The union is `string`, not the literals | Missing `as const` |
| `Object.keys` returned `string[]` | By design; assert to `(keyof T)[]` |
| `T[K]` is a union of everything | `K` was `keyof T` rather than a single key |
| Building a `Record<K, V>` incrementally failed | Start from `{} as Record<K, V>` |

## A check you can run

```typescript
const ROLES = ["admin", "editor", "viewer"] as const;
type Role = (typeof ROLES)[number];

function can(role: Role, action: string): boolean {
  return role === "admin" || action === "read";
}

console.log(ROLES.map((r) => can(r, "write")));
```

Now delete `as const` and run `tsc --noEmit`. `Role` becomes `string`, `can` accepts anything, and the typo `can("admnin", "write")` compiles.

Two words, and the difference between a union the compiler enforces and a `string` that documents nothing. That is the whole value of deriving types from values rather than declaring them twice.
',
   'Three operators that derive a type from something that already exists. Between them they remove nearly every case where two things have to be kept in step by hand.', 9, 1745,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-000000000049',
   'Typing Functions Precisely',
   'markdown',
   '# Typing Functions

Functions are where types do most of their work, because a signature is a contract that both sides are checked against. This lesson covers the signature forms, the two kinds of guard that narrow a caller''s types, and when overloads are worth the trouble.

## Parameters and returns

```typescript
function add(a: number, b: number): number {
  return a + b;
}

const multiply = (a: number, b: number): number => a * b;

// Optional, with a default. An optional parameter is `T | undefined`.
function greet(name: string, greeting = "Hello", punctuation?: string): string {
  return greeting + " " + name + (punctuation ?? "");
}

// Rest parameters are a real array, and can be a tuple.
function tally(label: string, ...amounts: number[]): string {
  return label + ": " + amounts.reduce((a, b) => a + b, 0);
}

console.log(add(1, 2), multiply(2, 3));
console.log(greet("Aisha"), greet("Sam", "Hi", "!"));
console.log(tally("total", 1, 2, 3));
```

**Omit the return type on most functions.** Inference is reliable and an annotation is one more thing to keep in sync. Annotate when the function is exported, when inference produces something unhelpfully wide, or when you want the compiler to check the body against your intent:

```typescript
type Status = "draft" | "published";

// Without the annotation this infers `string`, and the mistake below
// would not be caught until a caller used it.
function nextStatus(current: Status): Status {
  return current === "draft" ? "published" : "draft";
}

console.log(nextStatus("draft"));
```

Function *types*, for parameters and variables:

```typescript
type Comparator<T> = (a: T, b: T) => number;
type Predicate<T> = (value: T, index: number) => boolean;

function sortBy<T>(values: readonly T[], compare: Comparator<T>): T[] {
  return [...values].sort(compare);
}

const byLength: Comparator<string> = (a, b) => a.length - b.length;
console.log(sortBy(["ccc", "a", "bb"], byLength));     // [''a'', ''bb'', ''ccc'']
```

Note that `byLength`''s parameters need no annotations: the type of the variable flows into the function literal. That is **contextual typing**, and it is why callbacks passed to `map` and `filter` never need annotating.

## Predicate versus assertion

A **type predicate** returns a boolean and tells the compiler what a true result means.

```typescript
interface User { id: number; name: string }

function isUser(value: unknown): value is User {
  return (
    typeof value === "object" && value !== null &&
    typeof (value as Record<string, unknown>).id === "number" &&
    typeof (value as Record<string, unknown>).name === "string"
  );
}

const raw: unknown = { id: 1, name: "Aisha" };
if (isUser(raw)) {
  console.log(raw.name);          // narrowed to User
}
```

The payoff is in `filter`, which otherwise cannot narrow:

```typescript
const values: (string | null)[] = ["a", null, "b"];

// Without a predicate: still (string | null)[]
const a = values.filter((v) => v !== null);

// With one: string[]
function isNotNull<T>(value: T | null): value is T {
  return value !== null;
}
const b: string[] = values.filter(isNotNull);

console.log(a.length, b.join(""));          // 2 ab
```

Modern TypeScript can sometimes infer the predicate for a simple arrow, but writing it is still the reliable way, and it documents intent.

An **assertion signature** throws instead of returning, and narrows everything after the call:

```typescript
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") throw new TypeError("expected a string");
}

function assertDefined<T>(value: T | null | undefined, what: string): asserts value is T {
  if (value === null || value === undefined) throw new Error(what + " is missing");
}

const unknownValue: unknown = "hello";
assertIsString(unknownValue);
console.log(unknownValue.toUpperCase());    // string from here on

const maybe: number | undefined = 5;
assertDefined(maybe, "count");
console.log(maybe.toFixed(1));              // 5.0
```

Two rules about assertion signatures. The function **must have an explicit annotation** at the call site - assigning it to a `const` with an inferred type loses the assertion. And it must actually throw; the compiler takes your word for it, exactly as with a predicate.

Both are promises, not proofs. A predicate whose body is wrong is a lie the compiler will believe, which is why a validator generated from a schema is safer than one written by hand.

## Overloads are a last resort

```typescript
// Overload signatures - what callers see.
function parse(input: string): string[];
function parse(input: string, asNumbers: true): number[];
// The implementation signature - not callable, must cover both.
function parse(input: string, asNumbers?: boolean): string[] | number[] {
  const parts = input.split(",").map((p) => p.trim());
  return asNumbers === true ? parts.map(Number) : parts;
}

const words = parse("a, b, c");             // string[]
const numbers = parse("1, 2, 3", true);     // number[]
console.log(words.join("|"), numbers.reduce((a, b) => a + b, 0));
// a|b|c 6
```

Overloads solve a real problem - the return type depends on the arguments - but they have costs. The implementation signature is not checked against the overloads as strictly as you would like, so they can drift. They do not compose with generics well. And the error message when no overload matches lists them all, which is noisy.

Prefer a union return and let the caller narrow, or two functions with different names, or a generic:

```typescript
// Two functions. Clearer at every call site.
function parseWords(input: string): string[] {
  return input.split(",").map((p) => p.trim());
}
function parseNumbers(input: string): number[] {
  return parseWords(input).map(Number);
}

console.log(parseWords("a, b").length, parseNumbers("1, 2")[1]);   // 2 2
```

Where overloads genuinely earn their place is wrapping an existing API whose shape you cannot change - `document.createElement`, a database driver''s `query`, an event emitter''s `on`.

## this, and the two ways to type it

```typescript
interface Counter {
  count: number;
  increment(this: Counter): number;
}

const counter: Counter = {
  count: 0,
  increment() { return ++this.count; },
};

console.log(counter.increment(), counter.increment());    // 1 2

// The `this` parameter is compile-time only and is not a real
// argument. With it, detaching the method is an error:
//   const loose = counter.increment;
//   loose();   // Error: The ''this'' context of type ''void'' is not
//              // assignable to method''s ''this'' of type ''Counter''.
```

Declaring `this` as the first parameter is free documentation and it catches the detached-method bug at compile time. An arrow function cannot have one, because it has no `this` of its own.

## The parseInt trap

```typescript
// `parseInt` takes (string, radix?). `map` passes (value, index, array).
console.log(["10", "10", "10"].map(parseInt));       // [10, NaN, 2]

// The index became the radix. The fix is to pass only what you mean:
console.log(["10", "10", "10"].map((s) => parseInt(s, 10)));   // [10, 10, 10]
console.log(["10", "10", "10"].map(Number));                   // [10, 10, 10]
```

TypeScript does **not** catch this, and it is worth understanding why. A function with fewer parameters is assignable to a type with more - that is what makes `arr.map(x => x * 2)` work without declaring the unused index. `parseInt` has two parameters and both are compatible with what `map` passes, so the assignment is legal and the bug is a logic error rather than a type error.

The same shape bites with any multi-parameter function passed point-free. Pass an explicit arrow whenever the target takes more arguments than you want.

## Async functions

```typescript
async function load(id: number): Promise<string> {
  // The annotation is Promise<T>; `return "x"` is wrapped automatically.
  await new Promise((resolve) => setTimeout(resolve, 1));
  return "item " + id;
}

// An async function that returns nothing is Promise<void>.
async function save(): Promise<void> {
  await load(1);
}

// Typing a rejection is not possible: a Promise''s reject type is
// always `any`, so the error path is unchecked. This is a genuine
// hole, and the reason Result-style unions exist.
async function safeLoad(id: number): Promise<{ ok: true; value: string } | { ok: false; error: string }> {
  try {
    return { ok: true, value: await load(id) };
  } catch (error) {
    return { ok: false, error: error instanceof Error ? error.message : String(error) };
  }
}

void (async () => {
  const result = await safeLoad(1);
  console.log(result.ok ? result.value : result.error);
  await save();
})();
```

## A worked example

```typescript
// A typed query builder, exercising predicates, assertions, generics
// and contextual typing in one place.

interface Row { readonly [column: string]: string | number | null }

type Comparator<T> = (a: T, b: T) => number;

function assertDefined<T>(value: T | null | undefined, what: string): asserts value is T {
  if (value === null || value === undefined) throw new Error(what + " is missing");
}

function isNotNull<T>(value: T | null): value is T {
  return value !== null;
}

function isNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

class Query<T extends Row> {
  constructor(private readonly rows: readonly T[]) {}

  where(predicate: (row: T, index: number) => boolean): Query<T> {
    return new Query(this.rows.filter(predicate));
  }

  // The generic ties the column name to the value type, so `pluck`
  // returns exactly what that column holds.
  pluck<K extends keyof T>(column: K): T[K][] {
    return this.rows.map((row) => row[column]);
  }

  // A guard parameter narrows the result type for the caller. V is
  // constrained to T[K], because a guard that cannot possibly match
  // the column''s type would be a silent no-op.
  pluckWhere<K extends keyof T, V extends T[K]>(
    column: K,
    guard: (value: T[K]) => value is V,
  ): V[] {
    return this.rows.map((row) => row[column]).filter(guard);
  }

  sortBy(column: keyof T, compare?: Comparator<T[keyof T]>): Query<T> {
    const fallback: Comparator<T[keyof T]> = (a, b) => String(a).localeCompare(String(b));
    const cmp = compare ?? fallback;
    return new Query([...this.rows].sort((a, b) => cmp(a[column], b[column])));
  }

  first(): T | undefined {
    return this.rows[0];
  }

  get size(): number {
    return this.rows.length;
  }
}

interface Lesson extends Row {
  readonly title: string;
  readonly minutes: number;
  readonly note: string | null;
}

const query = new Query<Lesson>([
  { title: "Selectors", minutes: 7, note: "revised" },
  { title: "The box model", minutes: 7, note: null },
  { title: "Container queries", minutes: 6, note: "new" },
  { title: "Grid", minutes: 6, note: null },
]);

// Contextual typing: `row` needs no annotation.
const long = query.where((row) => row.minutes >= 7);
console.log(long.size);                                  // 2

// pluck returns string[] for title and number[] for minutes.
console.log(query.pluck("title").map((t) => t.toUpperCase()).slice(0, 2));
// [''SELECTORS'', ''THE BOX MODEL'']
console.log(query.pluck("minutes").reduce((a, b) => a + b, 0));     // 26

// The nulls are removed, and the type says so.
const notes: string[] = query.pluck("note").filter(isNotNull);
console.log(notes);                                      // [''revised'', ''new'']

// A guard narrows a mixed column to just the numbers.
console.log(query.pluckWhere("minutes", isNumber));      // [7, 7, 6, 6]

const sorted = query.sortBy("minutes", (a, b) => Number(a) - Number(b));
const shortest = sorted.first();
assertDefined(shortest, "shortest lesson");
console.log(shortest.title);                             // Container queries

// Without the assertion, `shortest.title` would not compile, because
// first() returns T | undefined - which is the compiler pointing at a
// real possibility rather than being awkward.
```

The three guards do three different jobs and it is worth separating them. `isNotNull` narrows an element type inside `filter`. `isNumber` is a validator used as a guard. `assertDefined` throws, and narrows everything after it in the enclosing scope.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `filter` did not narrow the type | It needs a `value is T` predicate |
| An assertion function did not narrow | The call site needs an explicit type annotation |
| `map(parseInt)` produced `NaN` | The index became the radix; pass an arrow |
| A detached method lost `this` | Declare `this` as the first parameter |
| An overload is never selected | Order matters; the first match wins |
| The implementation signature leaked to callers | It is not callable; check the overload list |
| A rejected promise''s type is `any` | Rejection types are unchecked; return a Result |
| A callback parameter is implicitly `any` | No contextual type; annotate the variable instead |

## A check you can run

```typescript
const values: (string | null)[] = ["a", null, "b"];
const filtered = values.filter((v) => v !== null);
const lengths = filtered.map((v) => v.length);
console.log(lengths);
```

Run `tsc --noEmit` on that with `strictNullChecks` on and see whether `v.length` is accepted. Then replace the arrow with a named `isNotNull` predicate and look again.

Whichever way your compiler version falls, the lesson is the same: a predicate makes the guarantee explicit instead of relying on the compiler''s inference of a particular arrow shape - and explicit survives a refactor that turns the arrow into something slightly more complicated.
',
   'Most functions need nothing but parameter types. The ones that need more - because their return depends on their input, or because they prove something - have specific tools for it.', 10, 2039,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

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

These two features turn the type system into a small functional language: mapped types transform every member of a type, conditional types branch on one. Together they are how every utility type in the standard library is written, and how you write the ones it does not have.

## Mapped types: transform every member

```typescript
interface Lesson {
  id: number;
  title: string;
  minutes: number;
}

// The shape of every mapped type: for each K in some union of keys,
// produce a property.
type MyPartial<T> = { [K in keyof T]?: T[K] };
type MyReadonly<T> = { readonly [K in keyof T]: T[K] };
type Nullable<T> = { [K in keyof T]: T[K] | null };
type Stringified<T> = { [K in keyof T]: string };

const patch: MyPartial<Lesson> = { minutes: 9 };
const frozen: MyReadonly<Lesson> = { id: 1, title: "x", minutes: 7 };
const nullable: Nullable<Lesson> = { id: 1, title: null, minutes: 7 };
const form: Stringified<Lesson> = { id: "1", title: "x", minutes: "7" };

console.log(patch.minutes, frozen.title, nullable.title, form.id);
```

Modifiers can be **added** with `readonly` and `?`, and **removed** with `-readonly` and `-?`:

```typescript
interface Loose {
  readonly id?: number;
  readonly name?: string;
}

type Strict<T> = { -readonly [K in keyof T]-?: T[K] };

const strict: Strict<Loose> = { id: 1, name: "x" };
strict.id = 2;                             // writable, and required
console.log(strict.id);
// Error: Property ''name'' is missing.
//   const bad: Strict<Loose> = { id: 1 };
```

Keys can be **renamed** with an `as` clause, which is where mapped types stop being bookkeeping and start being useful:

```typescript
interface Lesson { id: number; title: string; minutes: number }

type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

const accessors: Getters<Lesson> = {
  getId: () => 1,
  getTitle: () => "Selectors",
  getMinutes: () => 7,
};

console.log(accessors.getTitle().toUpperCase(), accessors.getMinutes() + 1);
```

The `as` clause can also **filter**, by mapping a key to `never`:

```typescript
interface Mixed {
  id: number;
  title: string;
  save(): void;
  load(): string;
}

type DataOnly<T> = {
  [K in keyof T as T[K] extends Function ? never : K]: T[K];
};
type MethodsOnly<T> = {
  [K in keyof T as T[K] extends Function ? K : never]: T[K];
};

const data: DataOnly<Mixed> = { id: 1, title: "x" };
const methods: MethodsOnly<Mixed> = { save() {}, load: () => "x" };

console.log(data.title, methods.load());
```

A key mapped to `never` disappears from the result. That is the whole filtering mechanism, and it composes with everything else.

## Conditional types: branch on a type

```typescript
type IsString<T> = T extends string ? "yes" : "no";

type A = IsString<"hello">;         // "yes"
type B = IsString<42>;              // "no"

const a: A = "yes";
const b: B = "no";
console.log(a, b);
```

`T extends U ? X : Y` asks whether `T` is assignable to `U`. The useful part is `infer`, which captures a type from the match:

```typescript
type ElementOf<T> = T extends readonly (infer E)[] ? E : never;
type Returned<T> = T extends (...args: never[]) => infer R ? R : never;
type Unwrapped<T> = T extends Promise<infer V> ? V : T;

type E = ElementOf<string[]>;                  // string
type R = Returned<() => number>;               // number
type U = Unwrapped<Promise<boolean>>;          // boolean

const e: E = "x";
const r: R = 1;
const u: U = true;
console.log(e, r, u);
```

`infer E` declares a type variable, matches it against the position it appears in, and makes it available in the true branch. That is how `ReturnType`, `Parameters` and `Awaited` are written.

## Reading one from the inside out

A real conditional type is best read innermost-first. This is `Awaited`, simplified:

```typescript
type DeepAwaited<T> =
  T extends Promise<infer Inner>          // is it a promise?
    ? DeepAwaited<Inner>                  // yes: unwrap and ask again
    : T;                                  // no: this is the value

type One = DeepAwaited<Promise<string>>;                    // string
type Two = DeepAwaited<Promise<Promise<number>>>;           // number
type Plain = DeepAwaited<boolean>;                          // boolean

const one: One = "x";
const two: Two = 1;
const plain: Plain = true;
console.log(one, two, plain);
```

Recursion is allowed and is how deep transformations are written. TypeScript limits the depth - around fifty levels for the general case - and reports "Type instantiation is excessively deep" when you exceed it.

A deep `Partial`, which the standard library does not provide:

```typescript
type DeepPartial<T> = T extends object
  ? T extends readonly unknown[]
    ? T                                   // leave arrays alone
    : { [K in keyof T]?: DeepPartial<T[K]> }
  : T;

interface Config {
  db: { host: string; pool: { min: number; max: number } };
  tags: string[];
  debug: boolean;
}

const patch: DeepPartial<Config> = { db: { pool: { max: 20 } } };
console.log(patch.db?.pool?.max);          // 20
```

The array check matters: without it, `tags` becomes `{ 0?: string; length?: number; ... }`, which is almost never what anyone wants.

## Distribution is the part that surprises people

A conditional type over a **naked type parameter** distributes across a union: it is applied to each member separately and the results are unioned back.

```typescript
type ToArray<T> = T extends unknown ? T[] : never;

type Distributed = ToArray<string | number>;      // string[] | number[]

const d: Distributed = ["a"];
console.log(d);
```

That is usually what you want - it is how `Exclude<T, U>` works:

```typescript
type MyExclude<T, U> = T extends U ? never : T;

type Status = "draft" | "published" | "deleted";
type Visible = MyExclude<Status, "deleted">;      // "draft" | "published"

const visible: Visible = "draft";
console.log(visible);
```

When you do **not** want distribution, wrap both sides in a tuple:

```typescript
type IsUnion<T> = [T] extends [infer _] ? true : false;

type NoDistribute<T> = [T] extends [string] ? "all strings" : "not all";

type X = NoDistribute<string | number>;           // "not all"
type Y = NoDistribute<"a" | "b">;                 // "all strings"

const x: X = "not all";
const y: Y = "all strings";
console.log(x, y);
```

Without the brackets, `NoDistribute<string | number>` would be `"all strings" | "not all"`, which is useless. The `[T] extends [U]` form is the standard way to ask the question about the union as a whole.

One more consequence worth knowing: distribution over `never` produces `never`, because `never` is the empty union and there is nothing to distribute over.

```typescript
type Wrapped<T> = T extends unknown ? T[] : never;
type Empty = Wrapped<never>;                      // never, not never[]

type NotEmpty = [never] extends [unknown] ? "ran" : "did not";
const ran: NotEmpty = "ran";
console.log(ran);
```

## A worked example

```typescript
// A typed API client, where every route''s handler signature is derived
// from one route table. This is where mapped and conditional types
// stop being clever and start removing real duplication.

interface Routes {
  "GET /lessons": { query: { courseId: number }; response: { id: number; title: string }[] };
  "GET /lessons/:id": { params: { id: number }; response: { id: number; title: string } };
  "POST /lessons": { body: { title: string; minutes: number }; response: { id: number } };
  "DELETE /lessons/:id": { params: { id: number }; response: void };
}

// Pull a part out if it exists, or `never` if the route has no such part.
type PartOf<R, K extends string> = R extends Record<K, infer V> ? V : never;

// Build the argument object from whichever parts a route declares,
// filtering absent ones out by mapping them to never.
type RequestOf<R> = {
  [K in "params" | "query" | "body" as PartOf<R, K> extends never ? never : K]:
    PartOf<R, K>;
};

type ResponseOf<R> = R extends { response: infer Res } ? Res : never;

// The client: one method per route, each with its own argument and
// return type, all derived.
type Client = {
  [K in keyof Routes]: keyof RequestOf<Routes[K]> extends never
    ? () => Promise<ResponseOf<Routes[K]>>
    : (request: RequestOf<Routes[K]>) => Promise<ResponseOf<Routes[K]>>;
};

const client: Client = {
  "GET /lessons": async ({ query }) => [{ id: 1, title: "Selectors " + query.courseId }],
  "GET /lessons/:id": async ({ params }) => ({ id: params.id, title: "One" }),
  "POST /lessons": async ({ body }) => ({ id: body.title.length }),
  "DELETE /lessons/:id": async ({ params }) => { void params; },
};

void (async () => {
  const list = await client["GET /lessons"]({ query: { courseId: 5 } });
  console.log(list.map((l) => l.title));            // [''Selectors 5'']

  const one = await client["GET /lessons/:id"]({ params: { id: 7 } });
  console.log(one.id, one.title);                   // 7 One

  const created = await client["POST /lessons"]({ body: { title: "Grid", minutes: 6 } });
  console.log(created.id);                          // 4

  await client["DELETE /lessons/:id"]({ params: { id: 7 } });
  console.log("deleted");
})();

// Each of these is a compile error, from the one Routes declaration:
//   client["GET /lessons"]({ query: { courseId: "5" } });   // wrong type
//   client["POST /lessons"]({ params: { id: 1 } });         // wrong part
//   client["GET /lessons/:id"]({ params: { id: 1 } }).then((r) => r.length);
//                                                          // not an array

// And a mapped type over the same table, for a router''s handler map.
type Handlers = {
  [K in keyof Routes as `handle${Capitalize<string & K>}`]: (
    request: RequestOf<Routes[K]>,
  ) => ResponseOf<Routes[K]> | Promise<ResponseOf<Routes[K]>>;
};

const names: (keyof Handlers)[] = [
  "handleGET /lessons",
  "handleGET /lessons/:id",
  "handlePOST /lessons",
  "handleDELETE /lessons/:id",
];
console.log(names.length);                          // 4
```

Three techniques are stacked there. `PartOf` is a conditional with `infer` that reads one property or gives `never`. `RequestOf` is a mapped type whose `as` clause filters out the parts a route does not declare. And `Client` is a mapped type over the route names whose value type is itself a conditional. One `Routes` interface, and every call site is checked.

## When to stop

This is the part of the language where it is easiest to write something nobody can maintain.

The honest limits, from codebases that have lived with this:

- **Three levels of nesting is the practical ceiling.** Past that, nobody - including you in six months - can read it.
- **Name the intermediate steps.** `type Part = ...; type Request = ...` is far better than one expression, costs nothing at run time, and makes the error messages legible.
- **If a plain interface would do, write the interface.** Deriving `UpdateLesson` from `Lesson` is worth it. Deriving a type that is used once, from a type that is used once, is not.
- **Watch compile times.** Deeply recursive conditional types over large unions are the main cause of a `tsc` run going from two seconds to forty.
- **A type that needs a comment to explain what it produces** is a type that should have been simpler, or should have the comment.

The test: if a colleague cannot tell you what `Foo<Bar>` evaluates to within thirty seconds, it is too clever for production code.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A conditional produced a union, not one branch | It distributed; wrap in `[T] extends [U]` |
| `Wrapped<never>` is `never` | Distribution over the empty union |
| A deep mapped type mangled arrays | No array guard before the object branch |
| "Type instantiation is excessively deep" | Unbounded recursion; add a depth limit |
| A key did not disappear | Map it to `never` in the `as` clause |
| `keyof T` includes array methods | `T` is an array; use `T[number]` |
| `tsc` became very slow | A recursive conditional over a large union |
| The error message is forty lines | Name the intermediate types |

## A check you can run

```typescript
type Boxed<T> = T extends unknown ? { value: T } : never;
type NotBoxed<T> = [T] extends [unknown] ? { value: T } : never;

type A = Boxed<string | number>;
type B = NotBoxed<string | number>;

const a: A = { value: "x" };
const b: B = { value: 1 };
console.log(a.value, b.value);
```

`A` is `{ value: string } | { value: number }`. `B` is `{ value: string | number }`. Try assigning `{ value: Math.random() > 0.5 ? "x" : 1 }` to each: it fits `B` and fails `A`.

Two square brackets, and a completely different type. That is the single most important thing to know about conditional types, and it is invisible until it bites.
',
   'Types that branch, and types that transform. Together they are how the whole standard library is written, and once you can read them the utility types stop being magic.', 10, 2065,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-00000000004b',
   'Template Literal Types',
   'markdown',
   '# Template Literal Types

A template literal type builds a string type from other types, with the same backtick syntax as a template string. It lets the compiler know the *shape* of a string, which turns a whole class of stringly-typed APIs into checked ones.

## The syntax

```typescript
type Greeting = `hello ${string}`;

const a: Greeting = "hello world";
const b: Greeting = "hello ";         // fits: ${string} matches the empty string
// Error: Type ''"hello"'' is not assignable to type ''`hello ${string}`''.
//   const c: Greeting = "hello";     // no trailing space, so the literal
//                                    // part of the pattern is not matched
// Error: Type ''"goodbye"'' is not assignable to type ''`hello ${string}`''.
//   const d: Greeting = "goodbye";

console.log(a, b);
```

Interpolating a union **distributes**, producing every combination:

```typescript
type Size = "small" | "large";
type Colour = "red" | "blue";

type Class = `${Size}-${Colour}`;
// "small-red" | "small-blue" | "large-red" | "large-blue"

const cls: Class = "large-blue";
console.log(cls);
```

That multiplication is the feature and the hazard. Two unions of four members give sixteen; three give sixty-four. TypeScript caps the result at 100,000 members and errors beyond that.

## The four intrinsic string types

```typescript
type Upper = Uppercase<"get">;             // "GET"
type Lower = Lowercase<"GET">;             // "get"
type Capped = Capitalize<"name">;          // "Name"
type Uncapped = Uncapitalize<"Name">;      // "name"

const u: Upper = "GET";
const c: Capped = "Name";
console.log(u, c);
```

These are built into the compiler - you cannot write them yourself - and they are what make generated key names read properly.

## Inferring from a string

`infer` works inside a template literal type, which is how you parse a string at the type level:

```typescript
type Method<T> = T extends `${infer M} ${string}` ? M : never;
type Path<T> = T extends `${string} ${infer P}` ? P : never;

type M = Method<"GET /lessons">;           // "GET"
type P = Path<"GET /lessons">;             // "/lessons"

const m: M = "GET";
const p: P = "/lessons";
console.log(m, p);
```

Extracting every parameter from a route pattern, recursively:

```typescript
type Params<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | Params<Rest>
    : T extends `${string}:${infer Param}`
      ? Param
      : never;

type One = Params<"/courses/:courseId">;                        // "courseId"
type Two = Params<"/courses/:courseId/lessons/:lessonId">;      // "courseId" | "lessonId"
type None = Params<"/about">;                                   // never

const one: One = "courseId";
const two: Two = "lessonId";
console.log(one, two);
```

And then a function that cannot be called with the wrong parameters:

```typescript
type Params<T extends string> =
  T extends `${string}:${infer P}/${infer Rest}` ? P | Params<Rest>
  : T extends `${string}:${infer P}` ? P
  : never;

function buildPath<T extends string>(
  pattern: T,
  values: Record<Params<T>, string | number>,
): string {
  return Object.entries(values).reduce<string>(
    (path, [key, value]) => path.replace(":" + key, String(value)),
    pattern,
  );
}

console.log(buildPath("/courses/:courseId/lessons/:lessonId", {
  courseId: 5,
  lessonId: 7,
}));
// /courses/5/lessons/7

// Each of these is a compile error:
//   buildPath("/courses/:courseId", {});                  // missing courseId
//   buildPath("/courses/:courseId", { courseID: 5 });     // wrong case
//   buildPath("/about", { anything: 1 });                 // no params allowed
```

That is the shape worth stealing. A route pattern is a string literal the developer already writes; the compiler now reads it and checks the arguments against it.

## Where they earn their place

**Generated key names in a mapped type.**

```typescript
interface State {
  user: string;
  count: number;
}

type WithSetters<T> = T & {
  [K in keyof T as `set${Capitalize<string & K>}`]: (value: T[K]) => void;
};

const state: WithSetters<State> = {
  user: "aisha",
  count: 0,
  setUser(value) { console.log("user ->", value); },
  setCount(value) { console.log("count ->", value); },
};

state.setUser("noshad");
state.setCount(1);
console.log(state.user);
```

`value` needs no annotation in either setter: the mapped type gave it `string` and `number` respectively.

**Event names with a prefix.**

```typescript
type Entity = "lesson" | "course" | "user";
type Action = "created" | "updated" | "deleted";
type EventName = `${Entity}:${Action}`;

function on(event: EventName, handler: () => void): void {
  console.log("listening for " + event);
  void handler;
}

on("lesson:created", () => {});
// Error: Argument of type ''"lesson:renamed"'' is not assignable.
//   on("lesson:renamed", () => {});
```

Nine event names from two declarations, each one checked, and adding an entity extends all of them.

**CSS and design tokens.**

```typescript
type Scale = 0 | 1 | 2 | 4 | 8;
type Side = "t" | "r" | "b" | "l";
type SpacingClass = `p${Side}-${Scale}` | `m${Side}-${Scale}`;

const classes: SpacingClass[] = ["pt-4", "mb-2", "pl-0"];
// Error: Type ''"pt-3"'' is not assignable - 3 is not in Scale.
//   const bad: SpacingClass[] = ["pt-3"];

console.log(classes.join(" "));
```

**Environment variables and config keys.**

```typescript
type Service = "content" | "search" | "support";
type EnvKey = `${Uppercase<Service>}_SERVICE_URL`;
// "CONTENT_SERVICE_URL" | "SEARCH_SERVICE_URL" | "SUPPORT_SERVICE_URL"

const env: Record<EnvKey, string> = {
  CONTENT_SERVICE_URL: "http://localhost:4003",
  SEARCH_SERVICE_URL: "http://localhost:4005",
  SUPPORT_SERVICE_URL: "http://localhost:4008",
};

function urlFor(service: Service): string {
  return env[`${service.toUpperCase() as Uppercase<Service>}_SERVICE_URL`];
}

console.log(urlFor("search"));             // http://localhost:4005
```

A missing key is an error at the declaration, which is the whole point: the set of services and the set of environment variables cannot drift.

## The cost is real

Three costs, in the order you will meet them.

**Combinatorial explosion.** Each interpolated union multiplies. `${A}-${B}-${C}` with ten members each is a thousand-member union, and the compiler holds all of them.

```typescript
type Ten = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j";
type Hundred = `${Ten}-${Ten}`;            // 100 members - fine
// type Million = `${Ten}-${Ten}-${Ten}-${Ten}-${Ten}-${Ten}`;
//   Error: Expression produces a union type that is too complex to represent.

const h: Hundred = "a-b";
console.log(h);
```

**Error messages.** When a value does not match, the compiler may list every member of the union it was checked against. A hundred-member union produces a hundred-line error.

**Compile time.** Recursive template parsing over long strings is one of the slowest things you can ask the checker to do. A route parser over twenty routes is fine; a general-purpose SQL parser in the type system is a known way to make `tsc` take a minute.

## When not to

- **When the string is not known at compile time.** A template literal type checks literals. A value from a database, a form or an API is a `string`, and no amount of type-level cleverness changes that - it needs a run-time validator.
- **When a plain union is enough.** `"lesson:created" | "lesson:updated"` written out is clearer than a generated type when there are four of them.
- **When the pattern is genuinely dynamic.** Type-level parsing of arbitrary user input is a party trick, not a design.
- **When the error message would be worse than the bug.** A fifty-line "not assignable" is not an improvement on a unit test.

Use them where the string is a literal the developer writes anyway - a route pattern, a class name, an event name, a config key. That is where the compiler has something real to check.

## A worked example

```typescript
// A typed query-string builder and router, where the patterns are the
// strings a developer already writes.

type Params<T extends string> =
  T extends `${string}:${infer P}/${infer Rest}` ? P | Params<Rest>
  : T extends `${string}:${infer P}` ? P
  : never;

type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";
type Route = `${HttpMethod} ${string}`;

type MethodOf<R extends Route> = R extends `${infer M} ${string}` ? M : never;
type PatternOf<R extends Route> = R extends `${string} ${infer P}` ? P : never;

// A handler whose params argument is derived from its own route string.
type Handler<R extends Route> = [Params<PatternOf<R>>] extends [never]
  ? () => string
  : (params: Record<Params<PatternOf<R>>, string>) => string;

function route<R extends Route>(spec: R, handler: Handler<R>): {
  method: MethodOf<R>;
  pattern: PatternOf<R>;
  handler: Handler<R>;
} {
  const [method, pattern] = spec.split(" ") as [MethodOf<R>, PatternOf<R>];
  return { method, pattern, handler };
}

const listCourses = route("GET /courses", () => "all courses");

const showLesson = route(
  "GET /courses/:courseSlug/lessons/:lessonSlug",
  (params) => "course " + params.courseSlug + ", lesson " + params.lessonSlug,
);

const deleteLesson = route(
  "DELETE /lessons/:id",
  (params) => "deleting " + params.id,
);

console.log(listCourses.method, listCourses.pattern);     // GET /courses
console.log(listCourses.handler());                       // all courses

console.log(showLesson.handler({ courseSlug: "css", lessonSlug: "grid" }));
// course css, lesson grid

console.log(deleteLesson.method, deleteLesson.handler({ id: "7" }));
// DELETE deleting 7

// Each of these is a compile error, and each is a real routing bug:
//   route("PATCH /x", () => "");                   // PATCH is not an HttpMethod
//   showLesson.handler({ courseSlug: "css" });     // lessonSlug missing
//   showLesson.handler({ course: "css", lesson: "grid" });  // wrong names
//   listCourses.handler({ id: "1" });              // no params on this route

// Query strings, built from a typed record rather than concatenation.
type QueryKey = "page" | "perPage" | "sort" | "q";

function query(values: Partial<Record<QueryKey, string | number>>): `?${string}` | "" {
  const pairs = Object.entries(values)
    .filter(([, v]) => v !== undefined && v !== "")
    .map(([k, v]) => encodeURIComponent(k) + "=" + encodeURIComponent(String(v)));
  return pairs.length === 0 ? "" : (("?" + pairs.join("&")) as `?${string}`);
}

console.log(query({ page: 2, q: "css grid" }));      // ?page=2&q=css%20grid
console.log(query({}));                              // ''''
// Error: ''pge'' does not exist in type Partial<Record<QueryKey, ...>>
//   query({ pge: 2 });
```

The `[Params<...>] extends [never]` test in `Handler` is the detail that makes this usable. Without the brackets it would distribute and a parameterless route would get `never` as its handler type; with them, a route with no parameters gets a zero-argument handler and a route with parameters gets a one-argument one.

## When it goes wrong

| Symptom | Cause |
|---|---|
| "Union type is too complex to represent" | Too many interpolated unions multiplied |
| A runtime string would not assign | Template types check literals, not `string` |
| The error listed a hundred alternatives | That is the union; narrow it or simplify |
| `Capitalize<K>` failed on `keyof T` | `K` may be `number | symbol`; use `string & K` |
| A parameterless route demanded an argument | A conditional distributed; use `[T] extends [U]` |
| `tsc` got very slow | Recursive template parsing; bound the depth |
| The inferred part was the wrong half | `infer` is greedy; reorder the pattern |
| A union member went missing | Recursion hit its limit silently |

## A check you can run

```typescript
type Params<T extends string> =
  T extends `${string}:${infer P}/${infer Rest}` ? P | Params<Rest>
  : T extends `${string}:${infer P}` ? P
  : never;

type A = Params<"/a/:one/b/:two/c/:three">;
const a: A = "two";
console.log(a);
```

Assign `"four"` to `a` and watch it fail; assign `"three"` and watch it pass. Then add a fourth parameter to the string and watch the union grow without you touching anything else.

That string is the one a developer writes anyway, in the router. Everything the compiler now knows about it came free - which is the entire case for this feature, and also the warning: it is free only while the string stays a literal.
',
   'String types built from patterns. They turn a stringly-typed API into one the editor can autocomplete.', 9, 1827,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY)),

  ('e0000001-0000-4000-8000-00000000004c',
   'Declaration Files and Configuration',
   'markdown',
   '# Declaration Files and Configuration

A declaration file describes the types of code that has none. `tsconfig.json` decides how strictly everything is checked and what the output looks like. Both are things you set up once per project and then mostly forget - which is exactly why it is worth understanding them once properly.

## What a .d.ts file is

A `.d.ts` holds types and no implementation. It is what the compiler reads to know about JavaScript it cannot see.

```typescript
// A declaration file is types only - `declare` means "this exists
// somewhere; here is its type".
declare const VERSION: string;
declare function formatDate(date: Date, pattern?: string): string;

declare interface Settings {
  readonly apiUrl: string;
  timeout: number;
}

declare namespace Legacy {
  function init(options: Settings): void;
}

// Nothing above emits any JavaScript. This file would be a .d.ts.
export type { Settings };
```

Three kinds exist, and knowing which you are writing avoids most confusion:

- **Generated** - `tsc` emits them from your own TypeScript when `declaration: true`. This is how a library ships types for code written in TypeScript.
- **Bundled** - a package ships its own `.d.ts` and points at it with `"types"` in its `package.json`. Most modern packages do.
- **Hand-written** - `@types/...` packages from DefinitelyTyped, or a file in your own project for a dependency that has none.

## Where declarations come from

```typescript
// 1. The package ships them. Nothing to do.
//      import { z } from "zod";

// 2. DefinitelyTyped has them.
//      npm install --save-dev @types/node @types/express

// 3. Neither. Write the smallest thing that unblocks you:
//      // types/untyped-lib.d.ts
//      declare module "untyped-lib" {
//        export function doThing(input: string): number;
//        export default function (): void;
//      }

// 4. Or, as a last resort, declare it as `any` with a comment saying
//    why and what the real shape is:
//      declare module "legacy-widget";

export {};
```

Option three is nearly always worth the ten minutes. You only need to declare the parts you actually use, and the file grows as you use more.

Declaring non-code imports that your bundler handles:

```typescript
// types/assets.d.ts
//
//   declare module "*.svg" {
//     const content: string;
//     export default content;
//   }
//
//   declare module "*.css";

export {};
```

## Augmenting what already exists

Interfaces merge, which is how you extend types you do not own.

```typescript
// Globals. In a .d.ts with no top-level import/export, these are
// global automatically; in a module, wrap them in `declare global`.
declare global {
  interface Window {
    readonly appVersion: string;
    analytics?: { track(event: string): void };
  }

  namespace NodeJS {
    interface ProcessEnv {
      readonly DATABASE_URL: string;
      readonly NODE_ENV: "development" | "test" | "production";
      readonly PORT?: string;
    }
  }
}

declare const window: Window;
declare const process: { env: NodeJS.ProcessEnv };

console.log(window.appVersion);
console.log(process.env.NODE_ENV === "production");
// Error: Property ''DATABSE_URL'' does not exist on type ''ProcessEnv''.
//   console.log(process.env.DATABSE_URL);

export {};
```

Typing `process.env` is one of the highest-value declarations in a Node project: it turns every environment-variable typo from `undefined` at run time into a compile error, and it documents what the service needs.

Augmenting a module you did not write:

```typescript
// Adding a property to Express''s Request, the canonical example:
//
//   import "express";
//   declare module "express-serve-static-core" {
//     interface Request {
//       user?: { id: number; role: "admin" | "editor" };
//     }
//   }

export {};
```

The rule: the `declare module` must name the module whose types you are extending, and the file must be a module itself (have an import or export) for `declare global` to be needed.

## The tsconfig flags that matter

```typescript
// tsconfig.json, annotated. The groups are what matter more than the
// individual names.
//
// {
//   "compilerOptions": {
//     // --- correctness: turn all of these on ---
//     "strict": true,
//     "noUncheckedIndexedAccess": true,
//     "exactOptionalPropertyTypes": true,
//     "noImplicitOverride": true,
//     "noFallthroughCasesInSwitch": true,
//
//     // --- module resolution: match your runtime ---
//     "module": "nodenext",
//     "moduleResolution": "nodenext",
//     "target": "es2022",
//     "lib": ["es2022"],
//     "verbatimModuleSyntax": true,
//
//     // --- output ---
//     "outDir": "dist",
//     "declaration": true,
//     "declarationMap": true,
//     "sourceMap": true,
//     "incremental": true,
//
//     // --- interop ---
//     "esModuleInterop": true,
//     "skipLibCheck": true,
//     "forceConsistentCasingInFileNames": true,
//
//     // --- your own declarations ---
//     "typeRoots": ["./node_modules/@types", "./types"]
//   },
//   "include": ["src/**/*.ts", "types/**/*.d.ts"],
//   "exclude": ["node_modules", "dist"]
// }

export {};
```

The five worth understanding rather than copying:

**`strict`** turns on eight flags. Start with it on; retrofitting it is a week of work per hundred files.

**`module` and `moduleResolution`** must match how your code actually runs. `nodenext` for Node, `bundler` for Vite or webpack, `preserve` when something downstream handles it. Getting this wrong produces "Cannot find module" for packages that are plainly installed - and the cause is nearly always a package using `exports` conditions that the older `node` resolution cannot read.

**`skipLibCheck: true`** skips type-checking inside `.d.ts` files. It feels like cheating and it is standard practice, because one dependency with a broken declaration otherwise blocks your entire build for a problem you cannot fix.

**`verbatimModuleSyntax: true`** makes `import type` mandatory for type-only imports and emits imports exactly as written. It removes a whole class of surprises where the compiler elided an import that had a side effect.

```typescript
// With verbatimModuleSyntax, the distinction is enforced:
//   import type { User } from "./types.js";   // erased at compile time
//   import { createUser } from "./users.js";  // kept, it is a value
export {};
```

**`declaration: true` plus `declarationMap: true`** is what a library needs: the first emits `.d.ts` files for consumers, the second lets their editor jump to your real source rather than the generated declaration.

## Project references, when one tsconfig is not enough

```typescript
// For a monorepo, each package gets its own tsconfig with
// "composite": true, and the root lists them:
//
//   {
//     "files": [],
//     "references": [
//       { "path": "./packages/shared" },
//       { "path": "./services/content" },
//       { "path": "./services/search" }
//     ]
//   }
//
// Then `tsc --build` compiles only what changed, in dependency order,
// and each package''s declarations are what the others see - so a
// breaking change in `shared` is reported at its consumers.

export {};
```

The payoff is incremental builds and real boundaries between packages. The cost is that every cross-package import must go through a package''s public entry point, which is usually a good thing and occasionally an afternoon of rearranging.

## The honest limit

A declaration file is a **claim**, and nothing checks it against the JavaScript it describes.

```typescript
// Suppose a hand-written declaration says:
//   declare module "some-lib" {
//     export function parse(input: string): { id: number };
//   }
//
// ...and the library actually returns { ID: string }. Everything
// compiles. Everything fails at run time. The declaration was wrong
// and the compiler has no way to know.

export {};
```

This is the same hole as `as` at a boundary, one level up. Three defences:

- **Prefer a package that ships its own types**, generated from its real source.
- **Declare only what you use**, so there is less surface to get wrong.
- **Test the boundary.** One integration test that actually calls the library and checks the shape is worth more than a hundred lines of careful declaration.

The same applies to `@types` packages: they are community-maintained and can lag behind the library by a major version. When something is mysteriously wrong, check the `@types` version against the library''s.

## A worked example

```typescript
// The declarations a small Node service actually needs, written as one
// file. In a real project this is `types/env.d.ts` and the `declare
// global` block would need the file to be a module - as it is here,
// because of the export at the bottom.

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      readonly NODE_ENV: "development" | "test" | "production";
      readonly DATABASE_URL: string;
      readonly CONTENT_SERVICE_URL: string;
      readonly SEARCH_SERVICE_URL: string;
      readonly PORT?: string;
      readonly LOG_LEVEL?: "debug" | "info" | "warn" | "error";
    }
  }
}

// A stand-in for the real `process`, so this example runs anywhere.
declare const process: { env: NodeJS.ProcessEnv };

// Reading configuration, with the types doing the documentation.
interface Config {
  readonly env: NodeJS.ProcessEnv["NODE_ENV"];
  readonly databaseUrl: string;
  readonly port: number;
  readonly logLevel: NonNullable<NodeJS.ProcessEnv["LOG_LEVEL"]>;
  readonly services: Readonly<Record<"content" | "search", string>>;
}

function readConfig(env: NodeJS.ProcessEnv): Config {
  // Required values are typed `string`, so the compiler does not force
  // a check - which is exactly why the declaration must be honest
  // about what is optional.
  return {
    env: env.NODE_ENV,
    databaseUrl: env.DATABASE_URL,
    port: Number(env.PORT ?? 3000),
    logLevel: env.LOG_LEVEL ?? "info",
    services: {
      content: env.CONTENT_SERVICE_URL,
      search: env.SEARCH_SERVICE_URL,
    },
  };
}

// A run-time check, because a declaration is a claim and this is the
// boundary where the claim is actually tested.
function assertConfigured(env: NodeJS.ProcessEnv): void {
  const required = ["NODE_ENV", "DATABASE_URL", "CONTENT_SERVICE_URL", "SEARCH_SERVICE_URL"] as const;
  const missing = required.filter((key) => !env[key]);
  if (missing.length > 0) {
    throw new Error("missing environment variables: " + missing.join(", "));
  }
}

const fakeEnv: NodeJS.ProcessEnv = {
  NODE_ENV: "development",
  DATABASE_URL: "mysql://localhost/learning",
  CONTENT_SERVICE_URL: "http://localhost:4003",
  SEARCH_SERVICE_URL: "http://localhost:4005",
  LOG_LEVEL: "debug",
};

assertConfigured(fakeEnv);
const config = readConfig(fakeEnv);

console.log(config.env, config.port, config.logLevel);
// development 3000 debug
console.log(config.services.content);
// http://localhost:4003

// Each of these is a compile error, which is the whole return on
// twelve lines of declaration:
//   config.env === "prod";                      // not a NODE_ENV value
//   fakeEnv.DATABSE_URL;                        // typo
//   readConfig({ NODE_ENV: "development" });    // missing required keys
//   config.port = 4000;                         // readonly

console.log(typeof process === "undefined" ? "no process here" : "process exists");

export { readConfig, assertConfigured };
export type { Config };
```

The `assertConfigured` function is the part people leave out. The declaration says `DATABASE_URL` is a `string`, so the compiler never asks whether it is set - and at run time an unset variable is `undefined`, which is a `string` as far as the declaration is concerned. One check at start-up, failing loudly, is what makes the declaration true.

## When it goes wrong

| Symptom | Cause |
|---|---|
| "Could not find a declaration file for module" | Install `@types/...` or write a `declare module` |
| "Cannot find module" for an installed package | `moduleResolution` does not match the runtime |
| A `declare global` block was ignored | The file is a script, not a module, or not in `include` |
| Errors inside `node_modules` | Turn on `skipLibCheck` |
| Types are right but run time is wrong | A declaration is a claim; test the boundary |
| An import vanished from the output | Type-only elision; use `verbatimModuleSyntax` |
| A consumer cannot jump to your source | Missing `declarationMap` |
| `@types` disagrees with the library | Version mismatch; check both |

## A check you can run

Add this to a Node project and run `tsc --noEmit`:

```typescript
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      readonly DATABASE_URL: string;
    }
  }
}
export {};
```

Every `process.env.SOMETHING_ELSE` in the codebase is now an error, and the list is the complete inventory of environment variables the service reads - including the three nobody documented and the one that is spelled differently in two files.

That inventory, produced in one command from twelve lines of declaration, is usually the most surprising thing a project learns about itself in its first week with TypeScript.
',
   'How to use a library that ships no types, how to extend one that does, and the handful of tsconfig flags that decide how much the compiler does for you.', 10, 1920,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 1 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt),
  -- The counts, because a seed must update every column it owns.
  --
  -- They were missing. Rewriting an article's body therefore left word_count
  -- and reading_time_minutes at whatever they were when the row was first
  -- inserted, so a lesson that had grown from 300 words to 1,300 went on
  -- telling every reader it was a two-minute read - and the body was visibly
  -- longer, which makes the stale number look like a bug in the page rather
  -- than in this clause.
  reading_time_minutes = VALUES(reading_time_minutes), word_count = VALUES(word_count),
  revision = content_articles.revision + 1;

CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000007');
