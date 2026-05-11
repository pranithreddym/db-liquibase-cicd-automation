-- changeset pranithreddym:1.2.0-001
-- comment: Create ai_model_registry table

CREATE TABLE IF NOT EXISTS `ai_model_registry` (
    `id`              BIGINT          NOT NULL AUTO_INCREMENT,
    `uuid`            VARCHAR(36)     NOT NULL,
    `name`            VARCHAR(150)    NOT NULL,
    `version`         VARCHAR(30)     NOT NULL,
    `model_type`      ENUM('recommendation','classification','regression','embedding','llm','ranking','anomaly_detection') NOT NULL,
    `framework`       VARCHAR(100)    NOT NULL,
    `artifact_uri`    VARCHAR(1000)   NOT NULL,
    `input_schema`    JSON            DEFAULT NULL,
    `output_schema`   JSON            DEFAULT NULL,
    `hyperparameters` JSON            DEFAULT NULL,
    `metrics`         JSON            DEFAULT NULL,
    `status`          ENUM('training','staging','champion','retired') NOT NULL DEFAULT 'staging',
    `champion_since`  DATETIME        DEFAULT NULL,
    `retired_at`      DATETIME        DEFAULT NULL,
    `trained_by`      BIGINT          DEFAULT NULL,
    `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_model_registry_uuid`         (`uuid`),
    UNIQUE KEY `uq_model_registry_name_version` (`name`, `version`),
    INDEX `idx_model_registry_type`             (`model_type`),
    INDEX `idx_model_registry_status`           (`status`),
    INDEX `idx_model_registry_trained_by`       (`trained_by`),
    CONSTRAINT `fk_model_registry_trained_by`
        FOREIGN KEY (`trained_by`) REFERENCES `users` (`id`)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Registry of all ML/AI models';
