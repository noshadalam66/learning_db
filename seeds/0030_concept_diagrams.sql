-- ===========================================================================
-- Seed 30 : the concept diagrams
--
-- The platform used to teach with video. It does not any more: the first
-- lesson of every course now opens with a diagram of how the pieces fit
-- together - how markup becomes a styled page, how a request reaches a
-- database and comes back - and the lessons that had a video have one too.
--
-- They live in one file rather than in each course seed because a diagram is
-- not part of a course's identity the way its lessons and levels are. It
-- points at a lesson by id, it is the same shape for every subject, and
-- keeping them together means the next one is written by copying the row
-- above it rather than by finding the right course file first.
--
-- A diagram is DATA: nodes and the edges between them. The website draws the
-- picture. Nothing here is markup, so nothing here needs sanitising - see
-- migration 0014, and views/partials/diagram.php in learning_website.
-- ===========================================================================

INSERT INTO content_lesson_diagrams (lesson_id, title, alt, caption, spec, `position`) VALUES
  ('e0000001-0000-4000-8000-000000000011',
   'How a page reaches the screen',
   'An HTML document is parsed by the browser into a DOM tree, CSS rules are matched against that tree to decide colour, spacing and layout, and the result is painted as the page a reader sees.',
   'HTML says what things are. CSS says what they look like. The browser does the rest, in that order.',
   '{"nodes": [{"label": "HTML document", "note": "Your markup: headings, paragraphs, links, images"}, {"label": "The DOM", "note": "A tree of elements the browser built from your tags"}, {"label": "CSS rules", "note": "Matched to those elements: colour, spacing, layout"}, {"label": "Rendered page", "note": "What the reader actually sees"}], "edges": [{"label": "parsed into"}, {"label": "styled by"}, {"label": "painted as"}]}', 1),

  ('e0000001-0000-4000-8000-00000000001d',
   'Where a style comes from',
   'A selector matches an element, the cascade and specificity decide which of the competing rules wins, that produces one computed value per property, and the browser lays out and paints a box from those values.',
   'Every CSS surprise is one of these four steps answering differently from how you expected.',
   '{"nodes": [{"label": "Selector", "note": "Which elements this rule is talking about"}, {"label": "Cascade", "note": "Which rule wins when several match"}, {"label": "Computed value", "note": "One final value per property, per element"}, {"label": "A box on screen", "note": "Laid out, then painted"}], "edges": [{"label": "matches"}, {"label": "resolved by"}, {"label": "laid out as"}]}', 1),

  ('e0000001-0000-4000-8000-000000000031',
   'What runs when',
   'JavaScript runs one function at a time on a call stack. Work that waits, such as a timer or a network call, is handed to the browser and its result is queued; the event loop puts it back on the stack only once the stack is empty.',
   'One thread, one stack, and a queue. This is why a slow loop freezes the page and a slow fetch does not.',
   '{"nodes": [{"label": "Your code", "note": "One function at a time, on the call stack"}, {"label": "The browser", "note": "Timers, fetch, events - work that waits"}, {"label": "The queue", "note": "Results lining up to be dealt with"}, {"label": "The event loop", "note": "Puts them back on the stack, when it is empty"}], "edges": [{"label": "hands off to"}, {"label": "finishes into"}, {"label": "drained by"}]}', 1),

  ('e0000001-0000-4000-8000-000000000041',
   'What TypeScript actually does',
   'TypeScript source is checked against its types before anything runs, errors are reported at that point, and then the types are erased to leave ordinary JavaScript for the runtime to execute.',
   'The types never reach the runtime. Everything they buy you, they buy before the program starts.',
   '{"nodes": [{"label": "TypeScript source", "note": "Your code, with types on top"}, {"label": "The type checker", "note": "Mistakes found before the program runs"}, {"label": "Plain JavaScript", "note": "Types erased - nothing left of them"}, {"label": "The runtime", "note": "Browser or Node, which never sees a type"}], "edges": [{"label": "checked by"}, {"label": "compiled to"}, {"label": "executed by"}]}', 1),

  ('e0000001-0000-4000-8000-000000000051',
   'From source to output',
   'Python source is compiled to bytecode, the interpreter executes that bytecode on its virtual machine, and the standard library and your dependencies are available throughout.',
   'Python is compiled - just not to machine code. Knowing that explains both its speed and its flexibility.',
   '{"nodes": [{"label": "Your .py file", "note": "Source, read top to bottom"}, {"label": "Bytecode", "note": "Compiled automatically, cached in __pycache__"}, {"label": "The interpreter", "note": "CPython, running that bytecode step by step"}, {"label": "Output", "note": "What your program prints, writes or returns"}], "edges": [{"label": "compiled to"}, {"label": "executed by"}, {"label": "produces"}]}', 1),

  ('e0000001-0000-4000-8000-000000000061',
   'A request, a script and a database',
   'A browser requests a page, the web server hands it to PHP, the script queries the database and builds HTML from the rows, and that HTML is what travels back to the browser.',
   'This is the whole shape of a PHP application. Everything in this course is one of these four boxes.',
   '{"nodes": [{"label": "Browser", "note": "Asks for a page, with cookies and form data"}, {"label": "PHP", "note": "Your script: validate, decide, fetch"}, {"label": "Database", "note": "Rows, fetched with parameterised SQL"}, {"label": "HTML back", "note": "Built from those rows, escaped on the way out"}], "edges": [{"label": "requests"}, {"label": "queries"}, {"label": "rendered as"}]}', 1),

  ('e0000001-0000-4000-8000-00000000006d',
   'Everything is an object',
   'In Ruby a value is an object, calling a method is sending it a message, and the method is found by walking the chain of classes and modules the object inherits from until one answers.',
   'Once you see method calls as messages, Ruby stops looking like special cases.',
   '{"nodes": [{"label": "A value", "note": "Numbers, strings, nil - all objects"}, {"label": "A message", "note": "The method name you send it"}, {"label": "The ancestors", "note": "Class, then its modules, then its parent"}, {"label": "The answer", "note": "The first method found, and its value"}], "edges": [{"label": "sent"}, {"label": "looked up through"}, {"label": "returns"}]}', 1),

  ('e0000001-0000-4000-8000-000000000091',
   'Compile once, run anywhere',
   'Java source is compiled by javac into class files of bytecode, and the Java virtual machine runs that bytecode, compiling the hot parts to native code while the program runs.',
   'The JVM is the reason the same jar runs on your laptop and on the server, and the reason a long-running program gets faster.',
   '{"nodes": [{"label": "Your .java file", "note": "Source, with its types checked by the compiler"}, {"label": "Bytecode", "note": "A .class file - portable, not machine code"}, {"label": "The JVM", "note": "Runs it, and compiles the hot paths as it goes"}, {"label": "A running program", "note": "On any machine with a JVM"}], "edges": [{"label": "compiled by javac to"}, {"label": "loaded by"}, {"label": "becomes"}]}', 1),

  ('e0000001-0000-4000-8000-0000000000a1',
   'From C# to something that runs',
   'C# is compiled to intermediate language in an assembly, the runtime loads that assembly and compiles it to native code as it runs, with the garbage collector managing memory throughout.',
   'Nothing here is specific to Windows any more, and the GC is the part worth understanding early.',
   '{"nodes": [{"label": "Your .cs file", "note": "Source, checked including nullability"}, {"label": "IL in an assembly", "note": "A .dll - portable intermediate language"}, {"label": "The runtime", "note": "Compiles IL to native code as it runs"}, {"label": "A running program", "note": "With a garbage collector behind it"}], "edges": [{"label": "compiled to"}, {"label": "JIT-compiled by"}, {"label": "becomes"}]}', 1),

  ('e0000001-0000-4000-8000-0000000000b1',
   'One command, one binary',
   'Go source is compiled into a single static binary that carries its own runtime, so deployment is a file copy, and that runtime schedules goroutines onto operating system threads.',
   'No interpreter to install and no runtime to match. This is most of why Go ended up in containers.',
   '{"nodes": [{"label": "Your .go files", "note": "Source, with no implicit conversions"}, {"label": "go build", "note": "One command, no build file to maintain"}, {"label": "A static binary", "note": "Carries its own runtime - copy it and run it"}, {"label": "Goroutines", "note": "Thousands of them, scheduled onto a few threads"}], "edges": [{"label": "compiled by"}, {"label": "produces"}, {"label": "which schedules"}]}', 1),

  ('e0000001-0000-4000-8000-0000000000c1',
   'Checked before it runs',
   'Rust source is checked by the borrow checker, which proves at compile time that no value is used after it is freed and no data is shared unsafely across threads, and the compiler then produces a binary that needs no garbage collector.',
   'The compiler argues with you once so the program does not crash later. That trade is the language.',
   '{"nodes": [{"label": "Your .rs file", "note": "Source, with ownership written into the types"}, {"label": "The borrow checker", "note": "Proves no use-after-free, no data race"}, {"label": "Optimised binary", "note": "No garbage collector, no runtime to ship"}, {"label": "Predictable speed", "note": "Memory freed exactly where it goes out of scope"}], "edges": [{"label": "proved by"}, {"label": "compiled to"}, {"label": "runs with"}]}', 1),

  ('e0000001-0000-4000-8000-000000000081',
   'One source, two compilers',
   'Dart source is compiled just in time during development, which is what makes hot reload possible, and ahead of time for release, which produces fast native code.',
   'The same code, compiled two different ways depending on whether you are writing it or shipping it.',
   '{"nodes": [{"label": "Your .dart file", "note": "Source, with sound null safety"}, {"label": "JIT, while you work", "note": "Compiled on the fly - this is hot reload"}, {"label": "AOT, for release", "note": "Compiled ahead of time to native code"}, {"label": "A fast app", "note": "No warm-up, no interpreter in the shipped build"}], "edges": [{"label": "compiled either"}, {"label": "or"}, {"label": "giving"}]}', 1),

  ('e0000001-0000-4000-8000-000000000001',
   'One deployment, or several',
   'A monolith is one deployable unit containing every module; splitting it makes each module its own service with its own deployment, reached over the network through a gateway, which trades deployment coupling for network calls.',
   'Neither shape is right by default. The course is about which costs you less, and when.',
   '{"nodes": [{"label": "One deployment", "note": "Every module, shipped together, calling in memory"}, {"label": "A gateway", "note": "One front door once there is more than one service"}, {"label": "Several services", "note": "Each deployed on its own schedule"}, {"label": "A network between them", "note": "The cost you just took on"}], "edges": [{"label": "split into"}, {"label": "routing to"}, {"label": "with"}]}', 1),

  ('e0000001-0000-4000-8000-000000000004',
   'What a request passes through',
   'A request arrives at a route, the controller validates it and calls one service method, the service applies the rules and asks a repository for data, and the repository is the only layer that talks to the database.',
   'Three layers, one direction. Every rule in this module follows from that.',
   '{"nodes": [{"label": "Request", "note": "A method, a path, a body"}, {"label": "Route and controller", "note": "Validate, then call one service method"}, {"label": "Service", "note": "The rules - and no idea what HTTP is"}, {"label": "Repository", "note": "The only layer that writes SQL"}], "edges": [{"label": "matched by"}, {"label": "calls"}, {"label": "asks"}]}', 1),

  ('e0000001-0000-4000-8000-000000000006',
   'Where SQL is allowed to live',
   'The service layer asks a repository for data, the repository runs parameterised SQL through the driver, and turns the rows that come back into domain objects before anything above it sees them.',
   'Rows stop at the repository. What leaves it is your own types, which is what makes the database swappable.',
   '{"nodes": [{"label": "Service", "note": "Knows the rules, not the schema"}, {"label": "Repository", "note": "Parameterised SQL, and nothing else"}, {"label": "Database", "note": "Returns driver rows"}, {"label": "Domain objects", "note": "What the service actually receives"}], "edges": [{"label": "asks"}, {"label": "queries"}, {"label": "mapped into"}]}', 1),

  ('e0000001-0000-4000-8000-000000000007',
   'What the gateway adds',
   'The gateway verifies the caller token once, mints a request id, forwards the identity to the service as trusted headers, and the same request id travels down every hop so one trace covers the whole call.',
   'Verify once, trace everywhere. Both of those are hard to add later.',
   '{"nodes": [{"label": "Client", "note": "One address to call, whatever is behind it"}, {"label": "Gateway", "note": "Verifies the token, mints a request id"}, {"label": "Service", "note": "Trusts the identity headers it was handed"}, {"label": "Response", "note": "Carrying the same request id back"}], "edges": [{"label": "calls"}, {"label": "forwards to"}, {"label": "returns"}]}', 1),

  ('e0000001-0000-4000-8000-000000000009',
   'From a brief to tables',
   'The nouns in a product brief become tables, the relationships between them become foreign keys or join tables, and the constraints that make invalid data impossible are written into the schema rather than left to the application.',
   'Crude, and it gets you most of a schema. The refining is the rest of this module.',
   '{"nodes": [{"label": "The brief", "note": "Plain English: courses, learners, quizzes"}, {"label": "Nouns", "note": "Each one is probably a table"}, {"label": "Relationships", "note": "Foreign keys, or a join table for many to many"}, {"label": "Constraints", "note": "The rules the database itself will enforce"}], "edges": [{"label": "underline the"}, {"label": "joined by"}, {"label": "guarded by"}]}', 1),

  ('e0000001-0000-4000-8000-00000000000b',
   'What EXPLAIN is telling you',
   'A query is parsed, the optimiser picks an access path using the indexes and statistics available, the storage engine examines some number of rows, and EXPLAIN shows you that plan before you wait for the query itself.',
   'The row count is the number to read first. The time follows from it.',
   '{"nodes": [{"label": "Your query", "note": "What you asked for"}, {"label": "The optimiser", "note": "Picks a plan from the indexes it has"}, {"label": "Rows examined", "note": "How much work that plan actually costs"}, {"label": "The result", "note": "Fast or slow, decided three boxes ago"}], "edges": [{"label": "planned by"}, {"label": "measured in"}, {"label": "producing"}]}', 1),

  ('e0000001-0000-4000-8000-00000000000e',
   'A page without a framework',
   'A PHP page fetches what it needs from a JSON API, shapes that data, and includes a template whose only job is markup and escaped output, which is sent to the browser as HTML.',
   'Fetch, shape, then render. Keeping those three apart is the whole discipline.',
   '{"nodes": [{"label": "PHP page", "note": "Decides what this URL needs"}, {"label": "JSON API", "note": "Where the data actually comes from"}, {"label": "Template", "note": "Markup and escaped echoes - no logic"}, {"label": "HTML", "note": "What the browser receives"}], "edges": [{"label": "calls"}, {"label": "passed to"}, {"label": "rendered as"}]}', 1),

  ('e0000001-0000-4000-8000-000000000010',
   'How a form proves it is yours',
   'A session cookie identifies the browser, the server renders a form carrying a token it also stored in that session, and when the form is submitted the two are compared so a request forged by another site cannot pass.',
   'The cookie says who. The token says that this form came from a page you rendered.',
   '{"nodes": [{"label": "Session cookie", "note": "HttpOnly, Secure, SameSite - says who this is"}, {"label": "Your form", "note": "Rendered with a token from that session"}, {"label": "The submission", "note": "Carries the token back in a hidden field"}, {"label": "The check", "note": "Compared on the server, or rejected"}], "edges": [{"label": "identifies"}, {"label": "posted as"}, {"label": "verified by"}]}', 1)
ON DUPLICATE KEY UPDATE
  title = VALUES(title), alt = VALUES(alt),
  caption = VALUES(caption), spec = VALUES(spec);
