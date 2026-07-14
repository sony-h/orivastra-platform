# ──────────────────────────────────────────────
# Orivastra — Backend Dockerfile
# ──────────────────────────────────────────────
# Multi-stage build for the NestJS backend.
#
# Stage design:
#   base       Node.js + corepack
#   deps       package.json files → pnpm install
#   builder    Source → prisma generate → nest build
#              → pnpm prune --prod (strips dev deps)
#   runner     Minimal production image, non-root
#   dev        Shared deps, volume-mounted source
#
# Production deps strategy:
#   pnpm v11's runDepsStatusCheck spawns a child process that ignores
#   .npmrc (ERR_PNPM_IGNORED_BUILDS). Workaround:
#   - Build : invoke prisma/nest directly via find in the virtual store
#   - Prune : pnpm prune --prod strips dev deps without triggering
#             runDepsStatusCheck (prune is a direct command, not a
#             script runner). Generated Prisma client inside @prisma/client
#             is preserved.
#   - Runner: COPY resolved files — no symlink-chain dependency.
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

RUN cd apps/backend && rm -f tsconfig.tsbuildinfo dist/*.tsbuildinfo 2>/dev/null && \
    NEST_BIN=$(find /app/node_modules/.pnpm \( -name nest -o -name nest.js \) -not -path "*/node_modules/.bin/*" 2>/dev/null | head -1) && \
    node "$NEST_BIN" build

# Strip devDependencies. pnpm prune does NOT trigger runDepsStatusCheck
# (only run/exec do). Generated Prisma client inside @prisma/client is
# preserved. If it fails (e.g. pnpm version regression), the build
# continues with full node_modules (larger image but functional).
RUN pnpm prune --prod 2>&1 || echo "prune skipped — keeping full node_modules"

# ── Runner (production) ──────────────────────
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/dist ./apps/backend/dist
COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/prisma ./apps/backend/prisma
COPY --from=builder --chown=nextjs:nodejs /app/apps/backend/package.json ./apps/backend/
COPY --from=builder /app/apps/backend/node_modules ./apps/backend/node_modules
COPY --from=builder /app/node_modules ./node_modules
# Prisma v6 places generated client inside @prisma/client in the virtual
# store, not at a separate .prisma/ path. The symlinks above resolve
# through the virtual store — no extra copy needed for Prisma.

WORKDIR /app/apps/backend
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
