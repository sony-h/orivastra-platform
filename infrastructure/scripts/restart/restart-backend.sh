#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-backend.sh — Restart Backend
# ──────────────────────────────────────────────
# Gracefully restarts the backend PM2 process.
# Faster than a full deploy for config changes
# or routine maintenance.
#
# Usage:
#   ./restart/restart-backend.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

pm2_restart_backend
