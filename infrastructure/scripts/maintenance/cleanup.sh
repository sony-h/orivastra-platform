#!/usr/bin/env bash
# ──────────────────────────────────────────────
# cleanup.sh — System Cleanup
# ──────────────────────────────────────────────
# Removes temporary files, old build artifacts,
# rotated logs, and unused Docker resources.
# Does NOT remove production data or backups.
#
# Usage:
#   ./maintenance/cleanup.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

cd "$PROJECT_ROOT"

info "=== Cleanup ==="

# PM2 logs
if command -v pm2 &>/dev/null; then
  info "Flushing PM2 logs..."
  pm2 flush 2>/dev/null || true
  success "PM2 logs flushed."
fi

# Project temporary files
info "Removing Turbo cache..."
rm -rf .turbo
success "Turbo cache removed."

info "Removing .next build cache..."
rm -rf apps/frontend/.next
success "Next.js cache removed."

info "Removing dist directories..."
rm -rf apps/backend/dist
success "Dist directories removed."

info "Removing TypeScript build info..."
find . -name '*.tsbuildinfo' -delete 2>/dev/null || true
success "TypeScript build info removed."

# Docker cleanup
if command -v docker &>/dev/null; then
  info "Pruning Docker system..."
  docker system prune -f 2>/dev/null || true
  success "Docker system pruned."
fi

# Log files
info "Removing PM2 log files..."
rm -rf logs/
success "Log files removed."

success "Cleanup complete."
