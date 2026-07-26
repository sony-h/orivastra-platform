#!/usr/bin/env bash
# ──────────────────────────────────────────────
# setup-polling.sh — Install Auto-Deploy Timer
# ──────────────────────────────────────────────
# Creates a systemd service + timer that runs
# poll-deploy.sh every 60 seconds.
#
# This is a ONE-TIME setup script. Run it after
# the initial VPS deployment is complete.
#
# Usage:
#   sudo bash setup/setup-polling.sh
#
# Verify:
#   systemctl status orivastra-deploy.timer
#   journalctl -u orivastra-deploy.service -n 20
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_root

POLL_SCRIPT="$PROJECT_ROOT/infrastructure/scripts/setup/poll-deploy.sh"

if [ ! -f "$POLL_SCRIPT" ]; then
  error "poll-deploy.sh not found at $POLL_SCRIPT"
  exit 1
fi

info "Installing orivastra-deploy systemd timer..."

# Service unit
cat > /etc/systemd/system/orivastra-deploy.service << 'EOF'
[Unit]
Description=Orivastra auto-deploy poller
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/orivastra/infrastructure/scripts/setup/poll-deploy.sh
User=orivastra
Group=orivastra
EOF
success "Service unit created."

# Timer unit
cat > /etc/systemd/system/orivastra-deploy.timer << 'EOF'
[Unit]
Description=Run orivastra-deploy every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF
success "Timer unit created."

systemctl daemon-reload
systemctl enable --now orivastra-deploy.timer
success "orivastra-deploy.timer enabled and started."

echo ""
echo "  Verify: systemctl status orivastra-deploy.timer"
echo "  Logs:   journalctl -u orivastra-deploy.service -n 20 --no-pager"
echo ""
