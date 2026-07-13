# Orivastra — Infrastructure

Version: 0.1
Status: Foundation

---

## Purpose

This directory owns everything related to deployment, containerization, networking, and server operations.

Applications (`apps/`) contain business logic. Infrastructure contains deployment logic.

**They should never be mixed.**

---

## Folder Structure

```
infrastructure/
├── compose/               # Docker Compose files per environment (dev, prod, ai)
├── dockerfiles/           # Multi-stage Dockerfiles per application
├── env/                   # Environment variable templates (never commit real secrets)
├── nginx/                 # Nginx reverse proxy configuration
├── postgres/              # Database initialization scripts
├── redis/                 # Redis configuration (future: custom redis.conf)
├── scripts/               # Operational scripts for deployment and maintenance
└── README.md              # This file
```

---

## Deployment Philosophy

### Development Happens Locally

Coding, testing, and debugging happen on your laptop. Docker is used for running services (PostgreSQL, Redis) during development, but the applications themselves run via `pnpm dev` for fast iteration.

### Deployment Happens on the VPS

The AWS EC2 instance is a deployment target, NOT a development machine. No editors, no build tools, no source modification happens on the VPS. It runs containers and nothing else.

### Workflow

```
Developer Laptop
    │
    ├── git commit
    ├── git push
    │
    ▼
GitHub
    │
    ├── (future) GitHub Actions CI/CD
    │
    ▼
AWS EC2 (VPS)
    │
    ├── git pull
    ├── docker compose build
    ├── docker compose up -d
    │
    ▼
Production
```

**Future:** Manual `git pull` on the VPS will be replaced by GitHub Actions that automatically deploy on merge to `main`.

---

## Docker Philosophy

1. **Every application runs in its own container.** Frontend, backend, database, cache — all containerized.
2. **Docker networks isolate internal services.** PostgreSQL and Redis are never exposed to the public internet. Only Nginx listens on ports 80/443.
3. **Secrets come from environment variables.** Never hardcoded in Dockerfiles or compose files. Use `.env` files on the server.
4. **Images are built from the monorepo root.** Because `pnpm` workspaces need the full monorepo context, Dockerfiles build from the repository root, not individual app directories.
5. **Development and production use different Docker targets.** The same Dockerfile supports `dev` (hot-reload, volume mounts) and `prod` (optimized, standalone) targets.

---

## Environment Files

| File                      | Purpose                                                                 |
| ------------------------- | ----------------------------------------------------------------------- |
| `.env.example`            | Template with all available keys. Safe to commit.                       |
| `.env.development`        | Development defaults. Safe to commit (no real secrets).                 |
| `.env.production.example` | Production template. Shows required keys with `CHANGE_ME` placeholders. |
| `.env`                    | Actual production secrets. **NEVER committed.** Created on the VPS.     |

**Adding a new environment variable:**

1. Add it to `.env.example` with a placeholder value
2. Add it to `.env.development` with a dev-appropriate default
3. Add it to `.env.production.example` with instructions on how to generate it
4. Never put real values in any committed file

---

## Scripts — Overview

Each script is a **single-purpose, independently callable building block.** This design enables future Hermes/OpenClaw integration without needing the AI to execute arbitrary shell commands.

All scripts:

- Use `set -euo pipefail` for strict error handling
- Accept optional arguments for flexibility
- Are designed to be called individually (not as a monolithic pipeline)
- Include Hermes integration notes in comments

| Script                | Purpose                                                    |
| --------------------- | ---------------------------------------------------------- |
| `deploy.sh`           | Pull latest code, rebuild images, restart services, verify |
| `rollback.sh`         | Revert to a previous commit/tag after a failed deployment  |
| `backup-db.sh`        | Create a timestamped PostgreSQL dump                       |
| `health-check.sh`     | Verify all services are running and responding             |
| `restart-backend.sh`  | Gracefully restart the backend container                   |
| `restart-frontend.sh` | Gracefully restart the frontend container                  |
| `show-logs.sh`        | Tail logs from one or all services                         |

---

## Future Hermes / OpenClaw Integration

Hermes is an AI DevOps agent. It will live on the VPS alongside the applications and manage infrastructure through a **trusted command pattern**:

```
Telegram (user message)
    │
    ▼
Hermes (AI agent on VPS)
    │
    ├── Validates the request
    ├── Determines which script to call
    │
    ▼
Scripts/ (trusted, audited)
    │
    ├── deploy.sh
    ├── rollback.sh
    ├── backup-db.sh
    ├── health-check.sh
    ├── restart-backend.sh
    ├── restart-frontend.sh
    └── show-logs.sh
    │
    ▼
Docker (container orchestration)
    │
    ▼
Applications (running services)
```

**Key principle:** Hermes never executes arbitrary shell commands. It calls pre-defined, version-controlled scripts. Each script does one thing, logs its output, and returns a clear exit code. This makes the system auditable, testable, and safe for AI-driven operations.

**Example future flow:**

```
User: "Deploy the latest version"
  → Telegram → Hermes → backup-db.sh → deploy.sh → health-check.sh
  → Hermes reports: "Deployed. Backend healthy, frontend healthy."
```

---

## Security Rules

1. **Never commit `.env`.** It is in `.gitignore`.
2. **Never hardcode secrets** in Dockerfiles, compose files, or scripts.
3. **PostgreSQL and Redis never exposed publicly.** Only accessible via the internal Docker network.
4. **Only ports 80, 443, and SSH open** on the VPS firewall.
5. **Scripts run as a dedicated user**, not root.
6. **Database backups are encrypted** before storage (future).

---

## Current State (v0.1)

- [x] Docker Compose files: dev, prod, ai (compose/)
- [x] Multi-stage Dockerfiles: frontend, backend, hermes (dockerfiles/)
- [x] Nginx reverse proxy configuration
- [x] Environment variable templates (dev, prod, example)
- [x] Operational scripts (7 scripts with Hermes integration notes)
- [ ] SSL/TLS certificates (Let's Encrypt + Certbot)
- [ ] Monitoring stack (Prometheus + Grafana)
- [ ] Redis custom configuration
- [ ] Automated backup rotation
- [ ] GitHub Actions CI/CD deployment pipeline
- [ ] Hermes/OpenClaw agent
