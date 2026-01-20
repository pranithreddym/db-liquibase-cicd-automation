#!/usr/bin/env bash
# rollback.sh — Roll back Liquibase changesets
#
# Usage:
#   ./rollback.sh dev 1              # roll back last 1 changeset
#   ./rollback.sh staging 3          # roll back last 3 changesets
#   ./rollback.sh prod tag v1.0.0    # roll back to tag
#   ./rollback.sh prod date 2026-01-20  # roll back to date
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIQUIBASE_DIR="${SCRIPT_DIR}/../liquibase"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die()  { log "ERROR: $*" >&2; exit 1; }
usage() {
    echo "Usage:"
    echo "  $0 <env> <count>              Roll back N changesets"
    echo "  $0 <env> tag <tag-name>       Roll back to a tag"
    echo "  $0 <env> date <YYYY-MM-DD>    Roll back to a date"
    exit 1
}

[[ $# -lt 2 ]] && usage

ENV="$1"
case "$ENV" in dev|staging|prod) ;; *) die "Unknown env: $ENV"; esac

PROPS_FILE="${LIQUIBASE_DIR}/liquibase-${ENV}.properties"
[[ -f "$PROPS_FILE" ]] || die "Properties file not found: $PROPS_FILE"

ENV_FILE="${SCRIPT_DIR}/../.env.${ENV}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

command -v liquibase >/dev/null 2>&1 || die "liquibase CLI not found"

if [[ "$2" == "tag" ]]; then
    [[ $# -lt 3 ]] && usage
    TAG="$3"
    log "Rolling back to tag: $TAG (env=$ENV)"
    liquibase --defaultsFile="$PROPS_FILE" rollback "$TAG"

elif [[ "$2" == "date" ]]; then
    [[ $# -lt 3 ]] && usage
    ROLLBACK_DATE="$3"
    log "Rolling back to date: $ROLLBACK_DATE (env=$ENV)"
    liquibase --defaultsFile="$PROPS_FILE" rollbackToDate "$ROLLBACK_DATE"

elif [[ "$2" =~ ^[0-9]+$ ]]; then
    COUNT="$2"
    log "Rolling back last $COUNT changeset(s) (env=$ENV)"
    liquibase --defaultsFile="$PROPS_FILE" rollbackCount "$COUNT"

else
    usage
fi

log "Rollback complete."
