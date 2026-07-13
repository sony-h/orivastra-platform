# Orivastra

Building Intelligent Digital Solutions for the Future.

## Overview

Orivastra is a modern technology company focused on designing, developing, and operating high-quality digital products for businesses and organizations.

This monorepo contains the complete Orivastra ecosystem — from the company website to infrastructure management, AI assistants, and automation platforms.

## Current Version

**0.1** — Company Profile Website

## Tech Stack

- **Frontend:** Next.js, React, TypeScript, Tailwind CSS, shadcn/ui, Framer Motion
- **Backend:** NestJS, Prisma, PostgreSQL, Redis
- **Infrastructure:** Docker, Nginx, AWS EC2
- **Monorepo:** Turborepo, pnpm

## Getting Started

```bash
pnpm install
pnpm dev
```

## Project Structure

```
orivastra/
├── apps/
│   ├── frontend/    # Next.js company website
│   ├── backend/     # NestJS API
│   ├── telegram/    # Telegram bot
│   └── hermes/      # AI agent
├── packages/
│   ├── ui/          # Shared UI components
│   ├── config/      # Shared configuration
│   ├── types/       # Shared TypeScript types
│   └── utils/       # Shared utilities
├── infrastructure/  # Docker, Nginx, database configs
├── docs/            # Project documentation
└── scripts/         # Utility scripts
```

## License

Proprietary — All rights reserved.
