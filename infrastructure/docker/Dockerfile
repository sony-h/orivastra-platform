# ---- Frontend ----
FROM node:24-alpine AS frontend-base
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.8.0 --activate

COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY package.json turbo.json tsconfig.base.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/config/package.json ./packages/config/
COPY packages/types/package.json ./packages/types/
COPY packages/ui/package.json ./packages/ui/
COPY packages/utils/package.json ./packages/utils/

RUN pnpm install --frozen-lockfile

COPY . .

FROM frontend-base AS frontend-dev
EXPOSE 3000
CMD ["pnpm", "--filter", "@orivastra/frontend", "dev"]

FROM frontend-base AS frontend-builder
RUN pnpm build --filter @orivastra/frontend

FROM node:24-alpine AS frontend-prod
WORKDIR /app

COPY --from=frontend-builder /app/apps/frontend/.next/standalone ./
COPY --from=frontend-builder /app/apps/frontend/.next/static ./apps/frontend/.next/static
COPY --from=frontend-builder /app/apps/frontend/public ./apps/frontend/public

EXPOSE 3000
CMD ["node", "apps/frontend/server.js"]
