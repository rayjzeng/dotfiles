# WezTerm user guide

The shared `wezterm` package provides a native bottom Powerline tab bar, domain
colors, pane navigation, search, and scrollback tools. The optional `wezterm-work`
package adds Enkaku server connections and the `devvm` command.

## Get started

For full dotfiles setup, follow the [environment setup guide](../.claude/skills/init-dotfiles/SKILL.md).
The work package is intended for work machines with Enkaku.

Local requirements: WezTerm, GNU Stow, Python 3, `ek`, and JetBrainsMono Nerd Font
Mono. Each server needs `wezterm-mux-server`. The configured font supplies the
Powerline separators.

From the dotfiles checkout, preview and install both WezTerm packages:

```sh
mkdir -p ~/.config/wezterm
stow --simulate --verbose=2 --no-folding wezterm wezterm-work
stow --no-folding wezterm wezterm-work
```

Install shell integration for zsh prompt navigation and working-directory tracking:

```sh
curl -o ~/.config/wezterm/wezterm.sh \
  https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh
```

The shared `.zshrc` sources this file when present and puts `~/.local/bin` on PATH.
It also loads the work package's `devvm` completion from the user completion directory.

Initialize the host list once:

```sh
devvm init
devvm ls
```

`devvm init` imports Enkaku's known targets into `~/.config/wezterm/devservers`.
It refuses to overwrite an existing list. Edit that list to choose your servers
and aliases, then start a fresh WezTerm process to register their mux domains.

```sh
devvm                    # Connect and gather configured servers
devvm primary            # Open/focus just one server
```

Normal WezTerm startup opens a local shell. Server connections are explicit.

## Read the bottom bar

Each tab shows its number, domain/server label, and terminal title:

```text
1 Local · zsh    2 primary · project    3 experiments · Claude Code    +
```

Local and server tabs share the main window. A server moved with `devvm detach`
has a separate window with its own native tab bar. The active tab has a filled
background and bold text; inactive tabs keep their domain color in the text and
Powerline separator. Hovering highlights a tab.

| Host-list position | Color |
|---|---|
| Local | Neutral blue-grey |
| 1 | Cyan |
| 2 | Purple |
| 3 | Green |
| 4 | Orange |
| 5 | Pink |
| 6 | Blue |
| 7 | Yellow |

The palette repeats after seven servers. Reordering the host list changes colors
and the `Cmd+Opt+1` … `9` assignments. Both reconnect domain IDs for a server use
the same label and color. Other domains use their domain name and a derived color.
Colors identify mux domains: SSH launched inside a Local shell still belongs to
that Local tab, although the terminal color scheme may change.

Titles are clipped to the available width. Click a tab to select it, or use
`Cmd+Shift+T` to find tabs in any window of the workspace, including those that
do not fit in the bar.

New tabs join their domain's group: after the last tab of that domain, in the
first group at or after the focused tab. This covers `Cmd+T` and tabs that arrive
any other way, such as `devvm` attaching a host. Tabs you move on purpose stay
where you put them.

WezTerm cannot drag tabs from the bar. To rearrange tabs, use
`Cmd+Opt+Shift+Left`/`Right`, or choose **Move this tab…** at the end of the
`Cmd+Shift+T` picker and pick a position in any window, or a new window. Within a
window any tab can move. Only unsplit local tabs move between windows; use
`devvm detach` and `devvm open` for server tabs.

## Keyboard shortcuts

These are the tracked macOS bindings: `Cmd` is Command and `Opt` is Option.
Machine-local overrides can change them. Run `wezterm show-keys` to inspect the
loaded bindings.

### Tabs, servers, and sessions

| Shortcut | Action |
|---|---|
| `Cmd+T` | Create a tab in the active pane's domain, grouped with that domain's tabs |
| `Cmd+1` … `Cmd+8` | Select that numbered tab |
| `Cmd+9` | Select the last tab |
| `Cmd+Shift+T` | Open the tab picker: jump to a tab, or move this tab to any position |
| `Cmd+Opt+Shift+Left` / `Right` | Move the current tab left / right |
| `Cmd+Opt+0` | Focus a local tab in the unified main window |
| `Cmd+Opt+1` … `Cmd+Opt+9` | Open/focus hosts in host-list order |
| `Cmd+Shift+O` | Open the fuzzy server picker |
| `Cmd+Shift+P` | Open the command palette |
| `Cmd+Shift+W` | Detach the active pane's mux domain; keep its remote processes alive |
| `Cmd+W` | Close the current tab, ending its pane processes |
| `Cmd+Q` | Quit the GUI; local shells end, remote mux sessions remain |
| `Cmd+R` | Reload configuration, except while search mode is active |

