#!/usr/bin/env bash
# init-db.sh — Start MySQL via Docker Compose and wait for it to be ready
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/../docker/docker-compose.yml"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

command -v docker  >/dev/null 2>&1 || die "docker not found"
command -v docker-compose >/dev/null 2>&1 || DOCKER_COMPOSE="docker compose" || die "docker compose not found"
DOCKER_COMPOSE="${DOCKER_COMPOSE:-docker-compose}"

ENV_FILE="${SCRIPT_DIR}/../.env"
if [[ -f "$ENV_FILE" ]]; then
    log "Loading environment from .env"
    set -a; source "$ENV_FILE"; set +a
fi

log "Starting MySQL container..."
$DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d mysql

log "Waiting for MySQL to be healthy..."
RETRIES=30
until $DOCKER_COMPOSE -f "$COMPOSE_FILE" exec -T mysql \
    mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-rootpassword}" --silent 2>/dev/null; do
    RETRIES=$((RETRIES - 1))
    [[ $RETRIES -le 0 ]] && die "MySQL did not start in time"
    log "  still waiting ($RETRIES retries left)..."
    sleep 3
done

log "MySQL is ready."
log "Database: ${MYSQL_DATABASE:-appdb}"
log "User    : ${MYSQL_USER:-appuser}"
