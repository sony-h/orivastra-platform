#!/usr/bin/env bash
# ──────────────────────────────────────────────
# health.sh — Run All Health Checks
# ──────────────────────────────────────────────
# Runs all platform health checks and returns
# PASS or FAIL. Exit code is 0 if all checks
# pass, non-zero otherwise.
#
# Usage:
#   ./monitoring/health.sh
#
# Future (Hermes):
#   Called after every deployment. Hermes reads
#   the exit code to decide whether to rollback.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/health.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

health_all
