#!/usr/bin/env bash
# run-migrations.sh — Execute Liquibase update for a given environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIQUIBASE_DIR="${SCRIPT_DIR}/../liquibase"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }
usage() { echo "Usage: $0 [dev|staging|prod]"; exit 1; }

ENV="${1:-dev}"
case "$ENV" in
    dev|staging|prod) ;;
    *) usage ;;
esac

PROPS_FILE="${LIQUIBASE_DIR}/liquibase-${ENV}.properties"
[[ -f "$PROPS_FILE" ]] || die "Properties file not found: $PROPS_FILE"

ENV_FILE="${SCRIPT_DIR}/../.env.${ENV}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; log "Loaded $ENV_FILE"; }

command -v liquibase >/dev/null 2>&1 || die "liquibase CLI not found. Install from https://www.liquibase.org/download"

log "Running Liquibase status check for [$ENV]..."
liquibase --defaultsFile="$PROPS_FILE" status --verbose

log "Applying migrations for [$ENV]..."
liquibase --defaultsFile="$PROPS_FILE" update

log "Migration complete for [$ENV]."
