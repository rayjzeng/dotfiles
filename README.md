# Dotfiles

GNU Stow-managed configuration for zsh, Vim, tmux, Starship, and WezTerm.
Each package installs links into your home directory. Work-specific WezTerm tools
are an optional package.

## Setup

Use the [init-dotfiles guide](.claude/skills/init-dotfiles/SKILL.md) for your environment:

- [Personal laptop](.claude/skills/init-dotfiles/references/personal-laptop.md)
- [Meta work laptop](.claude/skills/init-dotfiles/references/work-laptop.md)
- [Meta remote server](.claude/skills/init-dotfiles/references/work-remote.md)

Clone with submodules:

```sh
git clone --recurse-submodules https://github.com/rayjzeng/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Preview packages before installing them:

```sh
stow --simulate --verbose=2 zsh vim tmux starship
stow zsh vim tmux starship
```

The environment guides cover dependencies, existing configuration conflicts,
Git setup, terminal keybindings, and plugin installation. Homebrew profiles are
[personal](dependencies/Brewfile) and [work](dependencies/work/Brewfile).

## Packages and features

| Package | What it provides |
|---|---|
| `zsh` | Shell configuration, completion, syntax highlighting, fzf integration, and aliases |
| `starship` | Shared shell prompt |
| `vim` | Vim entry point, editing/navigation bindings, Git integration, and plugins; shares configuration with `nvim/init.vim` |
| `tmux` | Mouse support, copy mode, pane/window navigation, splitting, and resizing |
| `wezterm` | Native bottom Powerline tab bar, domain colors, pane navigation, search, and scrollback tools |
| `wezterm-work` | Enkaku connections, persistent server sessions, host picker, and the `devvm` CLI with zsh completion |
| `git-homedir` | Git configuration; apply with the [Git setup guide](.claude/skills/git-homedir-setup/SKILL.md) to preserve local settings |
| `codex` | Shared Codex status-line tooling |

Vim is the editor currently used and tested. The shared configuration also
recognizes Neovim and chooses its plugin directory accordingly.

## WezTerm daily use

The bottom bar is WezTerm's native tab bar. Tabs show a number, domain/server
label, and terminal title. Local tabs have a neutral color; configured servers
have distinct colors in host-list order. Active tabs have a filled background
and bold text. There is no terminal-pane footer.

With `wezterm-work` installed, `devvm` gathers local and configured server tabs
into the main window. Explicitly detached servers have their own windows.
The [WezTerm user guide](wezterm-work/README.md) covers installation, all shortcuts,
host configuration, connection/authentication, and session behavior.

On macOS, `Cmd` means Command and `Opt` means Option:

| Shortcut | Action |
|---|---|
| `Cmd+T` | New tab in the active pane's domain, placed with that domain's tabs |
| `Cmd+1` … `Cmd+8`; `Cmd+9` | Select a numbered tab; select the last tab |
| `Cmd+Shift+T` | Tab picker across windows; its last entry moves the current tab to any position |
| `Cmd+Opt+Shift+Left`; `Cmd+Opt+Shift+Right` | Move the current tab left; right |
| `Cmd+D`; `Cmd+Shift+D` | Split right; split below |
| `Cmd+Shift+Arrow` | Select a pane in that direction |
| `Cmd+[`; `Cmd+]` | Previous pane; next pane |
| `Cmd+F` | Search scrollback |
| `Shift+Up`; `Shift+Down` | Previous prompt; next prompt, with shell integration |
| `Cmd+E` | Open a scrollback snapshot in Vim |
| `Cmd+Shift+W` | Detach the current mux domain, preserving its remote sessions |
| `Cmd+R` | Reload configuration; in search mode, cycle search match type |
| `Cmd+Opt+0` | Focus a local tab in the unified window; work package required |
| `Cmd+Opt+1` … `Cmd+Opt+9` | Open/focus a configured server; work package required |
| `Cmd+Shift+O` | Server picker; work package required |

```sh
devvm                    # Connect/gather configured servers
devvm primary            # Open a server by alias
devvm detach primary     # Put that server in a separate window
devvm merge primary      # Bring it back to the main window
devvm local              # Focus a local tab
devvm ls                 # Show configured hosts
```

Quitting WezTerm preserves remote sessions while their mux server remains alive.
Local shells end when the GUI quits. Closing a tab ends the processes in that
tab; use domain detachment when you want remote sessions to keep running.
Direct server attachment preserves processes, scrollback, and existing splits.
Initial consolidation of several server windows flattens panes moved from other
windows into separate tabs.

## Machine-local configuration

Use these files for machine-specific settings:

| Application | Override files |
|---|---|
| zsh | `~/.zshrc.before.zsh`, `~/.zshrc.after.zsh` |
| Vim | `~/.vimrc.before.vim`, `~/.vimrc.after.vim` |
| tmux | `~/.tmux.local.conf` |
| WezTerm | `~/.config/wezterm/wezterm_local.lua`, returning a settings table |
| WezTerm work tools | `~/.config/wezterm/devservers`, containing hosts and optional aliases |

WezTerm shell integration is downloaded separately to
`~/.config/wezterm/wezterm.sh`; `.zshrc` sources it when present. It provides
prompt markers and working-directory tracking. Use `stow --no-folding wezterm`
so this downloaded file stays outside the repository-managed links.

Zsh modules are submodules under `zsh/.zmodules/`. The files in
`zsh/.zmodules/third-party/` are maintained manually.
