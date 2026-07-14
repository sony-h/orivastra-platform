#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-all.sh — Restart All Applications
# ──────────────────────────────────────────────
# Gracefully restarts both applications via PM2,
# then verifies health.
#
# Usage:
#   ./restart-all.sh
#
# Future (Hermes integration):
#   Hermes calls this after deploy. If health
#   check fails, calls rollback.sh automatically.
# ──────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "[restart-all] Restarting all applications..."

echo "[restart-all] Restarting backend..."
pm2 restart backend

echo "[restart-all] Restarting frontend..."
pm2 restart frontend

echo "[restart-all] Running health check..."
"$SCRIPT_DIR/health-check.sh"

echo "[restart-all] All applications restarted and healthy."
