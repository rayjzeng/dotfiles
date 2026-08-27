---
name: init-dotfiles
description: Bootstrap a fresh macOS or Linux machine with the rayjzeng/dotfiles repo, including safe Git config integration and installed agent status lines. Use for new-machine setup, SSH setup in this repo, or the full dotfiles installation workflow.
---

# Init Dotfiles

Automate the full setup of the rayjzeng/dotfiles repo on a fresh macOS or Linux machine.

Detect the platform at the start (`uname -s`) and branch accordingly where steps differ.

## Preconditions

Before running this skill, the following should already be installed:
- **macOS**: Homebrew (`brew`)
- **Linux**: `git`, `stow`, `curl` (install via system package manager if missing)
- The dotfiles repo, cloned via HTTPS to `~/dotfiles`

Repository helper scripts use `/bin/bash`. Zsh is required for the interactive
shell configuration and `zkbd`, but not for running the setup helpers.

## Workflow

Execute these steps in order. Pause for user input where indicated.

### Step 1: GitHub SSH Key Setup

Generate an ed25519 SSH key for GitHub and configure the SSH agent.

Ask the user for their GitHub email address before proceeding.

**macOS:**

```sh
eval "$(ssh-agent -s)"
ssh-keygen -t ed25519 -C "<user-email>"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

cat << 'EOF' > ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
```

**Linux:**

```sh
eval "$(ssh-agent -s)"
ssh-keygen -t ed25519 -C "<user-email>"
ssh-add ~/.ssh/id_ed25519

cat << 'EOF' > ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
```

After generating the key, print the public key (`cat ~/.ssh/id_ed25519.pub`) and tell the user to add it to their GitHub account at https://github.com/settings/ssh/new. Wait for them to confirm before continuing.

### Step 2: Switch Repo Remote to SSH

Once the user confirms the SSH key is added to GitHub:

```sh
cd ~/dotfiles
git remote set-url origin git@github.com:rayjzeng/dotfiles.git
```

Verify with `git remote -v` and `ssh -T git@github.com` (the latter should show "successfully authenticated").

### Step 3: Init Git Submodules

The repo uses submodules for zsh plugins and a vim plugin fork:

```sh
cd ~/dotfiles
git submodule init
git submodule update --recursive
```

### Step 4: Install Dependencies

**macOS:**

Ask whether to use the personal or work profile:
- **Personal**: `brew bundle install --file=dependencies/Brewfile`
- **Work**: `brew bundle install --file=dependencies/work/Brewfile`

Both Brewfiles include `fd`, `jq`, and starship.

**Linux:**

Install core dependencies via the system package manager (apt, dnf, etc.):
- `fd-find` (or `fd`), `fzf`, `jq`, `ripgrep`, `stow`, `tmux`, `vim`, `zoxide`, `zsh`

On Debian and Ubuntu, `fd-find` installs the executable as `fdfind`. If `fd` is
missing but `fdfind` exists, expose the name used by `.zshrc`:

```sh
mkdir -p "$HOME/.local/bin"
ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
```

Inspect an existing `~/.local/bin/fd` instead of overwriting it.

Then install starship (not available in most distro repos):

```sh
curl -sS https://starship.rs/install.sh | sh
```

After installing dependencies, tell the user if zsh is still unavailable. If
zsh is installed but is not the current login shell, suggest
`chsh -s "$(command -v zsh)"` and explain that a new login session is required.
Do not change the login shell without confirmation.

### Step 5: Stow Packages

Create symlinks from the repo into `$HOME`. Run from `~/dotfiles`:

```sh
cd ~/dotfiles
stow tmux
stow zsh
stow vim
stow starship
```

Use the `git-homedir-setup` skill for the Git package. A machine may already
have identities, credential helpers, proxies, conditional includes, or other
settings in `~/.gitconfig`; preserve them and merge the managed config into
local copies instead of blindly replacing the file. Never use
`stow --adopt` for this merge.

If WezTerm is installed, stow it on either macOS or Linux. Pre-create the target
directory and disable directory folding so the downloaded shell integration
does not get written back into the repository:

```sh
mkdir -p "$HOME/.config/wezterm"
stow --no-folding wezterm
```

Note: The `vim` package contains symlinks that point back to `nvim/`, so stowing `vim` alone is sufficient for both vim and neovim config.

### Step 6: Configure Installed Agent Status Lines

Detect which supported agent harnesses are installed and configure only those
the user uses:

- For Claude Code, ensure `jq` is installed and use the
  `claude-status-line-setup` skill. Preserve unrelated settings in
  `~/.claude/settings.json`.
- For Codex, use the `codex-status-line-setup` skill. It stows the `codex`
  package and updates only the managed `[tui]` keys in
  `~/.codex/config.toml`.

If neither harness is installed, skip this step. Do not create tool-specific
configuration unless the user asks for it.

### Step 7: WezTerm Shell Integration

If WezTerm is installed, download its shell integration script to enable
scroll-to-prompt and CWD tracking:

```sh
curl -o ~/.config/wezterm/wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh
```

The `.zshrc` already sources this file if it exists. Skip this step when WezTerm
is not installed.

### Step 8: Post-Install

These steps require manual interaction or a new shell session:

1. **zkbd**: Use the `zkbd-setup` skill to generate bindings for the current
   terminal and install matching `tmux-256color` and `screen-256color` copies.
2. **Vim plugins**: Run `vim +PlugInstall +qall`

## Summary Checklist

Print this at the end so the user can verify:

- [ ] `~/.ssh/id_ed25519` exists and is added to GitHub
- [ ] `git remote -v` shows `git@github.com:rayjzeng/dotfiles.git`
- [ ] `~/.tmux.conf` symlinks to dotfiles
- [ ] `~/.zshrc` symlinks to dotfiles
- [ ] `~/.vimrc` symlinks to dotfiles
- [ ] `~/.gitconfig` is a managed symlink or synchronized local copy
- [ ] `~/.config/git/ignore` is a managed symlink or synchronized local copy and is Git's active global excludes file
- [ ] `~/.config/starship.toml` symlinks to dotfiles
- [ ] `starship` is installed (`starship --version`)
- [ ] `~/.config/wezterm/wezterm.lua` symlinks to dotfiles (when WezTerm is installed)
- [ ] `~/.config/wezterm/wezterm.sh` exists (when WezTerm is installed)
- [ ] Installed agent harnesses have their managed status line configured
- [ ] zkbd bindings exist for the current terminal, `tmux-256color`, and `screen-256color`
- [ ] Vim plugins are installed
