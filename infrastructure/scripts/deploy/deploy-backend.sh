#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy-backend.sh — Backend Deployment
# ──────────────────────────────────────────────
# Full backend deployment pipeline:
#   git pull → pnpm install → turbo build
#   → PM2 restart → health check
#
# Usage:
#   ./deploy/deploy-backend.sh
#
# Future (Hermes):
#   Called after backup-db.sh. Returns exit code 0
#   if deployment was successful, 1 on failure.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/checks.sh"
source "$SCRIPT_DIR/../lib/git.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"
source "$SCRIPT_DIR/../lib/health.sh"
source "$SCRIPT_DIR/../lib/docker.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

cd "$PROJECT_ROOT"

info "=== Backend Deployment ==="

preflight || exit 1
git_pull

info "Installing dependencies..."
pnpm install --frozen-lockfile
success "Dependencies installed."

info "Building backend..."
turbo build --filter="$BACKEND_FILTER"
success "Backend built."

pm2_restart_backend
sleep 2

if health_backend_http; then
  success "Backend deployment complete."
  exit 0
else
  error "Backend deployment failed — health check did not pass."
  exit 1
fi
