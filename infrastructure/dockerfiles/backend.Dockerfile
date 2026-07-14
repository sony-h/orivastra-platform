# ──────────────────────────────────────────────
# Orivastra — Backend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the NestJS backend.
#
# Stage design:
#   base       Node.js + corepack
#   deps       package.json files → pnpm install
#   builder    Source → prisma generate → nest build
#              → pnpm deploy (production deps)
#   runner     Minimal production image, non-root
#   dev        Shared deps, volume-mounted source
#
# Builder uses `node` with resolved paths from
# the pnpm virtual store to invoke prisma/nest
# directly, bypassing pnpm v11's runDepsStatusCheck.
#
# pnpm deploy creates the production dependency
# tree. dist/ and .prisma/client/ are gitignored
# so pnpm deploy excludes them — copied manually.
#
# Build:
#   docker build -f infrastructure/dockerfiles/backend.Dockerfile .
# ──────────────────────────────────────────────

FROM node:22-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@11.13.0 --activate

# ── Dependencies ──────────────────────────────
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY package.json turbo.json tsconfig.base.json ./
COPY apps/backend/package.json ./apps/backend/
COPY packages/config/package.json ./packages/config/

RUN pnpm install --frozen-lockfile --ignore-scripts

# ── Builder ───────────────────────────────────
FROM deps AS builder
COPY . .
ENV NODE_ENV=production

RUN cd apps/backend && \
    PRISMA_BIN=$(find /app/node_modules/.pnpm \( -name prisma -o -name prisma.js \) -not -path "*/node_modules/.bin/*" 2>/dev/null | head -1) && \
    node "$PRISMA_BIN" generate

RUN cd apps/backend && \
    NEST_BIN=$(find /app/node_modules/.pnpm \( -name nest -o -name nest.js \) -not -path "*/node_modules/.bin/*" 2>/dev/null | head -1) && \
    node "$NEST_BIN" build

# ── Runner (production) ──────────────────────
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/prisma ./prisma
COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/package.json ./
COPY --from=builder /app/node_modules ./node_modules

USER nextjs
EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/health',function(r){process.exit(r.statusCode===200?0:1)})"

CMD ["node", "dist/main.js"]

# ── Development ──────────────────────────────
FROM deps AS backend-dev
ENV NODE_ENV=development
WORKDIR /app/apps/backend
EXPOSE 3001
CMD ["pnpm", "dev"]
