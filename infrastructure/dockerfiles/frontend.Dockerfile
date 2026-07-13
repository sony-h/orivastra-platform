# ──────────────────────────────────────────────
# Orivastra — Frontend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the Next.js frontend.
#
# Stages:
#   frontend-base     Shared dependencies install (pnpm workspace)
#   frontend-dev      Development with Turbopack hot-reload
#   frontend-builder  Production build (next build)
#   frontend-prod     Minimal production image with standalone output
#
# Build contexts:
#   Context must be the monorepo root (../..)
#   docker build -f infrastructure/dockerfiles/frontend.Dockerfile .
# ──────────────────────────────────────────────

FROM node:24-alpine AS frontend-base
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.8.0 --activate

# Copy workspace root configs — these change rarely, good for layer caching
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY package.json turbo.json tsconfig.base.json ./

# Copy only package.json files for dependency installation
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/config/package.json ./packages/config/
COPY packages/types/package.json ./packages/types/
COPY packages/ui/package.json ./packages/ui/
COPY packages/utils/package.json ./packages/utils/

RUN pnpm install --frozen-lockfile

# Now copy the full source
COPY . .

# ── Development ───────────────────────────────
FROM frontend-base AS frontend-dev
ENV NODE_ENV=development
EXPOSE 3000
CMD ["pnpm", "--filter", "@orivastra/frontend", "dev"]

# ── Build ─────────────────────────────────────
FROM frontend-base AS frontend-builder
ENV NODE_ENV=production
RUN pnpm build --filter @orivastra/frontend

# ── Production ────────────────────────────────
FROM node:24-alpine AS frontend-prod
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy standalone output from builder
COPY --from=frontend-builder /app/apps/frontend/.next/standalone ./
COPY --from=frontend-builder /app/apps/frontend/.next/static ./apps/frontend/.next/static
COPY --from=frontend-builder /app/apps/frontend/public ./apps/frontend/public

EXPOSE 3000
CMD ["node", "apps/frontend/server.js"]
