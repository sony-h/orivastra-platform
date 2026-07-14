# 03_TECH_ARCHITECTURE.md

# Orivastra Technical Architecture

Version: 0.1

Status: Planning

---

# 1. Overview

This document defines the overall technical architecture of Orivastra.

The objective is to create a scalable platform that begins as a company profile website and gradually evolves into a complete ecosystem consisting of web applications, AI services, infrastructure management, and cloud automation.

Every architectural decision should prioritize:

- Scalability
- Maintainability
- Performance
- Security
- Developer Experience

---

# 2. High Level Architecture

```
                    Internet
                         │
                         │
                 Cloudflare (Future)
                         │
                         │
                  Nginx Reverse Proxy
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
   Next.js Frontend                 NestJS Backend
                                            │
                           ┌────────────────┴───────────────┐
                           ▼                                ▼
                     PostgreSQL                         Redis
                           │
                           ▼
                     Docker Network
                           │
                           ▼
                        AWS EC2
```

Future architecture

```
Internet

↓

Cloudflare

↓

Nginx

↓

Frontend

↓

Backend

↓

PostgreSQL

↓

Redis

↓

Hermes/OpenClaw

↓

Telegram Bot

↓

GitHub

↓

Docker

↓

Monitoring
```

---

# 3. Architecture Principles

The architecture follows several engineering principles.

## Modular

Each application should have a single responsibility.

Frontend should never contain backend logic.

Backend should never directly manipulate infrastructure.

---

## Scalable

Every module should be replaceable without rewriting the entire project.

Example:

Redis can later become Redis Cluster.

EC2 can later become Kubernetes.

---

## Hybrid Infrastructure

Applications run natively on the host via PM2.

Infrastructure services (PostgreSQL, Redis) run inside Docker.

This hybrid approach balances simplicity, performance, and portability.

### Why applications are native

- Faster builds and restarts (no Docker overhead)
- Simpler debugging (`pm2 logs`, `curl localhost`)
- pnpm workspaces work naturally without volume mount issues
- Same commands work locally (WSL), on CI (GitHub Actions), and on the VPS

### Why infrastructure uses Docker

- PostgreSQL and Redis are self-contained, version-pinned, and portable across environments
- Backups and health checks use standard Docker commands
- Infrastructure can be swapped (e.g., RDS, ElastiCache) without application changes

### Future migration

If containerization becomes necessary for applications (Kubernetes, ECS, etc.), the preserved Dockerfiles in `infrastructure/legacy/dockerfiles/` can be reactivated.

The VPS should never become the development environment.

Development happens locally.

Deployment happens through PM2 and Docker Compose.

---

## API First

Communication between frontend and backend must happen through REST APIs.

The frontend must never directly communicate with the database.

---

## AI Ready

The architecture should allow future integration with:

- Hermes
- OpenClaw
- Telegram Bot
- GitHub
- AI Automation

without requiring major redesign.

---

# 4. System Components

## Frontend

Purpose

Public-facing website.

Responsibilities

- UI
- Routing
- SEO
- User Interaction
- API Requests

Technology

- Next.js
- React
- TypeScript
- Tailwind CSS

---

## Backend

Purpose

Business Logic.

Responsibilities

- REST API
- Authentication (future)
- Database Access
- Validation
- Logging

Technology

- NestJS
- TypeScript

---

## Database

Purpose

Persistent Storage.

Technology

- PostgreSQL

Stores

- Users
- Projects
- Articles
- Contact Requests
- Services
- Dashboard Data

---

## Cache

Purpose

High-speed temporary storage.

Technology

Redis

Uses

- Session
- Cache
- Queue
- Future AI Memory

---

## Infrastructure

Purpose

Application Hosting.

Technology

- AWS EC2
- Docker
- Docker Compose
- Nginx

---

# 5. Development Workflow

```
Developer

↓

Git

↓

GitHub

↓

AWS VPS

↓

git pull

↓

pnpm install

↓

turbo build

↓

PM2 Restart

↓

Production

```

Development should never occur directly on the VPS.

---

# 6. Deployment Workflow

```
Windows (WSL)
↓
VS Code
↓
Git Commit
↓
GitHub
↓
AWS VPS
↓
git pull
↓
pnpm install
↓
turbo build
↓
PM2 Restart
↓
Docker Infrastructure (PostgreSQL, Redis)
↓
Production
```

Future

```
Git Push

↓

GitHub Actions

↓

Automatic Deployment
```

---

# 7. Repository Structure

```
orivastra/

├── apps/
│
│   ├── frontend/
│
│   ├── backend/
│
│   ├── telegram/
│
│   └── hermes/
│
├── infrastructure/
│
│   ├── docker/
│
│   ├── nginx/
│
│   ├── postgres/
│
│   ├── redis/
│
│   └── monitoring/
│
├── packages/
│
│   ├── ui/
│
│   ├── config/
│
│   └── types/
│
├── docs/
│
├── scripts/
│
└── README.md
```

---

# 8. Technology Stack

## Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS
- shadcn/ui
- Framer Motion

---

## Backend

- NestJS
- Prisma ORM
- TypeScript

---

## Database

- PostgreSQL

---

## Cache

- Redis

---

## Infrastructure

- Docker
- Docker Compose
- Nginx
- AWS EC2

---

## Version Control

- Git
- GitHub

---

## AI

- DeepSeek V4
- OpenAI GPT
- Claude
- Hermes
- OpenClaw

---

# 9. Security Principles

- HTTPS only (production)
- Environment variables for secrets
- Never expose PostgreSQL publicly
- Never expose Redis publicly
- Validate all user input
- Principle of least privilege
- Docker containers isolated through internal networks

---

# 10. Scalability Roadmap

Current

```
Landing Page
```

↓

Future

```
Landing Page

↓

Portfolio

↓

Blog

↓

CMS

↓

Authentication

↓

Dashboard

↓

AI Platform

↓

Infrastructure Management
```

The architecture should support each phase without requiring a complete redesign.

---

# 11. Future Integrations

Planned integrations include:

- Telegram Bot
- GitHub API
- Cloudflare API
- Docker API
- OpenAI API
- DeepSeek API
- Hermes/OpenClaw
- Monitoring Stack
- CI/CD Pipeline

---

# 12. Engineering Philosophy

Orivastra follows a "build for tomorrow" philosophy.

Features should be implemented only when necessary, but the architecture should always be prepared for future growth.

Avoid overengineering.

Prefer simple, maintainable solutions.

Optimize only when real requirements emerge.

---

# AI Notes

Current focus:

Version 0.1

Only develop:

- Company Profile Website
- Basic Backend Structure
- Responsive UI
- Docker Environment

Do NOT implement:

- Authentication
- Dashboard
- Monitoring
- AI Assistant
- Telegram Integration
- Infrastructure Automation

Those belong to future milestones.
