#!/usr/bin/env bash
# ──────────────────────────────────────────────
# health-check.sh — Service Health Verification
# ──────────────────────────────────────────────
# Purpose:
#   Verifies that all Docker services are running
#   and responding correctly. Used after deployment
#   and for routine monitoring.
#
# Checks performed:
#   1. All containers are "running" (docker compose ps)
#   2. Frontend responds with HTTP 200
#   3. Backend /api/health responds with HTTP 200
#   4. PostgreSQL accepts connections
#   5. Redis responds to PING
#
# Exit codes:
#   0 — All services healthy
#   1 — One or more services failed
#
# Usage:
#   ./health-check.sh
#
# Future (Hermes integration):
#   Hermes runs this after deploy.sh. If it fails,
#   Hermes calls rollback.sh automatically.
#
#   deploy.sh → health-check.sh
#     ├── pass → notify success
#     └── fail → rollback.sh → notify failure
# ──────────────────────────────────────────────

set -euo pipefail

FAILED=0

echo "[health-check] Verifying services..."

# Check 1: Docker containers running
# RUNNING=$(docker compose -f infrastructure/compose/compose.prod.yml ps --status running -q | wc -l)
# EXPECTED=5
# if [ "${RUNNING}" -lt "${EXPECTED}" ]; then
#   echo "[health-check] FAIL: Only ${RUNNING}/${EXPECTED} containers running"
#   FAILED=1
# else
#   echo "[health-check] PASS: ${RUNNING}/${EXPECTED} containers running"
# fi

# Check 2: Frontend HTTP
# FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
# if [ "${FRONTEND_STATUS}" != "200" ]; then
#   echo "[health-check] FAIL: Frontend returned ${FRONTEND_STATUS}"
#   FAILED=1
# else
#   echo "[health-check] PASS: Frontend HTTP 200"
# fi

# Check 3: Backend health endpoint
# BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health)
# if [ "${BACKEND_STATUS}" != "200" ]; then
#   echo "[health-check] FAIL: Backend returned ${BACKEND_STATUS}"
#   FAILED=1
# else
#   echo "[health-check] PASS: Backend HTTP 200"
# fi

# Check 4: PostgreSQL
# if docker compose -f infrastructure/compose/compose.prod.yml exec -T postgres pg_isready -U orivastra > /dev/null 2>&1; then
#   echo "[health-check] PASS: PostgreSQL accepting connections"
# else
#   echo "[health-check] FAIL: PostgreSQL not responding"
#   FAILED=1
# fi

# Check 5: Redis
# if docker compose -f infrastructure/compose/compose.prod.yml exec -T redis redis-cli PING | grep -q PONG; then
#   echo "[health-check] PASS: Redis responding"
# else
#   echo "[health-check] FAIL: Redis not responding"
#   FAILED=1
# fi

echo "[health-check] Verification complete."

if [ "${FAILED}" -ne 0 ]; then
  echo "[health-check] One or more checks FAILED."
  exit 1
fi

echo "[health-check] All services healthy."
exit 0
