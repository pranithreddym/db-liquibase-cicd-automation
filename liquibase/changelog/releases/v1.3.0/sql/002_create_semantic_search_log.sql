-- changeset pranithreddym:1.3.0-002
-- comment: Create semantic_search_log table

CREATE TABLE IF NOT EXISTS `semantic_search_log` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT,
    `uuid`            VARCHAR(36)  NOT NULL,
    `user_id`         BIGINT       DEFAULT NULL,
    `session_id`      VARCHAR(100) DEFAULT NULL,
    `query_text`      TEXT         NOT NULL,
    `query_vector_id` VARCHAR(200) DEFAULT NULL,
    `model_id`        BIGINT       DEFAULT NULL,
    `top_k`           SMALLINT     NOT NULL DEFAULT 10,
    `results`         JSON         DEFAULT NULL,
    `latency_ms`      SMALLINT     DEFAULT NULL,
    `clicked_result`  BIGINT       DEFAULT NULL,
    `search_type`     ENUM('product','faq','support','general') NOT NULL DEFAULT 'product',
    `searched_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_sem_search_uuid`    (`uuid`),
    INDEX `idx_sem_search_user_id`     (`user_id`),
    INDEX `idx_sem_search_searched_at` (`searched_at`),
    CONSTRAINT `fk_sem_search_user`  FOREIGN KEY (`user_id`)  REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT `fk_sem_search_model` FOREIGN KEY (`model_id`) REFERENCES `ai_model_registry` (`id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Semantic search query log'
  PARTITION BY RANGE (YEAR(`searched_at`)) (
      PARTITION p2026 VALUES LESS THAN (2027),
      PARTITION p2027 VALUES LESS THAN (2028),
      PARTITION p_future VALUES LESS THAN MAXVALUE
  );
