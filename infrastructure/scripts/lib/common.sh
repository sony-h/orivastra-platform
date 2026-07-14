#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — Shared Library
# ──────────────────────────────────────────────
# Colors, logging, project constants, and
# utility functions used by every script.
#
# Usage:
#   source "$(dirname "$0")/lib/common.sh"
# ──────────────────────────────────────────────

# Prevent multiple sourcing
[[ -n "${ORIVASTRA_COMMON_LOADED:-}" ]] && return
readonly ORIVASTRA_COMMON_LOADED=1

set -Eeuo pipefail

# ── Colors ───────────────────────────────────
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ── Project Paths ────────────────────────────
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly INFRA_DIR="$PROJECT_ROOT/infrastructure"
readonly SCRIPTS_DIR="$INFRA_DIR/scripts"
readonly COMPOSE_FILE="$INFRA_DIR/compose/compose.infrastructure.yml"
readonly LEGACY_DOCKERFILES="$INFRA_DIR/legacy/dockerfiles"

# ── Application Constants ────────────────────
readonly BACKEND_PM2_NAME="backend"
readonly FRONTEND_PM2_NAME="frontend"
readonly BACKEND_PORT=3001
readonly FRONTEND_PORT=3000
readonly BACKEND_HEALTH_URL="http://localhost:${BACKEND_PORT}/health"
readonly FRONTEND_HEALTH_URL="http://localhost:${FRONTEND_PORT}"
readonly BACKEND_FILTER="@orivastra/backend"
readonly FRONTEND_FILTER="@orivastra/frontend"

# ── Infrastructure Constants ─────────────────
readonly POSTGRES_SERVICE="postgres"
readonly REDIS_SERVICE="redis"
readonly POSTGRES_USER="orivastra"
readonly POSTGRES_DB="orivastra"
readonly INFRA_EXPECTED_CONTAINERS=2

# ── Database ─────────────────────────────────
readonly BACKUP_DIR="/opt/orivastra/backups"

# ── Logging ──────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }

# ── Help ─────────────────────────────────────
show_help() {
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
}

# ── Utility ──────────────────────────────────
require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root."
    exit 1
  fi
}

confirm() {
  local prompt="${1:-Continue?}"
  local response
  read -r -p "$prompt [y/N] " response
  case "$response" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}
