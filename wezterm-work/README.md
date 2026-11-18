# WezTerm work tools

Optional GNU Stow package for one Enkaku devserver window. The shared `wezterm`
package works without it and does not load work shortcuts or Meta hyperlinks.

## Native bottom bar

One native Powerline-style tab bar sits at the bottom. Local and remote tabs
share the unified window. Labels include the server alias or short hostname;
colors identify domains, with the same color for both reconnect domain IDs.
Configured hosts use seven distinct colors in host-list order, then repeat the
palette; Local has its own neutral color.
The active tab has a filled background and bold text; inactive tabs retain their
server color in the text and separator. No terminal pane renders the bar.

Cmd+Shift+T opens the tab navigator when there are more tabs than fit on screen.
Cmd+T and Cmd+D / Cmd+Shift+D follow the active pane's domain. Cmd+Opt+0 focuses
a local tab; Cmd+Opt+1..9 opens/focuses hosts in list order. Cmd+Shift+O opens the
host picker. A separate per-domain selector is deferred.

The old menu prototype has been removed. Stale `domain-menu` flags are ignored.
Fresh GUI attachment and upgrade reload retire inherited menus by their reserved
`dotfiles-domain-menu` title. The helper also removes those owned remote menus
before attaching. Offline servers are cleaned when they next connect. Existing
content processes are preserved.

## Install

Requires local WezTerm, Python 3, and working `ek` connections. Each devserver
needs `wezterm-mux-server`; standard Meta devservers normally include it.

```sh
mkdir -p ~/.config/wezterm
stow --simulate --verbose=2 --no-folding wezterm-work
stow --no-folding wezterm-work
devvm init
devvm
```

`devvm init` writes a machine-local host list to `~/.config/wezterm/devservers`
and refuses to overwrite an existing list. Edit the list or use `devvm add` to
add hosts and aliases. New domains require a WezTerm restart; existing labels and
configuration reload automatically. Normal startup opens a local shell in the
`devservers` workspace; `devvm` gathers remote sessions into that window.

```text
devvm12345.example.facebook.com primary
devvm67890.example.facebook.com experiments
```

## Commands

| Command | Behavior |
|---|---|
| `devvm` | Gather all configured servers into the main window |
| `devvm primary` | Open/focus a server; focus its detached window if present |
| `devvm local` | Focus a local tab in the main window |
| `devvm detach primary` | Move that server's panes into a separate window |
| `devvm merge primary` | Move that server's panes back to the main window |
| `devvm merge` | Gather all configured servers |
| `devvm ls` | List configured servers and aliases |
| `devvm add <hostname> [alias]` | Add a server; restart before connecting |
| `devvm rm <host>` | Remove from the list without ending sessions |

Unique hostname fragments work wherever a host is accepted. Ambiguous fragments
are rejected. Connections use an interactive local tab for Duo/YubiKey input.
Authentication waits do not hold the shared GUI command lock. The helper does
not store credentials.

## Session behavior

- Remote sessions live in the devserver's mux server. Quitting the GUI or losing
  the connection preserves them while that server remains alive. Re-run `devvm`
  to reconnect. A server reboot or mux termination ends those sessions.
- Local Mac shells are ordinary terminal sessions and end when WezTerm quits.
- Closing a remote pane ends its session. Cmd+Shift+W detaches the current domain
  while leaving its remote sessions running.
- Moves preserve processes and scrollback but turn split panes into separate
  tabs. Relocation alternates client domain IDs to avoid stale mux layout cleanup.
- Main and detached windows keep local anchor tabs. A temporary local request window
  closes after each helper command. Mirrored remote windows are hidden in the
  `devservers-stale` workspace without closing shared processes.
- The work package is a machine-level opt-in. No global GUI wrapper or per-host
  application copies are installed.

Disable work tools with `stow --delete --no-folding wezterm-work`. The local host
list remains available for a later reinstall.

## Checks

```sh
bash wezterm-work/.local/bin/devvm.test
bash wezterm-work/.local/bin/devvm-auth.test
bash wezterm-work/.local/bin/devvm-request.test
bash wezterm-work/.config/wezterm/config.test
bash wezterm-work/.config/wezterm/integration.test
```

Request delivery retries startup notifications until a reply is acknowledged;
completed or pending requests are not executed twice. Helper paths and local
working directories are explicit, so relative invocation and remote-pane CWDs
do not break the control process.

GUI checks use private local mux servers and a separate Mac GUI process. They
exercise inherited duplicate-menu cleanup, native mixed-domain tabs, fresh
attachment, detach/merge, and session preservation. Authentication is simulated;
actual Duo/YubiKey interaction still depends on the live Enkaku environment.
