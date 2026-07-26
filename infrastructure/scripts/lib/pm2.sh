#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — PM2 Helpers
# ──────────────────────────────────────────────
# Manages application processes via PM2.
# Applications run natively (not in Docker).
#
# Usage:
#   source lib/pm2.sh
#   pm2_restart_backend
# ──────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

pm2_restart_backend() {
  info "Restarting backend via PM2..."
  pm2 restart "$BACKEND_PM2_NAME"
  success "Backend restarted."
}

pm2_restart_frontend() {
  info "Restarting frontend via PM2..."
  pm2 restart "$FRONTEND_PM2_NAME"
  success "Frontend restarted."
}

pm2_restart_all() {
  info "Restarting all applications via PM2..."
  pm2 restart ecosystem.config.js
  success "All applications restarted."
}

pm2_show_logs() {
  local app="$1"
  if [[ -n "$app" ]]; then
    pm2 logs "$app"
  else
    pm2 logs
  fi
}

pm2_show_status() {
  pm2 status
}

pm2_save() {
  info "Saving PM2 process list..."
  pm2 save
  success "PM2 process list saved."
}

pm2_startup_enable() {
  info "Enabling PM2 startup (systemd)..."
  pm2 startup systemd
  success "PM2 startup enabled."
}
