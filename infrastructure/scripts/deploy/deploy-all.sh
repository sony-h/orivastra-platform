#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy-all.sh — Deploy All Applications
# ──────────────────────────────────────────────
# Runs backend then frontend deployment.
# No duplicated logic — delegates to per-app
# deploy scripts.
#
# Usage:
#   ./deploy/deploy-all.sh
#
# Future (Hermes):
#   Single entry point for full platform deploy.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Full Platform Deployment ==="

"$SCRIPT_DIR/../deploy/deploy-backend.sh"
"$SCRIPT_DIR/../deploy/deploy-frontend.sh"

echo "=== Platform deployment complete ==="
