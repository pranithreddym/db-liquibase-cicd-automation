-- changeset pranithreddym:1.1.0-003
-- comment: Create audit_log table for tracking all data changes

CREATE TABLE IF NOT EXISTS `audit_log` (
    `id`          BIGINT          NOT NULL AUTO_INCREMENT,
    `table_name`  VARCHAR(100)    NOT NULL,
    `record_id`   BIGINT          NOT NULL,
    `action`      ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    `old_values`  JSON                    DEFAULT NULL,
    `new_values`  JSON                    DEFAULT NULL,
    `changed_by`  BIGINT                  DEFAULT NULL,
    `ip_address`  VARCHAR(45)             DEFAULT NULL,
    `user_agent`  VARCHAR(500)            DEFAULT NULL,
    `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_audit_log_table_record` (`table_name`, `record_id`),
    INDEX `idx_audit_log_action`       (`action`),
    INDEX `idx_audit_log_changed_by`   (`changed_by`),
    INDEX `idx_audit_log_created_at`   (`created_at`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Immutable audit trail for data changes'
  PARTITION BY RANGE (YEAR(`created_at`)) (
      PARTITION p2026 VALUES LESS THAN (2027),
      PARTITION p2027 VALUES LESS THAN (2028),
      PARTITION p_future VALUES LESS THAN MAXVALUE
  );
