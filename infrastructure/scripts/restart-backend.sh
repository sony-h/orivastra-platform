#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-backend.sh — Restart Backend via PM2
# ──────────────────────────────────────────────
# Gracefully restarts the backend PM2 process.
# Used after config changes or routine maintenance
# without full redeployment.
#
# Usage:
#   ./restart-backend.sh
#
# Future (Hermes integration):
#   Triggered by Hermes via Telegram command.
# ──────────────────────────────────────────────

set -euo pipefail

echo "[restart-backend] Restarting backend..."
pm2 restart backend
echo "[restart-backend] Backend restarted."
