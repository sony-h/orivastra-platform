# 05_DEVELOPMENT_GUIDE.md

# Orivastra Development Guide

Version: 0.1

Status: Active

---

# 1. Purpose

This document defines the engineering standards used throughout the Orivastra project.

Its objective is to ensure that all code—whether written by humans or AI—follows a consistent architecture, coding style, and development workflow.

The primary goals are:

- Consistency
- Maintainability
- Scalability
- Readability
- Collaboration

---

# 2. Development Philosophy

Orivastra follows several engineering principles.

## Build Simple

Avoid unnecessary complexity.

Every feature should solve a real problem.

---

## Build for Growth

Although Version 0.1 is a company profile website, every decision should support future expansion.

Avoid temporary solutions that require complete rewrites.

---

## Readability First

Code is read far more often than it is written.

Prioritize readability over cleverness.

---

## Small Components

Large files become difficult to maintain.

Components should have one responsibility.

---

## Reusability

If code will likely be reused, abstract it into reusable modules.

---

# 3. Repository Structure

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
├── packages/
│
│   ├── ui/
│
│   ├── types/
│
│   ├── config/
│
│   └── utils/
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
├── docs/
│
└── scripts/

```

Every directory has a single responsibility.

---

# 4. Branch Strategy

Main Branch

```

main

```

Production-ready code only.

---

Development Branch

```

develop

```

Main development branch.

---

Feature Branch

```

feature/navbar

feature/about-page

feature/contact-form

```

---

Bug Fix

```

fix/mobile-menu

```

---

Hotfix

```

hotfix/login-error

```

---

# 5. Commit Convention

Use Conventional Commits.

Examples

```

feat: add hero section

fix: resolve navbar overlap

style: improve spacing

refactor: simplify services component

docs: update roadmap

test: add navbar tests

chore: update dependencies

```

---

# 6. Coding Standards

Use TypeScript everywhere.

Avoid using `any`.

Prefer interfaces over loosely typed objects.

Use descriptive variable names.

Avoid magic numbers.

Keep functions small.

Avoid deeply nested logic.

---

# 7. Naming Convention

Folders

```

kebab-case

```

Example

```

contact-form

service-card

```

---

Components

```

PascalCase

```

Example

```

Navbar.tsx

HeroSection.tsx

Footer.tsx

```

---

Variables

```

camelCase

```

Example

```

companyName

serviceList

```

---

Constants

```

UPPER_SNAKE_CASE

```

Example

```

MAX_UPLOAD_SIZE

API_TIMEOUT

```

---

Environment Variables

```

UPPER_SNAKE_CASE

```

Example

```

DATABASE_URL

REDIS_URL

NEXT_PUBLIC_API_URL

```

---

# 8. Frontend Standards

Framework

Next.js

Language

TypeScript

Styling

Tailwind CSS

UI Components

shadcn/ui

Icons

Lucide

Animations

Framer Motion

---

Rules

Keep pages clean.

Move reusable UI into components.

Avoid duplicated styling.

Use semantic HTML.

Keep accessibility in mind.

---

# 9. Backend Standards

Framework

NestJS

Language

TypeScript

ORM

Prisma

Database

PostgreSQL

Cache

Redis

Rules

Controllers

↓

Services

↓

Repositories (future)

Never access the database directly from controllers.

---

# 10. Docker Standards

Each application should have its own Dockerfile.

Development and production configurations should be separated.

Never hardcode secrets.

Use .env files.

Keep images lightweight.

---

# 11. Git Workflow

```

Create Branch

↓

Develop Feature

↓

Commit

↓

Push

↓

Pull Request

↓

Review

↓

Merge

```

Never push directly to main.

---

# 12. Deployment Workflow

Development

```

Laptop

↓

GitHub

↓

VPS

↓

Docker Compose

```

Future

```

Laptop

↓

GitHub

↓

GitHub Actions

↓

AWS VPS

↓

Production

```

---

# 13. Code Review Checklist

Before merging:

- Code builds successfully.
- No TypeScript errors.
- No ESLint errors.
- Responsive design verified.
- Components reusable.
- No unnecessary dependencies.
- Documentation updated if required.

---

# 14. Security Rules

Never commit:

- .env
- API Keys
- Tokens
- Passwords

Always validate user input.

Never trust client-side validation.

---

# 15. Documentation Rules

Every major feature should update:

- PRD
- Roadmap
- TODO (if necessary)

Documentation should evolve with the project.

---

# 16. AI Development Rules

AI should:

- Read AI_CONTEXT.md before coding.
- Follow existing architecture.
- Reuse components whenever possible.
- Avoid unnecessary refactoring.
- Keep changes minimal.
- Explain architectural decisions.

AI should never:

- Rewrite unrelated files.
- Change folder structures without approval.
- Introduce new dependencies without justification.
- Break existing UI consistency.

---

# 17. Definition of Done

A task is considered complete when:

✓ Feature works correctly.

✓ Code is readable.

✓ Responsive.

✓ Type-safe.

✓ No lint errors.

✓ Documentation updated.

✓ Ready for deployment.

---

# AI Notes

Current Project Phase

Version 0.1

Current Focus

- Landing Page

- Company Profile

- Responsive UI

- SEO

Future phases will introduce:

- Dashboard

- Authentication

- AI Platform

- Telegram Integration

Until then, keep the architecture clean and avoid premature optimization.
