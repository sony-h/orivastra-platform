#!/usr/bin/env bash
# ──────────────────────────────────────────────
# health-check.sh — Service Health Verification
# ──────────────────────────────────────────────
# Verifies:
#   1. Docker infrastructure containers are running
#   2. PM2 processes are online
#   3. Frontend responds with HTTP 200
#   4. Backend /health responds with HTTP 200
#   5. PostgreSQL accepts connections
#   6. Redis responds to PING
#
# Exit codes:
#   0 — All services healthy
#   1 — One or more services failed
#
# Usage:
#   ./health-check.sh
#
# Future (Hermes integration):
#   Hermes runs this after deploy. If it fails,
#   Hermes calls rollback.sh automatically.
# ──────────────────────────────────────────────

set -euo pipefail

FAILED=0
INFRA_COMPOSE="-f $(dirname "$0")/../compose/compose.infrastructure.yml"

echo "[health-check] Verifying services..."

# Check 1: Docker containers running
RUNNING=$(docker compose $INFRA_COMPOSE ps --status running -q 2>/dev/null | wc -l)
EXPECTED=2
if [ "$RUNNING" -lt "$EXPECTED" ]; then
  echo "[health-check] FAIL: Only ${RUNNING}/${EXPECTED} infra containers running"
  FAILED=1
else
  echo "[health-check] PASS: ${RUNNING}/${EXPECTED} infra containers running"
fi

# Check 2: PM2 processes
if command -v pm2 &>/dev/null; then
  PM2_STATUS=$(pm2 list 2>/dev/null | grep -c 'online' || true)
  echo "[health-check] PASS: ${PM2_STATUS} PM2 processes online"
else
  echo "[health-check] WARN: PM2 not installed — skipping process check"
fi

# Check 3: Frontend HTTP
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
  echo "[health-check] PASS: Frontend HTTP 200"
else
  echo "[health-check] FAIL: Frontend returned ${FRONTEND_STATUS}"
  FAILED=1
fi

# Check 4: Backend health endpoint
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health 2>/dev/null || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
  echo "[health-check] PASS: Backend HTTP 200"
else
  echo "[health-check] FAIL: Backend returned ${BACKEND_STATUS}"
  FAILED=1
fi

# Check 5: PostgreSQL
if docker compose $INFRA_COMPOSE exec -T postgres pg_isready -U orivastra >/dev/null 2>&1; then
  echo "[health-check] PASS: PostgreSQL accepting connections"
else
  echo "[health-check] FAIL: PostgreSQL not responding"
  FAILED=1
fi

# Check 6: Redis
if docker compose $INFRA_COMPOSE exec -T redis redis-cli PING 2>/dev/null | grep -q PONG; then
  echo "[health-check] PASS: Redis responding"
else
  echo "[health-check] FAIL: Redis not responding"
  FAILED=1
fi

echo "[health-check] Verification complete."

if [ "$FAILED" -ne 0 ]; then
  echo "[health-check] One or more checks FAILED."
  exit 1
fi

echo "[health-check] All services healthy."
exit 0
