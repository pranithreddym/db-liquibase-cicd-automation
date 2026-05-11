-- changeset pranithreddym:1.3.0-001
-- comment: Create vector_embeddings table

CREATE TABLE IF NOT EXISTS `vector_embeddings` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT,
    `uuid`            VARCHAR(36)  NOT NULL,
    `entity_type`     ENUM('product','user','query','document') NOT NULL,
    `entity_id`       BIGINT       NOT NULL,
    `model_id`        BIGINT       NOT NULL,
    `collection_name` VARCHAR(200) NOT NULL,
    `vector_id`       VARCHAR(200) NOT NULL,
    `dimensions`      SMALLINT     NOT NULL,
    `norm`            FLOAT        DEFAULT NULL,
    `metadata`        JSON         DEFAULT NULL,
    `embedded_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `invalidated_at`  DATETIME     DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_vec_emb_uuid`         (`uuid`),
    UNIQUE KEY `uq_vec_emb_entity_model` (`entity_type`, `entity_id`, `model_id`),
    INDEX `idx_vec_emb_collection`       (`collection_name`),
    INDEX `idx_vec_emb_model_id`         (`model_id`),
    CONSTRAINT `fk_vec_emb_model`
        FOREIGN KEY (`model_id`) REFERENCES `ai_model_registry` (`id`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Metadata bridge between MySQL entities and their vector representations';
