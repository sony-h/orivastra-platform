#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — Health Check Helpers
# ──────────────────────────────────────────────
# Reusable health checks for all platform
# components: applications, Docker services,
# and system resources.
#
# Usage:
#   source lib/health.sh
#   health_all
# ──────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

health_backend_http() {
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_HEALTH_URL" 2>/dev/null || echo "000")
  if [[ "$status" = "200" ]]; then
    success "Backend HTTP 200 ($BACKEND_HEALTH_URL)"
    return 0
  fi
  error "Backend returned HTTP $status"
  return 1
}

health_frontend_http() {
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_HEALTH_URL" 2>/dev/null || echo "000")
  if [[ "$status" = "200" ]]; then
    success "Frontend HTTP 200 ($FRONTEND_HEALTH_URL)"
    return 0
  fi
  error "Frontend returned HTTP $status"
  return 1
}

health_postgres() {
  if docker compose -f "$COMPOSE_FILE" exec -T "$POSTGRES_SERVICE" pg_isready -U "$POSTGRES_USER" &>/dev/null; then
    success "PostgreSQL accepting connections"
    return 0
  fi
  error "PostgreSQL not responding"
  return 1
}

health_redis() {
  if docker compose -f "$COMPOSE_FILE" exec -T "$REDIS_SERVICE" redis-cli PING 2>/dev/null | grep -q PONG; then
    success "Redis responding"
    return 0
  fi
  error "Redis not responding"
  return 1
}

health_infra_containers() {
  local running
  running=$(docker compose -f "$COMPOSE_FILE" ps --status running -q 2>/dev/null | wc -l)
  if [[ "$running" -ge "$INFRA_EXPECTED_CONTAINERS" ]]; then
    success "${running}/${INFRA_EXPECTED_CONTAINERS} infra containers running"
    return 0
  fi
  error "Only ${running}/${INFRA_EXPECTED_CONTAINERS} infra containers running"
  return 1
}

health_pm2_processes() {
  if command -v pm2 &>/dev/null; then
    local online
    online=$(pm2 list 2>/dev/null | grep -c 'online' || true)
    success "${online} PM2 process(es) online"
    return 0
  fi
  warn "PM2 not installed — skipping process check"
  return 0
}

health_all() {
  local failed=0
  info "Running full health check..."
  health_infra_containers || ((failed++))
  health_pm2_processes    || true
  health_frontend_http    || ((failed++))
  health_backend_http     || ((failed++))
  health_postgres         || ((failed++))
  health_redis            || ((failed++))
  if [[ $failed -gt 0 ]]; then
    error "${failed} check(s) failed."
    return 1
  fi
  success "All services healthy."
  return 0
}
