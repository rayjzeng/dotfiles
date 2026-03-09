---
name: init-dotfiles
description: Bootstrap a fresh macOS machine with the rayjzeng/dotfiles repo. Use this skill when the user says "init dotfiles", "set up my dotfiles", "bootstrap my machine", "new mac setup", or any variation of setting up this dotfiles repo from scratch. Also use when the user mentions SSH key setup in the context of this repo, or asks about the full install process.
---

# Init Dotfiles

Automate the full setup of the rayjzeng/dotfiles repo on a fresh macOS machine.

## Preconditions

Before running this skill, the following should already be installed:
- Homebrew (`brew`)
- WezTerm
- Claude Code (you're running in it)
- The dotfiles repo, cloned via HTTPS to `~/dotfiles`

## Workflow

Execute these steps in order. Pause for user input where indicated.

### Step 1: GitHub SSH Key Setup

Generate an ed25519 SSH key for GitHub, configure the SSH agent with Keychain, and write the SSH config.

Ask the user for their GitHub email address before proceeding.

```sh
# Start ssh-agent
eval "$(ssh-agent -s)"

# Generate key (prompt user for email)
ssh-keygen -t ed25519 -C "<user-email>"

# Add to Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Write SSH config for GitHub
cat << 'EOF' > ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
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

### Step 4: Install Homebrew Dependencies

Ask whether to use the personal or work profile:
- **Personal**: `brew bundle install --file=dependencies/Brewfile`
- **Work**: `brew bundle install --file=dependencies/work/Brewfile`

### Step 5: Stow Packages

Create symlinks from the repo into `$HOME`. Run from `~/dotfiles`:

```sh
cd ~/dotfiles
stow tmux
stow zsh
stow vim
stow git-homedir
mkdir -p $HOME/.config/wezterm
stow -t $HOME/.config/wezterm wezterm
```

Note: `wezterm` requires the `-t` flag because it targets `~/.config/wezterm/` rather than `$HOME` directly. The `vim` package contains symlinks that point back to `nvim/`, so stowing `vim` alone is sufficient for both vim and neovim config.

### Step 6: WezTerm Shell Integration

Download the WezTerm shell integration script (enables scroll-to-prompt and CWD tracking):

```sh
curl -o ~/.config/wezterm/wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh
```

The `.zshrc` already sources this file if it exists.

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
- [ ] `~/.config/wezterm/wezterm.lua` symlinks to dotfiles
- [ ] `~/.config/wezterm/wezterm.sh` exists
- [ ] Vim plugins installed
