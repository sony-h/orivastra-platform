#!/usr/bin/env bash
# ──────────────────────────────────────────────
# ports.sh — Listening Ports Report
# ──────────────────────────────────────────────
# Displays all listening ports with their
# associated process, including which are
# managed by PM2 and which by Docker.
#
# Useful for debugging port conflicts or
# verifying that services are bound correctly.
#
# Usage:
#   ./monitoring/ports.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

info "Listening ports:"
echo ""

if command -v ss &>/dev/null; then
  ss -tlnp 2>/dev/null | awk 'NR>1 {
    split($4, a, ":")
    port = a[length(a)]
    proc = $7
    if (proc == "") proc = "-"
    printf "  %-6s %s\n", port, proc
  }' || true
elif command -v netstat &>/dev/null; then
  netstat -tlnp 2>/dev/null | awk 'NR>2 {
    split($4, a, ":")
    port = a[length(a)]
    proc = $7
    if (proc == "") proc = "-"
    printf "  %-6s %s\n", port, proc
  }' || true
else
  warn "Neither ss nor netstat are available."
fi

echo ""
info "Expected application ports:"
echo "  ${CYAN}${FRONTEND_PORT}${NC}  Frontend (PM2: ${FRONTEND_PM2_NAME})"
echo "  ${CYAN}${BACKEND_PORT}${NC}  Backend (PM2: ${BACKEND_PM2_NAME})"
echo "  ${CYAN}5432${NC}  PostgreSQL (Docker)"
echo "  ${CYAN}6379${NC}  Redis (Docker)"
echo "  ${CYAN}8080${NC}  Adminer (Docker, dev only)"
