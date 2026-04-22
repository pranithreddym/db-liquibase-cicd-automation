-- verify_schema.sql — Manual schema verification queries
-- Run against the target database after migrations

-- 1. List all tables
SHOW TABLES;

-- 2. Verify users table structure
DESCRIBE `users`;

-- 3. Verify categories table structure
DESCRIBE `categories`;

-- 4. Verify products table structure
DESCRIBE `products`;

-- 5. Verify orders table structure
DESCRIBE `orders`;

-- 6. Verify order_items table structure
DESCRIBE `order_items`;

-- 7. Verify audit_log table structure
DESCRIBE `audit_log`;

-- 8. Check all indexes on users
SHOW INDEX FROM `users`;

-- 9. Check all foreign keys in this schema
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = DATABASE()
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY
    TABLE_NAME, COLUMN_NAME;

-- 10. Check DATABASECHANGELOG (Liquibase tracking table)
SELECT
    ID,
    AUTHOR,
    FILENAME,
    DATEEXECUTED,
    ORDEREXECUTED,
    EXECTYPE,
    MD5SUM,
    DESCRIPTION,
    TAG
FROM DATABASECHANGELOG
ORDER BY ORDEREXECUTED;
