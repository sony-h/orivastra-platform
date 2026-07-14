#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-all.sh — Restart All Applications
# ──────────────────────────────────────────────
# Restarts both backend and frontend via PM2,
# then runs a full health check.
#
# Usage:
#   ./restart/restart-all.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"
source "$SCRIPT_DIR/../lib/health.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

pm2_restart_all
sleep 2
health_all