`Cmd+Shift+W` detaches a domain from the GUI. `devvm detach <host>` instead moves
that host into another window while keeping it attached. Those are different
operations. Detaching a domain can remove all of its attached tabs from the GUI.

### Panes and terminal input

| Shortcut | Action |
|---|---|
| `Cmd+D` | Split right, in the active pane's domain |
| `Cmd+Shift+D` | Split below, in the active pane's domain |
| `Cmd+Shift+Left/Right/Up/Down` | Select the pane in that direction |
| `Cmd+[` / `Cmd+]` | Previous/next pane; these navigate panes, not tabs |
| `Cmd+C` / `Cmd+V` | Copy selection / paste clipboard |
| `Cmd+Click` | Open a recognized hyperlink |
| `Shift+Enter` | Send a newline to the terminal application |

The work package also recognizes Meta task/diff/paste IDs and supported fbsource
path/line references as links. Source references open in VS Code Insiders through
the Meta source-link service.

### Scrollback and search

| Shortcut | Action |
|---|---|
| `Cmd+F` | Search scrollback, initially in regex mode |
| `Shift+Up` / `Shift+Down` | Previous/next shell prompt; requires shell integration |
| `Cmd+E` | Open a scrollback snapshot in Vim |
| `Cmd+K` | Clear scrollback and the viewport; the running program continues |

While search mode is active:

| Shortcut | Action |
|---|---|
| `Cmd+R` | Cycle search match type |
| `Cmd+G` / `Cmd+Shift+G` | Next/previous match |
| `Ctrl+A` / `Ctrl+E` | Move to the beginning/end of the search text |
| `Ctrl+U` | Clear the search pattern |

The shared configuration keeps 20,000 scrollback lines, enables the scrollbar,
and uses a 12-point JetBrainsMono Nerd Font Mono font. The base scheme is Dracula.

## Server commands

A host selector can be a full hostname, short hostname, alias, or unambiguous
hostname fragment. Exact matches take priority; ambiguous selectors are rejected.

| Command | What it does |
|---|---|
| `devvm` | Connect/gather all configured servers into the main window |
| `devvm <host>` | Open/focus a server; focus its separate window if already detached |
| `devvm local` | Focus a local tab in the main window |
| `devvm detach <host>` | Move an attached server's panes into a separate window |
| `devvm merge <host>` | Connect/gather that server into the main window |
| `devvm merge` / `devvm merge all` | Connect/gather all configured servers |
| `devvm ls` / `devvm list` | List hosts and aliases |
| `devvm init` | Initialize the host list from Enkaku, once |
| `devvm add <hostname> [alias]` | Add a host; start a fresh GUI before connecting |
| `devvm rm <host>` | Remove configuration without ending its running sessions |
| `devvm help` | Show command usage |

For example:

```sh
devvm primary
devvm detach primary
devvm merge primary
devvm local
```

When connecting, Enkaku handles Duo/YubiKey authentication. A CLI invocation uses
its terminal; a GUI shortcut opens a local terminal tab for authentication.
Approve the push, touch the key, or enter the requested response there. Pending
authentication does not hold the shared GUI command lock.

Commands may briefly open a local control window, which closes when the request
finishes. If one server cannot connect, successfully connected servers remain
available and the command reports the failure.

## Configure hosts and local settings

The host list is machine-local at `~/.config/wezterm/devservers`:

```text
# Full hostname, followed by an optional alias.
devvm12345.example.facebook.com primary
devvm67890.example.facebook.com experiments
```

Blank lines and `#` comments are supported. Use simple aliases containing letters,
numbers, underscores, or hyphens. Host short names and aliases must be unique;
command names such as `local`, `merge`, and `all` are reserved aliases.

Existing labels and styling can reload with `Cmd+R`. Adding a new mux domain
requires a fresh GUI process; ordinary config reload does not register it.
Remote sessions survive that restart, while local shells end with the old GUI.

Put machine-specific appearance settings in
`~/.config/wezterm/wezterm_local.lua`:

```lua
return {
  font_size = 14.0,
  window_background_opacity = 1.0,
}
```

Local settings override the shared configuration. For a personal setup, install
only `wezterm`; the native bar and terminal shortcuts remain available, while
Enkaku shortcuts and Meta hyperlinks are absent.

## Persistence and layout behavior

