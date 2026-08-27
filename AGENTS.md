# Repository Guide

This file provides guidance to coding agents and automation harnesses working in this repository.

## What This Is

A GNU Stow-managed dotfiles repository. Each top-level directory is a stow package that symlinks into `$HOME` (or a specified target).

## Setup Commands

See the `init-dotfiles` skill.

## Tests

Keep tests beside the script or code they exercise instead of adding them to a repository-wide test directory.

## Scripts

Use `/bin/bash` for maintained helper scripts unless the script inherently requires another interpreter.

## Architecture

### Extensibility Hooks

All three main configs support machine-local overrides without modifying tracked files:
- **zsh**: `~/.zshrc.before.zsh` and `~/.zshrc.after.zsh`
- **vim**: `~/.vimrc.before.vim` and `~/.vimrc.after.vim`
- **tmux**: `~/.tmux.local.conf`

### Shared Vim Config

Only vim is currently used and tested. But `nvim/init.vim` is dual-compatible — it detects `has('nvim')` and adjusts the plugin directory accordingly. It serves both `~/.vimrc` and `~/.config/nvim/init.vim`.

### Git Submodules

Zsh plugins and a vim plugin fork are tracked as submodules under `zsh/.zmodules/`. Clone with `--recurse-submodules`. The author maintains a personal fork of `zsh-clean` prompt theme.

### Two Homebrew Profiles

`dependencies/Brewfile` (personal) includes R and ffmpeg. `dependencies/work/Brewfile` includes Android tooling (scrcpy, gnirehtet, lsusb).

### Other Integration Points

- **WezTerm** dynamically colors the tab bar purple for remote/SSH sessions via the `update-status` event handler. Shell integration (`~/.config/wezterm/wezterm.sh`, sourced from `.zshrc`) enables scroll-to-prompt (Shift+Up/Down) and CWD tracking — this file is not stow-managed and must be downloaded manually (see Setup Commands).
- **fzf** is configured in zsh (using `fd` as the default command) and in vim (leader `s` prefix: `sf` files, `sg` ripgrep, `ss` buffers).
- **zsh/.zmodules/third-party** zsh modules need to be updated manually but should be relatively stable:
    - [curl completions](https://github.com/curl/curl/blob/master/scripts/completion.pl)
    - [bash completions](https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash)
