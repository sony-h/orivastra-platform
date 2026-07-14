# Orivastra — Infrastructure

Version: 0.2
Status: Hybrid Architecture

---

## Purpose

This directory owns everything related to deployment, containerization, networking, and server operations.

**Applications** (`apps/`) contain business logic. **Infrastructure** contains deployment logic. They should never be mixed.

---

## Architecture Philosophy — Hybrid Infrastructure

Orivastra uses a **hybrid infrastructure**:

| Layer              | Technology               | Responsibility                       |
| ------------------ | ------------------------ | ------------------------------------ |
| **Applications**   | PM2 native processes     | Frontend (Next.js), Backend (NestJS) |
| **Infrastructure** | Docker containers        | PostgreSQL, Redis, Adminer           |
| **Proxy**          | Nginx (native package)   | Reverse proxy, TLS termination       |
| **Deployment**     | Git + pnpm + turbo + PM2 | Pull, build, restart                 |

### Why applications are native

- **Simplicity**: No Dockerfile complexity for pnpm workspace builds. No volume mount issues. No `COPY` symlink problems. Builds run directly with `pnpm install && turbo build`.
- **Performance**: Native processes start and restart in milliseconds. No Docker daemon overhead.
- **Debugging**: `pm2 logs`, `curl localhost`, `journalctl` — standard Linux tools. No `docker exec`.
- **CI compatibility**: Same commands work on GitHub Actions, local WSL, and the VPS. No Docker-in-Docker needed.
- **Future Hermes integration**: Hermes calls PM2 commands and trusted scripts directly, without wrapping every action in Docker API calls.

### Why infrastructure uses Docker

- **Isolation**: PostgreSQL and Redis are self-contained, need no orchestration, and benefit from Docker's predictable environment.
- **Portability**: Same PostgreSQL version across all environments (dev, CI, prod).
- **Maintainability**: Backups, restarts, health checks via Docker CLI or compose. No manual PostgreSQL installation.
- **Replacement**: Infrastructure services can be swapped (e.g., PostgreSQL → RDS, Redis → ElastiCache) without changing application code.

### Future migration path

If containerization becomes necessary for applications in the future (e.g., Kubernetes, ECS, scaling requirements), the Dockerfiles in `legacy/dockerfiles/` can be reactivated. The current PM2-based deployment is designed to coexist with or transition to full containerization.

---

## Folder Structure

```
infrastructure/
├── compose/
│   ├── compose.infrastructure.yml    # Docker infra services (PostgreSQL, Redis, Adminer)
│   └── compose.ai.yml                # Future AI services placeholder
├── legacy/
│   └── dockerfiles/                  # Preserved Dockerfiles (frontend, backend, hermes)
├── env/
│   ├── .env.example                  # Infra-only env template
│   ├── .env.development              # Local dev values for infra
│   └── .env.production.example       # Production infra template
├── nginx/
│   └── default.conf                  # Reverse proxy configuration
├── postgres/
│   └── init.sql                      # Database initialization
├── redis/                            # Future Redis configuration
├── scripts/
│   ├── deploy-backend.sh             # Pull → install → build → restart backend
│   ├── deploy-frontend.sh            # Pull → install → build → restart frontend
│   ├── restart-all.sh                # Gracefully restart both apps + health check
│   ├── restart-backend.sh            # PM2 restart backend
│   ├── restart-frontend.sh           # PM2 restart frontend
│   ├── health-check.sh               # Verify infra services + PM2 + HTTP endpoints
│   ├── backup-db.sh                  # Create PostgreSQL dump
│   └── rollback.sh                   # Git revert + rebuild + redeploy
└── README.md                         # This file
```

---

## Deployment Workflow

### Full Backend Deployment

```bash
# 1. Backup database
./infrastructure/scripts/backup-db.sh

# 2. Deploy backend
./infrastructure/scripts/deploy-backend.sh
#   → git pull origin main
#   → pnpm install --frozen-lockfile
#   → turbo build --filter=@orivastra/backend
#   → pm2 restart backend
#   → health-check.sh
```

### Full Frontend Deployment

```bash
./infrastructure/scripts/deploy-frontend.sh
```

### Quick Restart

```bash
./infrastructure/scripts/restart-all.sh    # Both apps + health check
./infrastructure/scripts/restart-backend.sh # Backend only
./infrastructure/scripts/restart-frontend.sh # Frontend only
```

### Rollback

```bash
./infrastructure/scripts/rollback.sh              # Previous commit
./infrastructure/scripts/rollback.sh <commit-hash> # Specific commit
```

---

## PM2 Philosophy

**PM2 is the application process manager.** It runs the frontend and backend as native processes on the VPS.

| Aspect            | Approach                                                            |
| ----------------- | ------------------------------------------------------------------- |
| **Installation**  | `npm install -g pm2` on the VPS (once, not per-project)             |
| **Configuration** | `ecosystem.config.js` at the repository root (committed)            |
| **Environment**   | Env vars from `/etc/orivastra.env` (never committed)                |
| **Startup**       | `pm2 startup systemd` — registers with systemd, auto-starts on boot |
| **Restart**       | `pm2 restart <name>` — graceful, respects `kill_timeout`            |
| **Logs**          | `pm2 logs <name>` — rotated files in `~/.pm2/logs/`                 |
| **Monitoring**    | `pm2 monit` — CPU/memory per process                                |

