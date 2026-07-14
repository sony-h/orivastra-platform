#!/usr/bin/env bash
# ──────────────────────────────────────────────
# rollback.sh — Production Rollback
# ──────────────────────────────────────────────
# Reverts the repository to a previous commit,
# rebuilds the affected application, and restarts.
#
# Usage:
#   ./rollback.sh                          # Rollback to previous commit
#   ./rollback.sh <commit-hash>            # Rollback to specific commit
#
# Future (Hermes integration):
#   Hermes calls this after deploy.sh if
#   health-check.sh fails.
# ──────────────────────────────────────────────

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TARGET="${1:-HEAD~1}"

cd "$ROOT_DIR"

echo "[rollback] Rolling back to: ${TARGET}"

if git diff --cached --quiet && git diff --quiet; then
  git reset --hard "$TARGET"
else
  echo "[rollback] Uncommitted changes detected. Stashing..."
  git stash --include-untracked
  git reset --hard "$TARGET"
fi

echo "[rollback] Rebuilding backend..."
turbo build --filter=@orivastra/backend

echo "[rollback] Rebuilding frontend..."
turbo build --filter=@orivastra/frontend

echo "[rollback] Restarting services..."
pm2 restart backend
pm2 restart frontend

echo "[rollback] Running health check..."
"$(dirname "$0")/health-check.sh"

echo "[rollback] Rollback complete."
