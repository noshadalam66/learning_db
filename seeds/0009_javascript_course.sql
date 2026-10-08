-- ===========================================================================
-- Seed 09 : the JavaScript course, basics -> intermediate -> advanced -> expert
--
-- Same shape as HTML and CSS: one course, four modules, twelve lessons, a quiz
-- at the end of each level.
--
-- The fence language is what changes. These lessons carry ```javascript
-- blocks, and the front end reads that fence to decide which compiler the
-- "Try yourself!" button opens - JavaScript runs natively in the sandboxed
-- iframe, so there is no server involved in running any of this.
-- ===========================================================================

INSERT INTO catalog_tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-00000000000e', 'javascript', 'JavaScript'),
  ('bbbbbbb1-0000-4000-8000-00000000000f', 'typescript', 'TypeScript'),
  ('bbbbbbb1-0000-4000-8000-000000000010', 'async',      'Async')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO catalog_courses
  (id, slug, title, subtitle, overview, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000006',
   'javascript-from-basics-to-expert',
   'JavaScript: From Basics to Expert',
   'Four levels, twelve lessons, every example runs in your browser',
   'JavaScript is the only programming language a browser runs, which is how it ended up everywhere else as well: on servers through Node, in build tools, in databases, in editors. Learn it once and you can work at either end of a web application.

It has a reputation for being strange, and it has earned about half of it. The strangeness is concentrated in a few places - how values compare, what `this` refers to, what happens to code that waits - and the rest of the language is small and ordinary. This course spends its time on the few places rather than on the many.

The payoff is that most of the behaviour people work around without understanding has one explanation, usually a short one. A closure, the event loop, and the prototype chain account for a surprising share of the bugs in front-end code.',
   'A complete path through JavaScript in four levels. Level 1, Basic, covers values and types, functions and scope, and the two structures everything else is built from. Level 2, Intermediate, is the working vocabulary: the array methods you will use every day, destructuring, and classes. Level 3, Advanced, is where the language gets interesting - closures, promises and async/await, and modules. Level 4, Expert, finishes with the event loop, iterators and generators, and the metaprogramming hooks that make frameworks possible.

No previous JavaScript is assumed, though you will move faster if you have written HTML. If you already use the language at work, Level 1 and Level 2 are the vocabulary you probably have; Level 3 and Level 4 are the parts that explain the behaviour you have worked around without ever being told why it happens.

Three lessons and a Level Check quiz per level, then an Expert Exam. Every example is complete and runnable: press Try yourself and it opens in the compiler, where you edit on the left and watch what it logs on the right. It runs in your browser, so there is nothing to install and nothing is sent to a server.

Every lesson ships a complete, runnable example. Press the "Try yourself!" button under any of them and it opens in the compiler, where you write on the left and see what it logs on the right. It runs in your browser, not on a server.

By the end you will be able to read the JavaScript in any codebase and know what it is doing: why a value captured in a closure changed, what order your callbacks will run in, how a framework intercepts a property access, and when a generator is the simple answer rather than the clever one.',
   'aaaaaaa1-0000-4000-8000-000000000003',
   '55555555-5555-4555-8555-555555555555',
   'beginner', 'published',
   'https://images.example-cdn.test/courses/javascript-from-basics-to-expert.jpg', 0,
   JSON_ARRAY('Predict what a piece of JavaScript will do before you run it',
              'Reach for the right array method instead of a for loop',
              'Explain what a closure is, and use one on purpose',
              'Write async code that handles failure as carefully as success',
              'Read the event loop well enough to explain why order surprised you',
              'Use generators and proxies where they genuinely earn their place'),
   JSON_ARRAY('You can write basic HTML', 'No previous JavaScript required'),
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), subtitle = VALUES(subtitle), overview = VALUES(overview),
  description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog_course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-00000000000e'),
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-000000000010'),
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO catalog_modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'Level 1 - Basic',
   'The ground floor, and the three things that cause most early confusion. Values and types covers the two equalities and why one of them is almost always the one you want; functions and scope covers hoisting, let against var, and what this refers to; and the last lesson is arrays and objects, out of which everything else in the language is built.', 1),
  ('d0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'Level 2 - Intermediate',
   'The vocabulary you will actually type. The array methods lesson is map, filter, reduce and the ones people reimplement by hand because nobody showed them; destructuring and spread are how modern code moves data about; and classes and prototypes explain what the class keyword is standing in front of.', 2),
  ('d0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'Level 3 - Advanced',
   'Where the language stops being obvious and starts being powerful. Closures explain the captured variable, the counter that keeps counting and the loop that logged the wrong number; promises and async/await cover the error handling people get wrong; and modules are how any of it is split across files without a global.', 3),
  ('d0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'Level 4 - Expert',
   'The machinery underneath. The event loop lesson answers what runs when, including the difference between a microtask and a timer; iterators and generators show how for...of works and how to make your own lazy sequence; and the last lesson covers the symbols and proxies that frameworks are built on.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

INSERT INTO catalog_lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Level 1
  ('e0000001-0000-4000-8000-000000000031', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'values-and-types', 'Values and Types',
   'JavaScript has seven primitive types and one object type. That is the whole list, and knowing it settles most of the questions that look like language quirks - including the coercion rules that surprise everyone exactly once.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-000000000032', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'functions-and-scope', 'Functions and Scope',
   'Three ways to write a function, and the differences between them are not stylistic - they change when the function exists and what this means inside it. Declarations, expressions and arrows, with the hoisting rule for each.',
   'article', 'published', 2, 600, 1),
  ('e0000001-0000-4000-8000-000000000033', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'arrays-and-objects', 'Arrays and Objects',
   'Both are objects and both are held by reference. That one fact explains the first genuinely confusing bug most people write: a copy that was not a copy, and a change in one place showing up in another.',
   'article', 'published', 3, 600, 0),
  ('e0000001-0000-4000-8000-00000000003d', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'js-level-1-check', 'Level 1 Check: Values, Scope and Equality',
   'Five questions on the seven primitives, how equality actually compares them, where a binding is visible, and reference semantics. Every one of these is something you can settle in the scratchpad below the questions.',
   'quiz', 'published', 4, 420, 1),

  -- Level 2
  ('e0000001-0000-4000-8000-000000000034', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'array-methods', 'The Array Methods You Will Actually Use',
   'Nine methods replace almost every loop you would otherwise write. The win is not fewer characters - it is that the method name says what the loop is for before you read the body: map, filter, reduce and the six worth knowing by name.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000035', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'destructuring-and-spread', 'Destructuring and Spread',
   'Two pieces of syntax that show up in nearly every modern JavaScript file. Both are about moving values in and out of shapes without a pile of temporary variables - including defaults, renaming and the rest pattern.',
   'article', 'published', 2, 600, 0),
  ('e0000001-0000-4000-8000-000000000036', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'classes-and-prototypes', 'Classes and Prototypes',
   'class is syntax over the prototype system that was already there, and knowing what it compiles to explains every behaviour that looks odd from the outside. With the # private fields that are genuinely private rather than conventionally so.',
   'article', 'published', 3, 720, 0),
  ('e0000001-0000-4000-8000-00000000003e', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'js-level-2-check', 'Level 2 Check: Everyday JavaScript',
   'Five questions on which array method to reach for, what destructuring does with a missing property, and what class syntax is really doing underneath - the vocabulary you will use on every working day.',
   'quiz', 'published', 4, 480, 0),

  -- Level 3
  ('e0000001-0000-4000-8000-000000000037', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'closures', 'Closures',
   'A closure is a function that remembers the scope it was created in, even after that scope has finished. It sounds academic and it is behind most of the JavaScript patterns you will read, from a counter to a module to a memoised call.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000038', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'promises-and-async', 'Promises and async/await',
   'A promise is a value that is not there yet; async and await are syntax for waiting on one without nesting callbacks. Sequential when you need it, parallel when you do not, and failure handled either way rather than swallowed.',
   'article', 'published', 2, 840, 0),
  ('e0000001-0000-4000-8000-000000000039', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'modules', 'Modules',
   'A module is a file with its own scope: nothing leaks out unless you export it, nothing comes in unless you import it, and the file runs exactly once however many times it is imported. That last part is what makes a module a good place to keep state.',
   'article', 'published', 3, 660, 0),
  ('e0000001-0000-4000-8000-00000000003f', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'js-level-3-check', 'Level 3 Check: Closures and Async',
   'Five questions on what a closure captures, how promises order their work, and why a module body runs once. Several of these are easier to answer by running them than by reasoning about them, so run them.',
   'quiz', 'published', 4, 540, 0),

  -- Level 4
  ('e0000001-0000-4000-8000-00000000003a', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'the-event-loop', 'The Event Loop',
   'JavaScript runs on one thread, and everything asynchronous is a queue of work that thread picks up when it has finished what it is doing. Once you can see the queues, ordering stops being surprising - including why setTimeout(fn, 0) runs after a promise.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000003b', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'iterators-and-generators', 'Iterators and Generators',
   'for...of works on anything that follows one small protocol, and a generator is a function that can pause in the middle and implements that protocol for free. Which is how you write a lazy sequence, or one that never ends.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-00000000003c', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'metaprogramming', 'Symbols, Proxies and Metaprogramming',
   'The hooks that let you change what the language itself does to your objects. Every reactivity framework of the last decade is built on them, and most application code should not use them at all - this says why, as well as how.',
   'article', 'published', 3, 840, 0),
  ('e0000001-0000-4000-8000-000000000040', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'js-expert-exam', 'Expert Exam: JavaScript',
   'Twenty questions over the whole course: the event loop and the order its queues run in, iterators and generators, and the metaprogramming hooks underneath every modern framework.',
   'quiz', 'published', 4, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
-- ---------------------------------------------------------------------------
INSERT INTO content_articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000031',
   'Values and Types',
   'markdown',
   '# Values and Types

JavaScript has seven primitive types and one object type. That is the whole list, and most of the language''s reputation for strangeness comes from two decisions made in that list: all numbers are the same type, and values convert into one another when you compare them.

Both decisions are knowable. Neither is random.

## The seven primitives, and the one thing that is not

```javascript
typeof 42;              // ''number''
typeof 42n;             // ''bigint''
typeof ''hello'';         // ''string''
typeof true;            // ''boolean''
typeof undefined;       // ''undefined''
typeof Symbol(''id'');    // ''symbol''
typeof null;            // ''object''   <- the famous bug
typeof {};              // ''object''
typeof [];              // ''object''   <- arrays are objects
typeof function () {};  // ''function'' <- functions are objects too
```

A primitive is immutable and compared by value. An object is mutable and compared by identity. That single sentence explains more surprises than any other in the language:

```javascript
const a = ''hello'';
const b = ''hello'';
a === b;                // true  - same value

const x = { n: 1 };
const y = { n: 1 };
x === y;                // false - different objects
x === x;                // true
```

`x` and `y` look identical and are not equal, because `===` on objects asks "is this the same object", not "do these look alike". There is no built-in deep equality. When you need one, write it or use a library - and be suspicious of any code that compares objects with `===` and expects a match.

## Numbers are all the same type

There is no int and no float. Every `number` is a 64-bit IEEE 754 double, which means every integer up to 2 to the 53 is exact and every decimal fraction whose denominator is not a power of two is not.

```javascript
0.1 + 0.2;                      // 0.30000000000000004
0.1 + 0.2 === 0.3;              // false

Number.MAX_SAFE_INTEGER;        // 9007199254740991
9007199254740993;               // 9007199254740992  - silently wrong

(0.1 + 0.2).toFixed(2);         // ''0.30''  - a string, for display only
Math.abs(0.1 + 0.2 - 0.3) < Number.EPSILON;   // true - the comparison to use
```

This is not a JavaScript flaw; it is how binary floating point works everywhere. What is specific to JavaScript is that there is no integer type to escape into for ordinary arithmetic, so two rules follow.

**Never store money in a number.** Store it in the smallest unit as an integer - pence, cents - and divide only when you display it. An invoice total that is out by 0.00000000001 is a bug report you cannot reproduce.

**Use `BigInt` when you need exact integers past the safe range**, which in practice means database ids and anything counting in nanoseconds:

```javascript
const id = 9007199254740993n;   // exact
id + 1n;                        // 9007199254740994n
// id + 1;                      // TypeError - no mixing with number
Number(id);                     // 9007199254740992 - lossy, and silent
```

The `TypeError` on mixing is deliberate. Allowing it would mean a bigint silently losing precision the moment it met a number, which is the bug the type exists to prevent.

## typeof null is "object"

This is a genuine bug, dating from the first implementation, where a value''s type lived in the low bits of its tag and the null pointer had all bits zero - which happened to be the object tag. It has never been fixed because fixing it would break an enormous amount of code that works around it.

```javascript
typeof null;                    // ''object''
null instanceof Object;         // false

// The check that actually works:
const isObject = (v) => v !== null && typeof v === ''object'';
```

While we are here: `null` and `undefined` are different on purpose. `undefined` means nobody set this. `null` means somebody set this to nothing. A function returning `undefined` forgot; a function returning `null` decided.

```javascript
const user = { name: ''Aisha'', middleName: null };
user.middleName;        // null       - we asked; they have none
user.nickname;          // undefined  - we never asked
```

## Coercion, and the one rule worth memorising

**Use `===`. Always.** That is the rule, and if you stop reading here you have the useful part. But knowing what `==` does is still worth ten minutes, because you will read code that uses it.

`==` converts both sides to a common type before comparing. The conversion table is long; the parts that matter are short:

```javascript
''5'' == 5;               // true  - string becomes number
true == 1;              // true  - boolean becomes number
null == undefined;      // true  - special-cased, and only each other
null == 0;              // false - null does NOT become a number here
'''' == 0;                // true
''0'' == false;           // true
[] == false;            // true   - [] becomes '''' becomes 0
[] == ![];              // true   - which reads like a riddle
NaN == NaN;             // false  - NaN is equal to nothing, including itself
```

The last one is not coercion, it is the IEEE standard, and it applies to `===` too. To test for `NaN`, use `Number.isNaN(x)` - not the global `isNaN`, which coerces first and therefore says `isNaN(''hello'')` is true.

The one case where `==` is genuinely useful is `x == null`, which is true for both `null` and `undefined` and nothing else. It is a concise "is this missing", and it is the only `==` worth writing on purpose.

## Truthiness: eight falsy values, everything else true

```javascript
// Falsy, all of them:
false, 0, -0, 0n, '''', null, undefined, NaN
// Truthy, including the ones that surprise people:
''0'', ''false'', [], {}, function () {}, Infinity
```

`[]` and `{}` being truthy is the one that bites. `if (list)` is true for an empty array, so it does not mean "has items" - `if (list.length)` does.

## The operators that know the difference

```javascript
const settings = { retries: 0, label: '''', timeout: undefined };

settings.retries || 3;          // 3  - wrong! 0 is a real setting
settings.retries ?? 3;          // 0  - right
settings.label || ''none'';       // ''none'' - probably wrong
settings.label ?? ''none'';       // ''''     - right

// Optional chaining short-circuits on null and undefined only.
const city = user?.address?.city;             // undefined, no throw
const first = list?.[0];                      // works on arrays too
const result = handlers.onSave?.(payload);    // calls only if present
```

`??` and `?.` test for null and undefined specifically, rather than for falsiness. They are the right default for configuration, API responses and anything where zero or the empty string is a legitimate value.

## A worked example

```javascript
// A tiny settings merge that gets every one of the above right.
function resolve(defaults, overrides) {
  const out = { ...defaults };
  for (const [key, value] of Object.entries(overrides)) {
    // ?? not ||, so an explicit 0 or '''' survives.
    out[key] = value ?? defaults[key];
  }
  return out;
}

