# Giving yourself the admin role

The admin panel at `https://omniacad.com/ap/admin_panel/admin_login` lets any
account in that holds the `admin` role, and nobody else. This page is the one
statement that grants it.

**There is no new table and no migration here.** `identity_roles` and
`identity_user_roles` have existed since migration `0002_identity.sql`, which
is part of the first install. Nothing below changes the schema, so there is no
file to import before this one and nothing to run afterwards.

---

## Before you start

**Register normally first.** Go to
[omniacad.com/register](https://omniacad.com/register) and create the account
with the address you want to administer from. The statement below grants a role
to an account that already exists; it cannot create one, because an account
needs a password hash and this is not the place to be writing one by hand.

Then open phpMyAdmin, **click the site's database in the list on the left** —
the same one you import `content.sql` into — and open the **SQL** tab.

> If you are not sure which database that is, run
> `SELECT DATABASE();` after selecting one, or look for the database that has a
> table called `catalog_courses` in it. Running the statements below against
> the wrong database fails with `#1146 Table ... doesn't exist`, which is
> annoying rather than harmful — nothing here deletes anything.

---

## The statement

Change the address in **step 2** to yours, then run all three together.

```sql
-- 1. Make sure the three roles exist.
--
--    On most databases they already do and this rewrites the same three rows.
--    It is here because the three rows are seeded by seeds/0001, and 0001 is a
--    demo fixture that content.sql deliberately leaves out. The TABLE always
--    exists - migration 0002 creates it - but on a database whose content came
--    from content.sql rather than from install.sql it can be empty, and step 2
--    would then match nothing and say nothing about why.
INSERT INTO identity_roles (name, description) VALUES
  ('student',    'Can enrol in courses, track progress and take quizzes.'),
  ('instructor', 'Can author courses, lessons, articles and quizzes.'),
  ('admin',      'Full administrative access to every service.')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- 2. Grant admin to one address. CHANGE THIS to your own.
INSERT INTO identity_user_roles (user_id, role_id)
SELECT u.id, r.id
  FROM identity_users u
  JOIN identity_roles r ON r.name = 'admin'
 WHERE u.email = 'you@example.com'
ON DUPLICATE KEY UPDATE granted_at = identity_user_roles.granted_at;

-- 3. Check it took. CHANGE THIS to the same address.
SELECT u.email,
       u.full_name,
       u.status,
       COALESCE(GROUP_CONCAT(r.name ORDER BY r.name SEPARATOR ', '), '(none)') AS roles
  FROM identity_users u
  LEFT JOIN identity_user_roles ur ON ur.user_id = u.id
  LEFT JOIN identity_roles  r ON r.id = ur.role_id
 WHERE u.email = 'you@example.com'
 GROUP BY u.id, u.email, u.full_name, u.status;
```

Step 3 should print one row, and `roles` should contain `admin`:

```
email               full_name      status   roles
you@example.com     Your Name      active   admin, student
```

**If step 3 prints no rows at all**, the address in step 2 matched nobody —
step 2 then inserted nothing and reported success, because an `INSERT ...
SELECT` that selects no rows is not an error. It is almost always a typo or a
different address from the one you registered with. Find the right one:

```sql
SELECT email, full_name, status, created_at
  FROM identity_users
 ORDER BY created_at DESC
 LIMIT 20;
```

Re-running the whole thing is safe. Both inserts are `ON DUPLICATE KEY UPDATE`,
so a second run rewrites the same rows rather than failing or granting twice.

---

## Then sign in again

**An access token carries the roles that existed when it was issued.** If you
were already signed in to the site when you ran this, that session does not
know about the new role and the panel will still turn you away. Sign out, or
just go straight to `/ap/admin_panel/admin_login` and sign in there — the panel
reads the roles out of a fresh sign-in, so starting there is enough.

---

## Taking it away again

```sql
DELETE ur FROM identity_user_roles ur
  JOIN identity_roles r ON r.id = ur.role_id
  JOIN identity_users u ON u.id = ur.user_id
 WHERE r.name = 'admin' AND u.email = 'you@example.com';
```

This removes only the admin grant. Any other role on that account — `student`,
`instructor` — is left alone, and the account itself is untouched. The same
caveat applies in reverse: a session that already holds an admin token keeps it
until it expires, which is fifteen minutes.

---

## What the role actually opens

Today, one read-only page. `/ap/admin_panel/dashboard` counts registrations,
courses, enrolments, completions and quiz attempts, and `admin` is also what
the API requires for:

| Endpoint | What it does |
|---|---|
| `GET /api/analytics/admin/overview` | the figures the dashboard shows |
| `GET /api/analytics/platform` | the daily trend from the rollup table |
| `POST /api/analytics/rollup` | recompute one day |
| `POST /api/analytics/partitions` | create the next monthly partition |
| `GET /api/users` | list accounts |
| `GET /api/users/roles` | list the roles |
| `POST /api/users/{id}/roles` | grant a role to somebody else |

That last one means an administrator can make another administrator through the
API without touching the database again. Nothing in the dashboard does it —
the panel reports and does not edit — but the role carries the permission, so
grant it deliberately.

## Why the address of the panel is not the point

`/ap/admin_panel/` is unlisted, not secret. It keeps the panel out of crawl
queues and out of anybody's guesses, and that is the whole of what it does. The
things that actually keep it shut are the sign-in, this role, and a throttle of
five wrong passwords per address per quarter hour. Treat the role the way you
would treat the password.
