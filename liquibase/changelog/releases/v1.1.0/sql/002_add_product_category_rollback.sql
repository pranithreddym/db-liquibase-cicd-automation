-- rollback: revert product and category changes
ALTER TABLE `products`
    DROP INDEX  `ft_products_name_description`,
    DROP COLUMN `weight`,
    DROP COLUMN `tags`;

ALTER TABLE `categories`
    DROP FOREIGN KEY `fk_categories_parent`,
    DROP INDEX  `idx_categories_parent_id`,
    DROP COLUMN `sort_order`,
    DROP COLUMN `parent_id`;
