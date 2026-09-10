# Meta Work Laptop

Preserve Meta-managed Git and credential configuration.

## Dependencies

- On macOS, install `dependencies/work/Brewfile` with Homebrew.
- On Linux, use the system package manager to install `fd-find` (or `fd`),
  `fzf`, `jq`, `ripgrep`, `stow`, `tmux`, `vim`, `zoxide`, and `zsh`.
- Verify `fd`, `jq`, and Starship by command name after installation.

## Git and SSH

Use the `git-homedir-setup` skill and expect local-copy mode when Meta
identities, credential helpers, proxies, certificates, or URL rewrites exist.

Keep an intentional Meta HTTPS GitHub remote. Do not generate a GitHub SSH key,
start an agent, add `AddKeysToAgent`, or switch the remote unless the user
explicitly chooses SSH. If SSH is selected on macOS, `UseKeychain` is the only
macOS-specific directive; `AddKeysToAgent` itself is portable OpenSSH.

## Optional Components

- If WezTerm is installed and used locally, stow its config and download
  `wezterm.sh`.
- Stow the shared `codex` package, but skip `codex-profiles` because Meta Codex
  uses its default model for all tasks. If explicitly asked, use
  `stow --no-folding codex-profiles`.