| Operation | Result |
|---|---|
| Lose the connection or quit the GUI | Remote processes and scrollback remain in the server's mux |
| `Cmd+Shift+W` | GUI detaches; remote processes remain |
| `devvm detach` / `merge` | Processes, scrollback, and existing splits remain in grouped server windows |
| Close a remote tab or exit its shell | Processes in that pane/tab end |
| Restart the server or stop its mux server | Its remote sessions end |
| Quit WezTerm with local tabs | Local shells end |

Main and detached windows keep local anchor tabs. Native server tabs attach
directly to the destination window, preserving their existing splits. Initial
consolidation of multiple server windows still turns panes moved from other
windows into separate tabs. Detached-window placement is not saved.

### Runaway-loop guards

Each server's socket (`~/.local/share/wezterm-devservers/<host>.sock`) points at a
small relay, `devvm-guard`, in front of the Enkaku forward. WezTerm does not close
a connection when it detaches a domain, and a stale connection next to the live one
once drove a focus loop that pinned the GUI. Every detach/merge therefore restarts
the host's relay, so stale connections close before the server reattaches.

Two breakers disconnect servers instead of letting the GUI hang. Remote sessions
survive; reopen the server with `devvm <host>`.

| Breaker | Trips when | Disconnects |
|---|---|---|
| Relay | More than 100 focus messages per second for 3 seconds | That server |
| Watchdog (starts with the GUI) | GUI log grows faster than 256 KB/s for 3 seconds | Every server |

Before a server attaches, any of its tabs larger than the destination window
is shrunk to fit, keeping pane proportions. A new window adopts its tab's
stored size, and one 1,496-column tab once overflowed the GPU and crashed the
GUI. Each fit is logged as `"guard": "fit"`.

Trips appear as a macOS notification and as a line in
`~/.local/state/wezterm-devservers/trips.log`. `relays/<host>.connections` there
shows each server's live connection count, which should be 1 while attached.
Tab-title and status handlers that keep failing fall back to defaults after 50
errors in 10 seconds; reload the config to re-enable them.

The previous terminal-pane footer is retired. Stale `domain-menu` flags are
ignored, and inherited menu processes are removed on attachment/reload or the
next helper connection. The bar itself creates no terminal panes or resize loop.

## Troubleshooting

| Symptom | What to do |
|---|---|
| Host selector is ambiguous | Run `devvm ls`, then use a full hostname or exact alias |
| New host is not registered | Start a fresh WezTerm process after `devvm add` or editing the list |
| Labels or shortcuts have not updated | Press `Cmd+R` outside search mode; inspect `wezterm show-keys` |
| Prompt navigation does nothing | Install `wezterm.sh` and open a new zsh session |
| Powerline separators look wrong | Install/select JetBrainsMono Nerd Font Mono |
| Connection fails | Check `ek status` and complete any authentication prompt; retry that host |
| A command reports another command is running | Let the active operation finish, then retry |
| A server disconnected with a "WezTerm guard" notification | A runaway loop was stopped; check `~/.local/state/wezterm-devservers/trips.log`, then run `devvm <host>` |
| GUI lags while devservers are attached | Check `relays/<host>.connections` in the state directory; restart WezTerm if any reads above 1 |
| A GUI request times out | Confirm `wezterm-work` is installed and reload; inspect `~/.local/state/wezterm-devservers/startup.log` if the helper started a GUI |

To uninstall the work tools:

```sh
stow --delete --no-folding wezterm-work
```

The host list remains for a later reinstall. The shared WezTerm package continues
providing the native bar and terminal shortcuts.

## Verification and engineering notes

Run from the repository root:

```sh
bash wezterm-work/.local/bin/devvm.test
bash wezterm-work/.local/bin/devvm-auth.test
bash wezterm-work/.local/bin/devvm-guard.test
bash wezterm-work/.local/bin/devvm-request.test
bash wezterm-work/.config/wezterm/config.test
bash wezterm-work/.config/wezterm/integration.test
```

The GUI checks use private local mux servers and a separate Mac GUI. They cover
legacy-menu cleanup, in-place reload, host/local tab selection, fresh attachment,
detach/merge, and process preservation. Authentication is simulated; these tests
do not exercise physical Duo/YubiKey hardware.

For implementation history and the footer diagnosis, see the
[handoff](../wezterm/docs/handoffs/wezterm-devservers-handoff-v1.md),
[design](../wezterm/docs/specs/2026-11-16-unified-devservers-design-v1.md),
[investigation report](../wezterm/docs/reports/wezterm-devservers-anr-analysis-v1.md),
[focus-loop report](../wezterm/docs/reports/runaway-focus-loop-v1.md), and
[oversized-tab crash report](../wezterm/docs/reports/oversized-tab-crash-v1.md).
