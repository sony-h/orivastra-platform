# ──────────────────────────────────────────────
# Orivastra — Backend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the NestJS backend.
#
# Stages:
#   backend-base     Shared dependencies install (pnpm workspace)
#   backend-dev      Development with --watch hot-reload
#   backend-builder  Production build (nest build + prisma generate)
#   backend-prod     Minimal production image
#
# Build contexts:
#   Context must be the monorepo root (../..)
#   docker build -f infrastructure/dockerfiles/backend.Dockerfile .
# ──────────────────────────────────────────────

FROM node:24-alpine AS backend-base
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.8.0 --activate

# Copy workspace root configs
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY package.json turbo.json tsconfig.base.json ./

# Copy only package.json files for dependency installation
COPY apps/backend/package.json ./apps/backend/
COPY packages/config/package.json ./packages/config/

RUN pnpm install --frozen-lockfile

# Now copy the full source
COPY . .

# ── Development ───────────────────────────────
FROM backend-base AS backend-dev
ENV NODE_ENV=development
EXPOSE 3001
CMD ["pnpm", "--filter", "@orivastra/backend", "dev"]

# ── Build ─────────────────────────────────────
FROM backend-base AS backend-builder
ENV NODE_ENV=production

# Generate Prisma client, then build NestJS
RUN pnpm --filter @orivastra/backend prisma:generate
RUN pnpm --filter @orivastra/backend build

# ── Production ────────────────────────────────
FROM node:24-alpine AS backend-prod
WORKDIR /app

ENV NODE_ENV=production

# Copy built artifacts
COPY --from=backend-builder /app/apps/backend/dist ./dist
COPY --from=backend-builder /app/apps/backend/node_modules ./node_modules
COPY --from=backend-builder /app/apps/backend/prisma ./prisma
COPY --from=backend-builder /app/apps/backend/package.json ./

# Copy workspace packages that the backend depends on at runtime
COPY --from=backend-builder /app/packages/config/package.json ./packages/config/

EXPOSE 3001
CMD ["node", "dist/main.js"]
