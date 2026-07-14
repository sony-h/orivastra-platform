# ──────────────────────────────────────────────
# Orivastra — Frontend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the Next.js frontend.
#
# Stage design:
#   base       Node.js + corepack
#   deps       package.json files → pnpm install
#   builder    Source → next build (standalone)
#   runner     Minimal production image, non-root
#   dev        Shared deps, volume-mounted source
#
# Builder uses `node` with a resolved path from
# the pnpm virtual store to invoke next build
# directly. This bypasses pnpm v11's runDepsStatusCheck
# which spawns a child install that does not read
# .npmrc configuration.
#
# Build:
#   docker build -f infrastructure/dockerfiles/frontend.Dockerfile .
#   docker build --target frontend-dev -f infrastructure/dockerfiles/frontend.Dockerfile .
# ──────────────────────────────────────────────

FROM node:22-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@11.13.0 --activate

# ── Dependencies ──────────────────────────────
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY package.json turbo.json tsconfig.base.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/types/package.json ./packages/types/
COPY packages/ui/package.json ./packages/ui/
COPY packages/utils/package.json ./packages/utils/
COPY packages/config/package.json ./packages/config/

RUN pnpm install --frozen-lockfile --ignore-scripts

# ── Builder ───────────────────────────────────
FROM deps AS builder
COPY . .
ENV NODE_ENV=production

RUN cd apps/frontend && \
    NEXT_BIN=$(find /app/node_modules/.pnpm -name next -path "*/dist/bin/next" -type f 2>/dev/null | head -1) && \
    node "$NEXT_BIN" build

# ── Runner (production) ──────────────────────
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/apps/frontend/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/frontend/.next/static ./apps/frontend/.next/static
COPY --from=builder --chown=nextjs:nodejs /app/apps/frontend/public ./apps/frontend/public

USER nextjs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000',function(r){process.exit(r.statusCode===200?0:1)})"

CMD ["node", "apps/frontend/server.js"]

# ── Development ──────────────────────────────
FROM deps AS frontend-dev
ENV NODE_ENV=development
WORKDIR /app/apps/frontend
EXPOSE 3000
CMD ["pnpm", "dev"]
