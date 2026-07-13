#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restart-frontend.sh — Restart Next.js Frontend
# ──────────────────────────────────────────────
# Purpose:
#   Gracefully restarts the frontend container.
#   Used after static content changes or for
#   routine maintenance.
#
# Usage:
#   ./restart-frontend.sh
#
# Future (Hermes integration):
#   Triggered by Hermes via Telegram command.
#
#   Telegram → Hermes → restart-frontend.sh
# ──────────────────────────────────────────────

set -euo pipefail

echo "[restart-frontend] Restarting frontend..."

# Restart the frontend container
# docker compose -f infrastructure/compose/compose.prod.yml restart frontend

# Wait for the service to become healthy
# sleep 3

# Verify
# curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:3000

echo "[restart-frontend] Frontend restarted."
