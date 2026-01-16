-- rollback: remove account_status columns from users
ALTER TABLE `users`
    DROP INDEX  `idx_users_account_status`,
    DROP COLUMN `login_attempts`,
    DROP COLUMN `last_login_at`,
    DROP COLUMN `account_status`;
