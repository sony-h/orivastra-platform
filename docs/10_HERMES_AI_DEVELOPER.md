# 10 — Hermes AI Developer (Future)

Version: 0.1
Status: Planning

---

## Purpose

Define the architecture for an AI-driven development agent (Hermes) that can write code, create GitHub PRs, and deploy changes — operating entirely from the VPS and controlled via Telegram.

---

## Vision

```
Telegram
    │
    ▼
Hermes (VPS Node.js process)
    │
    ├── 1. Receives task: "Add a testimonials section"
    ├── 2. Analyzes codebase structure and conventions
    ├── 3. Generates code changes
    ├── 4. Validates: pnpm typecheck && pnpm lint && turbo build
    ├── 5. Creates git branch + commit + push
    ├── 6. Opens GitHub PR
    ├── 7. Waits for CI (ci.yml) to pass
    ├── 8. Merges PR (auto or review)
    ├── 9. Triggers deploy (deploy.yml)
    └── 10. Reports result to Telegram
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Telegram                             │
│   User ←────────→ Hermes Bot                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Hermes Agent (PS VPS)                        │
│                                                           │
│  ┌─────────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ Command      │  │ Task     │  │ Code Engine      │   │
│  │ Router      │→│ Planner  │→│ (opencode/LLM)     │   │
│  └─────────────┘  └──────────┘  └──────────────────┘   │
│                           │                              │
│                           ▼                              │
│  ┌─────────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ GitHub      │  │ CI       │  │ Deploy           │   │
│  │ Integration│  │ Monitor  │  │ Trigger          │   │
│  └─────────────┘  └──────────┘  └──────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │ Safety Layer: sandbox, review gates, rollback    │    │
│  └──────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Existing Infrastructure                      │
│                                                           │
│  GitHub Actions (ci.yml + deploy.yml)                     │
│  Operations Layer (infrastructure/scripts/)               │
│  PM2 (application processes)                              │
│  Docker (PostgreSQL, Redis)                               │
└─────────────────────────────────────────────────────────┘
```

---

## Components

### 1. Telegram Bot

- Receives commands and sends responses
- Authenticates users (allowlist of Telegram user IDs)
- Commands:
  - `/develop <task description>` — start a development task
  - `/status <pr-number>` — check PR status
  - `/cancel` — cancel running task
  - `/help` — list commands

### 2. Command Router

- Parses Telegram messages into structured tasks
- Routes to the appropriate handler (develop, status, etc.)
- Returns progress updates to the user

### 3. Task Planner

- Reads the codebase structure, file conventions, and patterns
- Breaks down the user's task into concrete file changes
- Produces a plan (what files to create/modify, in what order)
- Asks for confirmation before executing

### 4. Code Engine

Two approaches:

**Approach A — opencode integration (recommended for v1)**

```
Hermes → Spawn opencode subprocess → opencode writes code → Capture result
```

- Hermes calls opencode as a subprocess with the task prompt
- opencode reads the codebase, generates changes, runs validation
- Hermes captures the git diff and creates a PR

**Approach B — Custom LLM agent**

- Uses an LLM SDK (LangChain, Vercel AI SDK, or direct API)
- Has access to: file system read/write, shell commands, git
- Generates code via prompt engineering + few-shot examples
- More flexible but requires more development

### 5. GitHub Integration

- Create branch from `main`
- Commit generated changes
- Push branch to GitHub
- Create PR with description
- Check CI status (polling or webhook)
- Merge PR (auto if CI passes, or request review)

### 6. CI Monitor

- Polls GitHub API for PR status checks
- Waits for `ci.yml` to pass
- If CI fails: report errors, do not merge
- If CI passes: proceed to merge

### 7. Deploy Trigger

- After merge, existing `deploy.yml` runs automatically
- Hermes monitors the deploy action
- Reports success/failure to Telegram

---

## Safety Layer

| Safeguard                 | Description                                            |
| ------------------------- | ------------------------------------------------------ |
| **Sandboxed execution**   | opencode/LLM runs in a temporary directory or branch   |
| **Pre-commit validation** | `pnpm typecheck && pnpm lint && turbo build` must pass |
| **Branch protection**     | PRs cannot be merged without CI passing                |
| **Review gate**           | Optional: require human approval before merge          |
| **Rollback**              | Existing `rollback.sh` script for quick revert         |
| **Rate limiting**         | Limit number of concurrent tasks                       |
| **User allowlist**        | Only authorized Telegram users can issue commands      |

---

## Required Backend

Hermes runs as a native PM2 process on the VPS:

```bash
pm2 start hermes --interpreter node -- apps/hermes/dist/main.js
```

Or as a standalone Node.js process in a dedicated directory. It needs:

| Dependency                         | Purpose                             |
| ---------------------------------- | ----------------------------------- |
| OpenAI / Claude / DeepSeek API key | LLM access                          |
| Telegram Bot Token                 | Bot communication                   |
| GitHub Personal Access Token       | PR creation, CI monitoring          |
| opencode binary                    | Code generation engine (Approach A) |

---

## Environment Variables

