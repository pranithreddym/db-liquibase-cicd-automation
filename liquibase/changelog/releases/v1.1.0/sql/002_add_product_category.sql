-- changeset pranithreddym:1.1.0-002
-- comment: Add parent_id to categories for hierarchy and tags to products

ALTER TABLE `categories`
    ADD COLUMN `parent_id` INT DEFAULT NULL AFTER `id`,
    ADD COLUMN `sort_order` SMALLINT NOT NULL DEFAULT 0 AFTER `is_active`,
    ADD INDEX `idx_categories_parent_id` (`parent_id`),
    ADD CONSTRAINT `fk_categories_parent`
        FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`)
        ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `products`
    ADD COLUMN `tags`   JSON    DEFAULT NULL AFTER `description`,
    ADD COLUMN `weight` DECIMAL(8,3) DEFAULT NULL AFTER `stock_qty`,
    ADD FULLTEXT INDEX `ft_products_name_description` (`name`, `description`);
