#!/usr/bin/env bash
# ──────────────────────────────────────────────
# backup-db.sh — PostgreSQL Database Backup
# ──────────────────────────────────────────────
# Creates a timestamped, compressed PostgreSQL
# dump and saves it to /opt/orivastra/backups/.
#
# Usage:
#   ./database/backup-db.sh
#   ./database/backup-db.sh /custom/path
#
# Future (Hermes):
#   Called before every deployment so a rollback
#   can restore the database to the pre-deploy
#   state.
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/docker.sh"

if [[ "${1:-}" = "--help" ]] || [[ "${1:-}" = "-h" ]]; then
  sed -n '/^#/p' "$0" | sed 's/^# //; s/^#$//'
  exit 0
fi

local_backup_dir="${1:-$BACKUP_DIR}"
mkdir -p "$local_backup_dir"

timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="${local_backup_dir}/${POSTGRES_DB}_${timestamp}.sql.gz"

info "Creating database backup..."
docker_compose_cmd exec -T "$POSTGRES_SERVICE" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$backup_file"

file_size=$(du -h "$backup_file" | cut -f1)
success "Backup saved: ${backup_file} (${file_size})"
