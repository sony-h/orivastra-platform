#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-frontend.sh — Restart Frontend
# ──────────────────────────────────────────────
# Gracefully restarts the frontend PM2 process.
# Faster than a full deploy for config changes
# or routine maintenance.
#
# Usage:
#   ./restart/restart-frontend.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

pm2_restart_frontend
