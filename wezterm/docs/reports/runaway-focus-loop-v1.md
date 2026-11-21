# Runaway focus loop after devserver relocation

2026-11-19 · Diagnosed live; guards implemented and tested. Changes are uncommitted.

## What happened

The GUI lagged badly while `devvm58157` was attached. `wezterm-gui` ran at
97–132% CPU and its log grew about 2.5 MB/s, almost all of it one line alternating
between two panes:

```text
ERROR wezterm_gui::frontend > Error reconciling PaneFocused notification: pane 99 not found
ERROR wezterm_gui::frontend > Error reconciling PaneFocused notification: pane 100 not found
```

| Time | Event |
|---|---|
| 10:56:22.931 | Relocation detaches domain 3 (panes 62, 90–92); `devvm58157.sock` re-pointed |
| 10:56:22.934 | First `PaneFocused … pane 90 not found` (3 ms later) |
| 10:59:05.913 | Relocation detaches domain 4 (panes 97–100); domain 3 attached again |
| 10:59 | About 275,000 errors per minute for panes 99/100 |
| 10:59:39.237 | Last error; stale connections had closed |

The other servers' Enkaku tunnels stayed idle, and their mux sockets each held
4 forwarded connections, against 7 for `devvm58157`. After the flood stopped,
`devvm58157` was back to one GUI connection, even with no pane attached.

## Cause

Read against the installed build, `05343b387085842b434d267f91b6b0ec157e4331`:

- `ClientDomain::perform_detach()` only drops the domain's `inner`. The client's
  socket and reader thread live on while anything still references the client,
  for example a stale tab still holding its `ClientPane`s.
- Unsolicited messages are routed by **local domain ID**. Once a domain ID is
  attached again, both the old and new connections deliver into it.
- Unix-domain clients never reconnect. On EOF they end and call a late
  `detach(domain_id)`. The handoff's alternating domain IDs exist to keep that late
  detach off a freshly attached domain.
- The mux server sends `PaneFocused` to every client, including the sender, and
  `Tab::set_active_pane` emits a GUI `PaneFocused` for panes the mux may already
  have removed. That produces the "not found" error.

Together: the second relocation reattached domain 3 while its earlier connection
still lived, and a stale tab held panes 99/100. **Confirmed:** the flood began at a
relocation and ended when the extra connections closed. **Not reproduced:** the
exact message-by-message ping-pong. A private fixture with the same relocation
cycles, with and without 20–50 ms of added latency, never leaked a connection.
The trigger needs long-lived GUI state (stale tab objects) that the fixture does
not build.

## Fix

The fix does not depend on WezTerm internals. It enforces the broken invariant,
one live connection per server, from outside the GUI, and adds breakers for
anything the invariant misses.

| Layer | Change |
|---|---|
| `devvm-guard relay` | One relay per server between WezTerm and the Enkaku forward. `devvm --group`, run on every relocation, restarts it so stale connections close before the alternate domain attaches. `devvm <host>` keeps a healthy relay, so focusing an attached server never disconnects it. |
| Relay breaker | Counts `SetFocusedPane`/`PaneFocused` frames without changing the stream; trips at >100/s for 3 s and disconnects that server |
| `devvm-guard watchdog` | Started on `gui-attached`, runs outside the GUI (a flooded main thread cannot run Lua timers); trips at >256 KB/s of GUI log for 3 s and stops every relay |
| `wezterm.lua` | Repaint/status handlers log their first error and turn off after 50 failures in 10 s; on 2026-11-18 a missing `tab_domain` logged 2,784 tracebacks in 23 s |
| `wezterm.lua` | The `IS_REMOTE` scheme switch follows only the active pane, so a background pane's prompt cannot flip the window config against `update-status` |

Remote sessions survive every trip; `devvm <host>` reconnects.

## Audit notes

- `run_child_process` and `sleep_ms` are async in this build. They yield instead of
  blocking the GUI thread.
- Other retry loops (`devvm --request`, `focus()`, request handling) are already
  bounded.
- One watchdog runs per state directory. A second simultaneous GUI goes unwatched
  until the first exits and the second attaches again.
- The live GUI keeps its pre-relay direct connections until WezTerm restarts.

## Verification

`devvm-guard.test` covers frame counting across chunk boundaries; byte-exact
relaying; `ensure` keeping live connections; `restart` closing stale ones; bulk
output not tripping; a focus flood tripping and recovering; and watchdog
single-instance and trip behavior. The integration test now asserts that
relocation restarts the relay, that each host ends with exactly one connection,
and that the GUI logs no `PaneFocused` errors. `config.test` asserts the handler
guard. Removing the relay restart from `devvm`, or raising the guard limit, makes
the corresponding test fail.
