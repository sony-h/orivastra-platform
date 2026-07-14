#!/usr/bin/env bash
# ──────────────────────────────────────────────
# backup-db.sh — PostgreSQL Database Backup
# ──────────────────────────────────────────────
# Creates a timestamped dump of the PostgreSQL
# database and stores it locally.
#
# Usage:
#   ./backup-db.sh
#   ./backup-db.sh /path/to/backup/dir
#
# Future (Hermes integration):
#   Hermes calls this before any deploy.sh
#   so a rollback can restore the database.
# ──────────────────────────────────────────────

set -euo pipefail

BACKUP_DIR="${1:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/orivastra_${TIMESTAMP}.sql"
INFRA_COMPOSE="-f $(dirname "$0")/../compose/compose.infrastructure.yml"

mkdir -p "$BACKUP_DIR"

echo "[backup-db] Creating database backup..."
docker compose $INFRA_COMPOSE exec -T postgres pg_dump -U orivastra orivastra > "$BACKUP_FILE"

echo "[backup-db] Backup saved to ${BACKUP_FILE}"
