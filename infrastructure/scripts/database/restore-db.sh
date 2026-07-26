#!/usr/bin/env bash
# ──────────────────────────────────────────────
# restore-db.sh — PostgreSQL Database Restore
# ──────────────────────────────────────────────
# Lists available backups, auto-backups the
# current database before restoring, and
# requires explicit confirmation.
#
# Safety features:
#   1. Auto-backup current DB before restore
#   2. Always requires interactive confirmation
#   3. Verifies database health after restore
#
# Usage:
#   ./database/restore-db.sh                # Interactive — list & choose
#   ./database/restore-db.sh --list         # List backups only
#   ./database/restore-db.sh 20260714-223000  # Restore specific backup
#
# Future (Hermes):
#   Hermes lists backups and selects one to
#   restore during rollback. The confirmation
#   step may be bypassed via a future --yes
#   flag when Hermes validates the action.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/docker.sh"
source "$SCRIPT_DIR/../lib/health.sh"

# ── List backups ────────────────────────────
list_backups() {
  local dir="${1:-$BACKUP_DIR}"
  if [[ ! -d "$dir" ]]; then
    info "No backups directory found at ${dir}."
    return 1
  fi
  local files=("$dir"/*.sql.gz)
  if [[ ! -e "${files[0]}" ]]; then
    info "No backups found in ${dir}."
    return 1
  fi
  echo "Available backups:"
  for f in "${files[@]}"; do
    local name size
    name=$(basename "$f" .sql.gz)
    size=$(du -h "$f" | cut -f1)
    echo "  ${CYAN}${name}${NC}  (${size})"
  done
}

# ── Restore ─────────────────────────────────
restore_backup() {
  local backup_file="$1"
  if [[ ! -f "$backup_file" ]]; then
    error "Backup file not found: ${backup_file}"
    exit 1
  fi

  local backup_name
  backup_name=$(basename "$backup_file")

  # Step 1: Auto-backup current database
  info "Creating safety backup of current database..."
  local safety_timestamp
  safety_timestamp=$(date +%Y%m%d-%H%M%S)
  local safety_file="${BACKUP_DIR}/${POSTGRES_DB}_before_restore_${safety_timestamp}.sql.gz"
  mkdir -p "$BACKUP_DIR"
  docker_compose_cmd exec -T "$POSTGRES_SERVICE" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$safety_file"
  success "Safety backup saved: ${safety_file}"

  # Step 2: Confirm restore
  echo ""
  warn "You are about to RESTORE the database from: ${backup_name}"
  warn "This will OVERWRITE the current database."
  echo ""
  if ! confirm "Restore database?"; then
    info "Restore cancelled."
    exit 0
  fi

  # Step 3: Restore
  info "Restoring database from ${backup_name}..."
  gunzip -c "$backup_file" | docker_compose_cmd exec -T "$POSTGRES_SERVICE" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
  success "Database restored."

  # Step 4: Verify
  sleep 2
  if health_postgres; then
    success "Restore complete — PostgreSQL is healthy."
  else
    error "Restore completed but PostgreSQL health check failed."
    exit 1
  fi
}

# ── Main ────────────────────────────────────
case "${1:-}" in
  --help|-h)
    sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
    exit 0
    ;;
  --list)
    list_backups
    exit 0
    ;;
  "")
    list_backups
    echo ""
    read -r -p "Enter backup timestamp to restore (or Ctrl+C to cancel): " selected
    if [[ -z "$selected" ]]; then
      info "Cancelled."
      exit 0
    fi
    restore_backup "${BACKUP_DIR}/${selected}.sql.gz"
    ;;
  *)
    restore_backup "${BACKUP_DIR}/${1}.sql.gz"
    ;;
esac
