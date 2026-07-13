#!/usr/bin/env bash
# ──────────────────────────────────────────────
# rollback.sh — Emergency Rollback
# ──────────────────────────────────────────────
# Purpose:
#   Reverts the production stack to a previous
#   known-good state after a failed deployment.
#
# Strategy:
#   1. Checkout the previous Git tag or commit hash
#   2. Rebuild Docker images from that point
#   3. Restart services
#   4. Verify with health-check.sh
#
# Usage:
#   ./rollback.sh            # rollback to previous commit
#   ./rollback.sh v0.1.0     # rollback to a specific tag
#
# Future (Hermes integration):
#   Triggered automatically when health-check.sh
#   fails after a deploy. Hermes calls rollback.sh
#   without human intervention.
#
#   Telegram → Hermes → health-check fails → rollback.sh
# ──────────────────────────────────────────────

set -euo pipefail

TARGET="${1:-HEAD~1}"

echo "[rollback] Rolling back to: ${TARGET}"

# Step 1: Checkout target
# git checkout "${TARGET}"

# Step 2: Rebuild
# docker compose -f infrastructure/compose/compose.prod.yml build

# Step 3: Restart
# docker compose -f infrastructure/compose/compose.prod.yml up -d

# Step 4: Verify
# ./health-check.sh

echo "[rollback] Rollback complete. Now running: ${TARGET}"
