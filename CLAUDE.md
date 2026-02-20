# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A GNU Stow-managed dotfiles repository. Each top-level directory is a stow package that symlinks into `$HOME` (or a specified target).

## Setup Commands

```sh
# Install packages
brew bundle install --file=dependencies/Brewfile        # personal profile
brew bundle install --file=dependencies/work/Brewfile    # work profile

# Symlink configs (run from ~/dotfiles)
stow tmux
stow zsh
stow nvim
stow -t $HOME/.config/wezterm wezterm

# Vim plugins
vim +PlugInstall +qall
```

## Architecture

### Stow Package Layout

Each directory maps to a stow package. The directory structure inside mirrors the target filesystem relative to `$HOME`:
- `tmux/.tmux.conf` → `~/.tmux.conf`
- `zsh/.zshrc` → `~/.zshrc`
- `nvim/` → `~/.config/nvim/` (Neovim) and `~/.vimrc` (Vim, via shared `init.vim`)
- `wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua` (requires `-t` flag)

### Extensibility Hooks

All three main configs support machine-local overrides without modifying tracked files:
- **zsh**: `~/.zshrc.before.zsh` and `~/.zshrc.after.zsh`
- **vim/nvim**: `~/.vimrc.before.vim` and `~/.vimrc.after.vim`
- **tmux**: `~/.tmux.local.conf`

### Shared Vim Config

`nvim/init.vim` is dual-compatible — it detects `has('nvim')` and adjusts the plugin directory accordingly. It serves both `~/.vimrc` and `~/.config/nvim/init.vim`.

### Git Submodules

Zsh plugins and a vim plugin fork are tracked as submodules under `zsh/.zmodules/` and `nvim/fzf.vim`. Clone with `--recurse-submodules`. The author maintains personal forks of `fzf.vim` and the `zsh-clean` prompt theme.

### Two Homebrew Profiles

`dependencies/Brewfile` (personal) includes R and ffmpeg. `dependencies/work/Brewfile` includes Android tooling (scrcpy, gnirehtet, lsusb).

### Key Integration Points

- **vim-tmux-navigator** bindings are inlined in both `tmux/.tmux.conf` and `nvim/init.vim` — they must stay in sync for seamless `C-h/j/k/l` pane navigation across vim and tmux.
- **WezTerm** dynamically colors the tab bar purple for remote/SSH sessions via the `update-status` event handler.
- **fzf** is configured in zsh (using `fd` as the default command) and in vim (leader `s` prefix: `sf` files, `sg` ripgrep, `ss` buffers).
