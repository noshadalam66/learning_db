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
2. In the left-hand list, click the database **`gainglyi_learning`**.
   Click the database name itself, not a table — the import has to run with
   the database selected or the statements have nowhere to go.
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

`dist/install.sql` is for a first install, or a retry after one failed. It drops
every table and replaces the data with the seeds. It refuses to run at all when
the database holds an account that is not `@learning.test`, which the live
database does — so it is not merely the wrong file, it will stop. The file to
import for new content is always `content.sql`.

## Rebuilding these files yourself

`dist/` is not in the repository, deliberately: a checked-in copy goes stale the
moment a seed changes. After pulling the branch:

```bash
./scripts/build-content-sql.sh          # every content seed -> dist/content.sql
./scripts/build-content-sql.sh 0037 0039  # or just a range
```

The migration is already in the repository at
`migrations/0016_editorial_posts.sql`.
