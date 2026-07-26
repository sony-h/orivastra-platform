#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — Preflight Checks
# ──────────────────────────────────────────────
# Validates that all required tools, services,
# and system resources are available before
# running any deployment or maintenance task.
#
# Usage:
#   source lib/checks.sh
#   preflight
# ──────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

check_git() {
  if command -v git &>/dev/null; then
    success "Git: $(git --version 2>/dev/null | head -1)"
    return 0
  fi
  error "Git is not installed."
  return 1
}

check_node() {
  if command -v node &>/dev/null; then
    success "Node: $(node --version 2>/dev/null)"
    return 0
  fi
  error "Node.js is not installed."
  return 1
}

check_pnpm() {
  if command -v pnpm &>/dev/null; then
    success "pnpm: $(pnpm --version 2>/dev/null)"
    return 0
  fi
  error "pnpm is not installed."
  return 1
}

check_pm2() {
  if command -v pm2 &>/dev/null; then
    success "PM2: $(pm2 --version 2>/dev/null)"
    return 0
  fi
  warn "PM2 is not installed. Applications will not be managed."
  return 0
}

check_docker() {
  if command -v docker &>/dev/null; then
    success "Docker: $(docker --version 2>/dev/null | sed 's/Docker version //')"
    return 0
  fi
  error "Docker is not installed."
  return 1
}

check_docker_compose() {
  if docker compose version &>/dev/null; then
    success "Docker Compose: $(docker compose version 2>/dev/null | sed 's/Docker Compose version //')"
    return 0
  fi
  error "Docker Compose is not available."
  return 1
}

check_internet() {
  if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    success "Internet: connected"
    return 0
  fi
  warn "Internet: unreachable — some operations may fail"
  return 0
}

check_disk_space() {
  local threshold_mb="${1:-1024}"
  local available_kb
  available_kb=$(df / | awk 'NR==2 {print $4}')
  local available_mb=$((available_kb / 1024))
  if [[ $available_mb -lt $threshold_mb ]]; then
    warn "Disk: ${available_mb}MB free (threshold: ${threshold_mb}MB)"
    return 1
  fi
  success "Disk: ${available_mb}MB free"
  return 0
}

check_memory() {
  local threshold_mb="${1:-256}"
  if [[ -f /proc/meminfo ]]; then
    local available_kb
    available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local available_mb=$((available_kb / 1024))
    if [[ $available_mb -lt $threshold_mb ]]; then
      warn "Memory: ${available_mb}MB available (threshold: ${threshold_mb}MB)"
      return 1
    fi
    success "Memory: ${available_mb}MB available"
    return 0
  fi
  warn "Memory: unable to check (no /proc/meminfo)"
  return 0
}

preflight() {
  local failed=0
  info "Running preflight checks..."
  check_git       || ((failed++))
  check_node      || ((failed++))
  check_pnpm      || ((failed++))
  check_pm2       || true
  check_docker    || ((failed++))
  check_docker_compose || ((failed++))
  check_internet  || true
  check_disk_space || true
  check_memory    || true
  if [[ $failed -gt 0 ]]; then
    error "${failed} critical check(s) failed."
    return 1
  fi
  success "All critical checks passed."
  return 0
}
