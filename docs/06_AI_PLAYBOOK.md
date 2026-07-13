# 06_AI_PLAYBOOK.md

# Orivastra AI Playbook

Version: 0.1

Status: Active

---

# Purpose

This document provides context for AI coding assistants working on the Orivastra project.

Every AI session should begin by reading this document before making any changes.

The goal is to ensure that every generated code follows the same architecture, engineering philosophy, design language, and project roadmap.

---

# Project Summary

Project Name

Orivastra

Project Type

Technology Company Website

Current Version

0.1

Current Goal

Build a premium company profile website that represents Orivastra as an established technology company.

Future versions will gradually introduce:

- Portfolio
- Blog
- CMS
- Dashboard
- AI Platform
- Infrastructure Management
- Automation

---

# Current Scope

The AI should only work on Version 0.1 features.

Allowed

- Landing Page
- About
- Services
- Technologies
- Contact
- Roadmap
- SEO
- Responsive Design

Not Allowed

- Authentication
- Dashboard
- CMS
- AI Assistant
- Monitoring
- Deployment System
- Telegram Bot

Unless explicitly requested.

---

# Tech Stack

Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS
- shadcn/ui
- Framer Motion

Backend (Future)

- NestJS
- Prisma
- PostgreSQL
- Redis

Infrastructure

- Docker
- Docker Compose
- Nginx
- AWS EC2

AI

- DeepSeek V4
- GPT
- Claude
- Hermes
- OpenClaw

---

# Engineering Principles

Always prioritize:

- Simplicity
- Readability
- Scalability
- Reusability
- Maintainability

Avoid unnecessary complexity.

Avoid overengineering.

Follow existing project architecture.

---

# UI Philosophy

The interface should communicate:

Premium

Modern

Minimal

Elegant

Professional

Inspired by

- Apple
- Stripe
- Vercel
- Linear
- Cloudflare

Avoid

- Cyberpunk
- Neon
- Gaming aesthetics
- Excessive animations
- Visual clutter

---

# Coding Rules

Always

- Use TypeScript.
- Prefer reusable components.
- Follow folder structure.
- Keep files focused.
- Keep components small.
- Write clean code.

Never

- Use "any".
- Duplicate components.
- Create deeply nested logic.
- Add unnecessary libraries.
- Change architecture without approval.

---

# Component Rules

Components should:

- Have one responsibility.
- Be reusable.
- Be responsive.
- Support dark mode.
- Be accessible.

---

# Styling Rules

Use

Tailwind CSS

Prefer utility classes.

Avoid inline styles.

Animations

Framer Motion only when needed.

Whitespace is part of the design.

---

# Folder Structure

Follow the repository structure defined in:

05_DEVELOPMENT_GUIDE.md

Do not invent new directories without justification.

---

# Documentation Rules

If architecture changes,

recommend updating

- PRD
- Architecture
- Development Guide

Do not modify documentation automatically unless requested.

---

# Task Workflow

For every request:

1.

Understand the problem.

2.

Identify affected files.

3.

Modify only necessary files.

4.

Explain changes.

5.

Suggest improvements separately.

---

# AI Behavior

When coding,

focus on the requested task only.

Do not:

- Refactor unrelated files.
- Rename components unnecessarily.
- Replace libraries.
- Introduce breaking changes.

Keep pull requests small.

---

# If Information Is Missing

Do not assume.

Instead:

- Ask a clarifying question.
- Or clearly state assumptions.

---

# Definition of Success

A generated solution should be:

- Correct
- Clean
- Readable
- Responsive
- Type-safe
- Production-ready

---

# Current Sprint

Version

0.1

Objective

Build the best possible technology company landing page.

Priority

1.

Responsive Layout

2.

Premium Design

3.

SEO

4.

Performance

5.

Accessibility

Everything else is secondary.

---

# Long-Term Vision

Remember that this website is only the first stage of Orivastra.

Eventually it will evolve into a complete platform including:

- Portfolio
- Blog
- CMS
- Dashboard
- AI Assistant
- Infrastructure Management
- Telegram Automation

The current architecture should support that future without implementing those features today.

---

# Final Instruction

Before generating code,

always ask yourself:

"Does this solution align with Orivastra's philosophy of simplicity, scalability, and premium engineering quality?"

If the answer is no,

generate a better solution.
