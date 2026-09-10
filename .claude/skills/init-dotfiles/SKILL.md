---
name: init-dotfiles
description: Bootstrap or audit the rayjzeng/dotfiles repo on personal laptops, Meta work laptops, and Meta remote servers while preserving machine-specific configuration.
---

# Init Dotfiles

Set up the dotfiles repository according to the machine's environment. Avoid
applying laptop, personal, or SSH assumptions to Meta remote servers.

## Select the Environment

Detect the platform with `uname -s` and inspect `/etc/os-release` on Linux.
Determine which environment the user is configuring:

- **Personal laptop**: read [references/personal-laptop.md](references/personal-laptop.md).
- **Meta work laptop**: read [references/work-laptop.md](references/work-laptop.md).
- **Meta remote server** (devserver, OD, or similar): read
  [references/work-remote.md](references/work-remote.md).

Read only the selected environment reference. Ask the user which environment
this is when it is not explicit or reliably known. Do not infer that a machine
is a laptop merely because a WezTerm executable is visible.

## Shared Workflow

1. Confirm the repository root and required bootstrap tools. Repository helper
   scripts use `/bin/bash`; zsh is required only for the interactive shell and
   zkbd configuration.
2. Install missing dependencies according to the selected environment. Inspect
   an existing executable or symlink before replacing it, and verify the
   expected command name after installation. When Starship is unavailable from
   the system package manager, use its installer:

   ```sh
   curl -sS https://starship.rs/install.sh | sh
   ```
3. Initialize submodules:

   ```sh
   git submodule init
   git submodule update --recursive
   ```

4. Use the `git-homedir-setup` skill for Git. Preserve machine-specific
   identities, credential helpers, proxies, certificates, includes, URL
   rewrites, and existing ignore rules. Never use `stow --adopt` for Git.
5. Preview each applicable package with `stow --simulate --verbose=2` before
   running Stow:

   ```sh
   stow tmux
   stow zsh
   stow vim
   stow starship
   ```

   If Stow rejects an absolute symlink that resolves to the exact managed
   source, replace only that symlink and rerun Stow so it creates its normal
   relative link. Stop on any other conflict. The `vim` package also provides
   the Neovim entry point through links back to `nvim/`.
6. Configure only installed agent harnesses:
   - For Claude Code, ensure `jq` is installed and use the
     `claude-status-line-setup` skill. Preserve unrelated settings.
   - For Codex, use the `codex-status-line-setup` skill. The `codex` package
     contains shared status-line tooling only. The optional `codex-profiles`
     package is selected by the environment reference.
7. Apply WezTerm configuration only when the selected environment enables it.
   Before stowing, create `~/.config/wezterm` and use
   `stow --no-folding wezterm` so the downloaded `wezterm.sh` stays outside the
   repository. Then install the shell integration:

   ```sh
   curl -o ~/.config/wezterm/wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh
   ```
8. Use the `zkbd-setup` skill. Reuse existing bindings when possible and avoid
   launching interactive `zkbd` when all required variants already exist.
9. Install Vim plugins with `vim +PlugInstall +qall` when they are absent.

## Verification

Report only checks applicable to the selected environment:

- managed tmux, zsh, Vim, Starship, and selected Codex links resolve into the
  repository;
- Git uses either managed symlinks or verified local copies, and the global
  excludes file is active;
- required commands are installed, including `fd`, `jq`, and `starship`;
- installed agent harnesses have their managed status line;
- current-terminal, `tmux-256color`, and `screen-256color` zkbd files exist;
- Vim plugins are installed;
- SSH and WezTerm checks appear only when enabled for the environment.

Report intentionally skipped components as skipped, not missing.
