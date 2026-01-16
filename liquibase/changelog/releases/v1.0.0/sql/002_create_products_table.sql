-- changeset pranithreddym:1.0.0-002
-- comment: Create products table

CREATE TABLE IF NOT EXISTS `categories` (
    `id`          INT             NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(100)    NOT NULL,
    `slug`        VARCHAR(100)    NOT NULL,
    `description` TEXT                    DEFAULT NULL,
    `is_active`   TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_categories_slug` (`slug`),
    INDEX `idx_categories_is_active` (`is_active`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Product categories';

CREATE TABLE IF NOT EXISTS `products` (
    `id`            BIGINT          NOT NULL AUTO_INCREMENT,
    `uuid`          VARCHAR(36)     NOT NULL,
    `category_id`   INT             NOT NULL,
    `sku`           VARCHAR(100)    NOT NULL,
    `name`          VARCHAR(255)    NOT NULL,
    `description`   TEXT                    DEFAULT NULL,
    `price`         DECIMAL(12, 2)  NOT NULL,
    `stock_qty`     INT             NOT NULL DEFAULT 0,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME                DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_products_uuid`       (`uuid`),
    UNIQUE KEY `uq_products_sku`        (`sku`),
    INDEX `idx_products_category_id`    (`category_id`),
    INDEX `idx_products_is_active`      (`is_active`),
    INDEX `idx_products_price`          (`price`),
    CONSTRAINT `fk_products_category`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Product catalog';
