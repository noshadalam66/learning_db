# Working on learning_db

## Adding courses to the live site: content.sql, never install.sql

The production database is cPanel shared hosting (`gainglyi`, MariaDB,
phpMyAdmin). It has real learners in it. **When a new course is added, the
deliverable is `content.sql` for the new seeds only** — the live database is
never dropped, deleted or reinstalled to add content.

```bash
./scripts/build-content-sql.sh 0030 0031   # only the new seeds
```

Import that one file in phpMyAdmin: select the database → Import → Go.
Nothing to run afterwards — each course seed ends by calling
`catalog_refresh_course_rollup` and `search_reindex_all_quiet`, so the
catalogue counts and the search index are already correct.

Why it is safe, and what keeps it safe:

* every insert is `ON DUPLICATE KEY UPDATE`, so a re-import rewrites the same
  rows rather than duplicating or failing;
* the builder **refuses to write the file** if any seed it includes contains
  `DROP`, `TRUNCATE` or `DELETE FROM`;
* demo fixtures (users, enrolments, progress, attempts, analytics) are
  recognised by the tables they write to and left out;
* enrolments, quiz attempts and progress are untouched.

`install.sql` is for a **first install, or a retry after one failed**. It
drops every table and replaces the data with the seeds. It refuses to run at
all when the database holds an account that is not `@learning.test`, which the
live database now does — so it is not merely the wrong file for adding
courses, it will stop. Do not reach for it, and do not ask for the tables to
be dropped by hand.

**If the change needs a new migration**, `content.sql` does not carry it —
it is seeds only. Hand over the migration file separately, to be imported
before the content, and say so explicitly.

## Two rules the live server taught us

Both of these passed CI for weeks and broke a real import. Keep them.

1. **No seed may `CALL` a procedure that ends in a bare `SELECT`.** Use the
   `_quiet` variant. phpMyAdmin uses mysqli, which does not drain result sets,
   so the *next* statement dies with `#2014 Commands out of sync`. The `mysql`
   client hides this completely. `tests/import-as-phpmyadmin.php` is the test
   that does not hide it, and CI runs it over both generated files.

2. **A new `CREATE TABLE` must name its own charset:**
   `) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;`
   Inheriting the database default is how a lesson containing `世界` got
   `#1366 Incorrect string value` on a cPanel database, which is created
   `latin1`. `tests/verify.sql` checks every column's character set;
   `migrations/0000_charset.sql` sets the database default before anything
   else runs.

## Migrations are immutable

`scripts/migrate.sh` checksums every applied file and refuses one that
changed. Fix forward with a new migration; seeds, by contrast, are editable
and are expected to be re-imported.

## Verifying before handing anything over

Generated SQL is verified by importing it the way the user actually imports
it — `php tests/import-as-phpmyadmin.php <file> <database>` against a real
server — not by reading it. Twice now a file that looked right and passed the
`mysql`-client tests failed on the real one.
