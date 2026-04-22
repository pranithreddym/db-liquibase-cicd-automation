# Liquibase MySQL CI/CD Automation

Production-ready database change management using **Liquibase** and **MySQL**, with a full **GitLab CI/CD** pipeline for automated deployments across dev → staging → production.

---

## Table of Contents

1. [Overview](#overview)
2. [Repository Structure](#repository-structure)
3. [Prerequisites](#prerequisites)
4. [Quick Start (Local)](#quick-start-local)
5. [Liquibase Configuration](#liquibase-configuration)
6. [Changelog Structure](#changelog-structure)
7. [Running Migrations](#running-migrations)
8. [Rollback Strategy](#rollback-strategy)
9. [Testing](#testing)
10. [GitLab CI/CD Pipeline](#gitlab-cicd-pipeline)
11. [Adding New Changesets](#adding-new-changesets)
12. [Environment Variables Reference](#environment-variables-reference)
13. [Troubleshooting](#troubleshooting)

---

## Overview

| Tool        | Purpose                                  |
|-------------|------------------------------------------|
| Liquibase   | Database version control & migrations    |
| MySQL 8.0   | Target database                          |
| Docker      | Local MySQL environment                  |
| GitLab CI   | Automated deployment pipeline            |
| Bash        | Helper scripts for init / rollback / tag |

### How it works

```
Developer writes SQL → adds XML changeset → opens MR
      ↓
GitLab CI: validate → test (ephemeral DB) → deploy-dev (auto)
      ↓
Release branch → deploy-staging (auto)
      ↓
Git tag → deploy-prod (manual approval)
```

---

## Repository Structure

```
db-liquibase-cicd-automation/
├── .gitlab-ci.yml                        # GitLab pipeline definition
├── .gitignore
├── .env.example                          # Template for local secrets
├── README.md
│
├── docker/
│   ├── docker-compose.yml                # MySQL + Liquibase services
│   └── mysql/
│       └── init.sql                      # DB & user creation on first boot
│
├── liquibase/
│   ├── liquibase.properties              # Default (local) connection
│   ├── liquibase-dev.properties
│   ├── liquibase-staging.properties
│   ├── liquibase-prod.properties
│   └── changelog/
│       ├── db.changelog-master.xml       # Master include list
│       └── releases/
│           ├── v1.0.0/
│           │   ├── db.changelog-1.0.0.xml
│           │   └── sql/
│           │       ├── 001_create_users_table.sql
│           │       ├── 001_create_users_table_rollback.sql
│           │       ├── 002_create_products_table.sql
│           │       ├── 002_create_products_table_rollback.sql
│           │       ├── 003_create_orders_table.sql
│           │       ├── 003_create_orders_table_rollback.sql
│           │       ├── 004_seed_reference_data.sql
│           │       └── 004_seed_reference_data_rollback.sql
│           └── v1.1.0/
│               ├── db.changelog-1.1.0.xml
│               └── sql/
│                   ├── 001_add_user_status.sql
│                   ├── 001_add_user_status_rollback.sql
│                   ├── 002_add_product_category.sql
│                   ├── 002_add_product_category_rollback.sql
│                   ├── 003_create_audit_log.sql
│                   └── 003_create_audit_log_rollback.sql
│
├── scripts/
│   ├── init-db.sh                        # Start Docker MySQL
│   ├── run-migrations.sh                 # Apply Liquibase migrations
│   ├── rollback.sh                       # Roll back by count / tag / date
│   ├── tag-release.sh                    # Tag a checkpoint in DATABASECHANGELOG
│   └── validate.sh                       # Validate changelog & DB state
│
└── tests/
    ├── test-migrations.sh                # Full end-to-end test
    └── sql/
        ├── verify_schema.sql             # Manual schema inspection queries
        └── verify_data.sql               # Seed data verification queries
```

---

## Prerequisites

| Requirement      | Version  | Install                                      |
|------------------|----------|----------------------------------------------|
| Docker           | 24+      | https://docs.docker.com/get-docker/           |
| Docker Compose   | v2+      | Bundled with Docker Desktop                  |
| Liquibase CLI    | 4.25+    | https://www.liquibase.org/download           |
| MySQL client     | 8.0+     | `brew install mysql-client` / `apt install mysql-client` |
| Java             | 17+      | Required by Liquibase CLI                    |

---

## Quick Start (Local)

### 1. Clone and configure

```bash
git clone <repo-url>
cd db-liquibase-cicd-automation
cp .env.example .env          # edit if needed
```

### 2. Start MySQL

```bash
bash scripts/init-db.sh
# MySQL is now running on localhost:3306
```

### 3. Run all migrations

```bash
bash scripts/run-migrations.sh dev
```

Expected output:
```
[2026-01-15 10:00:00] Running Liquibase status check for [dev]...
[2026-01-15 10:00:01] Applying migrations for [dev]...
Liquibase: Update has been successful.
[2026-01-15 10:00:03] Migration complete for [dev].
```

### 4. Verify

```bash
# Check schema
mysql -h 127.0.0.1 -u appuser -papppassword appdb < tests/sql/verify_schema.sql

# Check seed data
mysql -h 127.0.0.1 -u appuser -papppassword appdb < tests/sql/verify_data.sql
```

### 5. (Optional) Run full end-to-end test

```bash
bash tests/test-migrations.sh
```

---

## Liquibase Configuration

Each environment has its own properties file under `liquibase/`:

| File                          | Environment       |
|-------------------------------|-------------------|
| `liquibase.properties`        | Local default     |
| `liquibase-dev.properties`    | Development       |
| `liquibase-staging.properties`| Staging           |
| `liquibase-prod.properties`   | Production        |

Sensitive values (`DB_USER`, `DB_PASSWORD`, `DB_HOST`) are injected via environment variables — never hardcoded.

---

## Changelog Structure

The master changelog at `liquibase/changelog/db.changelog-master.xml` includes release files in order:

```xml
<include file="changelog/releases/v1.0.0/db.changelog-1.0.0.xml"/>
<include file="changelog/releases/v1.1.0/db.changelog-1.1.0.xml"/>
```

Each release changelog references SQL files with explicit rollback SQL files.

### Changeset ID convention

```
<major>.<minor>.<patch>-<sequence>
```

Examples: `1.0.0-001`, `1.1.0-003`

---

## Running Migrations

```bash
# Apply all pending changesets
bash scripts/run-migrations.sh dev

# Preview SQL that would run (dry-run)
liquibase --defaultsFile=liquibase/liquibase-dev.properties updateSQL

# Check pending changesets
liquibase --defaultsFile=liquibase/liquibase-dev.properties status --verbose

# View change history
liquibase --defaultsFile=liquibase/liquibase-dev.properties history
```

---

## Rollback Strategy

Liquibase supports three rollback modes. **Every changeset in this repo has a matching rollback SQL file.**

### Roll back by count (most recent N changesets)

```bash
bash scripts/rollback.sh dev 1        # undo last 1 changeset
bash scripts/rollback.sh staging 3    # undo last 3 changesets
```

### Roll back to a tag

```bash
# First, tag a known-good state
bash scripts/tag-release.sh dev v1.0.0

# Later, roll back to that tag
bash scripts/rollback.sh dev tag v1.0.0
```

### Roll back to a date

```bash
bash scripts/rollback.sh dev date 2026-01-20
```

### Production rollback procedure

1. **Do not** run rollback directly on prod without a change ticket.
2. Run `updateSQL` first to preview what will change.
3. Take a database snapshot / backup.
4. Apply rollback during a maintenance window.
5. Notify the team via your incident management tool.

---

## Testing

### Automated end-to-end test

```bash
bash tests/test-migrations.sh
```

This script:
1. Starts a clean MySQL container
2. Runs all Liquibase migrations
3. Verifies all tables exist
4. Checks seed data counts
5. Tests rollback of the last changeset
6. Re-applies the rolled-back changeset

### Manual SQL verification

```bash
# Schema inspection
mysql -h 127.0.0.1 -u appuser -papppassword appdb \
  -e "SHOW TABLES; DESCRIBE users; DESCRIBE orders;"

# Check Liquibase tracking table
mysql -h 127.0.0.1 -u appuser -papppassword appdb \
  -e "SELECT ID, AUTHOR, DATEEXECUTED, EXECTYPE FROM DATABASECHANGELOG;"

# Validate changelog XML (no DB connection needed)
liquibase --defaultsFile=liquibase/liquibase.properties validate
```

---

## GitLab CI/CD Pipeline

### Pipeline stages

```
validate → test → deploy-dev → deploy-staging → deploy-prod
```

| Stage            | Trigger                     | Approval |
|------------------|-----------------------------|----------|
| `validate`       | Every MR + main             | Auto     |
| `test`           | Every MR + main             | Auto     |
| `deploy-dev`     | Push to `main` / `develop`  | Auto     |
| `deploy-staging` | Push to `release/*` branch  | Auto     |
| `deploy-prod`    | Git tag pushed              | **Manual** |

### Required GitLab CI/CD variables

Set these in **Settings → CI/CD → Variables** (mark as masked):

| Variable           | Description                  |
|--------------------|------------------------------|
| `DEV_DB_HOST`      | Dev database hostname        |
| `DEV_DB_NAME`      | Dev database name            |
| `DEV_DB_USER`      | Dev database user            |
| `DEV_DB_PASSWORD`  | Dev database password        |
| `STAGING_DB_HOST`  | Staging database hostname    |
| `STAGING_DB_NAME`  | Staging database name        |
| `STAGING_DB_USER`  | Staging database user        |
| `STAGING_DB_PASSWORD` | Staging database password |
| `PROD_DB_HOST`     | Production database hostname |
| `PROD_DB_NAME`     | Production database name     |
| `PROD_DB_USER`     | Production database user     |
| `PROD_DB_PASSWORD` | Production database password |

### Deploying to production

```bash
# 1. Create and push a git tag
git tag v1.1.0
git push origin v1.1.0

# 2. In GitLab: navigate to CI/CD → Pipelines
# 3. Click the manual "deploy:prod:dry-run" job — review the SQL output
# 4. Click the manual "deploy:prod" job to apply
```

---

## Adding New Changesets

1. **Create a new release directory** (increment version):
   ```
   liquibase/changelog/releases/v1.2.0/
   ├── db.changelog-1.2.0.xml
   └── sql/
       ├── 001_<description>.sql
       └── 001_<description>_rollback.sql
   ```

2. **Write the SQL** in `001_<description>.sql`:
   ```sql
   -- changeset pranithreddym:1.2.0-001
   -- comment: Add payment_methods table
   CREATE TABLE `payment_methods` ( ... );
   ```

3. **Write the rollback SQL** in `001_<description>_rollback.sql`:
   ```sql
   DROP TABLE IF EXISTS `payment_methods`;
   ```

4. **Add the changeset to the release changelog** `db.changelog-1.2.0.xml`:
   ```xml
   <changeSet id="1.2.0-001" author="pranithreddym">
       <comment>Add payment_methods table</comment>
       <sqlFile path="changelog/releases/v1.2.0/sql/001_add_payment_methods.sql"
                relativeToChangelogFile="false" encoding="UTF-8"/>
       <rollback>
           <sqlFile path="changelog/releases/v1.2.0/sql/001_add_payment_methods_rollback.sql"
                    relativeToChangelogFile="false" encoding="UTF-8"/>
       </rollback>
   </changeSet>
   ```

5. **Include the new release** in `db.changelog-master.xml`:
   ```xml
   <include file="changelog/releases/v1.2.0/db.changelog-1.2.0.xml"/>
   ```

6. **Test locally**, then open a merge request.

---

## Environment Variables Reference

| Variable              | Default          | Description                   |
|-----------------------|------------------|-------------------------------|
| `MYSQL_ROOT_PASSWORD` | `rootpassword`   | MySQL root password (Docker)  |
| `MYSQL_DATABASE`      | `appdb`          | Database name                 |
| `MYSQL_USER`          | `appuser`        | Application DB user           |
| `MYSQL_PASSWORD`      | `apppassword`    | Application DB password       |
| `DB_HOST`             | `localhost`      | DB host for migration scripts |
| `DB_NAME`             | `appdb`          | DB name for migration scripts |
| `DB_USER`             | —                | DB user (env-specific)        |
| `DB_PASSWORD`         | —                | DB password (env-specific)    |

---

## Troubleshooting

### MySQL container won't start

```bash
docker-compose -f docker/docker-compose.yml logs mysql
# Check for port conflicts: lsof -i :3306
```

### Liquibase checksum mismatch

A changeset was modified after it was applied. **Never modify applied changesets.** To fix:
```bash
liquibase --defaultsFile=liquibase/liquibase-dev.properties clearCheckSums
liquibase --defaultsFile=liquibase/liquibase-dev.properties update
```

### `validate` fails with XML error

```bash
# Check the specific file Liquibase reports
liquibase --defaultsFile=liquibase/liquibase-dev.properties validate
# Fix the XML, then re-run
```

### Migration fails mid-way

Liquibase wraps each changeset in a transaction (where supported). For failed non-transactional DDL:
1. Identify what was applied: `SELECT * FROM DATABASECHANGELOG ORDER BY ORDEREXECUTED DESC LIMIT 10;`
2. Manually revert the partial change if needed.
3. Delete the failed entry from `DATABASECHANGELOG` if it was recorded as `FAILED`.
4. Fix the changeset and re-run.

### Connection refused in CI

Ensure the service alias in `.gitlab-ci.yml` matches the hostname used in the JDBC URL (`mysql` → `jdbc:mysql://mysql:3306/...`).

---

## Author

**Pranith Reddy M**
