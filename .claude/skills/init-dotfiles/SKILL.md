---
name: init-dotfiles
description: Bootstrap a fresh macOS or Linux machine with the rayjzeng/dotfiles repo. Use this skill when the user says "init dotfiles", "set up my dotfiles", "bootstrap my machine", "new mac setup", or any variation of setting up this dotfiles repo from scratch. Also use when the user mentions SSH key setup in the context of this repo, or asks about the full install process.
---

# Init Dotfiles

Automate the full setup of the rayjzeng/dotfiles repo on a fresh macOS or Linux machine.

Detect the platform at the start (`uname -s`) and branch accordingly where steps differ.

## Preconditions

Before running this skill, the following should already be installed:
- **macOS**: Homebrew (`brew`), WezTerm
- **Linux**: `git`, `stow`, `curl` (install via system package manager if missing)
- Claude Code (you're running in it)
- The dotfiles repo, cloned via HTTPS to `~/dotfiles`

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

Both Brewfiles include starship.

**Linux:**

Install core dependencies via the system package manager (apt, dnf, etc.):
- `fd-find` (or `fd`), `fzf`, `ripgrep`, `tmux`, `vim`, `zoxide`, `stow`

Then install starship (not available in most distro repos):

```sh
curl -sS https://starship.rs/install.sh | sh
```

### Step 5: Stow Packages

Create symlinks from the repo into `$HOME`. Run from `~/dotfiles`:

```sh
cd ~/dotfiles
stow tmux
stow zsh
stow vim
stow git-homedir
stow starship
```

**macOS only** — also stow WezTerm (requires `-t` flag because it targets `~/.config/wezterm/`):

```sh
mkdir -p $HOME/.config/wezterm
stow -t $HOME/.config/wezterm wezterm
```

Note: The `vim` package contains symlinks that point back to `nvim/`, so stowing `vim` alone is sufficient for both vim and neovim config.

### Step 6: WezTerm Shell Integration (macOS only)

Download the WezTerm shell integration script (enables scroll-to-prompt and CWD tracking):

```sh
curl -o ~/.config/wezterm/wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh
```

The `.zshrc` already sources this file if it exists. Skip this step on Linux unless WezTerm is installed.

### Step 7: Post-Install

These steps require manual interaction or a new shell session:

1. **zkbd**: Launch a new terminal and run `zkbd` to generate keybindings for the current terminal type. For tmux, copy the xterm-256color bindings to tmux-256color.
2. **Vim plugins**: Run `vim +PlugInstall +qall`

## Summary Checklist

Print this at the end so the user can verify:

- [ ] `~/.ssh/id_ed25519` exists and is added to GitHub
- [ ] `git remote -v` shows `git@github.com:rayjzeng/dotfiles.git`
- [ ] `~/.tmux.conf` symlinks to dotfiles
- [ ] `~/.zshrc` symlinks to dotfiles
- [ ] `~/.vimrc` symlinks to dotfiles
- [ ] `~/.gitconfig` symlinks to dotfiles
- [ ] `~/.config/starship.toml` symlinks to dotfiles
- [ ] `starship` is installed (`starship --version`)
- [ ] `~/.config/wezterm/wezterm.lua` symlinks to dotfiles (macOS only)
- [ ] `~/.config/wezterm/wezterm.sh` exists (macOS only)
- [ ] Vim plugins installed
