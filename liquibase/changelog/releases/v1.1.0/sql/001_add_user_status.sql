-- changeset pranithreddym:1.1.0-001
-- comment: Add account_status and last_login_at to users

ALTER TABLE `users`
    ADD COLUMN `account_status` ENUM('active','suspended','locked','pending_verification')
                                NOT NULL DEFAULT 'pending_verification'
                                AFTER `is_verified`,
    ADD COLUMN `last_login_at`  DATETIME DEFAULT NULL
                                AFTER `account_status`,
    ADD COLUMN `login_attempts` TINYINT  NOT NULL DEFAULT 0
                                AFTER `last_login_at`;

ALTER TABLE `users`
    ADD INDEX `idx_users_account_status` (`account_status`);

-- Migrate existing active/verified users
UPDATE `users`
SET    `account_status` = 'active'
WHERE  `is_active` = 1 AND `is_verified` = 1;

UPDATE `users`
SET    `account_status` = 'pending_verification'
WHERE  `is_verified` = 0;
