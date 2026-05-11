-- changeset pranithreddym:1.2.0-002
-- comment: Create ai_recommendations table

CREATE TABLE IF NOT EXISTS `ai_recommendations` (
    `id`              BIGINT   NOT NULL AUTO_INCREMENT,
    `uuid`            VARCHAR(36)  NOT NULL,
    `user_id`         BIGINT   NOT NULL,
    `model_id`        BIGINT   NOT NULL,
    `context_type`    ENUM('homepage','product_page','cart','post_purchase','email','search') NOT NULL DEFAULT 'homepage',
    `context_id`      BIGINT   DEFAULT NULL,
    `recommended_ids` JSON     NOT NULL,
    `scores`          JSON     DEFAULT NULL,
    `explanation`     TEXT     DEFAULT NULL,
    `algorithm`       VARCHAR(100) DEFAULT NULL,
    `served_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `clicked_ids`     JSON     DEFAULT NULL,
    `purchased_ids`   JSON     DEFAULT NULL,
    `feedback_score`  TINYINT  DEFAULT NULL,
    `expires_at`      DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_ai_rec_uuid`      (`uuid`),
    INDEX `idx_ai_rec_user_id`       (`user_id`),
    INDEX `idx_ai_rec_model_id`      (`model_id`),
    INDEX `idx_ai_rec_served_at`     (`served_at`),
    CONSTRAINT `fk_ai_rec_user`  FOREIGN KEY (`user_id`)  REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_ai_rec_model` FOREIGN KEY (`model_id`) REFERENCES `ai_model_registry` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='AI-generated product recommendations'
  PARTITION BY RANGE (YEAR(`served_at`)) (
      PARTITION p2026 VALUES LESS THAN (2027),
      PARTITION p2027 VALUES LESS THAN (2028),
      PARTITION p_future VALUES LESS THAN MAXVALUE
  );
