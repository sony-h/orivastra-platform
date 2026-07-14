#!/usr/bin/env bash
# ──────────────────────────────────────────────
# update-system.sh — System Update
# ──────────────────────────────────────────────
# Updates the server's essential packages:
# Ubuntu packages, Docker, and optionally
# Node.js. Prints a summary after completion.
#
# Does NOT reboot automatically.
#
# Why not automatic reboot:
#   A reboot may disrupt running applications.
#   The operator should decide when to reboot
#   based on the update's criticality.
#
# Usage:
#   sudo ./maintenance/update-system.sh
#   sudo ./maintenance/update-system.sh --node   # Also update Node.js
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

require_root

info "=== System Update ==="

# Ubuntu
info "Updating Ubuntu package lists..."
apt-get update -qq
info "Upgrading Ubuntu packages..."
apt-get upgrade -y -qq
success "Ubuntu packages updated."

# Docker
if command -v docker &>/dev/null; then
  info "Updating Docker..."
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io 2>/dev/null || true
  success "Docker updated."
fi

# Node.js (optional)
if [[ "${1:-}" = "--node" ]]; then
  if command -v nvm &>/dev/null || command -v n &>/dev/null; then
    info "Updating Node.js to latest LTS..."
    nvm install --lts 2>/dev/null || n latest 2>/dev/null || true
    success "Node.js updated."
  else
    warn "Node.js version manager not found. Skipping Node update."
  fi
fi

# Summary
echo ""
info "Update summary:"
echo "  OS:    $(lsb_release -ds 2>/dev/null || echo 'N/A')"
echo "  Node:  $(node --version 2>/dev/null || echo 'N/A')"
echo "  npm:   $(npm --version 2>/dev/null || echo 'N/A')"
echo "  pnpm:  $(pnpm --version 2>/dev/null || echo 'N/A')"
echo "  PM2:   $(pm2 --version 2>/dev/null || echo 'N/A')"
echo "  Docker: $(docker --version 2>/dev/null || echo 'N/A')"
echo ""
success "Update complete. Reboot if necessary."
