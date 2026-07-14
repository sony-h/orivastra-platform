# ──────────────────────────────────────────────
# Orivastra — Frontend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the Next.js frontend.
#
# Key design: pnpm v11 runs `pnpm install` as a
# dependency check before every --filter command.
# This internal install does NOT respect --ignore-scripts
# and fails on ERR_PNPM_IGNORED_BUILDS in Docker.
#
# Fix: a wrapper script intercepts `pnpm install`
# calls from the dep check and appends --ignore-scripts.
#
# Build:
#   docker build -f infrastructure/dockerfiles/frontend.Dockerfile .
# ──────────────────────────────────────────────

# ── Base (shared deps) ────────────────────────
FROM node:24-alpine AS frontend-base
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.8.0 --activate

# pnpm wrapper: forces --ignore-scripts on all install calls
# that pnpm's internal dependency check spawns
RUN mv /usr/local/bin/pnpm /usr/local/bin/pnpm-real && \
    printf '#!/bin/sh\nset -e\ncase "$*" in\n  install*)\n    exec /usr/local/bin/pnpm-real "$$@" --ignore-scripts\n    ;;\n  *)\n    exec /usr/local/bin/pnpm-real "$$@"\n    ;;\nesac\n' > /usr/local/bin/pnpm && \
    chmod +x /usr/local/bin/pnpm

COPY pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY package.json turbo.json tsconfig.base.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/types/package.json ./packages/types/
COPY packages/ui/package.json ./packages/ui/
COPY packages/utils/package.json ./packages/utils/

RUN pnpm install --frozen-lockfile --ignore-scripts

# ── Development ───────────────────────────────
FROM frontend-base AS frontend-dev
COPY . .
ENV NODE_ENV=development
EXPOSE 3000
CMD ["pnpm", "--filter", "@orivastra/frontend", "dev"]

# ── Builder ───────────────────────────────────
FROM frontend-base AS frontend-builder
COPY . .
ENV NODE_ENV=production
RUN pnpm --filter @orivastra/frontend build

# ── Production ────────────────────────────────
FROM node:24-alpine AS frontend-prod
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=frontend-builder /app/apps/frontend/.next/standalone ./
COPY --from=frontend-builder /app/apps/frontend/.next/static ./apps/frontend/.next/static
COPY --from=frontend-builder /app/apps/frontend/public ./apps/frontend/public

EXPOSE 3000
CMD ["node", "apps/frontend/server.js"]
