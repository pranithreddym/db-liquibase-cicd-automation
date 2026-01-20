#!/usr/bin/env bash
# tag-release.sh — Tag a Liquibase checkpoint so rollbacks can target it
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIQUIBASE_DIR="${SCRIPT_DIR}/../liquibase"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

[[ $# -lt 2 ]] && { echo "Usage: $0 <env> <tag>"; exit 1; }

ENV="$1"
TAG="$2"

PROPS_FILE="${LIQUIBASE_DIR}/liquibase-${ENV}.properties"
[[ -f "$PROPS_FILE" ]] || die "Properties file not found: $PROPS_FILE"

ENV_FILE="${SCRIPT_DIR}/../.env.${ENV}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

command -v liquibase >/dev/null 2>&1 || die "liquibase CLI not found"

log "Tagging database at [$ENV] with tag: $TAG"
liquibase --defaultsFile="$PROPS_FILE" tag "$TAG"
log "Tag '$TAG' applied successfully."
