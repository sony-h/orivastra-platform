#!/usr/bin/env bash
# ──────────────────────────────────────────────
# Orivastra Operations — Git Helpers
# ──────────────────────────────────────────────
# Reusable git operations used by deploy and
# rollback scripts.
#
# Usage:
#   source lib/git.sh
#   git_pull
# ──────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

git_pull() {
  info "Pulling latest code from GitHub..."
  git pull origin main
  success "Repository up to date."
}

current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

current_commit() {
  git rev-parse --short HEAD 2>/dev/null
}

repository_status() {
  local branch
  local commit
  branch=$(current_branch)
  commit=$(current_commit)
  echo "${branch} (${commit})"
}

git_revert_to() {
  local target="${1:-HEAD~1}"
  info "Reverting to: ${target}"
  if git diff --cached --quiet && git diff --quiet; then
    git reset --hard "$target"
  else
    warn "Uncommitted changes detected. Stashing..."
    git stash --include-untracked
    git reset --hard "$target"
  fi
  success "Repository reverted to ${target}"
}
