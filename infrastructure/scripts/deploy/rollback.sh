#!/usr/bin/env bash
# ──────────────────────────────────────────────
# rollback.sh — Production Rollback
# ──────────────────────────────────────────────
# Reverts the repository to a previous commit,
# rebuilds all applications, restarts them,
# and runs a health check.
#
# Usage:
#   ./deploy/rollback.sh                  # Previous commit
#   ./deploy/rollback.sh <commit-hash>    # Specific commit
#
# Future (Hermes):
#   Called automatically when health-check.sh
#   fails after a deployment.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/git.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"
source "$SCRIPT_DIR/../lib/health.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

cd "$PROJECT_ROOT"

info "=== Rollback ==="

git_revert_to "${1:-HEAD~1}"

info "Rebuilding backend..."
turbo build --filter="$BACKEND_FILTER"
success "Backend rebuilt."

info "Rebuilding frontend..."
turbo build --filter="$FRONTEND_FILTER"
success "Frontend rebuilt."

pm2_restart_all
sleep 3

if health_all; then
  success "Rollback complete."
  exit 0
else
  error "Rollback completed but health check failed."
  exit 1
fi
