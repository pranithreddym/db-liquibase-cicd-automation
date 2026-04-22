#!/usr/bin/env bash
# test-migrations.sh — End-to-end test: spin up MySQL, run migrations, verify schema
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
COMPOSE_FILE="${ROOT_DIR}/docker/docker-compose.yml"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die()  { log "ERROR: $*" >&2; exit 1; }
ok()   { log "PASS: $*"; }
fail() { log "FAIL: $*" >&2; FAILURES=$((FAILURES+1)); }

FAILURES=0

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-rootpassword}"
MYSQL_DATABASE="${MYSQL_DATABASE:-appdb}"
MYSQL_USER="${MYSQL_USER:-appuser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-apppassword}"

MYSQL_CLI="docker-compose -f $COMPOSE_FILE exec -T mysql mysql \
    -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE"

command -v docker-compose >/dev/null 2>&1 || DOCKER_COMPOSE="docker compose"
DOCKER_COMPOSE="${DOCKER_COMPOSE:-docker-compose}"

log "=== Starting test environment ==="
$DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d mysql

log "Waiting for MySQL..."
RETRIES=30
until $DOCKER_COMPOSE -f "$COMPOSE_FILE" exec -T mysql \
    mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" --silent 2>/dev/null; do
    RETRIES=$((RETRIES-1))
    [[ $RETRIES -le 0 ]] && die "MySQL timeout"
    sleep 3
done
ok "MySQL is up"

log "=== Running migrations ==="
$DOCKER_COMPOSE -f "$COMPOSE_FILE" up liquibase
ok "Migrations applied"

log "=== Running schema verification ==="
mysql_exec() { $MYSQL_CLI -e "$1" 2>/dev/null; }
table_exists() { mysql_exec "SHOW TABLES LIKE '$1';" | grep -q "$1"; }
column_exists() { mysql_exec "SHOW COLUMNS FROM \`$1\` LIKE '$2';" | grep -q "$2"; }

# -- Table existence checks --
for tbl in users categories products orders order_items audit_log; do
    if table_exists "$tbl"; then
        ok "Table '$tbl' exists"
    else
        fail "Table '$tbl' MISSING"
    fi
done

# -- Column checks --
if column_exists "users" "account_status"; then
    ok "Column users.account_status exists (v1.1.0)"
else
    fail "Column users.account_status MISSING"
fi

if column_exists "categories" "parent_id"; then
    ok "Column categories.parent_id exists (v1.1.0)"
else
    fail "Column categories.parent_id MISSING"
fi

if column_exists "products" "tags"; then
    ok "Column products.tags exists (v1.1.0)"
else
    fail "Column products.tags MISSING"
fi

# -- Data checks --
log "=== Running data verification ==="
source "${SCRIPT_DIR}/sql/verify_data.sql" 2>/dev/null || true

CAT_COUNT=$(mysql_exec "SELECT COUNT(*) FROM categories;" | tail -1)
if [[ "$CAT_COUNT" -ge 5 ]]; then
    ok "Seed data: $CAT_COUNT categories found"
else
    fail "Seed data: expected >= 5 categories, got $CAT_COUNT"
fi

ADMIN_EXISTS=$(mysql_exec "SELECT COUNT(*) FROM users WHERE role='admin';" | tail -1)
if [[ "$ADMIN_EXISTS" -ge 1 ]]; then
    ok "Seed data: admin user found"
else
    fail "Seed data: admin user MISSING"
fi

# -- DATABASECHANGELOG check --
log "=== Checking DATABASECHANGELOG ==="
CS_COUNT=$(mysql_exec "SELECT COUNT(*) FROM DATABASECHANGELOG;" | tail -1)
if [[ "$CS_COUNT" -ge 7 ]]; then
    ok "DATABASECHANGELOG: $CS_COUNT entries recorded"
else
    fail "DATABASECHANGELOG: expected >= 7 entries, got $CS_COUNT"
fi

log "=== Rollback test (last 1 changeset) ==="
$DOCKER_COMPOSE -f "$COMPOSE_FILE" run --rm liquibase rollbackCount 1
if ! table_exists "audit_log"; then
    ok "Rollback removed audit_log as expected"
else
    fail "Rollback did not remove audit_log"
fi

log "=== Re-applying after rollback ==="
$DOCKER_COMPOSE -f "$COMPOSE_FILE" up liquibase
table_exists "audit_log" && ok "audit_log recreated after re-migration" || fail "audit_log missing after re-migration"

log ""
log "================================="
if [[ $FAILURES -eq 0 ]]; then
    log "ALL TESTS PASSED"
else
    log "$FAILURES TEST(S) FAILED"
    exit 1
fi
