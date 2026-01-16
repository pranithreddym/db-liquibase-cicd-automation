-- changeset pranithreddym:1.0.0-001
-- comment: Create users table with full profile fields

CREATE TABLE IF NOT EXISTS `users` (
    `id`            BIGINT          NOT NULL AUTO_INCREMENT,
    `uuid`          VARCHAR(36)     NOT NULL,
    `email`         VARCHAR(255)    NOT NULL,
    `username`      VARCHAR(100)    NOT NULL,
    `password_hash` VARCHAR(255)    NOT NULL,
    `first_name`    VARCHAR(100)    NOT NULL,
    `last_name`     VARCHAR(100)    NOT NULL,
    `phone`         VARCHAR(20)             DEFAULT NULL,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `is_verified`   TINYINT(1)      NOT NULL DEFAULT 0,
    `role`          ENUM('admin','manager','customer') NOT NULL DEFAULT 'customer',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME                DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_users_uuid`     (`uuid`),
    UNIQUE KEY `uq_users_email`    (`email`),
    UNIQUE KEY `uq_users_username` (`username`),
    INDEX `idx_users_role`         (`role`),
    INDEX `idx_users_is_active`    (`is_active`),
    INDEX `idx_users_deleted_at`   (`deleted_at`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Application users';
