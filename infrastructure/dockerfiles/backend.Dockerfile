# ──────────────────────────────────────────────
# Orivastra — Backend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the NestJS backend.
#
# Key design: same pnpm wrapper pattern as
# frontend.Dockerfile to handle pnpm v11's
# internal dep check that re-runs pnpm install
# without --ignore-scripts.
#
# Build:
#   docker build -f infrastructure/dockerfiles/backend.Dockerfile .
# ──────────────────────────────────────────────

# ── Base (shared deps) ────────────────────────
FROM node:24-alpine AS backend-base
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.8.0 --activate

# pnpm wrapper: forces --ignore-scripts on all install calls
# that pnpm's internal dependency check spawns
RUN mv /usr/local/bin/pnpm /usr/local/bin/pnpm-real && \
    printf '#!/bin/sh\nset -e\ncase "$*" in\n  install*)\n    exec /usr/local/bin/pnpm-real "$$@" --ignore-scripts\n    ;;\n  *)\n    exec /usr/local/bin/pnpm-real "$$@"\n    ;;\nesac\n' > /usr/local/bin/pnpm && \
    chmod +x /usr/local/bin/pnpm

COPY pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY package.json turbo.json tsconfig.base.json ./
COPY apps/backend/package.json ./apps/backend/

RUN pnpm install --frozen-lockfile --ignore-scripts

# ── Development ───────────────────────────────
FROM backend-base AS backend-dev
COPY . .
ENV NODE_ENV=development
EXPOSE 3001
CMD ["pnpm", "--filter", "@orivastra/backend", "dev"]

# ── Builder ───────────────────────────────────
FROM backend-base AS backend-builder
COPY . .
ENV NODE_ENV=production

RUN pnpm --filter @orivastra/backend build

# Deploy with production deps only
RUN pnpm deploy --filter @orivastra/backend --prod /deploy
# dist/ is gitignored — pnpm deploy excludes it. Copy manually.
RUN cp -r /app/apps/backend/dist /deploy/dist
# Generated Prisma client (.prisma/client/) lives inside the pnpm virtual
# store, not in the deploy output. Copy it so @prisma/client works at runtime.
RUN mkdir -p /deploy/node_modules/.prisma && \
    cp -rL /app/apps/backend/node_modules/.prisma/client /deploy/node_modules/.prisma/client

# ── Production ────────────────────────────────
FROM node:24-alpine AS backend-prod
WORKDIR /app

ENV NODE_ENV=production

COPY --from=backend-builder /deploy ./

EXPOSE 3001
CMD ["node", "dist/main.js"]
