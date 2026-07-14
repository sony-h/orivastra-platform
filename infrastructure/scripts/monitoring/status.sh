#!/usr/bin/env bash
# ──────────────────────────────────────────────
# status.sh — Platform Status Report
# ──────────────────────────────────────────────
# Generates a comprehensive status report of
# the entire Orivastra platform: applications,
# infrastructure, system resources, and git.
#
# Usage:
#   ./monitoring/status.sh
# ──────────────────────────────────────────────

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/health.sh"

# ── Helpers ──────────────────────────────────
label() { echo -e "  ${CYAN}$1${NC}"; }
pass()  { echo -e "    ${GREEN}●${NC} $1"; }
fail()  { echo -e "    ${RED}✗${NC} $1"; }

app_status() {
  local port=$1 name=$2
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
  if [[ "$status" = "200" ]]; then
    pass "$name (port $port) — ONLINE"
  else
    fail "$name (port $port) — OFFLINE ($status)"
  fi
}

# ── Report ───────────────────────────────────
echo ""
echo "  ==================================="
echo "     ORIVASTRA PLATFORM STATUS"
echo "  ==================================="
echo ""

# Applications
label "Applications"
app_status $FRONTEND_PORT "Frontend"
app_status $BACKEND_PORT "Backend"
echo ""

# Infrastructure
label "Infrastructure"
health_postgres && pass "PostgreSQL" || fail "PostgreSQL"
health_redis && pass "Redis" || fail "Redis"
echo ""

# Process managers
label "Process Managers"
if command -v docker &>/dev/null; then
  local containers
  containers=$(docker compose -f "$COMPOSE_FILE" ps --status running -q 2>/dev/null | wc -l)
  pass "Docker (${containers} running)"
else
  fail "Docker (not installed)"
fi
if command -v pm2 &>/dev/null; then
  local pm2_online
  pm2_online=$(pm2 list 2>/dev/null | grep -c 'online' || true)
  pass "PM2 (${pm2_online} online)"
else
  fail "PM2 (not installed)"
fi
echo ""

# System
label "System"
local load disk_used disk_total mem_used mem_total
load=$(awk '{print $1,$2,$3}' /proc/loadavg 2>/dev/null || echo "N/A")
disk_used=$(df / | awk 'NR==2 {print $3}')
disk_total=$(df / | awk 'NR==2 {print $2}')
mem_used=$(free -m | awk 'NR==2 {print $3}')
mem_total=$(free -m | awk 'NR==2 {print $2}')
pass "CPU Load: ${load}"
pass "Disk: $(( disk_used / 1024 ))MB / $(( disk_total / 1024 ))MB"
pass "RAM: ${mem_used}MB / ${mem_total}MB"
echo ""

# Git
label "Git"
local branch commit
branch=$(current_branch 2>/dev/null || echo "unknown")
commit=$(current_commit 2>/dev/null || echo "unknown")
pass "Branch: ${branch}"
pass "Commit: ${commit}"
echo ""
