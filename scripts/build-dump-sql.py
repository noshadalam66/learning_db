#!/usr/bin/env python3
"""Builds dist/learning_db.sql - a phpMyAdmin-style dump of a live database.

This is the shape a control panel produces and expects: a header, then each
table's structure, its data, then the indexes, AUTO_INCREMENT values and
foreign keys as ALTER statements, and finally the views, routines and
triggers.

It differs from scripts/build-install-sql.sh in what it reads. That one
concatenates the migration and seed *sources*, so it needs no database. This
one dumps a *database that has already been built*, so run migrate and seed
first. Use whichever suits: the installer is the repository's own history, the
dump is a photograph of the result.

    ./scripts/migrate.sh && ./scripts/seed.sh
    ./scripts/build-dump-sql.py                 # structure and data
    ./scripts/build-dump-sql.py --no-data       # structure only

Connection settings come from the same environment variables as the other
scripts: MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE.
"""
import argparse
import datetime
import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

# scripts/_lib.sh sources .env before reading these, so this has to as well or
# the two disagree about which server they are talking to.
_env_file = ROOT / ".env"
if _env_file.is_file():
    for _line in _env_file.read_text().splitlines():
        _line = _line.strip()
        if not _line or _line.startswith("#") or "=" not in _line:
            continue
        _key, _value = _line.split("=", 1)
        os.environ.setdefault(_key.strip(), _value.strip())

HOST = os.environ.get("MYSQL_HOST", "127.0.0.1")
PORT = os.environ.get("MYSQL_PORT", "3306")
USER = os.environ.get("MYSQL_USER", "root")
PASSWORD = os.environ.get("MYSQL_PASSWORD", "")
DATABASE = os.environ.get("MYSQL_DATABASE", "learning")

ENV = {**os.environ, "MYSQL_PWD": PASSWORD}
CONN = [f"--host={HOST}", f"--port={PORT}", f"--user={USER}"]


_UNESCAPE = {"0": "\0", "n": "\n", "r": "\r", "t": "\t", "\\": "\\"}


def _unescape(value):
    """Undo the escaping mysql --batch applies to newlines, tabs and backslashes.

    Done in one pass rather than a chain of replaces: a body containing the two
    characters \\ followed by n is a literal backslash and an n, not a newline,
    and replacing "\\n" first would turn it into one.
    """
    out, i = [], 0
    while i < len(value):
        if value[i] == "\\" and i + 1 < len(value):
            out.append(_UNESCAPE.get(value[i + 1], value[i + 1]))
            i += 2
        else:
            out.append(value[i])
            i += 1
    return "".join(out)


def query(sql):
    """Rows as lists of strings, tab-separated and header-free.

    --raw is deliberately absent: without it mysql escapes the newlines inside
    a DDL body, which is what keeps one row on one line and parseable.
    """
    out = subprocess.run(
        ["mysql", *CONN, "--batch", "--skip-column-names", DATABASE],
        input=sql, capture_output=True, text=True, env=ENV, check=True).stdout
    return [[_unescape(cell) for cell in line.split("\t")]
            for line in out.splitlines() if line]


def show_create(kind, name):
    """SHOW CREATE returns the DDL in a column whose position varies by kind."""
    column = {"TABLE": 1, "VIEW": 1, "TRIGGER": 2, "PROCEDURE": 2, "FUNCTION": 2}[kind]
    return query(f"SHOW CREATE {kind} `{name}`")[0][column]


def header(comment):
    return f"--\n-- {comment}\n--\n"


def _matching_paren(text, start):
    """Index of the ) that closes the ( at `start`.

    Not rindex: a partitioned table ends with a PARTITION BY clause full of
    parentheses, so the last one in the string is nowhere near the end of the
    column list. Quoted text is skipped, because a DEFAULT or a COMMENT may
    contain a bracket of its own.
    """
    depth = 0
    i = start
    while i < len(text):
        char = text[i]
        if char in "`'\"":
            quote = char
            i += 1
            while i < len(text):
                if text[i] == "\\" and quote != "`":
                    i += 2
                    continue
                if text[i] == quote:
                    break
                i += 1
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("unbalanced parentheses in CREATE TABLE")


