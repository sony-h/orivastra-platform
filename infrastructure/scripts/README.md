# Orivastra — Operations Layer

Version: 0.3
Status: Active

---

## Purpose

This directory is the **single operational interface** for the Orivastra platform.

Every task — deploying, restarting, monitoring, backing up, restoring, migrating, cleaning — is executable through a dedicated script. Scripts are modular, reusable, and use a shared library for all common logic.

---

## Philosophy: The Trusted Execution Layer

The operations layer is designed to be **the only way** to interact with the platform in production.

```
Telegram
    │
    ▼
Hermes (AI agent)
    │
    ▼
Deployment API (future NestJS endpoint)
    │
    ▼
╔══════════════════════════════════════╗
║   Operations Scripts  ← TRUSTED     ║
╠══════════════════════════════════════╣
║  deploy/    restart/   monitoring/  ║
║  database/  maintenance/            ║
╚══════════════════════════════════════╝
    │
    ├── PM2 (applications: Next.js, NestJS)
    └── Docker (infrastructure: PostgreSQL, Redis, Adminer)
```

**Key principle:** No one — not Hermes, not a dashboard, not a CI/CD pipeline — should execute arbitrary shell commands on the server. All operations must go through this layer. This makes the system auditable, testable, and safe for AI-driven operations.

---

## Folder Structure

```
scripts/
├── lib/
│   ├── common.sh       Colors, logging, constants, utility functions
│   ├── checks.sh       Preflight validation (tools, resources, connectivity)
│   ├── git.sh          Git operations (pull, status, revert)
│   ├── pm2.sh          PM2 process management (start, restart, logs)
│   ├── docker.sh       Docker infrastructure management
│   └── health.sh       Health checks (HTTP, PostgreSQL, Redis, PM2)
├── deploy/
│   ├── deploy-backend.sh     Full backend deployment pipeline
│   ├── deploy-frontend.sh    Full frontend deployment pipeline
│   ├── deploy-all.sh         Deploy both (delegates to per-app scripts)
│   └── rollback.sh           Git revert + rebuild + restart + health check
├── restart/
│   ├── restart-backend.sh    Graceful PM2 restart (backend only)
│   ├── restart-frontend.sh   Graceful PM2 restart (frontend only)
│   └── restart-all.sh        Restart both + health check
├── monitoring/
│   ├── status.sh             Comprehensive platform status report
│   ├── logs.sh               Route logs to PM2 or Docker
│   ├── health.sh             Run all health checks (PASS/FAIL)
│   └── ports.sh              Listening ports with process info
├── database/
│   ├── backup-db.sh          Compressed PostgreSQL dump
│   ├── restore-db.sh         Interactive restore with safety backup
│   └── migrate.sh            Prisma operations (generate, push, migrate)
├── maintenance/
│   ├── cleanup.sh            Remove temp files, caches, old builds
│   └── update-system.sh      System package update (Ubuntu, Docker, Node)
└── README.md                 This file
```

---

## Library Reference

Every script sources `lib/common.sh` first, which provides:

| Function/Variable   | Description                                          |
| ------------------- | ---------------------------------------------------- |
| `info()`            | Cyan-colored informational message                   |
| `warn()`            | Yellow-colored warning message                       |
| `error()`           | Red-colored error message to stderr                  |
| `success()`         | Green-colored success message                        |
| `show_help()`       | Prints header comments as help text                  |
| `confirm()`         | Interactive Yes/No prompt                            |
| `PROJECT_ROOT`      | Absolute path to repository root                     |
| `COMPOSE_FILE`      | Path to infrastructure compose file                  |
| `BACKEND_PM2_NAME`  | PM2 process name for backend                         |
| `FRONTEND_PM2_NAME` | PM2 process name for frontend                        |
| `BACKUP_DIR`        | Database backup directory (`/opt/orivastra/backups`) |

Module libraries build on top:

