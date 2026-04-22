-- changeset pranithreddym:1.0.0-003
-- comment: Create orders and order_items tables

CREATE TABLE IF NOT EXISTS `orders` (
    `id`              BIGINT          NOT NULL AUTO_INCREMENT,
    `uuid`            VARCHAR(36)     NOT NULL,
    `user_id`         BIGINT          NOT NULL,
    `status`          ENUM('pending','confirmed','processing','shipped','delivered','cancelled','refunded')
                                      NOT NULL DEFAULT 'pending',
    `subtotal`        DECIMAL(12, 2)  NOT NULL DEFAULT 0.00,
    `tax_amount`      DECIMAL(12, 2)  NOT NULL DEFAULT 0.00,
    `discount_amount` DECIMAL(12, 2)  NOT NULL DEFAULT 0.00,
    `total_amount`    DECIMAL(12, 2)  NOT NULL DEFAULT 0.00,
    `currency`        VARCHAR(3)      NOT NULL DEFAULT 'USD',
    `notes`           TEXT                    DEFAULT NULL,
    `placed_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_orders_uuid`     (`uuid`),
    INDEX `idx_orders_user_id`      (`user_id`),
    INDEX `idx_orders_status`       (`status`),
    INDEX `idx_orders_placed_at`    (`placed_at`),
    CONSTRAINT `fk_orders_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Customer orders';

CREATE TABLE IF NOT EXISTS `order_items` (
    `id`           BIGINT          NOT NULL AUTO_INCREMENT,
    `order_id`     BIGINT          NOT NULL,
    `product_id`   BIGINT          NOT NULL,
    `sku`          VARCHAR(100)    NOT NULL,
    `product_name` VARCHAR(255)    NOT NULL,
    `quantity`     INT             NOT NULL,
    `unit_price`   DECIMAL(12, 2)  NOT NULL,
    `line_total`   DECIMAL(12, 2)  NOT NULL,
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_order_items_order_id`   (`order_id`),
    INDEX `idx_order_items_product_id` (`product_id`),
    CONSTRAINT `fk_order_items_order`
        FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_order_items_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Line items for each order';
