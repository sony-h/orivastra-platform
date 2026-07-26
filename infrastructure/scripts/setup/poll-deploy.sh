#!/usr/bin/env bash
# ──────────────────────────────────────────────
# poll-deploy.sh — VPS Auto-Deploy Poller
# ──────────────────────────────────────────────
# Polls GitHub for new commits on main.
# If the remote has changes, pulls and deploys.
#
# Designed to be run by a systemd timer every 60s.
# No inbound SSH from GitHub needed.
#
# Usage:
#   ./setup/poll-deploy.sh          # Single run (for testing)
#   ./setup/poll-deploy.sh --force  # Deploy even if no changes
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

cd "$PROJECT_ROOT"

FORCE="${1:-}"

# Fetch latest without merging
git fetch origin main 2>/dev/null || {
  error "Cannot fetch from origin. Check network."
  exit 1
}

LOCAL=$(git rev-parse HEAD 2>/dev/null)
REMOTE=$(git rev-parse origin/main 2>/dev/null)

if [ "$LOCAL" = "$REMOTE" ] && [ "$FORCE" != "--force" ]; then
  exit 0
fi

echo "[poll-deploy] $(date -Iseconds) — New commits detected. Deploying..."

# Backup database
"$SCRIPT_DIR/../database/backup-db.sh" || warn "Backup skipped"

# Pull and deploy
git pull origin main
"$SCRIPT_DIR/../deploy/deploy-all.sh"