```
TELEGRAM_BOT_TOKEN=...
GITHUB_TOKEN=...
OPENAI_API_KEY=... (or ANTHROPIC_API_KEY, DEEPSEEK_API_KEY)
HERMES_ALLOWED_USERS=123456789,987654321
HERMES_REPO_PATH=/opt/orivastra
HERMES_MODEL=claude-sonnet-4-20250514
HERMES_MAX_CONCURRENT=1
```

---

## Directory Structure

```
apps/hermes/
├── src/
│   ├── index.ts              Entry point — starts bot
│   ├── bot/
│   │   ├── telegram.ts        Telegram client + command handlers
│   │   └── commands.ts        Command parsing + routing
│   ├── planner/
│   │   └── index.ts           Task planning + codebase analysis
│   ├── engine/
│   │   └── opencode.ts        opencode subprocess integration
│   ├── github/
│   │   ├── client.ts          GitHub API client
│   │   ├── pr.ts              PR creation + management
│   │   └── ci.ts              CI status polling
│   ├── safety/
│   │   ├── validator.ts       Pre-commit validation
│   │   └── sandbox.ts         Execution sandbox
│   └── utils/
│       └── logger.ts
├── package.json
├── tsconfig.json
└── README.md
```

---

## Workflow (Step by Step)

```
1. User sends: /develop "Add a testimonials section to the landing page"

2. Hermes Telegram bot receives the message
   → Verifies user is in ALLOWED_USERS list
   → Sends "Starting development task..."

3. Hermes Task Planner:
   → Reads /opt/orivastra (project structure, existing components)
   → Identifies: apps/frontend/src/app/page.tsx is the landing page
   → Plans: create TestimonialsSection component → import into page.tsx

4. Hermes Code Engine (opencode):
   → Spawns: opencode --task "Create a TestimonialsSection component..."
   → opencode reads the codebase, creates the component file
   → opencode updates page.tsx to include the new section
   → Runs: pnpm typecheck && pnpm lint && turbo build

5. If validation passes:
   → Creates branch: hermes/testimonials-section
   → Commits changes
   → Pushes to GitHub
   → Opens PR with description

6. CI (ci.yml) runs automatically on the PR

7. Hermes monitors CI status:
   → If CI passes: merges PR (or requests review)
   → If CI fails: commits fix, pushes again

8. After merge:
   → deploy.yml runs automatically
   → Hermes reports: "Deployed successfully ✓" to Telegram
```

---

## Implementation Phases

### Phase 1 — Foundation (Sprint ~10)

- Create `apps/hermes/` with Telegram bot skeleton
- Implement command routing and user authentication
- Add `/status`, `/help`, `/cancel` commands
- Set up PM2 process for Hermes

### Phase 2 — Code Writing (Sprint ~11)

- Integrate opencode as the code engine
- Implement task planning and file generation
- Add pre-commit validation pipeline
- Wire up GitHub PR creation

### Phase 3 — Autonomy (Sprint ~12)

- Add CI monitoring and auto-merge
- Implement error recovery and retry logic
- Add review gate (optional human approval)
- Support multi-step tasks (e.g., "Add form + backend endpoint + database table")

### Phase 4 — Intelligence (Future)

- Add codebase awareness (embed project docs, conventions)
- Support self-healing (Hermes fixes its own failing CI runs)
- Implement autonomous issue resolution (Hermes picks up GitHub issues)

---

## Security & Risks

| Risk                         | Mitigation                                       |
| ---------------------------- | ------------------------------------------------ |
| Hermes generates broken code | Pre-commit validation + CI must pass             |
| Hermes deletes files         | opencode runs in sandbox; git diff is reviewable |
| Unauthorized access          | Telegram user ID allowlist                       |
| API cost overruns            | Rate limiting + max task duration                |
| Infinite loops               | Max retry count per task (default: 3)            |

---

## Relationship to Existing Architecture

```
┌──────────────────────────────────────────────────────────┐
│                       Existing                             │
│                                                           │
│  GitHub Actions (CI/CD)    ← Hermes triggers via pushes  │
│  Operations Layer (scripts) ← Hermes calls for ops tasks │
│  PM2 + Docker             ← Runs the platform            │
│                                                           │
└──────────────────────────────────────────────────────────┘
                            ↑
                 Hermes orchestrates
                            ↓
┌──────────────────────────────────────────────────────────┐
│                       Hermes                               │
│                                                           │
│  Telegram Bot ←→ Task Planner ←→ Code Engine ←→ GitHub   │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

Hermes does NOT replace any existing component. It orchestrates them:

- **Existing CI/CD** — Hermes triggers it by pushing to GitHub
- **Existing deploy scripts** — Hermes could call them directly for quick operations
- **Existing Operations Layer** — Hermes reads from it to understand the platform

---

## Prerequisites Checklist

- [ ] Telegram Bot Token (from @BotFather)
- [ ] GitHub Personal Access Token (with repo + PR scopes)
- [ ] LLM API key (OpenAI, Anthropic, or DeepSeek)
- [ ] opencode installed on the VPS
- [ ] Node.js 22+ available
- [ ] PM2 installed (for running Hermes itself)

---

## Next Steps When Ready

1. Create `apps/hermes/` package in the monorepo
2. Build the Telegram bot skeleton
3. Integrate opencode as subprocess
4. Wire up GitHub PR creation
5. Deploy Hermes as a PM2 process
6. Test with a simple task: "Fix a typo on the landing page"
