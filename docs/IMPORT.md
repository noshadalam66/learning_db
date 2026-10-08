# Importing the eleven deepened courses into the live cPanel database

Two files, in this order. Nothing else, and nothing to run afterwards.
Paths below are from the repository root.

| # | File | Size | What it does |
| --- | --- | --- | --- |
| 1 | `dist/0016_editorial_posts.sql` | 7 KB | Adds one table, `content_editorial_posts`. Needed by the course-guide and blog work. |
| 2 | `dist/content.sql` | 3.0 MB | Rewrites the lesson bodies for eleven courses. |

A gzipped copy of each sits beside it (`.sql.gz`). phpMyAdmin detects and
decompresses those itself, so use them if the upload box rejects the 3 MB file.

## The steps

1. Sign in to cPanel and open **phpMyAdmin**.
2. In the left-hand list, click **the database the site already uses**.
   Click the database name itself, not a table — the import has to run with
   the database selected or the statements have nowhere to go.

   If you are not certain which one it is, open the **SQL** tab on a candidate
   and run `SELECT COUNT(*) FROM catalog_courses;`. The right database answers
   with a number; the wrong one says the table does not exist.
3. Open the **Import** tab.
4. **Choose File** → `0016_editorial_posts.sql` → leave the format as SQL →
   **Go**. It should report 3 queries.
5. Open the **Import** tab again.
6. **Choose File** → `content.sql` (or `content.sql.gz`) → **Go**.
   It should report 322 queries and take a minute or two.

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
| deep-learning | 35,374 |
| data-analytics | 23,718 |
| machine-learning | 23,192 |
| typescript-from-basics-to-expert | 22,743 |
| php-from-basics-to-expert | 21,538 |
| javascript-from-basics-to-expert | 19,760 |
| python-for-data-science | 19,112 |
| python-from-basics-to-expert | 18,634 |
| css-from-basics-to-expert | 18,501 |
| html-from-basics-to-expert | 14,247 |

The nine below them are the courses still to be deepened (Go 11,247 down to
Dynamic PHP Frontends 1,218).

And one row to confirm the new table arrived:

```sql
SELECT COUNT(*) FROM content_editorial_posts;
```

`0` is the right answer — the table is empty until the guides and the blog
posts are written.

## If it stops at the preflight

`content.sql` begins by checking that the database it was given actually holds
the learning schema. If it does not, the import stops on its sixth statement,
before writing anything, with the instruction in the error text:

```
#1146 - Table 'yourdb.STOP: no learning schema in this database
         - see docs/IMPORT.md' doesn't exist
```

There is no such table. The message is the table name, which is the only way a
plain `.sql` file can say something useful to the person running it.

It means the database selected in phpMyAdmin is not the one the site uses.
Pick another from the left-hand list and check it:

```sql
SELECT COUNT(*) FROM catalog_courses;
```

The right database answers with a number. **Do not** respond to this by running
`install.sql` — see the last section.

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
