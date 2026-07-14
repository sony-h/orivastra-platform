#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — Docker Helpers
# ──────────────────────────────────────────────
# Manages infrastructure Docker containers
# (PostgreSQL, Redis, Adminer).
#
# Usage:
#   source lib/docker.sh
#   docker_start_infra
# ──────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

docker_compose_cmd() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

docker_start_infra() {
  info "Starting infrastructure services..."
  docker_compose_cmd up -d
  success "Infrastructure services started."
}

docker_stop_infra() {
  info "Stopping infrastructure services..."
  docker_compose_cmd down
  success "Infrastructure services stopped."
}

docker_restart_infra() {
  info "Restarting infrastructure services..."
  docker_compose_cmd restart
  success "Infrastructure services restarted."
}

docker_status() {
  docker_compose_cmd ps
}

docker_logs() {
  local service="$1"
  if [[ -n "$service" ]]; then
    docker_compose_cmd logs -f "$service"
  else
    docker_compose_cmd logs -f
  fi
}

docker_purge() {
  warn "This will remove all infrastructure data volumes!"
  if confirm "Delete all volumes (postgres_data, redis_data)?"; then
    docker_compose_cmd down -v
    success "Volumes removed."
  else
    info "Volume removal cancelled."
  fi
}
