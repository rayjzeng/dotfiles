---
name: claude-status-line-setup
description: Configure the Claude Code status line setting. Use when the user says "set up status line", "configure status line", "fix my status line", or wants to copy/restore the status line configuration.
---

# Claude Status Line Setup

Configure the Claude Code status line to show working directory, git/sl branch with dirty/staged indicators, model name, and context window usage.

## Configuration

Add this `statusLine` block to the user's `~/.claude/settings.json` (or the appropriate project-level `settings.local.json`):

```json
{
  "statusLine": {
    "type": "command",
    "command": "input=$(cat); cwd=$(echo \"$input\" | jq -r '.workspace.current_dir // .cwd'); model=$(echo \"$input\" | jq -r '.model.display_name // .model.id'); used=$(echo \"$input\" | jq -r '.context_window.used_percentage // empty'); git_branch=$(cd \"$cwd\" 2>/dev/null && git branch --show-current 2>/dev/null || echo \"\"); sl_branch=$(cd \"$cwd\" 2>/dev/null && sl whereami 2>/dev/null || echo \"\"); branch=\"${git_branch:-$sl_branch}\"; dirty=\"\"; staged=\"\"; if [[ -n \"$git_branch\" ]]; then cd \"$cwd\" 2>/dev/null && git diff --no-ext-diff --quiet 2>/dev/null || dirty=\"*\"; [[ -z \"$dirty\" ]] && cd \"$cwd\" 2>/dev/null && [[ -n \"$(git ls-files --others --exclude-standard 2>/dev/null)\" ]] && dirty=\"*\"; cd \"$cwd\" 2>/dev/null && git diff --cached --no-ext-diff --quiet 2>/dev/null || staged=\"+\"; fi; status=\"${cwd}\"; [[ -n \"$branch\" ]] && status=\"${status} (${branch}${dirty}${staged})\"; status=\"${status} | ${model}\"; [[ -n \"$used\" ]] && status=\"${status} | ctx: ${used}% used\"; echo \"$status\""
  }
}
```

## What It Shows

`/path/to/dir (branch*+) | Model Name | ctx: 42% used`

- **cwd**: current working directory
- **branch**: git branch (falls back to `sl whereami` for Sapling)
- **`*`**: unstaged changes or untracked files
- **`+`**: staged changes
- **model**: display name or model ID
- **ctx**: context window usage percentage

## Workflow

1. Read the target settings file (`~/.claude/settings.json` or project `.claude/settings.local.json`)
2. Add or replace the `statusLine` block with the configuration above
3. Verify the JSON is valid with `jq . < settings-file`
