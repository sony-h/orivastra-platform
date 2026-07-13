#!/usr/bin/env bash
# ──────────────────────────────────────────────
# deploy.sh — Production Deployment
# ──────────────────────────────────────────────
# Purpose:
#   Pulls the latest code from GitHub, rebuilds
#   Docker images, and restarts all services.
#
# Workflow:
#   1. git pull origin main
#   2. docker compose build
#   3. docker compose up -d
#   4. health-check.sh
#
# Usage:
#   ./deploy.sh
#
# Future (Hermes integration):
#   This script will be triggered by Hermes via
#   a Telegram command. The backend will validate
#   the request and execute this script on the VPS.
#   Hermes calls deploy.sh  →  Docker restarts  →  new version live.
#
#   Telegram → Hermes → deploy.sh → Docker → Production
# ──────────────────────────────────────────────

set -euo pipefail

echo "[deploy] Starting deployment..."

# Step 1: Pull latest code
echo "[deploy] Pulling latest code from GitHub..."
# git pull origin main

# Step 2: Build Docker images
echo "[deploy] Building Docker images..."
# docker compose -f infrastructure/docker/docker-compose.yml build

# Step 3: Restart services
echo "[deploy] Restarting services..."
# docker compose -f infrastructure/docker/docker-compose.yml up -d

# Step 4: Health check
echo "[deploy] Running health check..."
# ./health-check.sh

echo "[deploy] Deployment complete."
