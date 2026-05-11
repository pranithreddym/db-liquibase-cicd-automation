-- changeset pranithreddym:1.2.0-003
-- comment: Create ai_feature_store table

CREATE TABLE IF NOT EXISTS `ai_feature_store` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT,
    `entity_type`     ENUM('user','product','order') NOT NULL,
    `entity_id`       BIGINT       NOT NULL,
    `feature_group`   VARCHAR(100) NOT NULL,
    `feature_version` VARCHAR(20)  NOT NULL DEFAULT 'v1',
    `features`        JSON         NOT NULL,
    `feature_hash`    VARCHAR(64)  NOT NULL,
    `computed_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `valid_until`     DATETIME     DEFAULT NULL,
    `pipeline_run_id` VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_feature_store_entity_group_ver` (`entity_type`, `entity_id`, `feature_group`, `feature_version`),
    INDEX `idx_feature_store_entity`     (`entity_type`, `entity_id`),
    INDEX `idx_feature_store_group`      (`feature_group`),
    INDEX `idx_feature_store_computed_at`(`computed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Pre-computed ML feature vectors for low-latency serving';
