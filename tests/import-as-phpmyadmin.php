#!/usr/bin/env php
<?php
/**
 * Imports a .sql file the way phpMyAdmin does, and fails the way phpMyAdmin
 * fails.
 *
 *   php tests/import-as-phpmyadmin.php dist/install.sql my_database
 *
 * scripts/migrate.sh and scripts/seed.sh use the mysql client, which is how a
 * developer loads this schema and is NOT how it gets installed on shared
 * hosting. The difference is not cosmetic: the client drains the result sets a
 * CALL leaves behind, and mysqli does not. A procedure ending in a bare SELECT
 * therefore imports perfectly from the command line and takes down the whole
 * file in phpMyAdmin, one statement later, with
 *
 *   #2014 - Commands out of sync; you can't run this command now
 *
 * That reached a real cPanel import twice - install.sql and content.sql - past
 * a CI job that was green throughout. So: mysqli, one statement at a time,
 * honouring DELIMITER, and deliberately never calling next_result().
 *
 * The splitter tracks quoting because the seeds are full of article bodies
 * with semicolons inside them. It is not a general SQL parser; it is enough
 * for these files, which is all it claims.
 *
 * Connection details come from the environment, matching scripts/_lib.sh.
 */
mysqli_report(MYSQLI_REPORT_OFF);

$file = $argv[1] ?? '';
$db   = $argv[2] ?? (getenv('MYSQL_DATABASE') ?: 'learning');

if ($file === '' || !is_file($file)) {
    fwrite(STDERR, "usage: php tests/import-as-phpmyadmin.php <file.sql> [database]\n");
    exit(2);
}

$conn = new mysqli(
    getenv('MYSQL_HOST') ?: '127.0.0.1',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: '',
    $db,
    (int) (getenv('MYSQL_PORT') ?: 3306)
);
if ($conn->connect_error) { fwrite(STDERR, "connect: {$conn->connect_error}\n"); exit(2); }
$conn->set_charset('utf8mb4');

$sql = file_get_contents($file);
$len = strlen($sql);
$delimiter = ';';
$buffer = '';
$i = 0;
$statements = 0;

function run(mysqli $conn, string $stmt, int &$statements): void {
    $stmt = trim($stmt);
    if ($stmt === '') { return; }
    $statements++;
    if ($conn->query($stmt) === false) {
        fwrite(STDERR, "FAILED after {$statements} statements\n");
        fwrite(STDERR, "  #{$conn->errno} - {$conn->error}\n");
        fwrite(STDERR, "  statement: " . substr(preg_replace('/\s+/', ' ', $stmt), 0, 110) . "\n");
        exit(1);
    }
}

while ($i < $len) {
    $c = $sql[$i];

    // Quoted strings and quoted identifiers: copied verbatim, delimiters inside
    // them mean nothing.
    if ($c === "'" || $c === '"' || $c === '`') {
        $quote = $c;
        $buffer .= $c; $i++;
        while ($i < $len) {
            if ($sql[$i] === '\\' && $quote !== '`') { $buffer .= substr($sql, $i, 2); $i += 2; continue; }
            if ($sql[$i] === $quote) {
                if (($sql[$i + 1] ?? '') === $quote) { $buffer .= $quote . $quote; $i += 2; continue; }
                $buffer .= $quote; $i++; break;
            }
            $buffer .= $sql[$i]; $i++;
        }
        continue;
    }

    // Comments.
    if ($c === '-' && substr($sql, $i, 3) === '-- ') {
        $end = strpos($sql, "\n", $i); $i = $end === false ? $len : $end + 1; continue;
    }
    if ($c === '/' && substr($sql, $i, 2) === '/*') {
        $end = strpos($sql, '*/', $i); $i = $end === false ? $len : $end + 2; continue;
    }

    // DELIMITER, only at the start of a line.
    if (($i === 0 || $sql[$i - 1] === "\n") && preg_match('/^DELIMITER[ \t]+(\S+)[ \t]*\r?\n/i', substr($sql, $i, 40), $m)) {
        run($conn, $buffer, $statements);
        $buffer = '';
        $delimiter = $m[1];
        $i += strlen($m[0]);
        continue;
    }

    if (substr($sql, $i, strlen($delimiter)) === $delimiter) {
        run($conn, $buffer, $statements);
        $buffer = '';
        $i += strlen($delimiter);
        continue;
    }

    $buffer .= $c; $i++;
}
run($conn, $buffer, $statements);

// phpMyAdmin's own trailing statement - where the reported error landed.
if ($conn->query('SET FOREIGN_KEY_CHECKS = ON') === false) {
    fwrite(STDERR, "FAILED on phpMyAdmin's trailing SET FOREIGN_KEY_CHECKS = ON\n");
    fwrite(STDERR, "  #{$conn->errno} - {$conn->error}\n");
    exit(1);
}

echo "imported {$statements} statements, then SET FOREIGN_KEY_CHECKS = ON\n";
