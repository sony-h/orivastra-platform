#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy-frontend.sh — Frontend Deployment
# ──────────────────────────────────────────────
# Workflow:
#   1. git pull origin main
#   2. pnpm install --frozen-lockfile
#   3. turbo build --filter=@orivastra/frontend
#   4. pm2 restart frontend
#   5. health-check.sh
#
# Usage:
#   ./deploy-frontend.sh
#
# Future (Hermes integration):
#   Hermes calls this script after deploy-backend.sh
#   or independently for frontend-only updates.
# ──────────────────────────────────────────────

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
echo "[deploy-frontend] Starting frontend deployment..."

cd "$ROOT_DIR"

echo "[deploy-frontend] Pulling latest code..."
git pull origin main

echo "[deploy-frontend] Installing dependencies..."
pnpm install --frozen-lockfile

echo "[deploy-frontend] Building frontend..."
turbo build --filter=@orivastra/frontend

echo "[deploy-frontend] Restarting frontend..."
pm2 restart frontend

echo "[deploy-frontend] Running health check..."
"$(dirname "$0")/health-check.sh"

echo "[deploy-frontend] Frontend deployment complete."