| Library     | Key Functions                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------------- |
| `checks.sh` | `preflight()` — validates git, node, pnpm, pm2, docker, internet, disk, memory                                 |
| `git.sh`    | `git_pull()`, `current_branch()`, `current_commit()`, `git_revert_to()`                                        |
| `pm2.sh`    | `pm2_restart_backend()`, `pm2_restart_frontend()`, `pm2_restart_all()`, `pm2_show_logs()`, `pm2_show_status()` |
| `docker.sh` | `docker_start_infra()`, `docker_stop_infra()`, `docker_restart_infra()`, `docker_status()`, `docker_logs()`    |
| `health.sh` | `health_backend_http()`, `health_frontend_http()`, `health_postgres()`, `health_redis()`, `health_all()`       |

---

## Usage Examples

```bash
# Deploy
./scripts/deploy/deploy-backend.sh
./scripts/deploy/deploy-all.sh

# Restart
./scripts/restart/restart-backend.sh
./scripts/restart/restart-all.sh

# Monitor
./scripts/monitoring/status.sh
./scripts/monitoring/health.sh
./scripts/monitoring/logs.sh backend
./scripts/monitoring/ports.sh

# Database
./scripts/database/backup-db.sh
./scripts/database/restore-db.sh --list
./scripts/database/migrate.sh generate

# Maintenance
sudo ./scripts/maintenance/cleanup.sh
sudo ./scripts/maintenance/update-system.sh
```

---

## Standards

Every script follows:

- **Shebang:** `#!/usr/bin/env bash`
- **Strict mode:** `set -Eeuo pipefail` (inherited from `common.sh`)
- **Error handling:** Non-zero exit codes for failures
- **Help:** `--help` or `-h` prints the script's header documentation
- **No magic values:** All constants defined in `lib/common.sh`
- **No duplicated logic:** Each operation lives in exactly one function or script
- **Color output:** Consistent info/warn/error/success across all scripts
- **Hermes-ready:** Exit codes and structured output for AI consumption

---

## Future Architecture

```
Telegram
    │
    ▼
Hermes (AI agent)
    │
    ├── Validates user request
    ├── Determines which operation to execute
    │
    ▼
Backend Deployment Service (NestJS endpoint)
    │
    ├── Authenticates the request
    ├── Validates permissions
    ├── Executes the trusted script
    │   ./scripts/deploy/deploy-backend.sh
    │
    ▼
Script (audited, version-controlled)
    │
    ├── Calls shared library functions
    ├── Returns exit code + logs
    │
    ▼
PM2 or Docker
    │
    ▼
Production
```

**How Hermes uses this layer:**

1. Hermes receives a user command via Telegram: "Deploy backend"
2. Hermes sends a request to the Deployment API (NestJS endpoint)
3. The API validates permissions and executes `deploy-backend.sh`
4. The script runs: `git pull → pnpm install → turbo build → pm2 restart → health check`
5. Exit code and logs are returned to Hermes
6. Hermes reports success/failure to the user

**How GitHub Actions will use this layer:**

1. CI/CD pipeline runs on push to `main`
2. Pipeline copies the scripts to the server via SSH or triggers the Deployment API
3. Executes `deploy/deploy-all.sh`
4. Health check runs automatically — if it fails, `rollback.sh` is executed
5. Status is reported back to the GitHub commit (deploy status check)

**How Dashboard will use this layer:**

1. Dashboard backend calls the Deployment API
2. API wraps script execution as REST endpoints
3. Dashboard displays real-time output from scripts
4. Users trigger operations via Dashboard UI → API → Scripts

---

## Security

- Scripts should be executed by the project's Linux user (not root), unless they explicitly require root (detected and noted).
- The `update-system.sh` script requires sudo.
- Database credentials come from `/etc/orivastra.env` (never hardcoded).
- Backup files are readable only by the project user.
- All destructive operations (restore, rollback) require confirmation.
