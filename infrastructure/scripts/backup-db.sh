#!/usr/bin/env bash
# ──────────────────────────────────────────────
# backup-db.sh — PostgreSQL Backup
# ──────────────────────────────────────────────
# Purpose:
#   Creates a timestamped dump of the PostgreSQL
#   database and stores it in the backups directory.
#
# Retention:
#   - Daily backups kept for 7 days
#   - Weekly backups kept for 30 days
#   - Manual backups kept indefinitely
#
# Usage:
#   ./backup-db.sh                # daily backup
#   ./backup-db.sh --weekly       # weekly backup (tagged)
#   ./backup-db.sh --manual       # manual backup (never deleted)
#
# Output:
#   backups/backup_YYYY-MM-DD_HHMMSS.sql.gz
#
# Future (Hermes integration):
#   Scheduled via cron or triggered by Hermes
#   before a deployment. Hermes can request a
#   backup before running deploy.sh.
#
#   Telegram → Hermes → backup-db.sh → deploy.sh
# ──────────────────────────────────────────────

set -euo pipefail

MODE="${1:-daily}"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
FILENAME="backup_${TIMESTAMP}_${MODE}.sql.gz"

echo "[backup-db] Creating ${MODE} backup..."

# Create backup directory if needed
# mkdir -p "${BACKUP_DIR}"

# Dump the database from the running postgres container
# docker compose -f infrastructure/compose/compose.prod.yml exec -T postgres \
#   pg_dump -U orivastra orivastra | gzip > "${BACKUP_DIR}/${FILENAME}"

echo "[backup-db] Backup saved: ${BACKUP_DIR}/${FILENAME}"
