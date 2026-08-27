---
name: git-homedir-setup
description: Safely apply the dotfiles Git configuration while preserving machine-specific ~/.gitconfig settings and existing global ignore patterns. Use during dotfiles bootstrap or when stowing git-homedir reports a conflict.
---

# Git Homedir Setup

Apply the `git-homedir` package without discarding machine-specific Git configuration.

## Workflow

1. Resolve the repository root and inspect every destination before running
   Stow:

   ```sh
   repo_root=$(git rev-parse --show-toplevel)
   ls -ld ~/.gitconfig ~/.config/git/ignore 2>/dev/null
   ls -ld ~/.config/git 2>/dev/null
   git config --global --show-origin --get core.excludesFile 2>/dev/null || true
   git config --show-origin --list
   ```

   Record the previous global excludes path with
   `git config --global --path --get core.excludesFile` before changing Git
   configuration.

2. Select **local-copy mode** before making any filesystem changes if any of
   these conditions is true:

   - `~/.gitconfig` exists and is not a symlink to
     `$repo_root/git-homedir/.gitconfig`.
   - `~/.config/git` exists and is not a symlink to
     `$repo_root/git-homedir/.config/git`.
   - A user-level `core.excludesFile` is already configured outside the
     managed Git config.

   Otherwise, use **symlink mode**. This decision must happen before invoking
   Stow so an existing ignore directory or file cannot cause a partial setup.

### Symlink mode

Confirm that the managed identity, proxy, certificate, and credential settings
are appropriate for the machine, then run:

   ```sh
   stow git-homedir
   ```

Do not run `git config --global core.excludesFile ...` afterward. The managed
config already contains the portable literal value `~/.config/git/ignore`, and
writing through the symlink would rewrite the tracked file.

### Local-copy mode

Do not run `stow git-homedir` or `stow --adopt`. Back up existing local files,
then install regular local copies:

- If `~/.gitconfig` is absent, copy the managed file. Otherwise merge only the
  appropriate managed keys into the local file. Preserve local identities,
  credential helpers, proxies, certificates, conditional includes, and URL
  rewrites. Do not import work-only settings onto machines where they are
  invalid.
- Ensure `~/.config/git` is a real directory rather than a symlink. If
  `~/.config/git/ignore` is absent, copy the managed ignore file. Otherwise
  merge the managed patterns without reordering rules; Git ignore negations are
  order-sensitive.
- If the previously configured `core.excludesFile` points to a different
  readable file, merge its patterns into `~/.config/git/ignore` while
  preserving their order. Add this comment to the local ignore file, with the
  actual previous path:

  ```text
  # Sync note: check <previous-excludes-file> for updates whenever this file is refreshed.
  ```

  Do not add a self-referential note when the previous path already resolves to
  `~/.config/git/ignore`.

After the local copies are ready, configure Git with a literal portable value:

   ```sh
   git config --global core.excludesFile '~/.config/git/ignore'
   ```

Repository hooks remind Claude Code and Codex users to repeat this manual merge
when tracked `git-homedir` files change. Approve the project hook when Claude
Code prompts for trust; in Codex, review and trust it with `/hooks`. Do not
bypass hook trust checks.

## Verification

Verify the selected mode and active configuration:

   ```sh
   git config --show-origin --get core.excludesFile
   git config --show-origin --list
   ls -ld ~/.gitconfig ~/.config/git
   git check-ignore -v --no-index default.profraw
   ```

Report which settings were merged, which local values won conflicts, and
whether the Git files use managed symlinks or manually synchronized local
copies.