def split_table(ddl):
    """Pull the keys and foreign keys out of a CREATE TABLE.

    phpMyAdmin emits a table with its columns only, then adds indexes,
    AUTO_INCREMENT and foreign keys afterwards as ALTER statements. CHECK
    constraints stay inline - they are not indexes, and MySQL reports them in
    the table body.

    Returns (create_sql, index_lines, constraint_lines, auto_increment_column).
    """
    open_paren = ddl.index("(")
    close_paren = _matching_paren(ddl, open_paren)
    head = ddl[:open_paren + 1]
    body = ddl[open_paren + 1:close_paren]
    tail = ddl[close_paren:]

    columns, indexes, constraints = [], [], []
    auto_column = None

    for line in body.split("\n"):
        stripped = line.strip().rstrip(",")
        if not stripped:
            continue
        if re.match(r"^(PRIMARY KEY|UNIQUE KEY|KEY|FULLTEXT KEY|SPATIAL KEY)\b", stripped):
            indexes.append(f"ADD {stripped}")
        elif re.match(r"^CONSTRAINT\s+`[^`]+`\s+FOREIGN KEY\b", stripped):
            constraints.append(f"ADD {stripped}")
        else:
            # AUTO_INCREMENT moves to its own section, so the column is
            # declared plainly here and modified once the key exists.
            if "AUTO_INCREMENT" in stripped.upper():
                auto_column = stripped
                stripped = re.sub(r"\s+AUTO_INCREMENT\b", "", stripped, flags=re.I)
            columns.append(f"  {stripped}")

    # AUTO_INCREMENT=98 in the table options would re-declare it too.
    tail = re.sub(r"\s+AUTO_INCREMENT=\d+", "", tail)
    return head + "\n" + ",\n".join(columns) + "\n" + tail, indexes, constraints, auto_column


