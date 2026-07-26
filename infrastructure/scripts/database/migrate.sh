#!/usr/bin/env bash
# ──────────────────────────────────────────────
# migrate.sh — Prisma Database Migration
# ──────────────────────────────────────────────
# Runs Prisma database operations: generate
# client, apply migrations, or push schema.
# Automatically detects the environment.
#
# Usage:
#   ./database/migrate.sh generate         # Generate Prisma client
#   ./database/migrate.sh push             # Push schema to DB
#   ./database/migrate.sh migrate          # Run pending migrations
#   ./database/migrate.sh                  # Default: migrate deploy
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/checks.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

cd "$PROJECT_ROOT/apps/backend"

command="${1:-migrate}"

case "$command" in
  generate)
    info "Generating Prisma client..."
    pnpm prisma:generate
    success "Prisma client generated."
    ;;
  push)
    info "Pushing schema to database..."
    pnpm prisma:push
    success "Schema pushed."
    ;;
  migrate)
    info "Running Prisma migrations..."
    pnpm prisma:migrate
    success "Migrations applied."
    ;;
  *)
    error "Unknown command: ${command}"
    info "Usage: migrate.sh {generate|push|migrate}"
    exit 1
    ;;
esac
