---
name: codex-status-line-setup
description: Apply or refresh the dotfiles-managed Codex TUI status line across machines. Use when setting up this dotfiles repository, configuring Codex status-line items, or syncing the shared status line while preserving machine-specific ~/.codex/config.toml settings.
---

# Codex Status Line Setup

Use the repository’s `codex` Stow package and setup command to apply the shared
Codex status line. The setup command edits only the managed status-line keys in
`~/.codex/config.toml`; do not replace the whole file because other settings are
machine-specific.

## Workflow

1. Confirm the current working directory is the dotfiles repository and inspect
   `codex/.local/bin/codex-status-line.toml` if the requested status line is
   unclear.
2. Stow the package so the setup command is available:

   ```sh
   stow codex
   ```

3. Apply the shared configuration:

   ```sh
   codex-status-line-setup
   ```

   The command defaults to `~/.codex/config.toml`. It can take an alternate
   config path for testing or controlled setup:

   ```sh
   codex-status-line-setup /path/to/config.toml
   ```

4. Verify that the target `[tui]` section contains the tracked status-line
   settings and that unrelated machine-specific settings are still present.

## Managed Settings

The synced fragment currently contains:

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "branch-changes", "context-remaining"]
status_line_use_colors = true
```

It is safe to rerun the setup command after pulling updates. Report any
configuration parse or permission error instead of overwriting the local
Codex config or removing unrelated settings.
