# Importing content into the live cPanel database

`dist/content.sql` is the file to import whenever courses have been written or
rewritten. It carries content and no schema: no `CREATE TABLE`, no migration,
and nothing that drops, truncates or deletes. Every insert is
`ON DUPLICATE KEY UPDATE`, so importing it twice changes nothing the second
time.

Nothing needs running afterwards. Paths below are from the repository root.

| File | Size | What it does |
| --- | --- | --- |
| `dist/content.sql` | 495 KB | The HTML course as thirty topics in five modules, plus its quizzes. |

A gzipped copy sits beside it (`.sql.gz`) when one has been built. phpMyAdmin
detects and decompresses those itself, so use one if the upload box rejects the
plain file.

## The steps

1. Sign in to cPanel and open **phpMyAdmin**.
2. In the left-hand list, click **the database the site already uses**.

   Click the **database name itself** — not a table inside it, and not
   `information_schema`. You can tell which view you are in by the tab row: the
   database view has **Structure · SQL · Search · Query · Export · Import**,
   while a table view also has **Browse** and **Insert**. Importing from the
   wrong one is the single commonest way this goes wrong, and the preflight
   below is there to catch it.

   If you are not certain which database it is, open the **SQL** tab on a
   candidate and run `SELECT DATABASE(), COUNT(*) FROM catalog_courses;`. The
   right one answers with its own name and a number; the wrong one says the
   table does not exist.
3. Open the **Import** tab.
4. **Choose File** → `content.sql` → leave the format as SQL → **Go**.
   It reports 42 queries and takes a few seconds.

There is no migration to import first. Every table this file writes to has
existed since the first install.

That is all. The catalogue counts and the search index update themselves: each
course seed ends by calling `catalog_refresh_course_rollup` and
`search_reindex_all_quiet`, so they are already correct when the import
finishes.

## Checking it worked

Open the **SQL** tab and run:

```sql
SELECT c.slug, c.lesson_count, SUM(a.word_count) AS words
FROM catalog_courses c
JOIN catalog_modules m ON m.course_id = c.id
JOIN catalog_lessons l ON l.module_id = m.id
JOIN content_articles a ON a.lesson_id = l.id
GROUP BY c.slug
ORDER BY words DESC;
```

The top eleven rows should read:

| slug | words |
| --- | --- |
| generative-ai | 48,375 |
| html-from-basics-to-expert | 36,989 |
| deep-learning | 35,374 |
| data-analytics | 23,718 |
| machine-learning | 23,192 |
| typescript-from-basics-to-expert | 22,743 |
| php-from-basics-to-expert | 21,538 |
| javascript-from-basics-to-expert | 19,760 |
| python-for-data-science | 19,112 |
| python-from-basics-to-expert | 18,634 |
| css-from-basics-to-expert | 18,501 |

The eight below them are the courses still to be deepened (Go 11,247 down to
Dynamic PHP Frontends 1,218).

And one query that confirms the HTML course has its new shape:

```sql
SELECT m.title, COUNT(l.id) AS lessons
FROM catalog_modules m
JOIN catalog_courses c ON c.id = m.course_id
LEFT JOIN catalog_lessons l ON l.module_id = m.id
WHERE c.slug = 'html-from-basics-to-expert'
GROUP BY m.id, m.title, m.`position`
ORDER BY m.`position`;
```

Five rows: Foundations 9, Forms Semantics and Media 7, Graphics Metadata and
Access 7, Advanced HTML 10, Project and Practice 3 — thirty-six in all, of
which thirty-one are articles and five are quizzes.

An older note, kept because the table it mentions is still checked this way:

```sql
SELECT COUNT(*) FROM content_editorial_posts;
```

`0` is the right answer — the table is empty until the guides and the blog
posts are written.

## If it stops at the preflight

`content.sql` begins by checking that the database it was given actually holds
the learning schema. If it does not, the import stops on its sixth statement,
**before writing anything**, with the diagnosis in the error text:

```
#1146 - Table 'gainglyi_learning.STOP: gainglyi_learning has 0 of 11 tables'
        doesn't exist
```

There is no such table. The message *is* the table name, which is the only way
a plain `.sql` file can say something useful to the person running it. Read the
two numbers:

