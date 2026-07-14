# ──────────────────────────────────────────────
# Orivastra — Hermes Dockerfile
# ──────────────────────────────────────────────
# Placeholder container for the Hermes AI agent.
#
# Hermes will be an AI DevOps engineer that manages
# the Orivastra infrastructure through trusted scripts.
#
# Current state: minimal Node.js Alpine image.
# Future: will include the Hermes agent binary,
# model files, and integration with Telegram.
#
# Architecture:
#   Telegram → Hermes → infrastructure/scripts/ → Docker → Apps
#
# Stages:
#   hermes-base     Base image with Node.js
#   hermes-dev      Development with shell access
#   hermes-prod     Production with agent process
#
# Build contexts:
#   Context must be the monorepo root (../..)
#   docker build -f infrastructure/dockerfiles/hermes.Dockerfile .
# ──────────────────────────────────────────────

FROM node:22-alpine AS hermes-base
WORKDIR /app

RUN apk add --no-cache curl git openssh bash

# Copy workspace root configs
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY package.json ./

# Install core workspace tools
RUN corepack enable && corepack prepare pnpm@11.13.0 --activate

# Copy any app-specific config if hermes package exists
# COPY apps/hermes/package.json ./apps/hermes/  # Future

# ── Development ───────────────────────────────
FROM hermes-base AS hermes-dev
ENV NODE_ENV=development

# In development, Hermes runs as a shell-accessible container
# with the scripts volume mounted for testing.
CMD ["sh", "-c", "echo 'Hermes agent ready' && tail -f /dev/null"]

# ── Production ────────────────────────────────
FROM hermes-base AS hermes-prod
ENV NODE_ENV=production

# Future: Copy the built Hermes application
# COPY apps/hermes/dist ./apps/hermes/dist
# COPY apps/hermes/node_modules ./apps/hermes/node_modules

# Future: Start the Hermes agent process
# CMD ["node", "apps/hermes/dist/main.js"]

# For now, keep the container running for manual interaction
CMD ["sh", "-c", "echo 'Hermes agent ready' && tail -f /dev/null"]
