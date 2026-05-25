## 2026-05-25

- **Liquibase updated**: `4.25` → `5.0.3` in `.gitlab-ci.yml`

### Migration Advisor

```
Latest version : v1.3.0
Target version : v1.4.0

============================================================
SCHEMA ANALYSIS REPORT
============================================================

[1] Table : orders
    Type  : column_addition
    Hint  : Add status_changed_at DATETIME column and an idx on it for time-series queries on status transitions.
    File  : liquibase/changelog/releases/v1.0.0/sql/003_create_orders_table.sql

[2] Table : orders
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.0.0/sql/003_create_orders_table.sql

[3] Table : audit_log
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.1.0/sql/003_create_audit_log.sql

[4] Table : audit_log
    Type  : timestamp_addition
    Hint  : Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP.
    File  : liquibase/changelog/releases/v1.1.0/sql/003_create_audit_log.sql

[5] Table : ai_model_registry
    Type  : column_addition
    Hint  : Add status_changed_at DATETIME column and an idx on it for time-series queries on status transitions.
    File  : liquibase/changelog/releases/v1.2.0/sql/001_create_ai_model_registry.sql

[6] Table : ai_recommendations
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.2.0/sql/002_create_ai_recommendations.sql

[7] Table : ai_feature_store
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.2.0/sql/003_create_ai_feature_store.sql

[8] Table : vector_embeddings
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.3.0/sql/001_create_vector_embeddings.sql

[9] Table : semantic_search_log
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.3.0/sql/002_create_semantic_search_log.sql

============================================================
DRY RUN — would create: liquibase/changelog/releases/v1.4.0/db.changelog-1.4.0.xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <!-- ==========================================
         Release: v1.4.0
         Description: Advisor-generated migrations
         Author: Pranith Reddy M
         Date: 2026-05-25
         ========================================== -->

    <changeSet id="1.4.0-001" author="pranithreddym">
        <comment>Column Addition on orders: Add status_changed_at DATETIME column and an idx on it for time-series queries o</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/001_column-addition_orders.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/001_column-addition_orders_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-002" author="pranithreddym">
        <comment>Soft Delete on orders: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/002_soft-delete_orders.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/002_soft-delete_orders_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-003" author="pranithreddym">
        <comment>Soft Delete on audit_log: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/003_soft-delete_audit_log.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/003_soft-delete_audit_log_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-004" author="pranithreddym">
        <comment>Timestamp Addition on audit_log: Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIM</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/004_timestamp-addition_audit_log.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/004_timestamp-addition_audit_log_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-005" author="pranithreddym">
        <comment>Column Addition on ai_model_registry: Add status_changed_at DATETIME column and an idx on it for time-series queries o</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/005_column-addition_ai_model_registry.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/005_column-addition_ai_model_registry_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

</databaseChangeLog>


  changeset: 1.4.0-001 — Column Addition on orders: Add status_changed_at DATETIME column and an idx on it for time-series queries o

  changeset: 1.4.0-002 — Soft Delete on orders: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.

  changeset: 1.4.0-003 — Soft Delete on audit_log: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.

  changeset: 1.4.0-004 — Timestamp Addition on audit_log: Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIM

  changeset: 1.4.0-005 — Column Addition on ai_model_registry: Add status_changed_at DATETIME column and an idx on it for time-series queries o
```

---

## 2026-05-18

- Liquibase image: `4.25` (no change)

### Migration Advisor

```
Latest version : v1.3.0
Target version : v1.4.0

============================================================
SCHEMA ANALYSIS REPORT
============================================================

[1] Table : orders
    Type  : column_addition
    Hint  : Add status_changed_at DATETIME column and an idx on it for time-series queries on status transitions.
    File  : liquibase/changelog/releases/v1.0.0/sql/003_create_orders_table.sql

[2] Table : orders
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.0.0/sql/003_create_orders_table.sql

[3] Table : audit_log
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.1.0/sql/003_create_audit_log.sql

[4] Table : audit_log
    Type  : timestamp_addition
    Hint  : Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP.
    File  : liquibase/changelog/releases/v1.1.0/sql/003_create_audit_log.sql

[5] Table : ai_model_registry
    Type  : column_addition
    Hint  : Add status_changed_at DATETIME column and an idx on it for time-series queries on status transitions.
    File  : liquibase/changelog/releases/v1.2.0/sql/001_create_ai_model_registry.sql

[6] Table : ai_recommendations
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.2.0/sql/002_create_ai_recommendations.sql

[7] Table : ai_feature_store
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.2.0/sql/003_create_ai_feature_store.sql

[8] Table : vector_embeddings
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.3.0/sql/001_create_vector_embeddings.sql

[9] Table : semantic_search_log
    Type  : soft_delete
    Hint  : Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.
    File  : liquibase/changelog/releases/v1.3.0/sql/002_create_semantic_search_log.sql

============================================================
DRY RUN — would create: liquibase/changelog/releases/v1.4.0/db.changelog-1.4.0.xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <!-- ==========================================
         Release: v1.4.0
         Description: Advisor-generated migrations
         Author: Pranith Reddy M
         Date: 2026-05-18
         ========================================== -->

    <changeSet id="1.4.0-001" author="pranithreddym">
        <comment>Column Addition on orders: Add status_changed_at DATETIME column and an idx on it for time-series queries o</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/001_column-addition_orders.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/001_column-addition_orders_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-002" author="pranithreddym">
        <comment>Soft Delete on orders: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/002_soft-delete_orders.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/002_soft-delete_orders_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-003" author="pranithreddym">
        <comment>Soft Delete on audit_log: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/003_soft-delete_audit_log.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/003_soft-delete_audit_log_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-004" author="pranithreddym">
        <comment>Timestamp Addition on audit_log: Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIM</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/004_timestamp-addition_audit_log.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/004_timestamp-addition_audit_log_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

    <changeSet id="1.4.0-005" author="pranithreddym">
        <comment>Column Addition on ai_model_registry: Add status_changed_at DATETIME column and an idx on it for time-series queries o</comment>
        <sqlFile path="changelog/releases/v1.4.0/sql/005_column-addition_ai_model_registry.sql"
                 relativeToChangelogFile="false"
                 encoding="UTF-8"/>
        <rollback>
            <sqlFile path="changelog/releases/v1.4.0/sql/005_column-addition_ai_model_registry_rollback.sql"
                     relativeToChangelogFile="false"
                     encoding="UTF-8"/>
        </rollback>
    </changeSet>

</databaseChangeLog>


  changeset: 1.4.0-001 — Column Addition on orders: Add status_changed_at DATETIME column and an idx on it for time-series queries o

  changeset: 1.4.0-002 — Soft Delete on orders: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.

  changeset: 1.4.0-003 — Soft Delete on audit_log: Add soft-delete support: deleted_at DATETIME DEFAULT NULL + index.

  changeset: 1.4.0-004 — Timestamp Addition on audit_log: Add updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIM

  changeset: 1.4.0-005 — Column Addition on ai_model_registry: Add status_changed_at DATETIME column and an idx on it for time-series queries o
```

---

# Liquibase DB Sync Log

Automated entries appended by `scripts/ai/liquibase_sync.py`.

---

## 2026-05-07 (initial)

- Repository created with v1.0.0 – v1.3.0 changesets
- AI infrastructure layer added (v1.2.0): `ai_model_registry`, `ai_recommendations`, `ai_feature_store`
- Vector search layer added (v1.3.0): `vector_embeddings`, `semantic_search_log`
- GitHub Actions scheduled sync workflow enabled

---
