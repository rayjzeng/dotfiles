# Personal Laptop

Use personal dependencies and GitHub SSH authentication.

## Dependencies

- On macOS, install `dependencies/Brewfile` with Homebrew.
- On Linux, install `fd-find` (or `fd`), `fzf`, `jq`, `ripgrep`, `stow`,
  `tmux`, `vim`, `zoxide`, and `zsh` with the system package manager.
- If Debian or Ubuntu provides only `fdfind`, create `~/.local/bin/fd` only
  after confirming that destination is unused.
- Install Starship only when `starship` is missing.

If zsh is installed but is not the login shell, suggest
`chsh -s "$(command -v zsh)"`; do not change it without confirmation.

## GitHub SSH

Inspect the existing Git remote, SSH key, agent, and `~/.ssh/config` before
changing them. Never overwrite an existing key or SSH configuration.

When GitHub SSH is not already configured:

1. Ask for the GitHub email address and generate an ed25519 key.
2. Configure the `github.com` host with `AddKeysToAgent yes` and
   `IdentityFile ~/.ssh/id_ed25519`. On macOS only, also use `UseKeychain yes`
   and `ssh-add --apple-use-keychain`.
3. Print the public key and wait for confirmation that it was added to GitHub.
4. Switch the repository remote to `git@github.com:rayjzeng/dotfiles.git` and
   verify authentication.

Merge directives into an existing `github.com` block rather than replacing the
whole SSH config.

## Optional Components

- If WezTerm is installed, stow its config and download `wezterm.sh`.
