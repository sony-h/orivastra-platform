#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-backend.sh — Restart NestJS Backend
# ──────────────────────────────────────────────
# Purpose:
#   Gracefully restarts the backend container.
#   Used after config changes or for routine
#   maintenance without full redeployment.
#
# Usage:
#   ./restart-backend.sh
#
# Future (Hermes integration):
#   Triggered by Hermes via Telegram command.
#   Faster than a full deploy.sh for quick fixes.
#
#   Telegram → Hermes → restart-backend.sh
# ──────────────────────────────────────────────

set -euo pipefail

echo "[restart-backend] Restarting backend..."

# Restart the backend container
# docker compose -f infrastructure/compose/compose.prod.yml restart backend

# Wait for the service to become healthy
# sleep 5

# Verify
# ./health-check.sh

echo "[restart-backend] Backend restarted."