const defaults = { retries: 3, prefix: ''app'', verbose: false, ratio: 0.5 };
const given = { retries: 0, prefix: '''', verbose: undefined, ratio: null };

const settings = resolve(defaults, given);
console.log(settings);
// { retries: 0, prefix: '''', verbose: false, ratio: 0.5 }

// retries 0 survived      - it is a number, not a missing value
// prefix '''' survived      - it is a string, not a missing value
// verbose fell back       - undefined means not set
// ratio fell back         - null means not set

// Money, done properly: integers until the moment of display.
const linePence = [1999, 450, 1299];
const totalPence = linePence.reduce((sum, p) => sum + p, 0);
console.log(totalPence);                        // 3748 - exact
console.log((totalPence / 100).toFixed(2));     // ''37.48''

// And the comparison that actually works for floats.
const close = (a, b) => Math.abs(a - b) < 1e-9;
console.log(0.1 + 0.2 === 0.3);                 // false
console.log(close(0.1 + 0.2, 0.3));             // true
```

## When it goes wrong

| Symptom | Cause |
|---|---|
| Two identical-looking objects are not equal | `===` compares identity, not contents |
| A total is out by a tiny fraction | Floating point; keep money in integer minor units |
| A large id changes by one | Past `Number.MAX_SAFE_INTEGER`; use `BigInt` or a string |
| A zero setting is replaced by the default | `||` instead of `??` |
| An empty array passed a truthiness check | `[]` is truthy; test `.length` |
| `typeof x === ''object''` was true for null | The historical bug; test `x !== null` as well |
| A `NaN` comparison is always false | Correct behaviour; use `Number.isNaN` |
| `JSON.parse` turned a big id into a wrong number | Same safe-integer limit; ask the API for a string |

## A check you can run

Paste the worked example above into the console and change one thing at a time. Set `retries` to `null` and watch the default come back. Change `??` to `||` and watch the explicit zero vanish. Replace `close(a, b)` with `===` and watch a correct calculation report itself as wrong.

Then try this, which is the whole lesson in four lines:

```javascript
console.log([] + {});        // ''[object Object]''
console.log([] + []);        // ''''
console.log(typeof NaN);     // ''number''
console.log(0.1 + 0.2);      // 0.30000000000000004
```

None of those is a bug. Each follows from a rule above. Being able to say which rule, for each line, is what it means to know this part of the language.
',
   'JavaScript has seven primitive types and one object type. That is the whole list, and knowing it settles most of the questions that look like language quirks.', 8, 1560,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000032',
   'Functions and Scope',
   'markdown',
   '# Functions and Scope

Two questions account for most confusion about JavaScript functions: when does a name exist, and what is `this`. Both have precise answers. Neither answer is "it depends".

## Four ways to make a function, and why it matters

```javascript
// 1. Declaration - hoisted completely, name and body.
function area(w, h) { return w * h; }

// 2. Expression assigned to a const - the binding is hoisted, the
//    value is not, so it exists but cannot be used before this line.
const volume = function (w, h, d) { return w * h * d; };

// 3. Arrow - same hoisting as 2, but no own this, arguments or
//    prototype, and it cannot be used with new.
const perimeter = (w, h) => 2 * (w + h);

// 4. Method shorthand in an object or class.
const shape = {
  w: 3, h: 4,
  area() { return this.w * this.h; },
};
```

The differences that matter day to day are hoisting and `this`. Everything else is style.

## Hoisting, precisely

Hoisting is not "declarations move to the top". It is that the engine creates every binding in a scope before running any of its code, and then decides what each binding holds until its declaration line is reached.

```javascript
console.log(declared());    // ''works'' - function declarations are complete
console.log(hoistedVar);    // undefined - the binding exists, holds undefined

// The third case throws, so it is caught here rather than ending the
// example. Delete the try to see it stop the file.
try {
  console.log(letBinding);
} catch (error) {
  console.log(error.constructor.name);   // ''ReferenceError''
}

function declared() { return ''works''; }
var hoistedVar = 1;
let letBinding = 2;
```

- **A function declaration** is hoisted whole. You can call it above its own definition, which is why a file can read top-down with helpers at the bottom.
- **`var`** is hoisted and initialised to `undefined`. The read does not throw; it silently gives you nothing, which is worse.
- **`let` and `const`** are hoisted but left uninitialised. Reading one before its declaration throws a `ReferenceError`. That region is called the temporal dead zone, and it exists precisely so the `var` behaviour above cannot happen.

Use `const` by default, `let` when you must reassign, and `var` never. That is not fashion: `var` is function-scoped rather than block-scoped, which produces a classic bug.

```javascript
// The loop everyone has met.
const withVar = [];
for (var i = 0; i < 3; i++) withVar.push(() => i);
console.log(withVar.map((f) => f()));   // [3, 3, 3] - one shared i

const withLet = [];
for (let j = 0; j < 3; j++) withLet.push(() => j);
console.log(withLet.map((f) => f()));   // [0, 1, 2] - a fresh j each pass
```

`let` in a `for` header creates a new binding per iteration. That is a special rule written into the language because this bug was so common.

## Scope is lexical, which means it is readable

A function can see the variables of the scope it was *written in*, not the scope it is called from. This is decided when you write the code, so you can answer "which x is this" by reading outwards from the function - you never need to know who calls it.

```javascript
const outer = ''module'';

function middle() {
  const outer = ''middle'';
  return inner();        // calls inner, but inner cannot see this one
}

function inner() {
  return outer;          // ''module'' - where inner was written
}

console.log(middle());   // ''module''
```

If scope were dynamic, `inner` would see `middle`''s `outer` and the answer would depend on the call site. It is not, and that is a feature: a function''s meaning is local.

## this, in one rule

`this` is not about where a function is defined. For an ordinary function, **`this` is whatever is to the left of the dot at the call site**. That single sentence covers nearly every case.

```javascript
const counter = {
  count: 0,
  increment() { this.count++; return this.count; },
};

counter.increment();            // this === counter, because of ''counter.''

const loose = counter.increment;
// loose();                     // this is undefined in a module - TypeError

loose.call(counter);            // explicit: this === counter
const bound = counter.increment.bind(counter);
bound();                        // this === counter, permanently
```

Four binding rules, in the order the engine checks them:

1. **`new Thing()`** - `this` is the newly created object.
2. **`fn.call(obj)`, `fn.apply(obj)`, `fn.bind(obj)`** - `this` is `obj`, explicitly.
3. **`obj.fn()`** - `this` is `obj`, implicitly, from the dot.
4. **A bare `fn()`** - `this` is `undefined` in modules and strict mode, and the global object in sloppy mode. Prefer modules; the `undefined` is a useful error rather than a silent global.

**An arrow function obeys none of these.** It has no `this` of its own, so `this` inside it means whatever `this` meant in the enclosing scope, permanently. That is exactly what you want in a callback and exactly what you do not want in an object literal:

```javascript
const timer = {
  seconds: 0,
  // Right: the arrow keeps the method''s this.
  startGood() { setInterval(() => { this.seconds++; }, 1000); },
  // Wrong: the ordinary function is called bare, so this is undefined.
  startBad() { setInterval(function () { this.seconds++; }, 1000); },
  // Wrong in a different way: an arrow as a method has no object this.
  reset: () => { this.seconds = 0; },
};
```

## A worked example

```javascript
// A small event emitter, exercising scope, this, and closures together.
function createEmitter() {
  // Private to every emitter, by closure rather than convention.
  const handlers = new Map();

  return {
    on(event, handler) {
      if (!handlers.has(event)) handlers.set(event, new Set());
      handlers.get(event).add(handler);
      // Return an unsubscribe closure over the exact handler.
      return () => handlers.get(event).delete(handler);
    },

    emit(event, payload) {
      const set = handlers.get(event);
      if (!set) return 0;
      // A copy, so a handler that unsubscribes during emit is safe.
      for (const handler of [...set]) handler(payload);
      return set.size;
    },

    get count() {
      let total = 0;
      for (const set of handlers.values()) total += set.size;
      return total;
    },
  };
}

const bus = createEmitter();

const log = [];
const off = bus.on(''save'', (p) => log.push(''first: '' + p));
bus.on(''save'', (p) => log.push(''second: '' + p));

bus.emit(''save'', ''doc-1'');
console.log(log);            // [''first: doc-1'', ''second: doc-1'']
console.log(bus.count);      // 2

off();                       // the closure remembers which handler
bus.emit(''save'', ''doc-2'');
console.log(log);            // ...plus ''second: doc-2'' only
console.log(bus.count);      // 1

// Now the this trap, demonstrated rather than described.
const listener = {
  seen: [],
  handle(p) { this.seen.push(p); },
};

// Passed as a value, the dot is left behind and this is undefined.
try {
  listener.handle.call(undefined, ''doc-3'');
} catch (error) {
  console.log(error.constructor.name);       // ''TypeError''
}

// The fix: keep the dot by wrapping the call, or bind it once.
bus.on(''save'', (p) => listener.handle(p));
bus.emit(''save'', ''doc-4'');
console.log(listener.seen);                  // [''doc-4'']
```

Three things are worth tracing. `handlers` is never exported, yet every method can reach it - that is closure, and it is a stronger privacy than a naming convention. The unsubscribe function returned by `on` closes over the specific handler, so it needs no arguments. And `listener.handle` loses its `this` the moment it is passed as a value, because the dot was left behind.

## Default parameters, rest and arity

```javascript
// Defaults are evaluated at call time, left to right, and can refer
// to earlier parameters.
function slice(list, start = 0, end = list.length) {
  return list.slice(start, end);
}

// Rest collects the remainder into a real array - unlike arguments,
// which is array-like and absent from arrow functions.
function tally(label, ...amounts) {
  return label + '': '' + amounts.reduce((a, b) => a + b, 0);
}
console.log(tally(''total'', 1, 2, 3));   // ''total: 6''

// Only parameters before the first default count towards length.
console.log(slice.length);              // 1
console.log(tally.length);              // 1
```

A default is re-evaluated on every call, which matters when it is an object: `function f(opts = {})` gives a fresh object each time, not one shared between calls. That is the opposite of Python, and it is the safer choice.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Cannot read properties of undefined (reading ...)` inside a method | The method was passed as a value and lost its `this` |
| All closures in a loop see the last value | `var` in the loop header; use `let` |
| `ReferenceError: Cannot access before initialization` | A `let` or `const` read in its temporal dead zone |
| A variable is `undefined` rather than throwing | `var` hoisting hid the mistake |
| `this` is `undefined` in a callback | An ordinary function where an arrow was wanted |
| `this` is the global object, not your object | Sloppy mode; use modules or `''use strict''` |
| An arrow method cannot see the object | Arrows have no own `this`; use method shorthand |
| `new` on an arrow throws | Arrows have no prototype and are not constructors |

## A check you can run

Take any function in your own code that reads `this` and ask one question: can it be called without a dot? If a `.map()`, an event listener or a `setTimeout` ever receives it as a bare value, it can - and it will fail the first time someone does.

Then run the `withVar` and `withLet` loops above and change nothing but the keyword. The result changes from `[3, 3, 3]` to `[0, 1, 2]`. That difference is the whole argument for block scoping, and it fits in four lines.
',
   'Three ways to write a function, and the differences are not stylistic - they change when the function exists and what this means inside it.', 8, 1595,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000033',
   'Arrays and Objects',
   'markdown',
   '# Arrays and Objects

Almost every data bug in a JavaScript codebase has the same shape: two names pointing at one object, and a change through one name surprising a reader of the other. This lesson is about seeing that shape before it costs you an afternoon.

## References, and the bug this lesson exists to prevent

Objects and arrays are handed around by reference. Assigning one does not copy it; it makes a second name for the same thing.

```javascript
const original = { name: ''Aisha'', tags: [''php'', ''sql''] };
const alias = original;

alias.name = ''Noshad'';
console.log(original.name);     // ''Noshad'' - one object, two names

const copy = { ...original };   // a copy, one level deep
copy.name = ''Sam'';
console.log(original.name);     // ''Noshad'' - the top level is safe

copy.tags.push(''go'');
console.log(original.tags);     // [''php'', ''sql'', ''go''] - still shared
```

The last three lines are the bug. `{ ...original }` copied the top level, so `name` is independent - but `tags` was a reference, and copying a reference gives you a second reference to the same array. This is called a shallow copy, and every built-in copy in JavaScript is shallow: spread, `Object.assign`, `Array.prototype.slice`, `Array.from`.

Three ways to go deeper, in order of preference:

```javascript
// 1. structuredClone - built in, handles Map, Set, Date, TypedArray,
//    and cycles. Does not handle functions or class identity.
const deep = structuredClone(original);

// 2. Copy explicitly, at each level you care about. Verbose, but it
//    says what it does and never copies more than you need.
const shaped = { ...original, tags: [...original.tags] };

// 3. JSON round trip - only for plain data, and it silently destroys
//    Date (becomes a string), undefined, Infinity, NaN and functions.
const risky = JSON.parse(JSON.stringify(original));
```

Reach for `structuredClone` by default. Reach for the explicit copy when the shape is small and known, which is most of the time in a well-designed module.

## Arrays are objects with a length

An array is an object whose keys happen to be numeric strings, plus a `length` that the engine maintains. Knowing this explains several behaviours that otherwise look arbitrary.

```javascript
const list = [''a'', ''b'', ''c''];
Object.keys(list);           // [''0'', ''1'', ''2''] - strings
list[10] = ''z'';
console.log(list.length);    // 11 - length tracks the highest index
console.log(list[5]);        // undefined - a hole, not a stored value
console.log(list);           // [''a'',''b'',''c'', <7 empty items>, ''z'']

// Holes are not undefined values, and some methods skip them.
console.log(list.map((x) => 1));        // holes stay holes
console.log([...list].length);          // 11 - spread fills them in

// length is writable, which is a truncation nobody expects.
list.length = 2;
console.log(list);                      // [''a'', ''b'']
```

Sparse arrays are a corner you should stay out of rather than master. Build arrays with `push`, `Array.from({ length: n }, fn)` or a literal, never by assigning past the end.

## Property order is specified, and it is not insertion order

Objects do have a defined key order, which surprises people who were told they do not.

```javascript
const odd = { b: 1, 2: 2, a: 3, 1: 4 };
console.log(Object.keys(odd));      // [''1'', ''2'', ''b'', ''a'']
```

Integer-like keys come first, in ascending numeric order. Everything else follows in insertion order. Symbols come last and are skipped by `Object.keys` entirely.

This is why a `Map` is the right choice when order matters and keys are not all strings:

```javascript
const counts = new Map();
counts.set(''b'', 1).set(2, 2).set(''a'', 3);
console.log([...counts.keys()]);    // [''b'', 2, ''a''] - true insertion order
```

Use a `Map` when keys are dynamic, non-string, or numerous; use an object when the shape is known and fixed. A `Map` also has a real `size`, iterates without `hasOwnProperty` ceremony, and cannot collide with `__proto__` or `toString`.

## Reading safely

```javascript
const response = { data: { items: [{ id: 1 }] } };

response.data?.items?.[0]?.id;          // 1
response.meta?.page?.total;             // undefined, no throw
response.meta?.page?.total ?? 0;        // 0 - a usable default

// ''in'' versus a truthiness test versus hasOwn:
const row = { value: 0, note: undefined };
row.value ? ''set'' : ''unset'';            // ''unset'' - wrong, 0 is a value
''value'' in row;                         // true  - correct
Object.hasOwn(row, ''note'');             // true  - it exists, holds undefined
Object.hasOwn(row, ''toString'');         // false - inherited, not own
''toString'' in row;                      // true  - in walks the prototype
```

`Object.hasOwn` replaces `Object.prototype.hasOwnProperty.call(obj, key)`, which was the long way of asking the same question safely.

## A worked example

```javascript
// Grouping, summing and shaping - the three things you actually do
// with arrays of records, done without mutating the input.
const orders = [
  { id: 1, customer: ''aisha'', total: 1999, status: ''paid'' },
  { id: 2, customer: ''noshad'', total: 450, status: ''pending'' },
  { id: 3, customer: ''aisha'', total: 1299, status: ''paid'' },
  { id: 4, customer: ''sam'', total: 2500, status: ''paid'' },
  { id: 5, customer: ''noshad'', total: 199, status: ''paid'' },
];

// 1. Group. Object.groupBy returns a null-prototype object, so a
//    customer called ''constructor'' cannot do any damage.
const byCustomer = Object.groupBy(orders, (o) => o.customer);
console.log(Object.keys(byCustomer));        // [''aisha'', ''noshad'', ''sam'']

// 2. Summarise, without touching orders.
const summary = Object.entries(byCustomer).map(([customer, rows]) => ({
  customer,
  orders: rows.length,
  paidPence: rows
    .filter((o) => o.status === ''paid'')
    .reduce((sum, o) => sum + o.total, 0),
}));

// 3. Sort a COPY. toSorted leaves the original alone; sort would not.
const ranked = summary.toSorted((a, b) => b.paidPence - a.paidPence);
console.log(ranked);
// [ { customer: ''aisha'',  orders: 2, paidPence: 3298 },
//   { customer: ''sam'',    orders: 1, paidPence: 2500 },
//   { customer: ''noshad'', orders: 2, paidPence: 199  } ]

// 4. Index for lookup. A Map, because ids are numbers and we want size.
const byId = new Map(orders.map((o) => [o.id, o]));
console.log(byId.get(3).customer);           // ''aisha''
console.log(byId.size);                      // 5

// 5. Update one record immutably. The spread replaces the object at
//    that index; every other element is the same reference, which is
//    exactly what a framework''s change detection wants.
const updated = orders.map((o) =>
  o.id === 2 ? { ...o, status: ''paid'' } : o);

console.log(orders[1].status);               // ''pending'' - untouched
console.log(updated[1].status);              // ''paid''
console.log(updated[0] === orders[0]);       // true - shared, deliberately
```

The last line is the point of immutable updates. Only the changed object is new, so a comparison by reference tells a renderer exactly which row to redraw. Deep-cloning the whole array would also be correct and would throw that information away.

## The copying methods, old and new

Four array methods now have non-mutating twins. Prefer the twin unless you have a reason.

| Mutates | Copies | Note |
|---|---|---|
| `sort()` | `toSorted()` | Default sort is lexicographic - always pass a comparator for numbers |
| `reverse()` | `toReversed()` | |
| `splice()` | `toSpliced()` | |
| `arr[i] = v` | `with(i, v)` | Returns a new array with one index changed |

```javascript
const nums = [10, 9, 100, 1];
console.log(nums.toSorted());                 // [1, 10, 100, 9]  - strings!
console.log(nums.toSorted((a, b) => a - b));  // [1, 9, 10, 100]
console.log(nums);                            // unchanged
```

`push`, `pop`, `shift`, `unshift` and `fill` have no copying twin, because spread covers them: `[...list, item]`, `list.slice(0, -1)`, `[item, ...list]`.

## When it goes wrong

| Symptom | Cause |
|---|---|
| Changing a copy changed the original | Spread and `Object.assign` are shallow |
| A `Date` became a string after copying | JSON round trip; use `structuredClone` |
| An array has `<n empty items>` | Assignment past the end created holes |
| `sort` put 100 before 9 | Default sort compares as strings |
| The original array changed after sorting | `sort` mutates; use `toSorted` |
| A key called `toString` broke a lookup | A plain object inherits from `Object.prototype` - use a `Map` |
| A React or Vue list did not re-render | The array was mutated, so its reference never changed |
| `obj.count` was falsy at zero | A truthiness test where `in` or `??` was meant |

## A check you can run

Take the worked example, add `orders[0].customer = ''CHANGED''` at the very end, and print `ranked`. Nothing moves, because `ranked` holds strings that were copied out.

Now add `updated[0].customer = ''CHANGED''` instead, and print `orders[0]`. It changed, because `updated[0]` and `orders[0]` are the same object - deliberately, as the console log says. Being able to predict which of those two lines affects the original, before running it, is what this lesson is for.
',
   'Arrays and objects are both held by reference. That one fact explains the first genuinely confusing bug most people write.', 7, 1407,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
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
  ('e0000001-0000-4000-8000-000000000034',
   'The Array Methods You Will Actually Use',
   'markdown',
   '# The Array Methods You Will Actually Use

There are about forty methods on `Array.prototype`. You need eight of them most days, and knowing which eight - and which two are traps - is worth more than memorising the rest.

## The eight

```javascript
const orders = [
  { id: 1, total: 1999, status: ''paid'' },
  { id: 2, total: 450, status: ''pending'' },
  { id: 3, total: 1299, status: ''paid'' },
];

orders.map((o) => o.total);                 // transform: same length out
orders.filter((o) => o.status === ''paid'');  // select: same or fewer
orders.find((o) => o.id === 2);             // the first match, or undefined
orders.findIndex((o) => o.id === 2);        // its index, or -1
orders.some((o) => o.total > 1500);         // true if any match
orders.every((o) => o.total > 100);         // true if all match
orders.reduce((sum, o) => sum + o.total, 0); // fold to one value
orders.flatMap((o) => [o.id, o.total]);     // map, then flatten one level
```

Each one says what it is for in its name, and that is the real argument for using them over a `for` loop. `filter` tells a reader "this narrows the list" before they read the callback. A `for` loop with an `if` and a `push` tells them nothing until they have read all five lines.

Two details about `find` and `findIndex` that matter: `find` returns `undefined` when nothing matches, which is indistinguishable from finding a stored `undefined`; and `findIndex` returns `-1`, which is truthy, so `if (findIndex(...))` is a bug - compare to `-1` explicitly or use `includes`.

## reduce deserves its reputation, but not always

`reduce` is the one that folds a list into a single value. It is also the one most often used where something clearer exists.

```javascript
const totals = [1999, 450, 1299];

// Good use: there is no more specific method for a sum.
const sum = totals.reduce((a, b) => a + b, 0);          // 3748

// Good use: building an index, where the accumulator is the point.
const byId = orders.reduce((acc, o) => {
  acc[o.id] = o;
  return acc;
}, {});

// Bad use: this is filter, written less clearly.
const paid = orders.reduce((acc, o) => {
  if (o.status === ''paid'') acc.push(o);
  return acc;
}, []);

// Worse use: quadratic, because spread copies the whole accumulator
// on every single element. Fine for ten rows, ruinous for ten thousand.
const slow = orders.reduce((acc, o) => ({ ...acc, [o.id]: o }), {});
```

The last one is worth dwelling on. Spreading the accumulator inside `reduce` turns an O(n) loop into O(n squared), because each iteration copies everything accumulated so far. It appears constantly in code that is trying to be functional, and it is the single most common accidental performance bug in modern JavaScript.

**Always pass the initial value.** Without it, `reduce` uses the first element as the seed, which means an empty array throws `TypeError: Reduce of empty array with no initial value`, and the callback receives an element rather than an accumulator on the first call.

```javascript
[].reduce((a, b) => a + b);        // TypeError
[].reduce((a, b) => a + b, 0);     // 0
```

## Mutating versus not

Nine methods change the array in place. Knowing them by sight prevents a whole category of bug, particularly in frameworks that detect change by comparing references.

| Mutates | Copies instead |
|---|---|
| `sort` | `toSorted` |
| `reverse` | `toReversed` |
| `splice` | `toSpliced` or `slice` |
| `push`, `pop`, `shift`, `unshift` | spread: `[...list, x]`, `list.slice(0, -1)` |
| `fill`, `copyWithin` | `Array.from({ length }, fn)` |
| `list[i] = v` | `list.with(i, v)` |

```javascript
const nums = [10, 9, 100, 1];

// The default comparator converts to strings. Always pass one for numbers.
console.log([...nums].sort());                  // [1, 10, 100, 9]
console.log(nums.toSorted((a, b) => a - b));    // [1, 9, 10, 100]
console.log(nums);                              // [10, 9, 100, 1] - intact

// sort is stable, so a second sort preserves the first order within ties.
const rows = [
  { name: ''b'', group: 2 }, { name: ''a'', group: 1 },
  { name: ''c'', group: 1 }, { name: ''d'', group: 2 },
];
const sorted = rows
  .toSorted((x, y) => x.name.localeCompare(y.name))
  .toSorted((x, y) => x.group - y.group);
console.log(sorted.map((r) => r.name).join(''''));   // ''acbd''
```

Stability is guaranteed by the specification, so sorting by secondary key first and primary key second is a legitimate technique rather than a happy accident.

## Chaining costs a pass each

```javascript
const result = orders
  .filter((o) => o.status === ''paid'')
  .map((o) => o.total)
  .reduce((a, b) => a + b, 0);
```

That reads beautifully and walks the list three times, allocating two intermediate arrays. For three rows this is irrelevant. For a hundred thousand rows inside a render loop it is not.

The honest rule: **write the chain first**. It is clearer, and clarity is worth more than speed in almost every line of code you will write. Collapse it only when a measurement tells you this chain is the problem:

```javascript
// One pass, no intermediates - but say why, or the next reader will
// helpfully turn it back into a chain.
let total = 0;
for (const o of orders) {
  if (o.status === ''paid'') total += o.total;
}
```

A `for...of` loop is the right shape for this. It reads almost as well, it can `break`, and it works with `await` inside - none of which `forEach` can do.

## forEach is almost never the right choice

```javascript
// forEach ignores the return value, cannot break, and cannot await.
orders.forEach(async (o) => { await save(o); });   // fires all at once,
                                                   // returns before any finish

// for...of awaits properly, one at a time.
for (const o of orders) { await save(o); }

// And when they should run together, be explicit about it.
await Promise.all(orders.map((o) => save(o)));
```

The `forEach` with `async` inside is a genuine bug that looks correct: the function returns immediately, the promises are unhandled, and errors vanish. If you want sequential, use `for...of`. If you want concurrent, use `Promise.all` and say so.

## A worked example

```javascript
// A sales report, built the readable way, with each step named.
const sales = [
  { region: ''north'', rep: ''aisha'',  amount: 1999, quarter: 1 },
  { region: ''north'', rep: ''noshad'', amount: 2450, quarter: 1 },
  { region: ''south'', rep: ''sam'',    amount: 1299, quarter: 1 },
  { region: ''north'', rep: ''aisha'',  amount: 3100, quarter: 2 },
  { region: ''south'', rep: ''sam'',    amount: 890,  quarter: 2 },
  { region: ''south'', rep: ''leah'',   amount: 2200, quarter: 2 },
];

// 1. Totals per region, in one pass. The accumulator is mutated, which
//    is safe because it was created here and never escapes.
const byRegion = sales.reduce((acc, s) => {
  acc[s.region] = (acc[s.region] ?? 0) + s.amount;
  return acc;
}, {});
console.log(byRegion);              // { north: 7549, south: 4389 }

// 2. The same thing, now that Object.groupBy exists.
const grouped = Object.groupBy(sales, (s) => s.region);
const totals = Object.entries(grouped).map(([region, rows]) => ({
  region,
  total: rows.reduce((a, s) => a + s.amount, 0),
  reps: [...new Set(rows.map((s) => s.rep))].toSorted(),
}));
console.log(totals);
// [ { region: ''north'', total: 7549, reps: [''aisha'', ''noshad''] },
//   { region: ''south'', total: 4389, reps: [''leah'', ''sam''] } ]

// 3. Questions that are not sums.
console.log(sales.some((s) => s.amount > 3000));        // true
console.log(sales.every((s) => s.amount > 500));        // false
console.log(sales.find((s) => s.rep === ''leah'').amount); // 2200
console.log(sales.filter((s) => s.quarter === 2).length); // 3

// 4. Flatten one level, which is what flatMap is for.
const tags = [
  { id: 1, tags: [''php'', ''sql''] },
  { id: 2, tags: [''js''] },
  { id: 3, tags: [] },
];
console.log(tags.flatMap((t) => t.tags));       // [''php'', ''sql'', ''js'']

// 5. flatMap also filters: return [] to drop, [x] to keep, [a, b] to
//    expand. One pass where filter-then-map would take two.
const parsed = [''1'', ''x'', ''3''].flatMap((s) => {
  const n = Number(s);
  return Number.isNaN(n) ? [] : [n];
});
console.log(parsed);                             // [1, 3]

// 6. Ranking, without disturbing the source.
const ranked = totals
  .toSorted((a, b) => b.total - a.total)
  .map((row, i) => ({ rank: i + 1, ...row }));
console.log(ranked[0]);     // { rank: 1, region: ''north'', total: 7549, ... }
console.log(totals[0].region);   // ''north'' - totals never moved
```

Step five is the technique worth stealing. `flatMap` returning an empty array is a filter and a map at once, and it handles the common "parse, and drop what will not parse" case without two traversals or a `null` to check for afterwards.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Reduce of empty array with no initial value` | No seed passed to `reduce` |
| Sorting put 100 before 9 | Default comparator converts to strings |
| The source array changed after sorting | `sort` mutates; use `toSorted` |
| A loop with `await` finished instantly | `forEach` with an async callback |
| Grouping ten thousand rows took seconds | Spreading the accumulator inside `reduce` |
| `if (list.findIndex(...))` matched the wrong thing | `-1` is truthy; compare explicitly |
| `find` returned `undefined` for a row that exists | The predicate is wrong, or the row holds `undefined` |
| A framework did not re-render after `push` | The array reference did not change |

## A check you can run

Take the slow reduce and measure it, rather than believing the paragraph above:

```javascript
const rows = Array.from({ length: 20000 }, (_, i) => ({ id: i, v: i }));

console.time(''mutating'');
rows.reduce((acc, r) => { acc[r.id] = r; return acc; }, {});
console.timeEnd(''mutating'');

console.time(''spreading'');
rows.reduce((acc, r) => ({ ...acc, [r.id]: r }), {});
console.timeEnd(''spreading'');
```

On a typical laptop the first finishes in single-digit milliseconds and the second takes seconds. Same output, same number of lines, one of them quadratic. Run it once and you will recognise the shape of it forever.
',
   'Nine methods replace almost every loop you would write. The win is not fewer characters - it is that the method name says what the loop is for before you read the body.', 8, 1645,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000035',
   'Destructuring and Spread',
   'markdown',
   '# Destructuring and Spread

Destructuring pulls values out of a structure by writing the shape of it. Spread puts them back. Both are syntax rather than functions, which is why they work in places a function could not - parameter lists, imports, assignments.

## Destructuring, in every position it works

```javascript
const user = { id: 7, name: ''Aisha'', address: { city: ''Leeds'', post: ''LS1'' } };

const { name } = user;                       // ''Aisha''
const { name: fullName } = user;             // rename
const { nickname = ''none'' } = user;          // default for undefined only
const { address: { city } } = user;          // nested
const { id, ...rest } = user;                // rest: everything else

const [first, second] = [10, 20, 30];        // by position
const [, , third] = [10, 20, 30];            // skip with a hole
const [head, ...tail] = [10, 20, 30];        // rest, in an array
const [a = 1, b = 2] = [undefined];          // a is 1, b is 2
```

The default applies only when the value is `undefined`. A stored `null` passes straight through, which is usually right and occasionally surprising:

```javascript
const { timeout = 30 } = { timeout: null };
console.log(timeout);        // null, not 30
```

If you want `null` to fall back too, destructure and then use `??`, or do not store `null` for "not set" in the first place.

## Where it earns its keep: function parameters

```javascript
// Without: four arguments whose order nobody remembers.
function connectOld(host, port, timeout, retries) {}
connectOld(''db.local'', 3306, 30, 3);

// With: named at the call site, defaulted at the definition, and
// reorderable without breaking anything.
function connect({ host, port = 3306, timeout = 30, retries = 3 } = {}) {
  return host + '':'' + port + '' (timeout '' + timeout + '', retries '' + retries + '')'';
}

console.log(connect({ host: ''db.local'' }));
// ''db.local:3306 (timeout 30, retries 3)''
console.log(connect({ host: ''db.local'', retries: 0 }));
// ''db.local:3306 (timeout 30, retries 0)''
```

## The `= {}` on a destructured parameter

That trailing `= {}` is not decoration. Without it, calling the function with no arguments throws.

```javascript
function bad({ a }) { return a; }
function good({ a } = {}) { return a; }

// bad();          // TypeError: Cannot destructure property ''a'' of
                   // ''undefined'' as it is undefined.
console.log(good());    // undefined - no throw
```

The reason is mechanical: destructuring reads properties off the value, and `undefined` has no properties. The `= {}` supplies something to read from. Any function whose options object is optional needs it, and forgetting it is the single most common destructuring bug.

## Spread is shallow. Every time.

```javascript
const defaults = { retries: 3, headers: { accept: ''json'' } };
const config = { ...defaults, retries: 5 };

config.headers.accept = ''text'';
console.log(defaults.headers.accept);        // ''text'' - shared object
```

The top level was copied. `headers` was not - the new object holds the same reference. This is the same shallowness as everywhere else in the language, and the fixes are the same: `structuredClone`, or spread each level you care about.

```javascript
const safe = { ...defaults, headers: { ...defaults.headers } };
```

Order matters, and later wins:

```javascript
const defaults = { retries: 3, headers: { accept: ''json'' } };

console.log({ ...defaults, retries: 5 });    // retries 5
console.log({ retries: 5, ...defaults });    // retries 3 - defaults won
```

Put the spread first when you are overriding, last when you are supplying a floor. Getting this backwards produces a settings object that ignores what the caller asked for, and it is silent.

One more edge: spread copies **own enumerable** properties, and it reads getters rather than copying them.

```javascript
const source = {
  first: ''Aisha'',
  get greeting() { return ''Hello '' + this.first; },
};
const copy = { ...source };

source.first = ''Noshad'';
copy.first = ''Sam'';

console.log(source.greeting);    // ''Hello Noshad'' - still a getter
console.log(copy.greeting);      // ''Hello Aisha''  - a string, fixed at copy time
console.log(typeof Object.getOwnPropertyDescriptor(copy, ''greeting'').get);
// ''undefined'' - there is no getter left to call
```

The getter became a plain string at the moment of spreading. If you need the behaviour rather than the value, use `Object.create` with `Object.getOwnPropertyDescriptors`.

## Spread in arrays and calls

```javascript
const a = [1, 2];
const b = [3, 4];

console.log([...a, ...b]);           // [1, 2, 3, 4] - concat, readably
console.log([0, ...a, 99]);          // [0, 1, 2, 99] - insert anywhere
console.log(Math.max(...a, ...b));   // 4 - apply, without apply

// It works on anything iterable, which is more than arrays.
console.log([...''hello'']);                      // [''h'',''e'',''l'',''l'',''o'']
console.log([...new Set([1, 1, 2])]);           // [1, 2]
console.log([...new Map([[''a'', 1]])]);          // [[''a'', 1]]
console.log(Object.fromEntries([[''a'', 1]]));    // { a: 1 }
```

`[...new Set(list)]` is the idiomatic deduplicate, and it preserves insertion order. Note the asymmetry: object spread works on any object, array spread needs an *iterable*, so `[...{ a: 1 }]` throws.

Spreading into a call has a limit worth knowing: argument lists are capped at somewhere around 65,000 to 125,000 entries depending on the engine. `Math.max(...hugeArray)` throws `RangeError: Maximum call stack size exceeded` on a long enough array. Use `reduce` for those.

## A worked example

```javascript
// A settings resolver and a small immutable update helper - the two
// jobs destructuring and spread actually get used for.
const DEFAULTS = {
  host: ''localhost'',
  port: 3306,
  pool: { min: 1, max: 10 },
  retries: 3,
  tags: [],
};

function resolveConfig({ pool, tags, ...flat } = {}) {
  return {
    ...DEFAULTS,
    ...flat,                              // top-level overrides
    pool: { ...DEFAULTS.pool, ...pool },  // merged one level deeper
    tags: [...DEFAULTS.tags, ...(tags ?? [])],
  };
}

const config = resolveConfig({ host: ''db.local'', pool: { max: 50 }, tags: [''live''] });
console.log(config);
// { host: ''db.local'', port: 3306, pool: { min: 1, max: 50 },
//   retries: 3, tags: [''live''] }

// DEFAULTS is untouched, which is the whole point of the explicit
// per-level spread.
console.log(DEFAULTS.pool);        // { min: 1, max: 10 }
console.log(DEFAULTS.tags);        // []

// Immutable update of one row in a list, by id.
const update = (rows, id, changes) =>
  rows.map((row) => (row.id === id ? { ...row, ...changes } : row));

const rows = [
  { id: 1, name: ''first'', done: false },
  { id: 2, name: ''second'', done: false },
];
const next = update(rows, 2, { done: true });

console.log(rows[1].done);          // false - original intact
console.log(next[1].done);          // true
console.log(next[0] === rows[0]);   // true - unchanged rows are shared

// Swapping, which needs no temporary variable.
let x = 1, y = 2;
[x, y] = [y, x];
console.log(x, y);                  // 2 1

// Destructuring in a loop header, which is where you will use it most.
const entries = Object.entries({ a: 1, b: 2 });
for (const [key, value] of entries) {
  console.log(key + ''='' + value);   // ''a=1'' then ''b=2''
}

// And a rest parameter, which is a real array - unlike arguments.
const tally = (label, ...amounts) => label + '': '' + amounts.reduce((p, q) => p + q, 0);
console.log(tally(''total'', 1, 2, 3));   // ''total: 6''
```

`resolveConfig` is worth reading twice. The parameter list pulls `pool` and `tags` out by name precisely because they need deeper handling, and `...flat` collects everything that can be merged at the top level. The shape of the merge is visible in the shape of the parameter.

## Where destructuring reads badly

It is syntax, so it can be nested arbitrarily, and arbitrarily nested is unreadable:

```javascript
const response = { data: { items: [{ meta: { tags: [''php''] } }] } };

// Technically valid. Do not write this.
const { data: { items: [{ meta: { tags: [tagA = ''none''] = [] } = {} } = {}] = [] } = {} } = response;

// Two readable lines instead.
const firstItem = response.data?.items?.[0];
const tagB = firstItem?.meta?.tags?.[0] ?? ''none'';

console.log(tagA, tagB);    // ''php'' ''php'' - same answer, one of them legible
```

The rule of thumb: one level of nesting is clear, two is borderline, three means use optional chaining instead. Destructuring is for naming things you are about to use, not for navigating.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Cannot destructure property of undefined` | Missing `= {}` on an optional options parameter |
| A default did not apply | The value was `null`, not `undefined` |
| A caller''s override was ignored | The spread came after the override |
| Changing a copy changed the original | Spread is shallow; copy each nested level |
| A getter stopped updating after copying | Spread reads getters into plain values |
| `[...obj]` threw `is not iterable` | Array spread needs an iterable; use `Object.entries` |
| `RangeError` from `fn(...list)` | Too many arguments; use `reduce` or chunk it |
| A renamed variable is `undefined` | `{ a: b }` renames; `{ a, b }` takes two properties |

## A check you can run

Take `resolveConfig` and delete the `pool:` line from the returned object, leaving only the two spreads. Then call it with `{ pool: { max: 50 } }` and print the result.

`pool` becomes `{ max: 50 }` - `min` has vanished, because the top-level spread replaced the whole nested object rather than merging into it. That one deleted line is the difference between a shallow copy and a correct one, and seeing it fail is more memorable than reading that it would.
',
   'Two pieces of syntax that show up in nearly every modern JavaScript file. Both are about moving values in and out of shapes without a pile of temporary variables.', 8, 1585,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000036',
   'Classes and Prototypes',
   'markdown',
   '# Classes and Prototypes

A JavaScript class is syntax over the prototype system, not a different system. Knowing what it compiles to explains every behaviour that otherwise looks arbitrary - why methods are shared, why `this` is lost, and why `instanceof` sometimes lies.

## The prototype chain, first

Every object has a hidden link to another object, its prototype. When you read a property that the object does not have, the engine follows that link, and keeps following until it finds the property or runs out of chain.

```javascript
const animal = {
  describe() { return this.name + '' the '' + this.kind; },
};

const dog = Object.create(animal);
dog.name = ''Rex'';
dog.kind = ''dog'';

console.log(dog.describe());                    // ''Rex the dog''
console.log(Object.hasOwn(dog, ''describe''));    // false - it is inherited
console.log(Object.getPrototypeOf(dog) === animal);   // true
```

`describe` lives once, on `animal`. A thousand dogs share that one function rather than each carrying a copy, and `this` inside it is whatever was to the left of the dot at the call site - so the shared function still reads the right name.

That is the entire mechanism. A class is a convenient way to build it.

## What a class actually creates

```javascript
class Animal {
  constructor(name, kind) {
    this.name = name;
    this.kind = kind;
  }
  describe() { return this.name + '' the '' + this.kind; }
}

const rex = new Animal(''Rex'', ''dog'');

console.log(Object.hasOwn(rex, ''name''));             // true  - own data
console.log(Object.hasOwn(rex, ''describe''));         // false - on prototype
console.log(Object.getPrototypeOf(rex) === Animal.prototype);   // true
console.log(typeof Animal);                          // ''function''
```

A class is a function. Its methods go on `Function.prototype`''s `prototype` object, shared by every instance. Data set in the constructor is per-instance. That split is the useful part: behaviour shared, state not.

Two differences from the old `function Animal() {}` style are worth knowing because they catch people out. Class bodies are always in strict mode, and a class binding is in the temporal dead zone - you cannot use it above its declaration, unlike a function.

## Fields versus methods

```javascript
class Button {
  // A field: assigned per instance, in declaration order, before the
  // constructor body runs.
  clicks = 0;

  // A method: one function, on the prototype, shared.
  increment() { this.clicks++; }

  // A field holding an arrow: a NEW function per instance, with this
  // bound by lexical scope rather than by the call site.
  handleClick = () => { this.clicks++; };
}

const b = new Button();
const loose = b.increment;
const bound = b.handleClick;

// loose();          // TypeError - this is undefined
bound();             // fine - the arrow closed over this
console.log(b.clicks);                              // 1
console.log(Object.hasOwn(b, ''handleClick''));       // true  - per instance
console.log(Object.hasOwn(b, ''increment''));         // false - prototype
```

The arrow field is the standard fix for passing a method as a callback. It costs one function object per instance, which is nothing for a handful of components and real for a hundred thousand records. For the hundred thousand, use a prototype method and bind at the call site: `onClick={() => item.increment()}`.

## #private is real

```javascript
class Account {
  #balancePence = 0;                 // genuinely inaccessible outside
  static #count = 0;                 // statics can be private too

  constructor(openingPence = 0) {
    this.#balancePence = openingPence;
    Account.#count++;
  }

  deposit(pence) {
    if (!Number.isInteger(pence) || pence <= 0) {
      throw new RangeError(''deposit must be a positive whole number of pence'');
    }
    this.#balancePence += pence;
    return this;
  }

  get balance() { return (this.#balancePence / 100).toFixed(2); }
  static get count() { return Account.#count; }

  // The only way to ask from outside whether something is an Account
  // with real private state - a brand check.
  static isAccount(value) { return #balancePence in value; }
}

const acc = new Account(1000);
acc.deposit(500);
console.log(acc.balance);                  // ''15.00''
console.log(Account.count);                // 1
console.log(Object.keys(acc));             // [] - nothing is enumerable
console.log(JSON.stringify(acc));          // ''{}'' - private fields do not serialise
console.log(Account.isAccount(acc));       // true
console.log(Account.isAccount({}));        // false
```

`#` privacy is enforced by the language, not by convention. Reading `acc.#balancePence` from outside is a *syntax* error, not a runtime one - the code will not even parse. That is stronger than the old underscore prefix, and stronger than a closure in one respect: it survives subclassing.

The trade is that private fields do not serialise. A class with `#` state needs an explicit `toJSON` if it is going over the wire.

## Inheritance, and super

```javascript
class Animal {
  constructor(name) { this.name = name; }
  speak() { return this.name + '' makes a noise''; }
  get kind() { return ''animal''; }
}

class Dog extends Animal {
  constructor(name, breed) {
    super(name);              // MUST come before any use of this
    this.breed = breed;
  }
  speak() { return super.speak() + '', specifically a bark''; }
  get kind() { return ''dog''; }
}

const rex = new Dog(''Rex'', ''collie'');
console.log(rex.speak());          // ''Rex makes a noise, specifically a bark''
console.log(rex.kind);             // ''dog''
console.log(rex instanceof Dog);   // true
console.log(rex instanceof Animal); // true
```

`super(...)` must be called before `this` is touched in a derived constructor, because `this` does not exist until the base constructor has created it. The error for getting this wrong - `Must call super constructor ... before accessing ''this''` - is one of the clearer messages in the language.

`instanceof` walks the prototype chain, which means it answers "is `Dog.prototype` anywhere in this object''s chain". That is why it returns false across realms: an array from an iframe is not `instanceof Array` in the parent, because there are two `Array` functions. For cross-realm checks use `Array.isArray` or `Object.prototype.toString.call(value)`.

## A worked example

```javascript
// A small domain model: shared behaviour on the prototype, state
// private, and a static factory that validates before constructing.
class Money {
  #pence;

  constructor(pence) {
    if (!Number.isInteger(pence)) throw new TypeError(''pence must be an integer'');
    this.#pence = pence;
  }

  static fromPounds(pounds) { return new Money(Math.round(pounds * 100)); }

  plus(other) { return new Money(this.#pence + other.#pence); }
  times(n) { return new Money(Math.round(this.#pence * n)); }

  get pence() { return this.#pence; }
  toString() { return ''GBP '' + (this.#pence / 100).toFixed(2); }
  toJSON() { return { pence: this.#pence }; }

  // Called by + and by template literals; returning the number for
  // ''number'' hints and the label otherwise.
  [Symbol.toPrimitive](hint) {
    return hint === ''number'' ? this.#pence : this.toString();
  }
}

const price = Money.fromPounds(19.99);
const vat = price.times(0.2);
const total = price.plus(vat);

console.log(String(total));              // ''GBP 23.99''
console.log(Number(total));              // 2399
console.log(JSON.stringify({ total }));  // ''{"total":{"pence":2399}}''

// plus() reaches into other.#pence - private is per CLASS, not per
// instance, so a Money can read another Money''s private field.
console.log(total.pence);                // 2399

// Inheritance that adds rather than overrides.
class TaxedMoney extends Money {
  #rate;
  constructor(pence, rate) {
    super(pence);
    this.#rate = rate;
  }
  get withTax() { return this.times(1 + this.#rate); }
  toString() { return super.toString() + '' (+'' + this.#rate * 100 + ''%)''; }
}

const net = new TaxedMoney(1999, 0.2);
console.log(String(net));                // ''GBP 19.99 (+20%)''
console.log(String(net.withTax));        // ''GBP 23.99''
console.log(net instanceof Money);       // true

// times() returned a Money, not a TaxedMoney, because it says
// `new Money(...)` explicitly. That is usually what you want; the
// alternative is new this.constructor(...), which is cleverer and
// surprises anyone who subclasses.
console.log(net.withTax instanceof TaxedMoney);   // false
```

The last comment is a real design decision rather than a footnote. A method that constructs `new this.constructor(...)` propagates the subclass, which sounds helpful until a subclass has a different constructor signature and the call throws.

## When not to use a class

Most of the time. A class is the right shape when you have **state plus behaviour that travels together**, and several instances of it. For everything else there is a simpler answer:

- One of something with no state - export plain functions from a module.
- Data with no behaviour - a plain object, or a `Map`.
- Behaviour with no state - a function, possibly curried.
- Private state, one instance - a closure, as in the emitter from the scope lesson.

A codebase full of classes with one method and no state has reinvented functions, with more ceremony.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Cannot read properties of undefined` in a method | Passed as a value; the dot was lost |
| `Must call super constructor before accessing this` | `this` used before `super()` |
| `JSON.stringify` produced `{}` | All state is in `#private` fields; add `toJSON` |
| `instanceof` is false for an obviously correct object | Two realms; use `Array.isArray` or a brand check |
| Memory grows with many instances | Arrow fields create one function per instance |
| A method is missing from `Object.keys` | Prototype methods are not own properties |
| `class X` used before its line throws | Class declarations are in the temporal dead zone |
| Subclass state is `undefined` in a base method | The base constructor ran before the subclass field was assigned |

## A check you can run

That last row is the subtle one, and it is worth seeing:

```javascript
class Base {
  constructor() { console.log(''base sees:'', this.label); }
}
class Derived extends Base {
  label = ''derived'';
  constructor() { super(); console.log(''derived sees:'', this.label); }
}
new Derived();
// base sees: undefined
// derived sees: derived
```

Field initialisers run *after* `super()` returns. Any base-class constructor that calls an overridable method will see the subclass''s fields unassigned. The fix is to do nothing in a constructor that a subclass might need to influence - initialise in a method the subclass calls when it is ready.
',
   'class is syntax over the prototype system that was already there. Knowing what it compiles to explains every behaviour that looks odd from the outside.', 8, 1590,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
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
  ('e0000001-0000-4000-8000-000000000037',
   'Closures',
   'markdown',
   '# Closures

A closure is a function together with the variables it was written next to. That is the whole definition, and it is less exotic than it sounds - every function in JavaScript is one. What is worth learning is exactly *what* is kept, for how long, and what that buys you.

## What is actually kept

A closure does not copy values. It keeps the *binding* alive - the variable itself, not a snapshot of what was in it.

```javascript
function counter() {
  let count = 0;                 // one binding, per call to counter()
  return {
    increment() { return ++count; },
    current() { return count; },
  };
}

const a = counter();
const b = counter();

console.log(a.increment());      // 1
console.log(a.increment());      // 2
console.log(b.increment());      // 1 - b has its own count
console.log(a.current());        // 2
```

`count` is gone from the stack the moment `counter()` returns, yet `increment` still reads and writes it. The engine noticed that the returned functions refer to `count` and kept the scope alive on the heap for as long as they are reachable.

Two calls to `counter()` make two independent `count` bindings. That is why closures give you instances without classes.

The "binding not snapshot" part is what makes the loop bug possible:

```javascript
const withVar = [];
for (var i = 0; i < 3; i++) withVar.push(() => i);
console.log(withVar.map((f) => f()));   // [3, 3, 3] - one shared binding

const withLet = [];
for (let j = 0; j < 3; j++) withLet.push(() => j);
console.log(withLet.map((f) => f()));   // [0, 1, 2] - a new binding per pass
```

Three closures, one `var` binding, which by the end holds 3. The `let` version is specified to create a fresh binding each iteration, so each closure keeps a different one.

## Privacy that the language enforces

Before `#private` fields, a closure was the only real privacy in JavaScript, and it is still the simplest.

```javascript
function createAccount(openingPence = 0) {
  let balance = openingPence;                  // unreachable from outside
  const history = [];

  return {
    deposit(pence) {
      if (!Number.isInteger(pence) || pence <= 0) throw new RangeError(''bad amount'');
      balance += pence;
      history.push({ kind: ''deposit'', pence });
      return balance;
    },
    get balance() { return balance; },
    get history() { return [...history]; },    // a copy, so callers cannot push
  };
}

const acc = createAccount(1000);
acc.deposit(500);
console.log(acc.balance);           // 1500
console.log(Object.keys(acc));      // [''deposit'', ''balance'', ''history'']
                                    // - and no ''balance'' VARIABLE among them
console.log(acc.history.length);    // 1
acc.history.push({ fake: true });   // pushes into the copy
console.log(acc.history.length);    // 1 - the real one is untouched
```

There is no way to reach `balance` from outside. Not by key, not by `Object.getOwnPropertyNames`, not by a debugger expression in the enclosing scope. The only access is through the functions that were written next to it.

Note the `get history()` returning a copy. Returning the array itself would hand out a reference to private state, which is the commonest hole in an otherwise correct encapsulation.

## The patterns worth recognising

**Partial application** - fix some arguments now, supply the rest later.

```javascript
const multiplyBy = (factor) => (n) => n * factor;
const double = multiplyBy(2);
const triple = multiplyBy(3);
console.log([1, 2, 3].map(double));   // [2, 4, 6]
console.log(triple(5));               // 15
```

**Memoisation** - a cache that lives with the function.

```javascript
function memoise(fn) {
  const cache = new Map();
  return (...args) => {
    const key = JSON.stringify(args);
    if (!cache.has(key)) cache.set(key, fn(...args));
    return cache.get(key);
  };
}

let calls = 0;
const slowSquare = (n) => { calls++; return n * n; };
const fast = memoise(slowSquare);

console.log(fast(9), fast(9), fast(9));   // 81 81 81
console.log(calls);                        // 1
```

**Once** - a guard that cannot be bypassed.

```javascript
function once(fn) {
  let done = false;
  let result;
  return (...args) => {
    if (!done) { done = true; result = fn(...args); }
    return result;
  };
}

const init = once(() => { console.log(''initialising''); return 42; });
console.log(init(), init(), init());
// ''initialising'' printed once, then: 42 42 42
```

**Module-level state** - the quiet, everyday one. Every `const` at the top of a module that a function below refers to is a closure, and that is how configuration, caches and connection pools are shared.

## Memory

Closures keep their scope alive. That is the feature, and it is also the leak.

```javascript
function leaky() {
  const huge = new Array(1e6).fill(''data'');   // about 8MB
  // This closure refers only to a number - but in most engines the
  // whole scope is kept, so `huge` cannot be collected either.
  return () => huge.length;
}

function tidy() {
  const huge = new Array(1e6).fill(''data'');
  const size = huge.length;                   // take what you need
  return () => size;                          // huge is now collectable
}
```

Engines have got better at this - V8 does analyse which variables a closure actually uses - but the analysis is per scope, not per variable, in enough cases that the habit is worth keeping: **extract the value you need rather than closing over the structure it came from.**

The other leak is the handler nobody removed:

```javascript
function attach(element, rows) {
  const handler = () => console.log(rows.length);
  element.addEventListener(''click'', handler);
  // Without this, `rows` stays alive for as long as the element does,
  // and the element stays alive for as long as the listener does.
  return () => element.removeEventListener(''click'', handler);
}
```

Returning the unsubscribe function from wherever you subscribe is the single habit that prevents most listener leaks. It also makes the lifetime visible in the calling code, which is where it belongs.

## A worked example

```javascript
// A rate limiter: state that must be private, per instance, and must
// survive between calls. Closures are the natural shape for all three.
function rateLimiter({ max = 3, windowMs = 1000 } = {}) {
  const hits = new Map();             // key -> array of timestamps

  return function allow(key, now = Date.now()) {
    const recent = (hits.get(key) ?? []).filter((t) => now - t < windowMs);
    if (recent.length >= max) {
      hits.set(key, recent);
      return { ok: false, retryInMs: windowMs - (now - recent[0]) };
    }
    recent.push(now);
    hits.set(key, recent);
    return { ok: true, remaining: max - recent.length };
  };
}

const allow = rateLimiter({ max: 3, windowMs: 1000 });
const start = 10000;

console.log(allow(''aisha'', start));          // { ok: true, remaining: 2 }
console.log(allow(''aisha'', start + 100));    // { ok: true, remaining: 1 }
console.log(allow(''aisha'', start + 200));    // { ok: true, remaining: 0 }
console.log(allow(''aisha'', start + 300));    // { ok: false, retryInMs: 700 }

// A different key has its own budget.
console.log(allow(''noshad'', start + 300));   // { ok: true, remaining: 2 }

// And once the window has passed, the first caller is allowed again.
console.log(allow(''aisha'', start + 1100));   // { ok: true, remaining: 1 }
// remaining is 1, not 2: the hit at start + 200 is still inside the
// window at start + 1100, so only two of the three slots are free.

// A second limiter is genuinely independent - its own hits Map.
const other = rateLimiter({ max: 1, windowMs: 1000 });
console.log(other(''aisha'', start));          // { ok: true, remaining: 0 }
console.log(other(''aisha'', start + 1));      // { ok: false, retryInMs: 999 }
console.log(allow(''noshad'', start + 400));   // { ok: true, remaining: 1 }
```

`hits` is created once per limiter and reached by every call to `allow`. Nothing outside can inspect it, corrupt it, or share it between limiters by accident. Passing `now` as a parameter rather than calling `Date.now()` inside is a small discipline that makes the whole thing testable without faking the clock - which is why the example above can assert exact numbers.

## Every function is a closure

```javascript
const greeting = ''Hello'';
function greet(name) { return greeting + '' '' + name; }
```

`greet` closes over `greeting`. Nobody calls that a closure in conversation, but it is the same mechanism - which is the point. There is no separate closure feature to learn. There is lexical scope, and the fact that a function outliving its scope keeps that scope alive.

## When it goes wrong

| Symptom | Cause |
|---|---|
| Every callback in a loop sees the last value | `var` in the loop header; use `let` |
| Two instances share state | The state was created outside the factory |
| Memory grows and never falls | A closure keeps a large structure alive |
| Removing a listener does nothing | `removeEventListener` was given a different function object |
| A memoised function never hits its cache | The key is built from an object with unstable key order |
| A cache grows without limit | No eviction; use a bounded `Map` or `WeakMap` |
| Private state leaked | A getter returned the array or object itself, not a copy |
| A value is stale | The closure captured a snapshot where a getter was wanted |

## A check you can run

Open DevTools, go to the Memory panel, and take a heap snapshot. Then run this in the console:

```javascript
globalThis.keep = [];
for (let i = 0; i < 100; i++) {
  const big = new Array(100000).fill(i);
  globalThis.keep.push(() => big.length);
}
```

Take a second snapshot and compare. The retained size has grown by tens of megabytes, held by one hundred closures that each need a single number. Now change `big.length` to a `const size = big.length` captured outside the arrow, re-run, and compare again. The difference is the lesson, and it is the kind of thing you only really believe once you have watched the number.
',
   'A closure is a function that remembers the scope it was created in, even after that scope has finished. It sounds academic and it is behind most of the patterns you will read.', 8, 1597,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000038',
   'Promises and async/await',
   'markdown',
   '# Promises and async/await

A promise is an object representing a value that is not here yet. `async` and `await` are syntax that makes code using promises read like code that does not. Underneath, it is all promises - which is why the failure modes are promise failure modes even in code that never says the word.

## The three states, and the one transition

A promise is **pending**, then either **fulfilled** with a value or **rejected** with a reason. The transition happens once and cannot be undone. A promise that has settled stays settled.

```javascript
const later = new Promise((resolve, reject) => {
  setTimeout(() => resolve(''done''), 10);
  setTimeout(() => resolve(''again''), 20);   // ignored - already settled
});

later.then((v) => console.log(v));          // ''done'', ten milliseconds later
```

You will rarely write `new Promise` - almost everything that is asynchronous already returns one. The two places it is still right are wrapping a callback API, and wrapping a timer:

```javascript
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
```

## async/await is promise syntax

```javascript
// These two are the same function.
async function loadA(id) {
  const res = await fetch(''/api/'' + id);
  const data = await res.json();
  return data.name;
}

function loadB(id) {
  return fetch(''/api/'' + id)
    .then((res) => res.json())
    .then((data) => data.name);
}
```

Three rules follow from that equivalence, and they explain most surprises:

**An async function always returns a promise.** Even if the body returns a plain value, even if it never awaits. `return 1` from an async function gives a promise that fulfils with 1.

```javascript
async function one() { return 1; }
console.log(one());                 // Promise { 1 }
console.log(await one());           // 1
```

**`await` on a non-promise still yields to the event loop.** `await 1` does not block, but it does defer the rest of the function to a microtask, which is why ordering can surprise you.

**A `throw` inside an async function becomes a rejection**, and `await` on a rejected promise re-throws. That is what makes `try/catch` work across asynchronous boundaries.

```javascript
async function risky() { throw new Error(''nope''); }

try {
  await risky();
} catch (error) {
  console.log(error.message);       // ''nope''
}
```

## await in a loop is usually a bug

```javascript
const ids = [1, 2, 3, 4, 5];
const fetchOne = async (id) => { await delay(100); return id * 10; };

// Sequential: 500ms. Each await waits for the previous one.
async function slow() {
  const out = [];
  for (const id of ids) out.push(await fetchOne(id));
  return out;
}

// Concurrent: about 100ms. Every request starts before any is awaited.
async function fast() {
  return Promise.all(ids.map((id) => fetchOne(id)));
}
```

The difference is where the work *starts*. In `slow`, `fetchOne(2)` is not called until `fetchOne(1)` has resolved. In `fast`, `.map` calls all five immediately and `Promise.all` waits for the array of promises that already exist.

Sequential is correct when each step needs the previous step''s result, or when you are deliberately rate-limiting. It is a bug when the calls are independent, and it is a bug that only shows up as "the page is slow".

## The four combinators

```javascript
const ok = (v, ms) => new Promise((r) => setTimeout(() => r(v), ms));
const bad = (e, ms) => new Promise((_, r) => setTimeout(() => r(new Error(e)), ms));

// all: every value, or the FIRST rejection. Fails fast.
await Promise.all([ok(''a'', 10), ok(''b'', 20)]);             // [''a'', ''b'']

// allSettled: never rejects. One entry per input, with status.
await Promise.allSettled([ok(''a'', 10), bad(''boom'', 20)]);
// [ { status: ''fulfilled'', value: ''a'' },
//   { status: ''rejected'', reason: Error: boom } ]

// race: the first to SETTLE, fulfilled or rejected.
await Promise.race([ok(''fast'', 10), bad(''slow'', 50)]);     // ''fast''

// any: the first to FULFIL; rejects only if all do, with AggregateError.
await Promise.any([bad(''first'', 10), ok(''second'', 50)]);   // ''second''
```

`Promise.all` rejecting on the first failure does **not** cancel the others. They keep running, and if a second one rejects after `all` has already rejected, that rejection is unhandled. This is why `allSettled` is the right default when you want a report rather than a transaction.

## The trap that catches everyone: a rejection with no handler

```javascript
// Fires and forgets - and swallows every error.
async function save() { throw new Error(''disk full''); }
save();                                 // UnhandledPromiseRejection

// Three correct endings for a promise you are not awaiting:
save().catch((error) => console.error(error));
void save().catch(report);
try { await save(); } catch (error) { report(error); }
```

In Node, an unhandled rejection terminates the process by default. In a browser it fires `window.onunhandledrejection` and otherwise does nothing visible. Either way, a promise nobody awaited and nobody caught is a silent failure, and it is the commonest way asynchronous bugs hide.

The `forEach` version is the same bug wearing a disguise:

```javascript
// Returns immediately, before anything has saved, errors lost.
items.forEach(async (item) => { await save(item); });

// Sequential, errors propagate:
for (const item of items) await save(item);

// Concurrent, errors propagate:
await Promise.all(items.map((item) => save(item)));
```

## A worked example

```javascript
const delay = (ms, value) => new Promise((r) => setTimeout(() => r(value), ms));

// A fetch-with-retry, with a timeout and a backoff - the four things
// every real network call needs, written once.
async function withTimeout(promise, ms) {
  // AbortSignal.timeout is the real answer for fetch; this is the
  // general shape for anything else.
  const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error(''timed out after '' + ms + ''ms'')), ms));
  return Promise.race([promise, timeout]);
}

async function retry(operation, { attempts = 3, baseMs = 50 } = {}) {
  let lastError;
  for (let attempt = 1; attempt <= attempts; attempt++) {
    try {
      return await operation(attempt);
    } catch (error) {
      lastError = error;
      if (attempt === attempts) break;
      // Exponential backoff: 50ms, 100ms, 200ms...
      await delay(baseMs * 2 ** (attempt - 1));
    }
  }
  throw lastError;
}

// A flaky operation that succeeds on the third try.
let tries = 0;
const flaky = async () => {
  tries++;
  if (tries < 3) throw new Error(''attempt '' + tries + '' failed'');
  return ''succeeded on attempt '' + tries;
};

console.log(await retry(flaky));          // ''succeeded on attempt 3''

// Sequential versus concurrent, measured rather than asserted.
const work = (n) => delay(60, n * 10);

const t1 = Date.now();
const sequential = [];
for (const n of [1, 2, 3]) sequential.push(await work(n));
const seqMs = Date.now() - t1;

const t2 = Date.now();
const concurrent = await Promise.all([1, 2, 3].map(work));
const conMs = Date.now() - t2;

console.log(sequential, concurrent);           // [10,20,30] [10,20,30]
console.log(seqMs > 150, conMs < 120);         // true true

// allSettled, when a partial result is still useful.
const report = await Promise.allSettled([
  delay(10, ''ok''),
  Promise.reject(new Error(''one failed'')),
  delay(20, ''also ok''),
]);
console.log(report.map((r) => r.status));
// [''fulfilled'', ''rejected'', ''fulfilled'']
console.log(report.filter((r) => r.status === ''fulfilled'').map((r) => r.value));
// [''ok'', ''also ok'']

// A timeout that wins.
try {
  await withTimeout(delay(500, ''too slow''), 50);
} catch (error) {
  console.log(error.message);                  // ''timed out after 50ms''
}
```

Two details in `retry` are not accidental. The `return await operation(...)` keeps the call inside the `try`, so a rejection is caught - a bare `return operation(...)` would return the promise and leave the `catch` with nothing to catch. And the backoff is awaited between attempts rather than before the first, so a call that succeeds immediately pays nothing.

## Cancellation

Promises cannot be cancelled. What you cancel is the *work*, through an `AbortController`:

```javascript
const controller = new AbortController();
const promise = fetch(''/slow'', { signal: controller.signal });
controller.abort();                 // the fetch rejects with AbortError

// The modern shorthand for the common case:
await fetch(''/slow'', { signal: AbortSignal.timeout(5000) });

// And for combining several reasons to stop:
const signal = AbortSignal.any([controller.signal, AbortSignal.timeout(5000)]);
```

Anything that takes a `signal` participates. Anything that does not will keep running after you stop caring about it, which is why `withTimeout` above races rather than cancels - the slow promise is still out there, it is just ignored.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A function returned a `Promise` instead of a value | `await` was forgotten at the call site |
| Three independent calls took three times as long | `await` inside the loop; use `Promise.all` |
| Errors vanish silently | An unawaited promise with no `.catch` |
| `forEach` with `await` finished immediately | `forEach` ignores returned promises |
| `try/catch` did not catch | `return promise` instead of `return await promise` |
| `Promise.all` rejected and other work kept running | `all` does not cancel; it only stops waiting |
| `AggregateError: All promises were rejected` | `Promise.any` with no successes |
| `UnhandledPromiseRejection` crashed Node | Default behaviour; attach a handler or `await` |

## A check you can run

Search your codebase for `await` immediately inside a `for` or `while` body. For each one, ask a single question: does this iteration need the previous iteration''s result?

If yes, leave it - sequential is correct, and `Promise.all` would be the bug. If no, you have found free latency, and `Promise.all` or a bounded concurrency pool will collect it.

Then search for calls to `async` functions with no `await` and no `.catch`. Each one is an error that will never be reported. In Node you can make them loud immediately:

```javascript
process.on(''unhandledRejection'', (reason) => {
  console.error(''unhandled:'', reason);
  process.exit(1);
});
```

Run your test suite with that in place once. What it finds is usually surprising.
',
   'A promise is a value that is not there yet. async/await is syntax that lets you write code that waits for one without nesting callbacks.', 8, 1576,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000039',
   'Modules',
   'markdown',
   '# Modules

A module is a file with its own scope, loaded once, whose exports are resolved before any of it runs. Those three properties - private scope, single instance, static structure - are what make modules different from the script tags they replaced, and they explain every behaviour in this lesson.

## The syntax, in one place

```javascript
// --- maths.js ---
export const PI = 3.14159;                 // named, inline
export function area(r) { return PI * r * r; }

const internal = ''not exported'';           // private to this file

const circumference = (r) => 2 * PI * r;
export { circumference };                  // named, at the bottom
export { circumference as perimeter };     // and renamed

export default class Circle {              // one default per module
  constructor(r) { this.r = r; }
}
```

```javascript
// --- app.js ---
import Circle from ''./maths.js'';                   // the default
import { PI, area } from ''./maths.js'';             // named
import { area as circleArea } from ''./maths.js'';   // renamed
import * as maths from ''./maths.js'';               // everything as a namespace

// Default and named together, in one statement. Shown separately
// because a name may only be bound once per file - importing Circle
// twice is a SyntaxError, not a duplicate that quietly wins.
//   import Circle, { PI } from ''./maths.js'';

// Re-export, for a package''s public entry point.
export { area, PI } from ''./maths.js'';
export * from ''./shapes.js'';
export { default as Circle } from ''./maths.js'';
```

The extension is required in the browser and in Node''s ESM resolution. Bundlers often let you omit it; the moment you run the same file without one, the import fails. Write the extension.

## Imports are hoisted and static

Every `import` is resolved and executed before any other code in the file, regardless of where you wrote it.

```javascript
console.log(greeting);          // works - the import has already run
import { greeting } from ''./strings.js'';
```

That is not a style recommendation, it is the specification. And it has a consequence: **you cannot import conditionally**.

```javascript
// if (dev) import ''./debug.js'';        // SyntaxError
const module = await import(''./debug.js'');   // this is how
```

`import()` is a function-like expression that returns a promise for the module namespace. It is how you load something conditionally, lazily, or by a name you compute:

```javascript
if (user.wantsCharts) {
  const { renderChart } = await import(''./charts.js'');
  renderChart(data);
}
```

The static structure is what makes tree-shaking possible. A bundler can see that `area` is imported and `circumference` is not, because the imports are literal strings resolved at build time rather than values computed at run time. Dynamic imports are a deliberate opt-out of that, which is why they create a separate chunk.

## A module runs once

The first import evaluates the file. Every later import of the same resolved specifier gets the same namespace object, without re-running anything.

```javascript
// --- counter.js ---
console.log(''counter.js is evaluating'');
export let count = 0;
export function increment() { return ++count; }
```

```javascript
// --- a.js ---
import { increment } from ''./counter.js'';
increment();

// --- b.js ---
import { count, increment } from ''./counter.js'';
increment();
console.log(count);        // 2 - a.js and b.js share one module
```

"counter.js is evaluating" prints once. This is a module registry, not a copy per importer, and it is what makes a module the natural home for a connection pool, a configuration object or a cache.

It is also what makes module-level mutable state dangerous in tests: one test''s mutation is visible to the next. Export a factory rather than an instance when that matters.

## Bindings are live, and read-only to the importer

This is the part that surprises people who think of imports as copies.

```javascript
// --- counter.js ---
export let count = 0;
export function increment() { count++; }
```

```javascript
// --- app.js ---
import { count, increment } from ''./counter.js'';
console.log(count);        // 0
increment();
console.log(count);        // 1 - the binding is live, not a snapshot
// count = 5;              // TypeError: Assignment to constant variable
```

An imported name is a live, read-only view of the exporting module''s binding. The exporter can change it; the importer can only watch. That combination - shared truth, single writer - is a genuinely good design, and it is why `export let` plus an exported setter is a legitimate pattern rather than a smell.

## Named or default

Prefer named exports. The reasons are practical rather than aesthetic:

- **A default export has no name at the import site**, so two files can import the same thing under different names and nothing will tell you. Named imports have to match, and a typo is an error rather than `undefined`.
- **Tree-shaking and auto-import work better** with named exports, because the tooling has a name to key on.
- **Refactoring is safer**: renaming a named export breaks every importer loudly.

A default export is right when a module genuinely *is* one thing - a React component, a class that gives the file its name, a configuration object. It is wrong as a habit of exporting an object full of functions, which gives you the worst of both: one import, no tree-shaking, no rename safety.

```javascript
const area = (r) => Math.PI * r * r;
const circumference = (r) => 2 * Math.PI * r;
const volume = (r) => (4 / 3) * Math.PI * r ** 3;

// Avoid: a bag of functions behind a default. One import, nothing
// shakeable, and no name to rename.
export default { area, circumference, volume };

// Prefer: three named exports, and let the importer take what it needs.
export { area, circumference, volume };
```

## Modules are strict, deferred and top-level-await capable

Four behaviours come free with `type="module"` or a `.mjs` file:

```javascript
// 1. Always strict mode. No implicit globals, no sloppy this.
// 2. `this` at the top level is undefined, not globalThis.
console.log(this);                 // undefined

// 3. Deferred by default - a <script type="module"> does not block
//    parsing and runs after the document is parsed.

// 4. Top-level await, which a script cannot have:
//      const config = await fetch(''/config.json'').then((r) => r.json());
//      export { config };
//    Every module importing this one now waits for that fetch, which is
//    fine at an entry point and a hidden cost in a leaf utility.
const ready = await Promise.resolve(''loaded before any importer runs'');
console.log(ready);
```

Top-level `await` is worth using carefully: every module that imports yours now waits for it. For a configuration load at the entry point that is fine. In a leaf utility it is a hidden delay on everyone.

## CommonJS, and the interop that bites

Node still runs a great deal of `require`, and the two systems are not the same shape.

| | ESM | CommonJS |
|---|---|---|
| Syntax | `import` / `export` | `require` / `module.exports` |
| Resolution | Static, before execution | Dynamic, at the call |
| Bindings | Live, read-only | A snapshot of the value |
| Conditional | `await import()` only | `require()` anywhere |
| Top-level await | Yes | No |
| `__dirname` | No - use `import.meta.dirname` | Yes |

```javascript
// The ESM replacements for the CommonJS globals:
import.meta.url;          // file:///path/to/this/file.js
import.meta.dirname;      // /path/to/this
import.meta.filename;     // /path/to/this/file.js
```

ESM can import CommonJS; CommonJS cannot `require` ESM synchronously. A package declares which it is with `"type": "module"` in its `package.json`, and the error you get for mixing them - `Cannot use import statement outside a module`, or `require() of ES Module` - names the mismatch exactly.

## A worked example

```javascript
// Everything in one file, because the registry behaviour is the point
// and a single file can demonstrate it with dynamic import of a data URL.

// A module, as a string, so this example runs anywhere.
const source = `
  console.log(''module body evaluated'');
  export let count = 0;
  export function increment() { return ++count; }
  export const createCounter = () => { let n = 0; return () => ++n; };
  export default ''I am the default'';
`;
const url = ''data:text/javascript,'' + encodeURIComponent(source);

// First import: the body runs.
const first = await import(url);          // logs ''module body evaluated''
// Second import of the SAME specifier: nothing runs again.
const second = await import(url);         // logs nothing

console.log(first === second);            // true - one namespace object

// Live bindings, shared by both importers.
console.log(first.count);                 // 0
second.increment();
console.log(first.count);                 // 1 - first sees second''s change

// The namespace object is sealed: no properties can be added or
// removed. It is not frozen, because a module may still reassign its
// own `export let` - the restriction is on the importer, not the author.
console.log(Object.isSealed(first));      // true
console.log(Object.isFrozen(first));      // false
try {
  first.count = 99;
} catch (error) {
  console.log(error.constructor.name);    // ''TypeError''
}

// The default is just a named export called ''default''.
console.log(first.default);               // ''I am the default''

// Module state is shared; a factory gives each caller its own.
const a = first.createCounter();
const b = first.createCounter();
console.log(a(), a(), b());               // 1 2 1
```

The last three lines are the practical lesson. `count` is module state and is shared by everyone who imports the module - excellent for a cache, wrong for anything per-request. `createCounter` returns a closure, so each caller gets its own. When you are deciding where to put state, that is the question: should every importer see the same one?

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Cannot use import statement outside a module` | Missing `"type": "module"` or a `.mjs` extension |
| `require() of ES Module ... not supported` | CommonJS importing ESM; use `await import()` |
| `Failed to resolve module specifier` | Missing file extension, or a bare specifier with no import map |
| An import is `undefined` | Default imported as named, or a name typo |
| A module ran twice | Two different specifiers resolved to two URLs |
| `Assignment to constant variable` on an import | Imported bindings are read-only |
| A circular import gave `undefined` | The other module had not finished evaluating |
| State leaked between tests | Module-level mutable state; export a factory |

## A check you can run

Circular imports are the one failure mode you cannot reason your way around, so see it once:

```javascript
// --- a.js ---
import { b } from ''./b.js'';
export const a = ''A'';
console.log(''a.js sees b as'', b);

// --- b.js ---
import { a } from ''./a.js'';
export const b = ''B'';
console.log(''b.js sees a as'', a);
```

Import `a.js` and you get a `ReferenceError: Cannot access ''a'' before initialization` from `b.js`, because `b.js` evaluated first and `a` was still in its temporal dead zone. Change both to `export function` and it works, because function declarations are fully hoisted.

That is the whole rule for cycles: functions survive them, values do not. The real fix is almost always to extract the shared thing into a third module that neither imports the other.
',
   'A module is a file with its own scope. Nothing leaks out unless you export it, and the file runs exactly once however many times it is imported.', 9, 1864,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
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
  ('e0000001-0000-4000-8000-00000000003a',
   'The Event Loop',
   'markdown',
   '# The Event Loop

JavaScript runs your code on one thread. Everything that looks concurrent - timers, network calls, clicks - is the same thread picking up queued work between runs. Understanding the queue order is what turns "why did that log print second" from a mystery into arithmetic.

## The model

There is a **call stack**, where the currently running code lives, and there are **queues** of work waiting for the stack to empty. The event loop is the rule that decides what to take next.

Two queues matter:

- The **microtask queue**: resolved promise callbacks, `queueMicrotask`, `MutationObserver`.
- The **macrotask queue** (the task queue): `setTimeout`, `setInterval`, I/O completions, events.

The rule, in one sentence: **after each task, the engine drains the entire microtask queue before taking the next task.** Not one microtask - all of them, including any added while draining.

```javascript
console.log(''1 sync'');

setTimeout(() => console.log(''5 timeout''), 0);

Promise.resolve().then(() => console.log(''3 microtask''));
queueMicrotask(() => console.log(''4 microtask''));

console.log(''2 sync'');

// 1 sync
// 2 sync
// 3 microtask
// 4 microtask
// 5 timeout
```

Synchronous code first, because it is already on the stack. Then every microtask. Then the timer. The numbers are not a convention - they are what the specification requires.

## await is a microtask boundary

An `async` function runs synchronously until its first `await`. Everything after that `await` is a microtask.

```javascript
async function run() {
  console.log(''A'');
  await null;              // not a promise, still a microtask boundary
  console.log(''C'');
}

console.log(''start'');
run();
console.log(''B'');

// start
// A        - the body runs synchronously up to the await
// B        - run() returned at the await; the caller continues
// C        - queued as a microtask, runs when the stack empties
```

`await null` does not wait for anything, and it still defers. That is why inserting an `await` into a function can reorder logs that had nothing to do with the thing being awaited.

## setTimeout(fn, 0) is not zero

```javascript
setTimeout(() => console.log(''later''), 0);
```

The 0 is a *minimum* delay, and three things add to it:

- **Clamping.** Nested timers - a `setTimeout` scheduled from inside a timer callback - are clamped to 4ms after the fifth level of nesting, by specification. A recursive `setTimeout(fn, 0)` loop therefore runs at about 250 iterations a second, not as fast as possible.
- **Queue position.** The callback goes to the back of the task queue, behind anything already there.
- **The stack.** Nothing runs until the current synchronous work has finished. A 500ms calculation delays every timer by 500ms.

```javascript
const start = Date.now();
setTimeout(() => console.log(''fired after'', Date.now() - start, ''ms''), 0);
// A deliberately slow loop, on the same thread.
let n = 0;
while (Date.now() - start < 200) n++;
console.log(''blocked for 200ms'');
// blocked for 200ms
// fired after 200ms or so - the timer was ready at 0 and could not run
```

When you genuinely want "after this, but before the next paint", the tools are `queueMicrotask` (as soon as the stack empties) and `requestAnimationFrame` (just before the next frame). `setTimeout(fn, 0)` is neither.

## Why this matters in practice

**A long task blocks everything.** Not just other JavaScript - rendering, scrolling, clicks, the lot. Browsers call anything over 50ms a long task, and a run of them is what "janky" means. The fix is to break the work up:

```javascript
async function processAll(items, handle) {
  for (const [i, item] of items.entries()) {
    handle(item);
    // Yield every 100 items so the browser can paint and respond.
    if (i % 100 === 99) await new Promise((r) => setTimeout(r, 0));
  }
}
```

In a browser, `scheduler.yield()` is the purpose-built version of that line and keeps your place in the queue rather than going to the back.

**A microtask loop starves everything.** Because the loop drains microtasks *completely*, a microtask that queues another microtask forever is an infinite loop that never lets a timer, an event or a paint through:

```javascript
// Do not run this: the page will stop responding entirely.
function spin() { Promise.resolve().then(spin); }
```

The equivalent with `setTimeout` is merely busy; this one is fatal. That asymmetry is the practical reason to know which queue you are on.

## A worked example

```javascript
// The complete ordering, in one runnable file. Predict each line
// before running it; the ones you get wrong are the ones worth
// re-reading above.
const log = [];
const note = (s) => log.push(s);

note(''1: script start'');

setTimeout(() => {
  note(''8: timeout A'');
  Promise.resolve().then(() => note(''9: microtask inside timeout A''));
}, 0);

setTimeout(() => note(''10: timeout B''), 0);

Promise.resolve()
  .then(() => {
    note(''4: promise then 1'');
    // Returning a promise adds TWO extra microtask ticks before the
    // next .then runs - this is why 7 lands after 6.
    return Promise.resolve();
  })
  .then(() => note(''7: promise then 2''));

queueMicrotask(() => note(''5: queueMicrotask''));

(async () => {
  note(''2: async body, before await'');
  await null;
  note(''6: async body, after await'');
})();

note(''3: script end'');

// Report once every queue has drained.
setTimeout(() => { for (const line of log) console.log(line); }, 10);

// 1: script start
// 2: async body, before await
// 3: script end
// 4: promise then 1
// 5: queueMicrotask
// 6: async body, after await
// 7: promise then 2
// 8: timeout A
// 9: microtask inside timeout A
// 10: timeout B
```

Three things in that output are worth defending.

**Line 6 before line 7.** Both are microtasks queued in the first drain, but `then 1` returned a promise, which costs two extra ticks to adopt. The async function''s continuation was queued first and had no such cost.

**Line 9 before line 10.** Timeout A and timeout B were both queued before either ran. After A''s callback finishes, the engine drains microtasks - which now contains A''s promise callback - *before* taking B. Microtasks beat the next task, always.

**Lines 1 to 3 in order.** The async IIFE printed line 2 synchronously. Nothing about `async` defers the start of a function; only the `await` defers the rest.

## Node and the browser differ

The microtask rule is identical. The task side is not: Node has phases, and two extra queues that the browser does not have.

```javascript
// Node only, and inside a callback, which is where the order is
// actually defined.
setTimeout(() => {
  process.nextTick(() => console.log(''1 nextTick''));
  Promise.resolve().then(() => console.log(''2 promise''));
  setTimeout(() => console.log(''4 timeout''), 0);
  setImmediate(() => console.log(''3 setImmediate''));
});

// 1 nextTick        - its own queue, drained first
// 2 promise         - then the microtask queue
// 3 setImmediate    - the check phase, this time round the loop
// 4 timeout         - the timers phase, next time round
```

`process.nextTick` has its own queue, drained before the promise microtask queue - so a `nextTick` that queues another `nextTick` starves promises, the same way a self-queueing microtask starves timers.

Inside a callback, `setImmediate` runs before `setTimeout(fn, 0)`, because the check phase comes after the current phase and the timers phase does not come round again until the next iteration. At the **top level** the order of those two is genuinely non-deterministic - it depends on how long the process took to start, and whether the 0ms timer is already due on the first pass. It is a famous interview question and it almost never matters in real code.

One more top-level subtlety, since you may try it: in an ES module the module body itself runs as a promise job, so a top-level `process.nextTick` is queued from inside a microtask and can print *after* a `Promise.resolve().then`. In CommonJS the same four lines print `nextTick` first. The rule above holds in both; what changes is what counts as "the current callback".

The browser has one more wrinkle worth knowing: rendering. The loop is roughly task, microtasks, then *possibly* a render - style, layout, paint - before the next task. `requestAnimationFrame` callbacks run inside that render step, which is why they are the right place for visual updates and the wrong place for data processing.

## When it goes wrong

| Symptom | Cause |
|---|---|
| A log printed in an order you did not expect | Microtasks drain before the next task |
| The UI froze for a second | A long synchronous task; break it up and yield |
| The page stopped responding entirely | A microtask queueing itself forever |
| `setTimeout(fn, 0)` took 4ms or more | Nested-timer clamping |
| A timer fired much later than asked | The stack was busy; the delay is a minimum |
| A DOM read after a write gave stale values | The render step had not run yet |
| Node ordering differs from the browser | `nextTick` and `setImmediate` are Node-only phases |
| An `await` reordered unrelated logs | Every `await` is a microtask boundary |

## A check you can run

Take the worked example and move the `queueMicrotask` call to the very top of the file, above everything. Predict the output, then run it.

It still prints fifth. Nothing about writing it first matters, because the whole synchronous body runs before any microtask does. That is the single most useful thing to internalise here: the order you write asynchronous calls in affects only the order they are *queued*, and the queue they land in decides everything else.
',
   'JavaScript runs on one thread. Everything asynchronous is a queue of work that thread picks up when it has finished. Once you can see the queues, ordering stops being surprising.', 8, 1564,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-00000000003b',
   'Iterators and Generators',
   'markdown',
   '# Iterators and Generators

`for...of`, spread, destructuring and `Promise.all` all speak one protocol. Once you know what it is, you can make your own objects work with all of them, and you can produce values lazily instead of building an array you may not need.

## The iteration protocol

An object is **iterable** if it has a method at the key `Symbol.iterator` that returns an **iterator**. An iterator is any object with a `next()` method returning `{ value, done }`.

```javascript
const range = {
  from: 1,
  to: 4,
  [Symbol.iterator]() {
    let current = this.from;
    const last = this.to;
    return {
      next() {
        return current <= last
          ? { value: current++, done: false }
          : { value: undefined, done: true };
      },
    };
  },
};

console.log([...range]);                    // [1, 2, 3, 4]
for (const n of range) process.stdout.write(n + '' '');   // 1 2 3 4
console.log();
const [first, second] = range;
console.log(first, second);                 // 1 2
```

That is the whole protocol. Thirty lines of ceremony, and now `range` works with every construct in the language that consumes iterables - `for...of`, spread, array and parameter destructuring, `Array.from`, `new Set`, `new Map`, `Promise.all`, `yield*`.

## What you already use it for

Every one of these is the protocol, and knowing that explains why they compose:

```javascript
console.log([...''hey'']);                        // [''h'', ''e'', ''y'']
console.log([...new Set([1, 1, 2])]);           // [1, 2]
console.log([...new Map([[''a'', 1]])]);          // [[''a'', 1]]
console.log([...[10, 20].entries()]);           // [[0, 10], [1, 20]]
console.log([...Object.entries({ a: 1 })]);     // [[''a'', 1]]

// Maps and Sets iterate in insertion order, and give you three views.
const m = new Map([[''a'', 1], [''b'', 2]]);
console.log([...m.keys()], [...m.values()]);    // [''a'',''b''] [1,2]
for (const [key, value] of m) console.log(key, value);
```

A plain object is **not** iterable - `[...{a: 1}]` throws. That is deliberate: object iteration is ambiguous (keys? values? inherited?), so the language makes you say which with `Object.keys`, `Object.values` or `Object.entries`.

## Generators write the iterator for you

The `range` above took thirty lines. A generator writes the same thing in four.

```javascript
function* range(from, to) {
  for (let n = from; n <= to; n++) yield n;
}

console.log([...range(1, 4)]);     // [1, 2, 3, 4]
```

`function*` returns a generator object, which is both an iterator and iterable. `yield` suspends the function, hands a value out, and keeps the entire local state - variables, loop counters, position - until `next()` is called again.

```javascript
function* range(from, to) {
  for (let n = from; n <= to; n++) yield n;
}

const gen = range(1, 3);
console.log(gen.next());           // { value: 1, done: false }
console.log(gen.next());           // { value: 2, done: false }
console.log(gen.next());           // { value: 3, done: false }
console.log(gen.next());           // { value: undefined, done: true }
console.log(gen.next());           // { value: undefined, done: true }
```

That suspension is the feature. A function that can pause mid-loop and resume later is how you express a sequence without materialising it.

## Generators are lazy, which is the point

```javascript
function* naturals() {
  let n = 1;
  while (true) yield n++;          // infinite, and harmless
}

function* take(iterable, count) {
  let taken = 0;
  for (const value of iterable) {
    if (taken++ >= count) return;
    yield value;
  }
}

function* map(iterable, fn) {
  for (const value of iterable) yield fn(value);
}

function* filter(iterable, predicate) {
  for (const value of iterable) if (predicate(value)) yield value;
}

// Nothing has run yet. Each of these returns a generator object.
const pipeline = take(map(filter(naturals(), (n) => n % 3 === 0), (n) => n * n), 5);

console.log([...pipeline]);        // [9, 36, 81, 144, 225]
```

`naturals()` is an infinite sequence and the program terminates, because nothing asks for a value until `[...pipeline]` does, and it stops asking after five. An array-based version would need a bound guessed in advance and would allocate four intermediate arrays.

`yield*` delegates to another iterable, which is how you compose generators without a loop:

```javascript
function* inorder(node) {
  if (!node) return;
  yield* inorder(node.left);
  yield node.value;
  yield* inorder(node.right);
}

const tree = {
  value: 5,
  left: { value: 3, left: { value: 1 }, right: { value: 4 } },
  right: { value: 8 },
};
console.log([...inorder(tree)]);   // [1, 3, 4, 5, 8]
```

A recursive tree walk that yields rather than pushing into an accumulator, in six lines, and the caller can stop halfway through without the walk completing.

## Two-way: next(value), return and throw

`yield` is an expression. Whatever is passed to the *next* `next()` call becomes its value, which makes a generator a coroutine rather than only a producer.

```javascript
function* conversation() {
  const name = yield ''What is your name?'';
  const year = yield ''Hello '' + name + ''. What year were you born?'';
  return name + '' is about '' + (2026 - Number(year)) + '' years old.'';
}

const chat = conversation();
console.log(chat.next().value);         // ''What is your name?''
console.log(chat.next(''Aisha'').value);  // ''Hello Aisha. What year...''
console.log(chat.next(''1997'').value);   // ''Aisha is about 29 years old.''
```

The first `next()` takes no argument - there is no suspended `yield` for it to answer yet. That off-by-one is the thing to remember.

Two more methods complete the picture:

```javascript
function* withCleanup() {
  try {
    yield 1;
    yield 2;
  } finally {
    console.log(''cleaned up'');        // runs on return(), throw(), or break
  }
}

const g = withCleanup();
console.log(g.next().value);          // 1
console.log(g.return(''stopped''));     // ''cleaned up'' then { value: ''stopped'', done: true }

// And a for...of that breaks early calls return() for you.
for (const n of withCleanup()) {
  console.log(n);                     // 1
  break;                              // ''cleaned up'' prints here
}
```

The `finally` running on early exit is what makes generators safe for resources. A generator that opens a file can close it in `finally` and trust that `break`, `throw` and `return` all reach it.

## Async generators, for streams

```javascript
async function* pages(total) {
  for (let page = 1; page <= total; page++) {
    // In real code: await fetch(...). Here, a delay stands in for it.
    await new Promise((r) => setTimeout(r, 5));
    yield { page, rows: [page * 10, page * 10 + 1] };
  }
}

for await (const { page, rows } of pages(3)) {
  console.log(''page'', page, rows);
}
// page 1 [10, 11]
// page 2 [20, 21]
// page 3 [30, 31]
```

`for await...of` is how you consume anything that produces values over time - a paginated API, a file read in chunks, a WebSocket. Node streams are async iterables, so `for await (const chunk of readable)` works with no adapter at all.

## A worked example

```javascript
// Paging through a large result set without ever holding it all in
// memory, with a limit, a transformation and early exit - the shape
// this feature actually gets used for.
const DATA = Array.from({ length: 95 }, (_, i) => ({
  id: i + 1,
  name: ''row '' + (i + 1),
  score: (i * 37) % 100,
}));

// Pretend this is a network call returning one page.
async function fetchPage(page, size = 10) {
  await new Promise((r) => setTimeout(r, 1));
  const start = (page - 1) * size;
  return { rows: DATA.slice(start, start + size), hasMore: start + size < DATA.length };
}

// An async generator that hides paging entirely from the caller.
async function* allRows(size = 10) {
  let page = 1;
  let calls = 0;
  try {
    while (true) {
      calls++;
      const { rows, hasMore } = await fetchPage(page, size);
      yield* rows;
      if (!hasMore) return;
      page++;
    }
  } finally {
    console.log(''stopped after '' + calls + '' request(s)'');
  }
}

// The caller writes a loop over rows and never mentions pages.
const highScorers = [];
for await (const row of allRows()) {
  if (row.score > 90) highScorers.push(row.id);
  if (highScorers.length === 3) break;     // early exit, mid-page
}
console.log(highScorers);
// stopped after 3 request(s)
// [ 9, 17, 28 ]

// Three requests, not ten: the break reached the generator''s finally,
// which is how you know the remaining pages were never fetched.

// Synchronous composition over the same data, still lazy.
function* take(iterable, n) {
  let i = 0;
  for (const value of iterable) {
    if (i++ >= n) return;
    yield value;
  }
}
function* map(iterable, fn) {
  for (const value of iterable) yield fn(value);
}

const names = [...take(map(DATA, (r) => r.name.toUpperCase()), 3)];
console.log(names);                        // [''ROW 1'', ''ROW 2'', ''ROW 3'']
```

## When not to reach for one

Generators are the wrong tool more often than they are the right one.

- **The collection is small and in memory.** `array.map(...)` is faster, more familiar and reads better. Laziness is overhead when there is nothing to save.
- **You need the length, random access or to sort.** An iterator has none of those. Build the array.
- **You need to iterate twice.** A generator is consumed once; the second `for...of` sees nothing. An iterable *object* with a `Symbol.iterator` that returns a fresh generator each time can be re-iterated; the generator object itself cannot.

```javascript
const gen = (function* () { yield 1; yield 2; })();
console.log([...gen]);            // [1, 2]
console.log([...gen]);            // [] - already exhausted
```

That silent empty array on the second pass is the commonest generator bug, and it is silent precisely because an exhausted iterator is indistinguishable from an empty one.

## When it goes wrong

| Symptom | Cause |
|---|---|
| The second loop over a generator saw nothing | Generators are consumed once |
| `is not iterable` on a plain object | Use `Object.entries` or add `Symbol.iterator` |
| `.length` is undefined | Iterators have no length; spread into an array |
| An infinite generator hung the program | Nothing bounded it; use `take` or a `break` |
| Cleanup never ran | `return()` was not called - avoid `while` with a manual `next` |
| The first `next(value)` argument was ignored | There is no suspended `yield` to receive it |
| `for await` on a sync iterable of promises | It awaits each value; usually what you want, occasionally not |
| A generator function returned a generator, not a value | Calling it only creates the object; `next()` runs it |

## A check you can run

The worked example prints "stopped after 3 request(s)". Delete the `break` and run it again: it prints "stopped after 10 request(s)" and finds every high scorer.

That difference is the entire value proposition. The consumer decided how much work the producer did, without the producer knowing anything about the consumer - and the `finally` proves the producer was told to stop rather than left dangling.
',
   'for...of works on anything that follows one small protocol. A generator is a function that can pause in the middle, and it implements that protocol for free.', 9, 1760,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-00000000003c',
   'Symbols, Proxies and Metaprogramming',
   'markdown',
   '# Symbols, Proxies and Metaprogramming

These three features let you change what the basic operations of the language *mean* for your objects: what happens on a property read, on a `for...of`, on a `+`. That is enormous power and it is nearly always the wrong tool. This lesson is about recognising the handful of cases where it is right - and about reading the frameworks that are built on it.

## Symbols: keys that cannot collide

A symbol is a unique primitive. Two symbols with the same description are different values, so a symbol used as a key can never clash with anyone else''s key.

```javascript
const id = Symbol(''id'');
const otherId = Symbol(''id'');
console.log(id === otherId);              // false - descriptions are labels

const user = { name: ''Aisha'', [id]: 7 };
console.log(user[id]);                    // 7
console.log(Object.keys(user));           // [''name''] - symbols are skipped
console.log(JSON.stringify(user));        // ''{"name":"Aisha"}''
console.log(Object.getOwnPropertySymbols(user));   // [Symbol(id)]
```

Symbol keys are skipped by `Object.keys`, `JSON.stringify`, `for...in` and spread-into-JSON, but they are **not private** - `getOwnPropertySymbols` finds them. Use `#private` fields for privacy and symbols for *metadata that should not show up in ordinary enumeration*.

The well-known symbols are where it gets useful. These are the hooks the language itself calls:

```javascript
class Temperature {
  constructor(celsius) { this.celsius = celsius; }

  // Called by for...of, spread, destructuring.
  *[Symbol.iterator]() { yield this.celsius; yield this.celsius * 9 / 5 + 32; }

  // Called by +, by template literals, by Number() and String().
  [Symbol.toPrimitive](hint) {
    if (hint === ''number'') return this.celsius;
    if (hint === ''string'') return this.celsius + '' degrees C'';
    return ''Temperature('' + this.celsius + '')'';
  }

  // Changes what Object.prototype.toString reports.
  get [Symbol.toStringTag]() { return ''Temperature''; }
}

const t = new Temperature(20);
console.log([...t]);                      // [20, 68]
console.log(String(t));                   // ''20 degrees C''  - string hint
console.log(Number(t));                   // 20
console.log(Object.prototype.toString.call(t));   // ''[object Temperature]''

// `+` passes the hint ''default'', NOT ''number'' - it cannot know whether
// you meant addition or concatenation, so it asks for neither.
console.log(t + 5);                       // ''Temperature(20)5''
console.log(Number(t) + 5);               // 25
```

That `t + 5` line is the one worth remembering. Almost everyone writing `Symbol.toPrimitive` for the first time handles `''number''` and `''string''` and forgets that the operator most likely to reach it passes `''default''`. If addition should mean arithmetic, return the number for the default hint; `Date` is the odd one out in the standard library, returning a string, which is why `date1 + date2` concatenates and `date1 - date2` gives milliseconds.

`Symbol.iterator` is the one you will implement; the rest are worth recognising when you meet them in a library.

## Proxies: intercepting the operations themselves

A `Proxy` wraps a target object and lets you define what happens for each fundamental operation - a *trap*.

```javascript
const target = { a: 1 };

const proxy = new Proxy(target, {
  get(obj, key, receiver) {
    console.log(''read'', String(key));
    return Reflect.get(obj, key, receiver);
  },
  set(obj, key, value, receiver) {
    console.log(''write'', String(key), ''='', value);
    return Reflect.set(obj, key, value, receiver);
  },
  has(obj, key) { return Reflect.has(obj, key); },
  deleteProperty(obj, key) { return Reflect.deleteProperty(obj, key); },
});

proxy.a;              // ''read a''
proxy.b = 2;          // ''write b = 2''
console.log(target.b);   // 2 - the proxy wrote through to the target
```

Thirteen traps exist in all. The ones you will use are `get`, `set`, `has`, `deleteProperty`, `ownKeys` and `apply`.

## Reflect is not optional

Every trap has a matching `Reflect` method with the same signature, and using it is not a style preference.

```javascript
const wrong = {
  // Loses the receiver, so a getter on the prototype sees the wrong
  // `this` - and returns nothing, which strict mode treats as failure.
  set(obj, key, value) { obj[key] = value; },
};

const right = {
  set(obj, key, value, receiver) { return Reflect.set(obj, key, value, receiver); },
};
```

Two reasons. `Reflect.get` and `Reflect.set` take the **receiver**, which is what `this` should be inside an inherited getter or setter - `obj[key]` throws that away. And `Reflect.set` and `Reflect.deleteProperty` **return a boolean**; a `set` trap that returns a falsy value throws a `TypeError` in strict mode, which is every module.

The rule: write every trap as a `Reflect` call with the trap''s own arguments, then add your behaviour around it.

## What reactivity frameworks do with this

Vue''s reactivity, MobX and several signal libraries are a `get` trap that records which effect is reading a property, and a `set` trap that re-runs the effects which read it. In about forty lines:

```javascript
let activeEffect = null;
const dependencies = new WeakMap();   // target -> Map(key -> Set(effect))

function track(target, key) {
  if (!activeEffect) return;
  if (!dependencies.has(target)) dependencies.set(target, new Map());
  const keys = dependencies.get(target);
  if (!keys.has(key)) keys.set(key, new Set());
  keys.get(key).add(activeEffect);
}

function trigger(target, key) {
  const effects = dependencies.get(target)?.get(key);
  if (!effects) return;
  for (const effect of [...effects]) effect();
}

function reactive(object) {
  return new Proxy(object, {
    get(obj, key, receiver) {
      track(obj, key);
      const value = Reflect.get(obj, key, receiver);
      // Deep reactivity, created on demand rather than up front.
      return value !== null && typeof value === ''object'' ? reactive(value) : value;
    },
    set(obj, key, value, receiver) {
      const had = Reflect.get(obj, key, receiver);
      const ok = Reflect.set(obj, key, value, receiver);
      if (had !== value) trigger(obj, key);
      return ok;
    },
  });
}

function effect(fn) {
  const run = () => { activeEffect = run; try { fn(); } finally { activeEffect = null; } };
  run();
  return run;
}

// And it behaves exactly like the real thing.
const state = reactive({ count: 0, user: { name: ''Aisha'' } });
const log = [];

effect(() => log.push(''count is '' + state.count));
effect(() => log.push(''name is '' + state.user.name));

state.count = 1;              // re-runs the first effect only
state.user.name = ''Noshad'';   // re-runs the second effect only
state.count = 1;              // no change, no re-run

console.log(log);
// [ ''count is 0'', ''name is Aisha'', ''count is 1'', ''name is Noshad'' ]
```

Three design decisions in there are worth noticing, because they are the same ones the real libraries made. Dependencies are keyed per *property*, not per object, so changing `count` does not re-run an effect that only read `user`. Nested objects are wrapped lazily inside the `get` trap, so a large object costs nothing until it is read. And the `set` trap compares before triggering, so an assignment that changes nothing costs nothing.

## The invariants you cannot break

A proxy is not allowed to lie about certain things. The engine checks, and throws when a trap contradicts the target.

```javascript
const frozen = Object.freeze({ a: 1 });
const liar = new Proxy(frozen, { get() { return ''different''; } });

try {
  liar.a;
} catch (error) {
  console.log(error.constructor.name);   // ''TypeError''
}
```

Reading a non-writable, non-configurable property must return the real value. Similarly, `ownKeys` must report every non-configurable key, `has` cannot hide one, and `deleteProperty` cannot claim to have removed one that is non-configurable. These invariants exist so that code holding a frozen object can trust it even if a proxy is in the way.

Four more limits worth knowing before you build on proxies:

- **`#private` fields do not work through a proxy.** A method called on the proxy has the proxy as `this`, and the proxy is not the object that holds the private field. The error is `Cannot read private member`.
- **Identity is not preserved.** `proxy !== target`, so a `Map` keyed by the target will not find the proxy, and vice versa.
- **`===` and `instanceof` are not trappable.** There is no trap for equality.
- **Every operation costs.** A proxied property read is substantially slower than a plain one, because it is a function call plus a `Reflect` call instead of an inline cache hit.

## A worked example

```javascript
// A defensive settings object: unknown keys throw instead of silently
// returning undefined, writes are validated, and deletes are refused.
// This is the one proxy use that earns its place in ordinary code.
function strict(shape, values) {
  return new Proxy({ ...values }, {
    get(obj, key, receiver) {
      if (typeof key === ''symbol'') return Reflect.get(obj, key, receiver);
      if (!(key in shape)) {
        throw new ReferenceError(''unknown setting: '' + key);
      }
      return Reflect.get(obj, key, receiver);
    },

    set(obj, key, value, receiver) {
      const expected = shape[key];
      if (!expected) throw new ReferenceError(''unknown setting: '' + key);
      if (typeof value !== expected) {
        throw new TypeError(key + '' must be a '' + expected + '', got '' + typeof value);
      }
      return Reflect.set(obj, key, value, receiver);
    },

    deleteProperty() { throw new TypeError(''settings cannot be deleted''); },

    ownKeys(obj) { return Reflect.ownKeys(obj); },
  });
}

const settings = strict(
  { host: ''string'', port: ''number'', debug: ''boolean'' },
  { host: ''localhost'', port: 3306, debug: false },
);

console.log(settings.port);               // 3306
settings.port = 5432;
console.log(settings.port);               // 5432
console.log(Object.keys(settings));       // [''host'', ''port'', ''debug'']

const errors = [];
const tryIt = (fn) => { try { fn(); } catch (e) { errors.push(e.constructor.name + '': '' + e.message); } };

tryIt(() => settings.prot);               // a typo, caught
tryIt(() => { settings.port = ''5432''; }); // a string where a number belongs
tryIt(() => { delete settings.host; });   // refused

console.log(errors);
// [ ''ReferenceError: unknown setting: prot'',
//   ''TypeError: port must be a number, got string'',
//   ''TypeError: settings cannot be deleted'' ]

// The typo is the point. Without the proxy, settings.prot is undefined,
// the connection silently uses a default, and the bug surfaces in
// production as a timeout rather than here as a stack trace.
```

The `typeof key === ''symbol''` guard on the `get` trap is not decoration. Without it, anything that probes the object - `console.log`, `JSON.stringify`, `util.inspect`, a `for...of` attempt - reads `Symbol.toStringTag` or `Symbol.iterator` and gets a thrown `ReferenceError` from your own trap. A strict `get` trap without a symbol escape hatch is unloggable, and that is a miserable afternoon.

## When to use any of this

Honestly: rarely.

**Symbols** - yes, when you need a key that cannot collide, or when you are implementing `Symbol.iterator`. That second one is common and entirely ordinary.

**Proxies** - when the set of properties is genuinely not known in advance, and the behaviour must apply to all of them. Reactivity systems, API clients that build a URL from the property path, validation wrappers, test doubles that record every access. Four real categories.

**Not proxies** - for anything you could write as a method, a getter, a `Map` or a class. A proxy makes code harder to read, harder to debug (your stepping through a trap, not the operation), slower, and incompatible with private fields. The cost is paid by everyone who reads the file afterwards.

The test: if you can name the properties, you do not need a proxy.

## When it goes wrong

| Symptom | Cause |
|---|---|
| `Cannot read private member` through a proxy | `#fields` key on the real object, not the proxy |
| A `set` trap threw `TypeError` in strict mode | The trap returned nothing; return `Reflect.set(...)` |
| An inherited setter saw the wrong `this` | `obj[key] = value` instead of `Reflect.set` with the receiver |
| `TypeError: proxy must report the same value` | A trap contradicted a non-configurable property |
| `console.log` on a proxy threw | The `get` trap has no escape hatch for symbol keys |
| A `Map` lookup missed | `proxy !== target`; pick one and use it consistently |
| Property access became measurably slow | Every trapped read is a double function call |
| A symbol key leaked into a log | Symbols are hidden from enumeration, not private |

## A check you can run

Take the reactivity example and add `console.log(state)` inside one of the effects. It re-runs forever - because logging reads every property, which tracks every property, which the next write triggers.

That infinite loop in two added characters is the honest summary of metaprogramming. The power is real, the frameworks built on it are excellent, and the failure modes are of a kind that ordinary code simply does not have. Use it where the problem genuinely has no fixed set of keys, and nowhere else.
',
   'The hooks that let you change what the language does to your objects. Every reactivity framework of the last decade is built on them, and most application code should not use them.', 10, 2017,'55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
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

CALL catalog_refresh_course_rollup('c0000001-0000-4000-8000-000000000006');
