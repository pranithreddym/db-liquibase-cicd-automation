#!/usr/bin/env bash
# validate.sh — Validate Liquibase changelog and database state
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIQUIBASE_DIR="${SCRIPT_DIR}/../liquibase"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die()  { log "ERROR: $*" >&2; exit 1; }
ok()   { log "OK: $*"; }

ENV="${1:-dev}"
case "$ENV" in dev|staging|prod) ;; *) die "Unknown env: $ENV"; esac

PROPS_FILE="${LIQUIBASE_DIR}/liquibase-${ENV}.properties"
[[ -f "$PROPS_FILE" ]] || die "Properties file not found: $PROPS_FILE"

ENV_FILE="${SCRIPT_DIR}/../.env.${ENV}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

command -v liquibase >/dev/null 2>&1 || die "liquibase CLI not found"

log "=== Liquibase Validation: [$ENV] ==="

log "1) Validating changelog XML syntax..."
liquibase --defaultsFile="$PROPS_FILE" validate && ok "Changelog is valid"

log "2) Checking pending changesets..."
liquibase --defaultsFile="$PROPS_FILE" status --verbose

log "3) Generating changelog diff report..."
liquibase --defaultsFile="$PROPS_FILE" diff || true

log "4) Checking DATABASECHANGELOG history..."
liquibase --defaultsFile="$PROPS_FILE" history

log "=== Validation complete ==="
