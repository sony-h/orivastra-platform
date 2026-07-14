#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy-backend.sh — Backend Deployment
# ──────────────────────────────────────────────
# Workflow:
#   1. git pull origin main
#   2. pnpm install --frozen-lockfile
#   3. turbo build --filter=@orivastra/backend
#   4. pm2 restart backend
#   5. health-check.sh
#
# Usage:
#   ./deploy-backend.sh
#
# Future (Hermes integration):
#   Hermes calls this script after backup-db.sh.
#   deploy-backend.sh → health-check.sh → notify
# ──────────────────────────────────────────────

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
echo "[deploy-backend] Starting backend deployment..."

cd "$ROOT_DIR"

echo "[deploy-backend] Pulling latest code..."
git pull origin main

echo "[deploy-backend] Installing dependencies..."
pnpm install --frozen-lockfile

echo "[deploy-backend] Building backend..."
turbo build --filter=@orivastra/backend

echo "[deploy-backend] Restarting backend..."
pm2 restart backend

echo "[deploy-backend] Running health check..."
"$(dirname "$0")/health-check.sh"

echo "[deploy-backend] Backend deployment complete."
