# Codex Status Line Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide a synced setup command that applies the shared Codex context-usage status line without replacing machine-specific Codex settings.

**Architecture:** Add a GNU Stow package named `codex` containing an executable setup command and a declarative status-line fragment. The command edits only the `[tui]` section’s `status_line` key in the target config, appending `[tui]` when absent and using a temporary file for safe replacement.

**Tech Stack:** zsh, awk, TOML, shell integration tests.

## Global Constraints

- Preserve all non-status-line content in each machine’s `~/.codex/config.toml`.
- Make repeated runs idempotent.
- Keep the shared status-line definition tracked in the dotfiles repository.
- Do not require third-party dependencies.

### Task 1: Add behavior tests

**Files:**
- Create: `tests/test-codex-status-line-setup`

- [x] **Step 1: Write tests for insertion, replacement, preservation, and idempotence.**
- [x] **Step 2: Run the tests and confirm they fail because the setup command is missing.**

### Task 2: Add synced config and setup command

**Files:**
- Create: `codex/.local/bin/codex-status-line-setup`
- Create: `codex/.local/bin/codex-status-line.toml`

- [x] **Step 1: Implement the minimal config updater.**
- [x] **Step 2: Run the behavior tests and confirm they pass.**
- [x] **Step 3: Validate shell syntax and the generated TOML.**

### Task 3: Document usage

**Files:**
- Modify: `README.md`

- [x] **Step 1: Document stowing the package and running `codex-status-line-setup`.**
- [x] **Step 2: Run the full relevant verification commands.**