### PM2 Commands

```bash
pm2 start ecosystem.config.js          # Start all apps
pm2 restart ecosystem.config.js        # Restart all apps
pm2 restart backend                    # Restart single app
pm2 stop backend                       # Stop single app
pm2 status                             # List app status
pm2 logs                               # Tail all logs
pm2 logs backend                       # Tail backend logs
pm2 save                               # Save process list
pm2 startup systemd                    # Enable auto-start on boot
```

### Env File Location

On the VPS, `/etc/orivastra.env` contains both infrastructure and application environment variables:

```bash
# Database
DATABASE_URL=postgresql://orivastra:CHANGE_ME@localhost:5432/orivastra
POSTGRES_PASSWORD=CHANGE_ME

# Cache
REDIS_URL=redis://localhost:6379

# Backend
PORT=3001
JWT_SECRET=CHANGE_ME

# Frontend
NEXT_PUBLIC_API_URL=https://orivastra.com/api
```

---

## Docker Infrastructure

### Starting Services

```bash
# Production (PostgreSQL + Redis only)
docker compose -f infrastructure/compose/compose.infrastructure.yml up -d

# Development (with Adminer GUI)
docker compose -f infrastructure/compose/compose.infrastructure.yml --profile dev up -d
```

### Stopping Services

```bash
docker compose -f infrastructure/compose/compose.infrastructure.yml down
docker compose -f infrastructure/compose/compose.infrastructure.yml down -v   # Also delete volumes
```

### Backups

```bash
./infrastructure/scripts/backup-db.sh                    # Save to ./backups/
./infrastructure/scripts/backup-db.sh /path/to/backup/   # Custom directory
```

---

## Environment Files

| File                                         | Purpose                                           |
| -------------------------------------------- | ------------------------------------------------- |
| `infrastructure/env/.env.example`            | Template for infrastructure vars. Safe to commit. |
| `infrastructure/env/.env.development`        | Development defaults. Safe to commit.             |
| `infrastructure/env/.env.production.example` | Production template. Safe to commit.              |
| `apps/backend/.env.example`                  | Backend env vars template.                        |
| `apps/frontend/.env.example`                 | Frontend env vars template.                       |
| `/etc/orivastra.env` (VPS)                   | **Actual production secrets.** NEVER committed.   |

---

## Security Rules

1. **Never commit `/etc/orivastra.env`** or any `.env` file with real secrets. They are in `.gitignore`.
2. **PostgreSQL and Redis** are exposed to the host machine (`localhost`). Host firewall should block external access to ports 5432 and 6379.
3. **Adminer** is a development-only service (Docker profile `dev`). Never run it in production.
4. **Applications** run as the Linux user who owns the project directory, not as root.
5. **PM2** runs under a dedicated Linux user (future: create `orivastra` system user).

---

## Legacy Dockerfiles

The Dockerfiles in `infrastructure/legacy/dockerfiles/` are preserved for future use. They were used when applications were fully containerized. The current deployment strategy does NOT use them.

To reactivate them:

1. Move them back to `infrastructure/dockerfiles/`
2. Update compose files to reference the Docker targets
3. Switch PM2 processes back to `docker compose` commands

---

## Long-Term Vision — Hermes Integration

The future architecture aims for AI-driven operations through Hermes:

```
Telegram
    │
    ▼
Hermes (AI agent on VPS)
    │
    ├── Validates user request
    ├── Determines trusted script to call
    │
    ▼
Scripts/ (audited, version-controlled)
    │
    ├── deploy-backend.sh
    ├── deploy-frontend.sh
    ├── restart-all.sh
    ├── health-check.sh
    ├── backup-db.sh
    └── rollback.sh
    │
    ▼
PM2 (application orchestration) → Docker (infrastructure) → Production

---

Backend Deployment Service (NestJS endpoint, future):
- Hermes calls a secure REST endpoint
- Backend validates permissions and executes the trusted script
- Result is returned as JSON
- Hermes reports to the user via Telegram
```

**Key principle:** Hermes never executes arbitrary shell commands. It calls pre-defined, version-controlled scripts that are auditable, testable, and safe.

---

## Current State (v0.2)

- [x] Compose infrastructure file (PostgreSQL, Redis, Adminer)
- [x] Nginx reverse proxy configuration (localhost upstreams)
- [x] Environment variable templates (infra + apps)
- [x] PM2 ecosystem configuration (ecosystem.config.js)
- [x] Deployment scripts (per-app: deploy, restart, health check)
- [x] Backup and rollback scripts
- [x] Legacy Dockerfiles preserved
- [ ] SSL/TLS certificates (Let's Encrypt + Certbot)
- [ ] Redis custom configuration
- [ ] Database backup rotation
- [ ] GitHub Actions CI/CD pipeline
- [ ] Hermes/OpenClaw agent
- [ ] Monitoring stack (Prometheus + Grafana)
