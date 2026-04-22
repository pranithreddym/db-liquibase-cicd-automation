-- verify_data.sql — Validate seed data after migrations

-- 1. Confirm categories were seeded
SELECT
    id,
    name,
    slug,
    is_active
FROM `categories`
ORDER BY id;

-- Expected: 5 rows (electronics, clothing, home-garden, sports, books)
SELECT
    COUNT(*) AS category_count,
    CASE WHEN COUNT(*) >= 5 THEN 'PASS' ELSE 'FAIL' END AS result
FROM `categories`;

-- 2. Confirm admin user exists
SELECT
    id,
    email,
    username,
    role,
    is_active,
    is_verified
FROM `users`
WHERE role = 'admin';

-- 3. Check no orders exist (clean state)
SELECT
    COUNT(*) AS order_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS (clean state)' ELSE 'INFO (orders exist)' END AS result
FROM `orders`;

-- 4. Verify DATABASECHANGELOG entries match expected changesets
SELECT
    ID,
    AUTHOR,
    DATEEXECUTED,
    EXECTYPE
FROM DATABASECHANGELOG
ORDER BY ORDEREXECUTED;

SELECT
    COUNT(*) AS applied_changesets,
    CASE WHEN COUNT(*) >= 7 THEN 'PASS' ELSE 'FAIL' END AS result
FROM DATABASECHANGELOG
WHERE EXECTYPE = 'EXECUTED';
