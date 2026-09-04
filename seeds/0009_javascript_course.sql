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

INSERT INTO catalog.tags (id, slug, name) VALUES
  ('bbbbbbb1-0000-4000-8000-00000000000e', 'javascript', 'JavaScript'),
  ('bbbbbbb1-0000-4000-8000-00000000000f', 'typescript', 'TypeScript'),
  ('bbbbbbb1-0000-4000-8000-000000000010', 'async',      'Async')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO catalog.courses
  (id, slug, title, subtitle, description, category_id, instructor_id, level, status,
   thumbnail_url, price_cents, learning_outcomes, requirements, published_at)
VALUES
  ('c0000001-0000-4000-8000-000000000006',
   'javascript-from-basics-to-expert',
   'JavaScript: From Basics to Expert',
   'Four levels, twelve lessons, every example runs in your browser',
   'A complete path through JavaScript in four levels. Level 1, Basic, covers values and types, functions and scope, and the two structures everything else is built from. Level 2, Intermediate, is the working vocabulary: the array methods you will use every day, destructuring, and classes. Level 3, Advanced, is where the language gets interesting - closures, promises and async/await, and modules. Level 4, Expert, finishes with the event loop, iterators and generators, and the metaprogramming hooks that make frameworks possible.

Every lesson ships a complete, runnable example. Press the "Try yourself!" button under any of them and it opens in the compiler, where you write on the left and see what it logs on the right. It runs in your browser, not on a server.',
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
  title = VALUES(title), subtitle = VALUES(subtitle), description = VALUES(description),
  learning_outcomes = VALUES(learning_outcomes), requirements = VALUES(requirements);

INSERT INTO catalog.course_tags (course_id, tag_id) VALUES
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-00000000000e'),
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-000000000010'),
  ('c0000001-0000-4000-8000-000000000006', 'bbbbbbb1-0000-4000-8000-00000000000a')
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO catalog.modules (id, course_id, title, summary, `position`) VALUES
  ('d0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'Level 1 - Basic', 'Values, functions and the two structures everything else is built from.', 1),
  ('d0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'Level 2 - Intermediate', 'Array methods, destructuring and classes - the everyday vocabulary.', 2),
  ('d0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'Level 3 - Advanced', 'Closures, promises and modules.', 3),
  ('d0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'Level 4 - Expert', 'The event loop, generators, and the hooks frameworks are built on.', 4)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary);

INSERT INTO catalog.lessons
  (id, module_id, course_id, slug, title, summary, kind, status, `position`,
   duration_seconds, is_free_preview)
VALUES
  -- Level 1
  ('e0000001-0000-4000-8000-000000000031', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'values-and-types', 'Values and Types',
   'Seven primitives, one object type, and the coercion rules that surprise everyone once.',
   'article', 'published', 1, 540, 1),
  ('e0000001-0000-4000-8000-000000000032', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'functions-and-scope', 'Functions and Scope',
   'Declarations, expressions, arrows - and which one changes what `this` means.',
   'article', 'published', 2, 600, 1),
  ('e0000001-0000-4000-8000-000000000033', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'arrays-and-objects', 'Arrays and Objects',
   'Reference semantics, and why copying one is the bug you will write first.',
   'article', 'published', 3, 600, 0),
  ('e0000001-0000-4000-8000-00000000003d', 'd0000001-0000-4000-8000-000000000010', 'c0000001-0000-4000-8000-000000000006',
   'js-level-1-check', 'Level 1 Check: Values, Scope and Equality',
   'Five questions on types, scope and reference semantics.',
   'quiz', 'published', 4, 420, 1),

  -- Level 2
  ('e0000001-0000-4000-8000-000000000034', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'array-methods', 'The Array Methods You Will Actually Use',
   'map, filter, reduce and the six others that replace most loops you would write.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000035', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'destructuring-and-spread', 'Destructuring and Spread',
   'Pulling values out and putting them back, without a pile of temporary variables.',
   'article', 'published', 2, 600, 0),
  ('e0000001-0000-4000-8000-000000000036', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'classes-and-prototypes', 'Classes and Prototypes',
   'What class syntax is actually doing, and the private fields that are genuinely private.',
   'article', 'published', 3, 720, 0),
  ('e0000001-0000-4000-8000-00000000003e', 'd0000001-0000-4000-8000-000000000011', 'c0000001-0000-4000-8000-000000000006',
   'js-level-2-check', 'Level 2 Check: Everyday JavaScript',
   'Five questions on array methods, destructuring and classes.',
   'quiz', 'published', 4, 480, 0),

  -- Level 3
  ('e0000001-0000-4000-8000-000000000037', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'closures', 'Closures',
   'A function remembering where it was born. The idea behind most JavaScript patterns.',
   'article', 'published', 1, 720, 0),
  ('e0000001-0000-4000-8000-000000000038', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'promises-and-async', 'Promises and async/await',
   'Sequential when you need it, parallel when you do not, and failure handled either way.',
   'article', 'published', 2, 840, 0),
  ('e0000001-0000-4000-8000-000000000039', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'modules', 'Modules',
   'import, export, and why a module runs exactly once no matter how often you import it.',
   'article', 'published', 3, 660, 0),
  ('e0000001-0000-4000-8000-00000000003f', 'd0000001-0000-4000-8000-000000000012', 'c0000001-0000-4000-8000-000000000006',
   'js-level-3-check', 'Level 3 Check: Closures and Async',
   'Five questions on closures, promises and modules.',
   'quiz', 'published', 4, 540, 0),

  -- Level 4
  ('e0000001-0000-4000-8000-00000000003a', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'the-event-loop', 'The Event Loop',
   'Why setTimeout(fn, 0) runs after a promise, and what a microtask actually is.',
   'article', 'published', 1, 840, 0),
  ('e0000001-0000-4000-8000-00000000003b', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'iterators-and-generators', 'Iterators and Generators',
   'The protocol behind for...of, and functions that pause in the middle.',
   'article', 'published', 2, 780, 0),
  ('e0000001-0000-4000-8000-00000000003c', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'metaprogramming', 'Symbols, Proxies and Metaprogramming',
   'The hooks reactivity frameworks are built on, and when reaching for them is a mistake.',
   'article', 'published', 3, 840, 0),
  ('e0000001-0000-4000-8000-000000000040', 'd0000001-0000-4000-8000-000000000013', 'c0000001-0000-4000-8000-000000000006',
   'js-expert-exam', 'Expert Exam: JavaScript',
   'The event loop, generators and metaprogramming.',
   'quiz', 'published', 4, 900, 0)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), `position` = VALUES(`position`);

-- ---------------------------------------------------------------------------
-- Level 1 - Basic
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000031',
   'Values and Types',
   'markdown',
   '# Values and Types

JavaScript has seven primitive types and one object type. That is the whole
list, and knowing it settles most of the questions that look like language
quirks.

```javascript
// The seven primitives.
console.log(typeof "text");        // string
console.log(typeof 42);            // number  - one type for every number
console.log(typeof 42n);           // bigint  - for integers past 2^53
console.log(typeof true);          // boolean
console.log(typeof undefined);     // undefined
console.log(typeof Symbol("id"));  // symbol
console.log(typeof null);          // "object" - a bug from 1995, kept forever

// Everything else is an object, including arrays and functions.
console.log(typeof [1, 2], typeof {}, typeof console.log);

// --- Equality -------------------------------------------------------------
// == converts before comparing. === does not. Use === unless you have a
// reason you can say out loud.
console.log(0 == "");        // true  - both convert to 0
console.log(0 === "");       // false
console.log(null == undefined);   // true  - the one useful == case
console.log(null === undefined);  // false

// NaN is the only value not equal to itself, which is how isNaN works.
console.log(NaN === NaN);          // false
console.log(Object.is(NaN, NaN));  // true

// --- Truthiness -----------------------------------------------------------
// Exactly eight values are falsy. Everything else is truthy, including "0",
// an empty array and an empty object - which is the one that catches people.
const falsy = [false, 0, -0, 0n, "", null, undefined, NaN];
console.log("falsy count:", falsy.filter(Boolean).length);   // 0
console.log("empty array is truthy:", Boolean([]));          // true

// --- Nullish vs falsy -----------------------------------------------------
// || falls through on any falsy value. ?? only on null or undefined, which
// is what you almost always meant.
const count = 0;
console.log(count || 10);   // 10 - probably a bug
console.log(count ?? 10);   // 0  - probably what you wanted
```

## Numbers are all the same type

There is no int and no float. Every number is a 64-bit float, which is why
`0.1 + 0.2` is `0.30000000000000004` - the same in every language that uses
IEEE 754, JavaScript is just honest enough to print it. For money, work in
integer pence rather than fractional pounds.

`bigint` exists for integers beyond `Number.MAX_SAFE_INTEGER` (about nine
quadrillion). You cannot mix it with `number` in arithmetic, deliberately -
silent conversion would lose the precision you reached for bigint to keep.

## `typeof null` is `"object"`

It is a bug in the first implementation, kept because fixing it would break
the web. Check for null with `value === null`, never with `typeof`.

## The one rule worth memorising

**Use `===`.** The coercion table for `==` is large, mostly surprising, and
memorising it buys you nothing. The single exception is `== null`, which is a
neat way to catch both `null` and `undefined` at once.',
   'JavaScript has seven primitive types and one object type. That is the whole list, and knowing it settles most of the questions that look like language quirks.',
   6, 520, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000032',
   'Functions and Scope',
   'markdown',
   '# Functions and Scope

Three ways to write a function, and the differences between them are not
stylistic - they change when the function exists and what `this` means inside
it.

```javascript
// --- Three forms ----------------------------------------------------------
// A declaration is hoisted: it exists before the line that defines it.
console.log(declared(2));           // 4 - works
function declared(n) { return n * 2; }

// An expression is not. The variable is hoisted, the value is not.
try { expressed(2); } catch (e) { console.error(e.constructor.name); }
const expressed = function (n) { return n * 2; };

// An arrow is an expression too, and it has no `this` of its own.
const arrow = (n) => n * 2;
console.log(declared(3), expressed(3), arrow(3));

// --- Why that matters -----------------------------------------------------
const counter = {
  count: 0,
  // A method gets `this` from how it is called.
  incrementBroken: function () {
    [1, 2, 3].forEach(function () {
      // A plain function call: `this` is undefined in a module.
      // this.count += 1;   <- would throw
    });
  },
  // An arrow closes over the `this` of where it was written, which here is
  // the method. This is the single most useful thing about arrows.
  incrementWorks() {
    [1, 2, 3].forEach(() => { this.count += 1; });
  },
};

counter.incrementWorks();
console.log("count:", counter.count);   // 3

// --- Scope ----------------------------------------------------------------
// let and const are block-scoped. var is function-scoped, which is why this
// classic prints 3, 3, 3 with var and 0, 1, 2 with let.
const withLet = [];
for (let i = 0; i < 3; i++) withLet.push(() => i);
console.log(withLet.map((f) => f()));   // [0, 1, 2]

const withVar = [];
for (var j = 0; j < 3; j++) withVar.push(() => j);
console.log(withVar.map((f) => f()));   // [3, 3, 3]

// --- Parameters -----------------------------------------------------------
// Defaults are evaluated at call time, so this is a fresh array each call -
// unlike the shared-default bug the same code has in Python.
function addTo(item, list = []) {
  list.push(item);
  return list;
}
console.log(addTo(1), addTo(2));   // [1] [2]

// Rest gathers the remaining arguments into a real array.
const sum = (...numbers) => numbers.reduce((a, b) => a + b, 0);
console.log(sum(1, 2, 3, 4));
```

## Hoisting, precisely

Declarations are moved to the top of their scope. `function` declarations are
hoisted **with their body**, so you can call one above where it is written.
`let` and `const` are hoisted **without** their value, into what the spec calls
the temporal dead zone - touching one before its line throws a ReferenceError
rather than giving you `undefined`.

That last part is the improvement over `var`, which gives you `undefined` and
lets the bug travel somewhere else before it surfaces.

## `this`, in one rule

For a normal function, `this` is decided by **how it is called**, not where it
is written:

- `obj.method()` - `this` is `obj`
- `fn()` - `this` is `undefined` in a module, the global object otherwise
- `fn.call(x)` - `this` is `x`
- `new Fn()` - `this` is the new object

An arrow function has no `this` of its own and looks it up in the enclosing
scope, exactly like any other variable. That is why an arrow is right for a
callback inside a method, and wrong for a method itself.',
   'Three ways to write a function, and the differences are not stylistic - they change when the function exists and what this means inside it.',
   7, 600, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000033',
   'Arrays and Objects',
   'markdown',
   '# Arrays and Objects

Both are objects, and both are held by reference. That one fact explains the
first genuinely confusing bug most people write.

```javascript
// --- Reference semantics --------------------------------------------------
const a = { name: "Aisha" };
const b = a;            // not a copy - the same object
b.name = "Kenji";
console.log(a.name);    // "Kenji"

// const stops the binding being reassigned. It does not freeze the value.
const list = [1, 2];
list.push(3);           // fine
// list = [4];          // TypeError

// Object.freeze does stop it - one level deep.
const frozen = Object.freeze({ a: 1, nested: { b: 2 } });
frozen.a = 99;
frozen.nested.b = 99;   // not frozen
console.log(frozen.a, frozen.nested.b);   // 1 99

// --- Copying --------------------------------------------------------------
const original = { name: "Lena", scores: [1, 2] };

// Spread is a shallow copy: the top level is new, nested values are shared.
const shallow = { ...original };
shallow.scores.push(3);
console.log(original.scores);   // [1, 2, 3] - shared

// structuredClone is a real deep copy, and it is built in.
const deep = structuredClone(original);
deep.scores.push(4);
console.log(original.scores.length, deep.scores.length);   // 3 4

// --- Equality -------------------------------------------------------------
// Two objects are equal only if they are the same object.
console.log({ a: 1 } === { a: 1 });   // false
console.log([1] === [1]);             // false

// --- Useful shapes --------------------------------------------------------
// Object keys are always strings or symbols. A Map takes anything as a key
// and remembers insertion order.
const byUser = new Map();
const key = { id: 1 };
byUser.set(key, "Aisha");
console.log(byUser.get(key), byUser.size);

// Optional chaining and nullish coalescing together read the shape safely.
const config = { server: { port: 0 } };
console.log(config.server?.port ?? 8080);      // 0, not 8080
console.log(config.database?.host ?? "none");  // "none"

// Converting between objects and arrays.
const scores = { aisha: 92, kenji: 78 };
console.log(Object.entries(scores));
console.log(Object.fromEntries(Object.entries(scores).map(([k, v]) => [k, v + 5])));
```

## The bug this lesson exists to prevent

```javascript
const defaults = { retries: 3, tags: [] };

function makeConfig(overrides) {
  return { ...defaults, ...overrides };
}

const one = makeConfig({});
const two = makeConfig({});
one.tags.push("x");
console.log(two.tags);   // ["x"] - the same array
```

Spread copied the *reference* to `tags`, so both configs share one array. Use
`structuredClone(defaults)`, or build the default fresh each call.

## Arrays are objects with a length

`typeof [] === "object"`, which is why `Array.isArray()` exists. An array
index is really a string key - `arr[1]` and `arr["1"]` are the same property.
Setting a large index leaves holes rather than filling them:

```javascript
const sparse = [1];
sparse[5] = 6;
console.log(sparse.length, sparse);
```

Most array methods skip those holes. `Array.from({ length: n })` gives you a
dense array of `undefined` instead, which behaves the way you expect.',
   'Arrays and objects are both held by reference. That one fact explains the first genuinely confusing bug most people write.',
   7, 580, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 2 - Intermediate
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000034',
   'The Array Methods You Will Actually Use',
   'markdown',
   '# The Array Methods You Will Actually Use

Nine methods replace almost every loop you would otherwise write. The win is
not fewer characters - it is that the method name says what the loop is for
before you read the body.

```javascript
const orders = [
  { id: 1, customer: "Aisha", total: 42.50, status: "shipped" },
  { id: 2, customer: "Kenji", total: 18.00, status: "pending" },
  { id: 3, customer: "Aisha", total: 91.25, status: "shipped" },
  { id: 4, customer: "Lena",  total: 7.99,  status: "cancelled" },
];

// --- The three you will use most ------------------------------------------
// map: same length, each item transformed.
console.log(orders.map((o) => o.customer));

// filter: fewer items, each one unchanged.
const shipped = orders.filter((o) => o.status === "shipped");
console.log("shipped:", shipped.length);

// reduce: many items to one value. The second argument is the starting value,
// and leaving it off is the classic reduce bug - on an empty array it throws.
const revenue = shipped.reduce((sum, o) => sum + o.total, 0);
console.log("revenue:", revenue.toFixed(2));

// --- Finding things -------------------------------------------------------
console.log(orders.find((o) => o.total > 50));        // the item, or undefined
console.log(orders.findIndex((o) => o.id === 3));     // the index, or -1
console.log(orders.some((o) => o.status === "pending"));   // true
console.log(orders.every((o) => o.total > 5));             // true

// --- Grouping -------------------------------------------------------------
// reduce into an object is the general shape; Object.groupBy does the common
// case directly where it is available.
const byCustomer = orders.reduce((acc, o) => {
  (acc[o.customer] ??= []).push(o.id);
  return acc;
}, {});
console.log(byCustomer);

// --- Sorting: the trap ----------------------------------------------------
// sort() mutates, and with no comparator it sorts by STRING.
const numbers = [10, 9, 100, 1];
console.log([...numbers].sort());              // [1, 10, 100, 9]
console.log([...numbers].sort((a, b) => a - b)); // [1, 9, 10, 100]

// toSorted returns a new array and leaves the original alone.
console.log(numbers.toSorted((a, b) => b - a), numbers);

// --- Flattening -----------------------------------------------------------
const tags = [["a", "b"], ["c"], []];
console.log(tags.flat());
console.log(orders.flatMap((o) => (o.status === "shipped" ? [o.id] : [])));

// --- at() -----------------------------------------------------------------
// Negative indexes, without the length arithmetic.
console.log(orders.at(-1).customer);
```

## `reduce` deserves its reputation, but not always

`reduce` can express every other method on this page, which is exactly why it
is often the wrong choice: a reduce that is really a filter is harder to read
than a filter. Reach for it when you are genuinely collapsing many values into
one shape - a sum, a group, a lookup table - and reach for a named method
otherwise.

Always pass the initial value. Without it, `reduce` uses the first element as
the accumulator, which changes the type on a one-element array and throws
outright on an empty one.

## Mutating versus not

| Mutates | Returns a copy |
| --- | --- |
| `sort`, `reverse`, `splice` | `toSorted`, `toReversed`, `toSpliced` |
| `push`, `pop`, `shift`, `unshift` | `concat`, `slice`, `with` |

The left column changing the array under you is a real source of bugs in
shared state. `[...array].sort()` was the old workaround; `toSorted()` is the
same thing built in.

## Chaining costs a pass each

`filter().map().filter()` walks the array three times. For a few hundred items
that is free and the readability is worth it. For a million, one `reduce` or
one `for...of` does it in a single pass - measure before assuming you are in
the second case.',
   'Nine methods replace almost every loop you would write. The win is not fewer characters - it is that the method name says what the loop is for before you read the body.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000035',
   'Destructuring and Spread',
   'markdown',
   '# Destructuring and Spread

Two pieces of syntax that show up in nearly every modern JavaScript file. Both
are about moving values in and out of shapes without a pile of temporary
variables.

```javascript
// --- Destructuring objects ------------------------------------------------
const order = { id: 7, customer: "Aisha", address: { city: "Leeds" } };

const { id, customer } = order;
console.log(id, customer);

// Rename, default, and reach into a nested shape - all in one pattern.
const { customer: name, currency = "GBP", address: { city } } = order;
console.log(name, currency, city);

// Rest gathers whatever is left.
const { id: orderId, ...withoutId } = order;
console.log(withoutId);

// --- Destructuring arrays -------------------------------------------------
const scores = [92, 78, 85];
const [first, , third = 0] = scores;   // the hole skips one
console.log(first, third);

// Swapping, without a temporary.
let a = 1, b = 2;
[a, b] = [b, a];
console.log(a, b);

// --- In parameters --------------------------------------------------------
// Named arguments, effectively - and the = {} matters, or calling it with no
// argument throws rather than using the defaults.
function createOrder({ customer, total = 0, express = false } = {}) {
  return `${customer ?? "unknown"}: ${total} ${express ? "(express)" : ""}`.trim();
}
console.log(createOrder({ customer: "Kenji", total: 18 }));
console.log(createOrder());

// --- Spread ---------------------------------------------------------------
// Copying and merging. Later keys win, which is what makes overrides work.
const defaults = { retries: 3, timeout: 1000 };
console.log({ ...defaults, timeout: 5000 });

// Conditionally including a key, without an if.
const debug = true;
console.log({ ...defaults, ...(debug && { verbose: true }) });

// Arrays: concatenating and inserting.
console.log([0, ...scores, 100]);

// Spreading any iterable into an array - a string, a Set, a Map.
console.log([...new Set([1, 1, 2, 2, 3])]);   // deduplicated
console.log([..."hello"]);

// --- Rest in functions ----------------------------------------------------
const tally = (label, ...values) => `${label}: ${values.length} values`;
console.log(tally("scores", 1, 2, 3));
```

## Spread is shallow. Every time.

`{ ...original }` copies the top level and shares everything below it. This is
the single most common cause of "I changed the copy and the original changed
too". `structuredClone()` is the built-in deep copy.

## The `= {}` on a destructured parameter

```javascript
function f({ a } = {}) {}
f();    // fine
```

Without the `= {}` the call throws, because you cannot destructure
`undefined`. It costs four characters and turns a crash into a default.

## Where destructuring reads badly

Deeply nested patterns with renames and defaults all at once become
write-only:

```javascript
const { a: { b: { c: renamed = 1 } = {} } = {} } = input;
```

Two plain lines beat one clever one. Destructuring is for flattening a shape
you already understand, not for navigating one you do not.',
   'Two pieces of syntax that show up in nearly every modern JavaScript file. Both are about moving values in and out of shapes without a pile of temporary variables.',
   6, 560, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000036',
   'Classes and Prototypes',
   'markdown',
   '# Classes and Prototypes

`class` is syntax over the prototype system that was already there. Knowing
what it compiles to explains every behaviour that looks odd from the outside.

```javascript
class Account {
  // A private field. The # is part of the name, and it is enforced by the
  // language - not a convention like a leading underscore.
  #balance = 0;

  // A static field belongs to the class, not to an instance.
  static currency = "GBP";

  constructor(owner, opening = 0) {
    this.owner = owner;
    this.#balance = opening;
  }

  // A getter looks like a property from outside.
  get balance() { return this.#balance; }

  deposit(amount) {
    if (amount <= 0) throw new RangeError("Deposit must be positive");
    this.#balance += amount;
    return this;          // returning this makes calls chainable
  }

  toString() { return `${this.owner}: ${Account.currency}${this.#balance}`; }
}

const account = new Account("Aisha", 100);
account.deposit(50).deposit(25);
console.log(String(account));
console.log("balance:", account.balance);

// Genuinely private: not reachable, not enumerable, not in the JSON.
console.log(Object.keys(account));
try { console.log(account.#balance); } catch (e) { console.error("private"); }

// --- Inheritance ----------------------------------------------------------
class SavingsAccount extends Account {
  constructor(owner, opening, rate) {
    super(owner, opening);     // must come before any use of this
    this.rate = rate;
  }

  addInterest() {
    this.deposit(this.balance * this.rate);
    return this;
  }

  // Overriding, with a call up to the parent.
  toString() { return `${super.toString()} at ${this.rate * 100}%`; }
}

const savings = new SavingsAccount("Kenji", 1000, 0.05);
console.log(String(savings.addInterest()));
console.log(savings instanceof Account);

// --- What it is underneath ------------------------------------------------
// Methods live on the prototype, shared by every instance. Fields live on the
// instance. That is why a thousand accounts have one deposit function.
console.log(Object.getOwnPropertyNames(Account.prototype));
console.log(Object.getPrototypeOf(savings) === SavingsAccount.prototype);

// A class is a function with a flag that stops you calling it without new.
console.log(typeof Account);
try { Account("x"); } catch (e) { console.error(e.constructor.name); }
```

## Fields versus methods

A **method** is defined once, on the prototype, and shared. A **field** -
including an arrow function assigned to one - is created fresh on every
instance:

```javascript
class A {
  method() {}                 // one function, on A.prototype
  bound = () => {};           // a new function per instance
}
```

The arrow-function field is the idiom for a callback that needs a fixed
`this`, and the cost is one closure per instance. Fine for a few objects,
worth knowing about for thousands.

## `#private` is real

A `#field` is not accessible from outside the class body at all - not by
bracket notation, not by `Object.keys`, not through `JSON.stringify`. That is
different from `_underscore`, which is a request. It also means you cannot
feature-detect one with `in` unless you use the `#x in obj` form inside the
class.

## When not to use a class

If a thing has no state and no behaviour beyond one function, a function is
better. Classes earn their place when you have several instances that each
carry state and share behaviour. A "class" with only static methods is a
module with extra syntax.',
   'class is syntax over the prototype system that was already there. Knowing what it compiles to explains every behaviour that looks odd from the outside.',
   7, 620, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 3 - Advanced
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-000000000037',
   'Closures',
   'markdown',
   '# Closures

A closure is a function that remembers the scope it was created in, even after
that scope has finished. It sounds academic and it is behind most of the
JavaScript patterns you will read.

```javascript
// --- The idea -------------------------------------------------------------
function makeCounter(start = 0) {
  let count = start;                 // lives as long as the returned functions
  return {
    increment: () => ++count,
    value: () => count,
  };
}

const a = makeCounter();
const b = makeCounter(100);
a.increment(); a.increment();
b.increment();
console.log(a.value(), b.value());   // 2 101 - separate scopes

// count is unreachable from outside. This is encapsulation without a class.
console.log(Object.keys(a));

// --- The classic bug ------------------------------------------------------
// var is function-scoped, so all three closures share ONE i.
const withVar = [];
for (var i = 0; i < 3; i++) withVar.push(() => i);
console.log(withVar.map((f) => f()));    // [3, 3, 3]

// let creates a fresh binding per iteration.
const withLet = [];
for (let j = 0; j < 3; j++) withLet.push(() => j);
console.log(withLet.map((f) => f()));    // [0, 1, 2]

// --- Where you actually meet them -----------------------------------------
// A debounce: `timer` survives between calls because the returned function
// closes over it.
function debounce(fn, ms) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
}

const log = debounce((text) => console.log("ran:", text), 30);
log("first"); log("second"); log("third");   // only the last one runs

// A one-time initialiser.
function once(fn) {
  let called = false, result;
  return (...args) => {
    if (!called) { called = true; result = fn(...args); }
    return result;
  };
}
const init = once(() => { console.log("initialising"); return 42; });
console.log(init(), init(), init());

// A private cache.
function memoize(fn) {
  const cache = new Map();
  return (n) => {
    if (!cache.has(n)) cache.set(n, fn(n));
    return cache.get(n);
  };
}
let calls = 0;
const slow = memoize((n) => { calls++; return n * n; });
slow(4); slow(4); slow(4);
console.log("computed once:", calls);
```

## What is actually kept

A closure keeps the **variable**, not a copy of its value. Two functions
closing over the same variable see each other''s changes:

```javascript
function pair() {
  let n = 0;
  return [() => ++n, () => n];
}
const [bump, read] = pair();
bump(); bump();
console.log(read());   // 2
```

That sharing is the feature in `makeCounter` and the bug in the `var` loop.
They are the same mechanism.

## Memory

A closure keeps its enclosing scope alive for as long as the function lives.
Usually that is a few variables and irrelevant. It matters when the closure
outlives what it captured - an event listener that closes over a large object
and is never removed keeps that object in memory for the life of the page.
Remove listeners you add, and the problem disappears.

## Every function is a closure

Strictly, all of them - a function that uses no outer variables just closes
over nothing interesting. The word describes a relationship, not a special
kind of function.',
   'A closure is a function that remembers the scope it was created in, even after that scope has finished. It sounds academic and it is behind most of the patterns you will read.',
   7, 600, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000038',
   'Promises and async/await',
   'markdown',
   '# Promises and async/await

A promise is a value that is not there yet. `async`/`await` is syntax that
lets you write code that waits for one without nesting callbacks.

```javascript
const wait = (ms, value) => new Promise((resolve) => setTimeout(() => resolve(value), ms));
const fail = (ms, message) => new Promise((_, reject) => setTimeout(() => reject(new Error(message)), ms));

// --- Sequential vs parallel -----------------------------------------------
// Each await waits for the one before. Three waits of 40ms takes 120ms.
console.time("sequential");
await wait(40, "a"); await wait(40, "b"); await wait(40, "c");
console.timeEnd("sequential");

// Started together, awaited together: 40ms in total.
console.time("parallel");
await Promise.all([wait(40, "a"), wait(40, "b"), wait(40, "c")]);
console.timeEnd("parallel");

// This is the mistake worth remembering: awaiting inside a loop makes
// everything sequential, usually without meaning to.

// --- Which combinator -----------------------------------------------------
// all: every one, or the first rejection - and the rest keep running.
try {
  await Promise.all([wait(10, "ok"), fail(20, "boom")]);
} catch (error) {
  console.error("all rejected:", error.message);
}

// allSettled: never rejects. Reports what happened to each.
const settled = await Promise.allSettled([wait(10, "ok"), fail(20, "boom")]);
console.log(settled.map((s) => s.status));

// race: the first to settle either way.
console.log("race:", await Promise.race([wait(10, "fast"), wait(50, "slow")]));

// any: the first to SUCCEED, ignoring earlier failures.
console.log("any:", await Promise.any([fail(10, "no"), wait(30, "yes")]));

// --- Errors ---------------------------------------------------------------
async function risky() { throw new Error("inside"); }

// An async function never throws synchronously - it returns a rejected
// promise. This try/catch catches nothing:
try { risky(); } catch { console.log("never runs"); }

// This one does.
try { await risky(); } catch (e) { console.error("caught:", e.message); }

// --- Timeouts -------------------------------------------------------------
const withTimeout = (promise, ms) =>
  Promise.race([promise, fail(ms, `Timed out after ${ms}ms`)]);

try {
  await withTimeout(wait(200, "slow"), 50);
} catch (error) {
  console.error(error.message);
}
```

## The three states

A promise is **pending**, then either **fulfilled** or **rejected**. It settles
once and never changes again. Calling `resolve` twice is not an error - the
second call does nothing.

## `await` in a loop is usually a bug

```javascript
for (const id of ids) { await fetchOne(id); }        // one at a time
await Promise.all(ids.map(fetchOne));                 // all at once
```

The first is right when each step depends on the last, or when you are
deliberately rate-limiting. Otherwise it turns a 100ms operation into a
10-second one.

## An async function always returns a promise

Even `async function f() { return 1; }` returns a promise for `1`. That means
a caller who forgets `await` gets a Promise object where they expected a
number - which usually shows up as `[object Promise]` in a string, or as
`undefined` after a property access.

## Unhandled rejections

A rejected promise nobody catches raises an `unhandledrejection` event and, in
Node, can end the process. `Promise.allSettled` is the tool when you genuinely
want to continue past a failure - and every `catch` should either handle the
error or rethrow it, never swallow it silently.',
   'A promise is a value that is not there yet. async/await is syntax that lets you write code that waits for one without nesting callbacks.',
   8, 680, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-000000000039',
   'Modules',
   'markdown',
   '# Modules

A module is a file with its own scope. Nothing leaks out unless you export it,
nothing comes in unless you import it, and the file runs exactly once however
many times it is imported.

```javascript
// This playground is itself a module, which is why top-level await works
// here and would not in a classic script.

// --- What module scope means ----------------------------------------------
// Nothing here becomes a global. In a classic script, `const` at the top
// level would still be reachable from another script on the page.
const notGlobal = "scoped to this file";
console.log(typeof globalThis.notGlobal);   // undefined

// Modules are always strict mode - you cannot opt out.
try {
  undeclared = 1;
} catch (error) {
  console.error(error.constructor.name);    // ReferenceError
}

// `this` at the top level of a module is undefined, not the global object.
console.log("top-level this:", this);

// --- Dynamic import -------------------------------------------------------
// A static import is hoisted and resolved before any code runs. import() is
// a function that returns a promise, so it can be conditional and lazy.
// Nothing to import from in this playground, so this shows the failure path.
try {
  await import("./a-module-that-does-not-exist.js");
} catch (error) {
  console.error("dynamic import failed, as expected");
}

// --- Live bindings, demonstrated locally ----------------------------------
// An import is a live view of the exporting module''s binding, not a copy of
// its value at import time. The closure below behaves the same way.
function makeModule() {
  let counter = 0;
  return { increment: () => ++counter, get value() { return counter; } };
}
const mod = makeModule();
mod.increment();
console.log("live binding:", mod.value);
```

## The syntax, in one place

```javascript
// Named exports - as many as you like.
export const VERSION = "1.0";
export function parse(text) { return text.trim(); }

// A default export - at most one.
export default class Parser {}

// Re-exporting, to build a public surface from several files.
export { parse as parseText } from "./parse.js";
export * from "./helpers.js";
```

```javascript
import Parser, { VERSION, parse as parseText } from "./parser.js";
import * as parser from "./parser.js";
const lazy = await import("./heavy.js");     // only when needed
```

## Imports are hoisted and static

Every `import` is resolved before any code in the file runs, which is why they
cannot be conditional:

```javascript
if (needed) { import "./x.js"; }   // SyntaxError
if (needed) { await import("./x.js"); }   // fine
```

That staticness is what lets a bundler tree-shake: it can see which exports
are used without running anything.

## A module runs once

Import the same file from ten places and its top-level code runs once. The
module registry caches it by resolved URL. That makes a module a natural
singleton - and means top-level side effects happen at a time you do not
control, which is why keeping them out of module top level is worth the
discipline.

## Named or default

Prefer named exports. They are checked at build time, they refactor by name,
and they cannot be silently renamed at the import site the way a default can.
A default export is worth it when a file genuinely has one subject.',
   'A module is a file with its own scope. Nothing leaks out unless you export it, and the file runs exactly once however many times it is imported.',
   7, 600, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

-- ---------------------------------------------------------------------------
-- Level 4 - Expert
-- ---------------------------------------------------------------------------
INSERT INTO content.articles
  (lesson_id, title, format, body, excerpt, reading_time_minutes, word_count,
   author_id, status, published_at)
VALUES
  ('e0000001-0000-4000-8000-00000000003a',
   'The Event Loop',
   'markdown',
   '# The Event Loop

JavaScript runs on one thread. Everything asynchronous is a queue of work that
thread picks up when it has finished what it is doing. Once you can see the
queues, ordering stops being surprising.

```javascript
// Run this and predict the order before you read the explanation below.
console.log("1 sync");

setTimeout(() => console.log("5 macrotask (setTimeout 0)"), 0);

Promise.resolve().then(() => console.log("3 microtask"));

queueMicrotask(() => console.log("4 microtask (queued second)"));

console.log("2 sync");

// Output: 1, 2, 3, 4, 5
// Every synchronous line runs first. Then EVERY microtask. Only then the
// first macrotask.
```

```javascript
// --- Microtasks starve macrotasks -----------------------------------------
// The microtask queue is drained completely before the next macrotask. A
// microtask that queues another microtask keeps the loop from ever moving on.
let depth = 0;
function recurse() {
  if (depth++ < 3) {
    Promise.resolve().then(recurse);
    console.log("microtask depth", depth);
  }
}
setTimeout(() => console.log("macrotask, after all of them"), 0);
recurse();
```

```javascript
// --- await is a microtask boundary ----------------------------------------
async function run() {
  console.log("A: runs synchronously up to the first await");
  await null;                     // yields here, even awaiting a non-promise
  console.log("C: resumes as a microtask");
}
run();
console.log("B: runs before C");

// --- Blocking the thread --------------------------------------------------
// Nothing else happens while this loop runs - no timers, no clicks, no
// rendering. This is what "JavaScript is single-threaded" costs you.
const start = Date.now();
setTimeout(() => console.log("timer waited", Date.now() - start, "ms for a 0ms delay"), 0);
while (Date.now() - start < 50) { /* deliberately blocking */ }
console.log("blocked for 50ms");
```

## The order, precisely

1. Run the current synchronous code to completion.
2. Drain the **entire** microtask queue - promise callbacks, `queueMicrotask`,
   `MutationObserver`. Anything queued during this step is also drained.
3. Render, if the browser decides to.
4. Take **one** macrotask - a timer, an I/O callback, an event handler.
5. Back to step 2.

## `setTimeout(fn, 0)` is not zero

It means "queue this as a macrotask", which is after all pending microtasks
and after the current task finishes. The HTML spec also clamps nested timeouts
to 4ms after five levels of nesting.

## Why this matters in practice

- **A long loop freezes the page.** Not slows - freezes. No clicks, no
  animation, no rendering. Break long work into chunks or move it to a Worker.
- **A microtask loop is worse than a slow function**, because it never yields
  at all. `await` inside a `while (true)` over already-resolved promises will
  hang the tab.
- **State can change between two `await`s.** The lines are adjacent; the
  execution is not. Anything you read before an await may be stale after it.

## Node and the browser differ

Node adds `process.nextTick` (drained before other microtasks) and phases for
timers, I/O and `setImmediate`. The sync-then-microtask-then-macrotask shape is
the same; the detail below it is not portable. Code that depends on the finer
ordering is code that will break when it moves.',
   'JavaScript runs on one thread. Everything asynchronous is a queue of work that thread picks up when it has finished. Once you can see the queues, ordering stops being surprising.',
   8, 660, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-00000000003b',
   'Iterators and Generators',
   'markdown',
   '# Iterators and Generators

`for...of` works on anything that follows one small protocol. A generator is a
function that can pause in the middle, and it implements that protocol for
free.

```javascript
// --- The protocol ---------------------------------------------------------
// An iterable has a [Symbol.iterator] method returning an iterator: an object
// with next() returning { value, done }.
const range = {
  from: 1,
  to: 4,
  [Symbol.iterator]() {
    let current = this.from;
    const last = this.to;
    return {
      next: () => (current <= last ? { value: current++, done: false } : { value: undefined, done: true }),
    };
  },
};

console.log([...range]);                    // spread uses it
for (const n of range) process.stdout;      // so does for...of
console.log(Math.max(...range));            // and so does every spread call

// --- A generator does the same, far more briefly --------------------------
function* rangeGen(from, to) {
  for (let n = from; n <= to; n++) yield n;   // pauses here, resumes on next()
}
console.log([...rangeGen(1, 4)]);

// --- Pausing is the point -------------------------------------------------
function* counter() {
  let n = 0;
  while (true) {
    // The value passed to next() becomes the result of this yield.
    const reset = yield ++n;
    if (reset) n = 0;
  }
}
const c = counter();
console.log(c.next().value, c.next().value, c.next().value);   // 1 2 3
console.log(c.next(true).value);                                // 1 - reset
```

```javascript
// --- Lazy, and therefore infinite -----------------------------------------
// Nothing is computed until it is asked for, so an infinite sequence is fine
// as long as you stop taking from it.
function* naturals() { let n = 1; while (true) yield n++; }

function* take(iterable, count) {
  let taken = 0;
  for (const item of iterable) {
    if (taken++ >= count) return;
    yield item;
  }
}

function* map(iterable, fn) { for (const item of iterable) yield fn(item); }

console.log([...take(map(naturals(), (n) => n * n), 6)]);

// --- Delegating -----------------------------------------------------------
function* inner() { yield "b"; yield "c"; }
function* outer() { yield "a"; yield* inner(); yield "d"; }
console.log([...outer()]);

// --- Async iteration ------------------------------------------------------
// for await...of, over a sequence that arrives over time.
async function* pages() {
  for (let page = 1; page <= 3; page++) {
    await new Promise((r) => setTimeout(r, 10));
    yield { page, items: [page * 10, page * 10 + 1] };
  }
}
for await (const { page, items } of pages()) {
  console.log("page", page, items);
}
```

## What you already use it for

Every one of these goes through the iterator protocol: `for...of`, spread,
array destructuring, `Array.from`, `Promise.all`, `new Map(pairs)`,
`yield*`. Implementing `[Symbol.iterator]` on your own type makes it work with
all of them at once.

## Generators are lazy

`[...rangeGen(1, 1e9)]` will exhaust memory, because spread asks for
everything. `take(rangeGen(1, 1e9), 5)` costs five iterations. That laziness is
the reason to reach for a generator over an array-returning function: the
consumer decides how much work happens.

## `return` and `throw`

An iterator may implement `return()`, called when a `for...of` exits early via
`break` or an exception. In a generator that runs the `finally` block, which is
where cleanup belongs:

```javascript
function* withCleanup() {
  try { yield 1; yield 2; }
  finally { console.log("cleaned up"); }
}
for (const n of withCleanup()) { break; }   // prints "cleaned up"
```

## When not to reach for one

For a fixed, small collection an array is simpler, faster and easier to debug.
Generators pay off for sequences that are infinite, expensive per item, or
genuinely streamed - and for state machines, where pausing mid-function is the
clearest way to express the steps.',
   'for...of works on anything that follows one small protocol. A generator is a function that can pause in the middle, and it implements that protocol for free.',
   8, 640, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY)),

  ('e0000001-0000-4000-8000-00000000003c',
   'Symbols, Proxies and Metaprogramming',
   'markdown',
   '# Symbols, Proxies and Metaprogramming

The hooks that let you change what the language itself does to your objects.
Every reactivity framework of the last decade is built on them, and most
application code should not use them at all.

```javascript
// --- Symbols: keys that cannot collide ------------------------------------
const id = Symbol("id");
const user = { name: "Aisha", [id]: 42 };

// Invisible to every normal enumeration - which is the point.
console.log(Object.keys(user), JSON.stringify(user));
console.log(user[id]);

// Well-known symbols are how you hook into language operations.
class Temperature {
  constructor(deg) { this.deg = deg; }
  [Symbol.toPrimitive](hint) {
    return hint === "number" ? this.deg : `${this.deg} degrees`;
  }
  get [Symbol.toStringTag]() { return "Temperature"; }
}
const t = new Temperature(21);
console.log(+t, `${t}`, Object.prototype.toString.call(t));

// --- Proxy: intercepting operations ---------------------------------------
const target = { a: 1 };

const observed = new Proxy(target, {
  get(obj, key, receiver) {
    if (!(key in obj) && typeof key === "string") {
      console.warn("read of missing key:", key);
    }
    return Reflect.get(obj, key, receiver);
  },
  set(obj, key, value, receiver) {
    console.log("set", key, "=", value);
    return Reflect.set(obj, key, value, receiver);
  },
  deleteProperty(obj, key) {
    console.log("delete", key);
    return Reflect.deleteProperty(obj, key);
  },
});

observed.b = 2;
observed.missing;
delete observed.a;
console.log(target);

// --- Why Reflect ----------------------------------------------------------
// Reflect gives the default behaviour of each trap, with the correct
// receiver. Writing obj[key] = value directly inside a set trap breaks
// getters and setters further up the prototype chain.

// --- A defaulting dictionary ----------------------------------------------
const counts = new Proxy({}, {
  get: (obj, key) => (key in obj ? obj[key] : 0),
});
counts.hits += 1;
counts.hits += 1;
console.log(counts.hits, counts.misses);   // 2 0
```

## What reactivity frameworks do with this

Vue 3 wraps your state in a `Proxy`. The `get` trap records which component is
reading which key; the `set` trap looks up the components that read that key
and re-renders them. That is the whole idea - the rest is scheduling.

Knowing that explains its limits: a proxy sees property access, so anything
that does not go through property access is invisible to it. That is why
frameworks used to need special array methods before proxies, and why
replacing a whole object breaks the link unless the framework re-wraps it.

## `Reflect` is not optional

Every trap has a matching `Reflect` method giving the default behaviour. Use
it rather than hand-writing the default:

- `Reflect.get(obj, key, receiver)` respects getters on the prototype chain
  and passes the right `this`. `obj[key]` does not.
- `Reflect.set` returns a boolean instead of throwing in strict mode, which
  is what a `set` trap must return.

## The invariants you cannot break

A proxy cannot lie about a non-configurable, non-writable property - report a
different value for one and the engine throws a TypeError rather than
believing you. The rules exist so that code holding a reference to a frozen
object can still trust it.

## When to use any of this

**Symbols:** when you need a key on someone else''s object that cannot collide
and should not show up in their loops. Rare, and correct when it happens.

**Proxies:** for building a framework, a mock, a validation layer, or an
observable store. They cost a lot of performance per access and turn a plain
object into something a debugger shows unhelpfully. If the answer is a getter
or a `Map`, use that instead.',
   'The hooks that let you change what the language does to your objects. Every reactivity framework of the last decade is built on them, and most application code should not use them.',
   8, 660, '55555555-5555-4555-8555-555555555555', 'published',
   DATE_SUB(UTC_TIMESTAMP(3), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE
  title = VALUES(title), body = VALUES(body), body_html = NULL,
  excerpt = VALUES(excerpt), revision = content.articles.revision + 1;

CALL catalog.refresh_course_rollup('c0000001-0000-4000-8000-000000000006');