def dump_data(table):
    """Data for one table, via mysqldump so escaping is never hand-rolled."""
    out = subprocess.run(
        ["mysqldump", *CONN, "--no-create-info", "--complete-insert",
         "--skip-extended-insert", "--skip-add-locks", "--skip-disable-keys",
         "--skip-set-charset", "--skip-comments", "--no-tablespaces",
         "--single-transaction", DATABASE, table],
        capture_output=True, text=True, env=ENV, check=True).stdout
    return [l for l in out.splitlines() if l.startswith("INSERT INTO")]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-data", action="store_true",
                        help="structure only, no INSERT statements")
    parser.add_argument("-o", "--output", default=str(ROOT / "dist" / "learning_db.sql"))
    args = parser.parse_args()

    tables = [r[0] for r in query(
        "SELECT table_name FROM information_schema.tables "
        f"WHERE table_schema='{DATABASE}' AND table_type='BASE TABLE' ORDER BY table_name")]
    views = [r[0] for r in query(
        "SELECT table_name FROM information_schema.views "
        f"WHERE table_schema='{DATABASE}' ORDER BY table_name")]
    routines = query(
        "SELECT routine_name, routine_type FROM information_schema.routines "
        f"WHERE routine_schema='{DATABASE}' ORDER BY routine_type, routine_name")
    triggers = [r[0] for r in query(
        "SELECT trigger_name FROM information_schema.triggers "
        f"WHERE trigger_schema='{DATABASE}' ORDER BY event_object_table, trigger_name")]
    server = query("SELECT VERSION()")[0][0]

    if not tables:
        sys.exit(f"database `{DATABASE}` has no tables - run migrate.sh and seed.sh first")

    out = []
    w = out.append
    generated = datetime.datetime.now(datetime.timezone.utc).strftime("%b %d, %Y at %I:%M %p")

    w(f"""-- learning_db SQL Dump
-- https://github.com/noshadalam66/learning_db
--
-- Host: {HOST}:{PORT}
-- Generation Time: {generated} UTC
-- Server version: {server}
--
-- Generated by scripts/build-dump-sql.py from a migrated, seeded database.
-- Import it into a database you have already created - it does not create one,
-- because shared hosting does not allow that and the name belongs in your
-- connection string.
--
-- Contains {len(tables)} tables, {len(views)} views, {len(routines)} routines
-- and {len(triggers)} triggers.{'' if args.no_data else ' Data included.'}

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `{DATABASE}`
--
""")

    all_indexes, all_constraints, all_auto = [], [], []

    for table in tables:
        create, indexes, constraints, auto = split_table(show_create("TABLE", table))
        w("-- --------------------------------------------------------\n")
        w(header(f"Table structure for table `{table}`"))
        w(create + ";\n")

        if not args.no_data:
            rows = dump_data(table)
            if rows:
                w(header(f"Dumping data for table `{table}`"))
                w("\n".join(rows) + "\n")

        if indexes:
            all_indexes.append((table, indexes))
        if constraints:
            all_constraints.append((table, constraints))
        if auto:
            all_auto.append((table, auto))

    # Views come after every table they read from exists.
    for view in views:
        w("-- --------------------------------------------------------\n")
        w(header(f"Structure for view `{view}`"))
        w(f"DROP TABLE IF EXISTS `{view}`;\n")
        # The stored definition carries a DEFINER that will not exist on
        # another server, and SQL SECURITY INVOKER is what makes it run as
        # whoever queries it. Strip the one, keep the other.
        ddl = re.sub(r"CREATE ALGORITHM=(\w+) DEFINER=[^ ]+ SQL SECURITY \w+ VIEW",
                     r"CREATE ALGORITHM=\1 SQL SECURITY INVOKER VIEW",
                     show_create("VIEW", view))
        w(ddl + ";\n")

    if all_indexes:
        w("--\n-- Indexes for dumped tables\n--\n")
        for table, indexes in all_indexes:
            w(header(f"Indexes for table `{table}`"))
            # InnoDB refuses more than one FULLTEXT index per ALTER, and
            # search_documents has five - one per weighted field, because
            # MySQL cannot weight fields inside a single index. So they each
            # get their own statement while the ordinary keys stay grouped.
            plain = [i for i in indexes if not i.startswith("ADD FULLTEXT")]
            fulltext = [i for i in indexes if i.startswith("ADD FULLTEXT")]
            if plain:
                w(f"ALTER TABLE `{table}`\n  " + ",\n  ".join(plain) + ";\n")
            for index in fulltext:
                w(f"ALTER TABLE `{table}` {index};\n")

    if all_auto:
        w("--\n-- AUTO_INCREMENT for dumped tables\n--\n")
        for table, column in all_auto:
            w(header(f"AUTO_INCREMENT for table `{table}`"))
            w(f"ALTER TABLE `{table}`\n  MODIFY {column} AUTO_INCREMENT;\n")

    if all_constraints:
        w("--\n-- Constraints for dumped tables\n--\n")
        for table, constraints in all_constraints:
            w(header(f"Constraints for table `{table}`"))
            w(f"ALTER TABLE `{table}`\n  " + ",\n  ".join(constraints) + ";\n")

    if routines or triggers:
        w("--\n-- Routines and triggers\n--\n-- DELIMITER is a client instruction, not SQL. phpMyAdmin and the mysql\n"
          "-- command line both understand it; a tool that does not will choke here.\n--\n")
        w("DELIMITER $$\n")
        for name, kind in routines:
            w(header(f"{kind.capitalize()} `{name}`"))
            ddl = re.sub(r"CREATE DEFINER=[^ ]+ (PROCEDURE|FUNCTION)",
                         r"CREATE \1", show_create(kind, name))
            w(ddl + "$$\n")
        for trigger in triggers:
            w(header(f"Trigger `{trigger}`"))
            ddl = re.sub(r"CREATE DEFINER=[^ ]+ TRIGGER",
                         "CREATE TRIGGER", show_create("TRIGGER", trigger))
            w(ddl + "$$\n")
        w("DELIMITER ;\n")

    w("COMMIT;\n")
    w("""
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;""")

    path = pathlib.Path(args.output)
    path.parent.mkdir(parents=True, exist_ok=True)
    text = "\n".join(out) + "\n"
    path.write_text(text)
    print(f"wrote {path} - {len(text.splitlines())} lines, {len(text) / 1024:.1f} KB")
    print(f"{len(tables)} tables, {len(views)} views, {len(routines)} routines, "
          f"{len(triggers)} triggers"
          f"{'' if args.no_data else ', data included'}")


if __name__ == "__main__":
    main()
