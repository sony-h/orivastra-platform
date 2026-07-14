#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-frontend.sh — Restart Frontend via PM2
# ──────────────────────────────────────────────
# Gracefully restarts the frontend PM2 process.
# Used after config changes or routine maintenance
# without full redeployment.
#
# Usage:
#   ./restart-frontend.sh
#
# Future (Hermes integration):
#   Triggered by Hermes via Telegram command.
# ──────────────────────────────────────────────

set -euo pipefail

echo "[restart-frontend] Restarting frontend..."
pm2 restart frontend
echo "[restart-frontend] Frontend restarted."