| It says | It means | Do this |
| --- | --- | --- |
| `has 0 of 11 tables` | The wrong database entirely. | Pick the right one from the left-hand list. |
| `has 10 of 11 tables` | The right database, but a migration has not been applied. | Import the missing migration first, then this file again. |

### The one that looks different

```
#1109 - Unknown table 'STOP: information_schema has 0 of 11 tables'
        in information_schema
```

A different error number, and it has one cause: **`information_schema` was the
selected database**. That is MySQL's own catalogue, it is read-only, and
nothing can be written to it — so the import wrote nothing at all. phpMyAdmin
may still say "Import has been successfully finished, N queries executed" above
the error, because it counts the statements it sent rather than the ones that
worked.

It happens when phpMyAdmin is left on a table inside `information_schema` — the
tab row reads **Browse · Structure · SQL · Search · Insert · Export · Import**,
which is the *table* view, not the database view. Click your own database in
the left-hand list first, then **Import**.

### Checking which database is the right one

Open the **SQL** tab on a candidate and run:

```sql
SELECT DATABASE(), COUNT(*) AS courses FROM catalog_courses;
```

The right database answers with its own name and a number. The wrong one says
the table does not exist.

**Do not** respond to any of this by running `install.sql` — see the last
section.

## If it stops with "Table ... doesn't exist"

A database installed by hand, or from an older `install.sql`, may be missing a
table that a seed happens to mention. The import stops at that statement and
writes nothing.

`content.sql` now needs only the catalogue and content tables:

```sql
SELECT t.table_name
  FROM information_schema.tables t
 WHERE t.table_schema = DATABASE()
   AND t.table_name IN ('catalog_categories', 'catalog_courses',
                        'catalog_modules', 'catalog_lessons', 'catalog_tags',
                        'catalog_course_tags', 'content_articles',
                        'content_lesson_diagrams', 'assessment_quizzes',
                        'assessment_questions', 'assessment_question_options');
```

That is the complete list, read out of the generated file rather than
remembered — eleven tables. Anything the query does not return is missing, and
the import will stop on it. It also calls two procedures,
`catalog_refresh_course_rollup` and `search_reindex_all_quiet`, which write to
`search_documents`:

```sql
SHOW PROCEDURE STATUS WHERE Db = DATABASE();
```

Send me whatever is absent and I will say which migration creates it.

## Why this is safe

* Every insert is `ON DUPLICATE KEY UPDATE`. Importing it twice changes
  nothing the second time, so a retry after an interrupted upload is fine.
* The file contains no `DROP`, no `TRUNCATE` and no `DELETE FROM`. The builder
  refuses to write it if a seed ever does.
* **Enrolments, quiz attempts and lesson progress are untouched.** No learner
  loses anything.
* Demo fixtures — the sample users, their enrolments, their progress, a graded
  attempt, a month of analytics — are recognised by the tables they write to
  and left out. None of that reaches the live database.
* It carries no schema, which is why the migration is a separate first step.

One thing it *will* do: `content.sql` covers all twenty courses, not only the
eleven that changed. The other nine are rewritten with the same content they
already have, so the effect is nil — unless you have edited a lesson by hand
in phpMyAdmin, in which case that edit is overwritten. If you have made such an
edit and want to keep it, say so and I will build a file limited to the eleven.

## Do not use install.sql

`dist/install.sql` is for a first install into an empty database, or a retry
after one failed. **It drops every table it manages and replaces the data with
the seeds.**

It has a guard: it refuses to run when the database holds an account that is
not `@learning.test`. That guard protects the live learning database. It does
**not** protect a database belonging to something else — a database with no
learning accounts in it passes the check, and then the drops run.

So if the preflight above told you that you are in the wrong database, the
answer is to find the right one, never to install the schema where you are.
The file to import for new content is always `content.sql`.

## Rebuilding these files yourself

`dist/` is not in the repository, deliberately: a checked-in copy goes stale the
moment a seed changes. After pulling the branch:

```bash
./scripts/build-content-sql.sh          # every content seed -> dist/content.sql
./scripts/build-content-sql.sh 0037 0039  # or just a range
```

The migration is already in the repository at
`migrations/0016_editorial_posts.sql`.
