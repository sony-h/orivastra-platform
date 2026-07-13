#!/usr/bin/env bash
# ──────────────────────────────────────────────
# show-logs.sh — View Docker Service Logs
# ──────────────────────────────────────────────
# Purpose:
#   Tails logs from one or all Docker services.
#   Used for debugging, monitoring, and incident
#   response without SSH-ing into individual
#   containers.
#
# Usage:
#   ./show-logs.sh              # all services
#   ./show-logs.sh backend      # backend only
#   ./show-logs.sh frontend 100 # frontend, last 100 lines
#
# Future (Hermes integration):
#   Hermes can request logs via Telegram and
#   relay them back to the user. Enables remote
#   debugging without direct VPS access.
#
#   Telegram → Hermes → show-logs.sh → Telegram
# ──────────────────────────────────────────────

set -euo pipefail

SERVICE="${1:-}"
LINES="${2:-50}"

if [ -z "${SERVICE}" ]; then
  echo "[show-logs] Tailing all services (last ${LINES} lines)..."
  # docker compose -f infrastructure/compose/compose.prod.yml logs --tail="${LINES}" -f
else
  echo "[show-logs] Tailing '${SERVICE}' (last ${LINES} lines)..."
  # docker compose -f infrastructure/compose/compose.prod.yml logs --tail="${LINES}" -f "${SERVICE}"
fi
