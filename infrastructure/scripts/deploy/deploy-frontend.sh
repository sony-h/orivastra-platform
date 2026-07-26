#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy-frontend.sh — Frontend Deployment
# ──────────────────────────────────────────────
# Full frontend deployment pipeline:
#   git pull → pnpm install → turbo build
#   → PM2 restart → health check
#
# Usage:
#   ./deploy/deploy-frontend.sh
#
# Future (Hermes):
#   Called for frontend-only updates.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/checks.sh"
source "$SCRIPT_DIR/../lib/git.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"
source "$SCRIPT_DIR/../lib/health.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

cd "$PROJECT_ROOT"

info "=== Frontend Deployment ==="

preflight || exit 1
git_pull

info "Installing dependencies..."
pnpm install --frozen-lockfile
success "Dependencies installed."

info "Building frontend..."
turbo build --filter="$FRONTEND_FILTER"
success "Frontend built."

pm2_restart_frontend
sleep 2

if health_frontend_http; then
  success "Frontend deployment complete."
  exit 0
else
  error "Frontend deployment failed — health check did not pass."
  exit 1
fi
