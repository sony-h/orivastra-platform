#!/usr/bin/env bash
# ──────────────────────────────────────────────
# logs.sh — View Logs
# ──────────────────────────────────────────────
# Routes log requests to PM2 (applications) or
# Docker (infrastructure services).
#
# Usage:
#   ./monitoring/logs.sh backend        # PM2 backend logs
#   ./monitoring/logs.sh frontend       # PM2 frontend logs
#   ./monitoring/logs.sh postgres       # Docker PostgreSQL logs
#   ./monitoring/logs.sh redis          # Docker Redis logs
#   ./monitoring/logs.sh                # All PM2 logs
#
# Future (Hermes):
#   Hermes calls this to inspect service logs
#   during incident response.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/pm2.sh"
source "$SCRIPT_DIR/../lib/docker.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

case "${1:-}" in
  backend)
    pm2_show_logs "$BACKEND_PM2_NAME"
    ;;
  frontend)
    pm2_show_logs "$FRONTEND_PM2_NAME"
    ;;
  postgres)
    docker_logs "$POSTGRES_SERVICE"
    ;;
  redis)
    docker_logs "$REDIS_SERVICE"
    ;;
  *)
    pm2_show_logs
    ;;
esac
