# WezTerm devserver handoff

Updated: 2026-11-18. Repository: `/Users/rayzeng/dotfiles`.

## Remote split/resize fix — 2026-11-18

The current uncommitted fix prepares native server tabs before attaching them
with `domain:attach(destination)`. It removes post-attachment client-pane moves
and hidden mirror cleanup. Those moves left stored server tab IDs stale, causing
splits and resizing to use old measurements. Existing grouped splits now survive
reconnect/detach/merge. Initial native multi-window consolidation may flatten
panes moved from other windows. Tests cover both split shortcuts, window resizing,
extra-alias recovery, and process continuity. The two live server views were
migrated without restarting their shells. See
`wezterm/docs/reports/remote-split-resize-fix-v1.md` for the short report.

## Superseding native-bar revision — 2026-11-18

The user replaced the two-bar prototype with one native bottom Powerline bar,
all domains' tabs in the unified window, and domain/server colors. A separate
per-domain selector is deferred. `wezterm_domains.lua`, `domain-menu.sh`, and the
prototype test are retired; archived source text is in the investigation report's
evidence directory. Stale menu flags are ignored. GUI attachment/reload and native
helper cleanup remove owned menus by reserved title while preserving content.

Current checks: CLI, interactive-auth fixture, config renderer, and GUI integration
with inherited duplicate-menu cleanup, direct fresh attachment, detach/merge, and
session preservation. The old text below is historical context, not the current
setup or an instruction to re-enable the prototype. Current commands and setup
are in `wezterm-work/README.md`; design requirements were updated in place.

Safety stash `before-native-bottom-tabs-v1` was saved, restored, and retained.
Changes remain uncommitted. Live verification confirms two original local tabs
and four original remote tabs in main window 0, zero menu panes, and preserved
remote native pane IDs and shell PIDs. Evidence: `wezterm/docs/reports/evidence/native-bottom-tabs-v1/`. Do not restore the terminal footer to implement a future selector.

## Current status

The MVP and subsequent domain-menu iteration are implemented, installed on this
work Mac, and left **uncommitted** for iteration. The latest isolated GUI
regression run passed after fixing the user's authentication, footer splitting,
resize, and domain-click reports. The user has **not yet confirmed those last
fixes in their live windows**. Actual Duo/YubiKey hardware authentication was not
exercised; tests use interactive authentication fixtures.

The current design keeps native tabs at the top and a thin terminal menu pane at
the bottom. Each domain gets its own workspace/window, so the top bar contains
only that domain's tabs. The user authorized a simpler bottom layout if this
footer cannot be maintained reliably. That fallback has not been implemented:
the repaired footer passed resize and damaged-layout recovery checks.

## User intent and working preferences

- Unified access to local sessions and several devservers.
- Work tools must be optional and absent from personal setups.
- Preserve running remote sessions; support separate devserver windows and merge.
- Hide the system title bar, which had transparency artifacts.
- Add vertical space around tab text.
- Bottom domain menu/status; top tabs limited to the current domain.
- Implement an MVP and iterate. Do not restart a design/permission questionnaire.
- Give concise progress updates during longer work. This session became lengthy,
  and the user repeatedly requested status.

Follow the repository guide: GNU Stow packages, maintained helpers use
`/bin/bash`, and tests live beside their implementation. Preserve uncommitted work
before code changes. Preserve unrelated submodule changes and other users'/agents'
concurrent edits. Do not commit without a request.

## Files

| File | Responsibility |
|---|---|
| `wezterm/.config/wezterm/wezterm.lua` | Shared config; optional work-module loading; title-bar removal; padded fancy tab renderer; existing fonts/navigation/search/scrollback |
| `wezterm/.stow-local-ignore` | Keeps docs/tests out of HOME |
| `wezterm-work/.config/wezterm/wezterm_work.lua` | Host parsing/validation, paired mux domains, work-only hyperlinks and shortcuts, legacy mixed-domain mode, menu-mode loading |
| `wezterm-work/.config/wezterm/wezterm_domains.lua` | Domain workspaces, menu lifecycle/rendering/activation, workspace focus, protected splitting/navigation, footer recovery and maintenance polling |
| `wezterm-work/.config/wezterm/domain-menu.sh` | Same-domain menu process; framed input and OSC user-variable relay |
| `wezterm-work/.local/bin/devvm` | Bash CLI, Enkaku connection/forward management, native remote grouping/cleanup, interactive progress launch, locking and GUI requests |
| `wezterm-work/.local/share/zsh/site-functions/_devvm` | Completion for hosts, aliases and commands |
| `wezterm-work/.stow-local-ignore` | Excludes README/tests from installation |
| `wezterm-work/README.md` | User-facing setup, commands and limitations |
| `zsh/.zshrc` | Adds the optional user completion directory; refreshes compinit cache when that directory changes |

Design: `wezterm/docs/specs/2026-11-16-unified-devservers-design-v1.md`.
Local plan/progress ledger:
`/Users/rayzeng/.claude/plans/2026-11-17-wezterm-devservers-mvp-v1.md`.
Read its **Progress** section; early task checkboxes and architecture text predate
the domain-menu revision.

## Installed machine-local state

The work package was installed with `stow --no-folding wezterm-work`. HOME links
resolve into this checkout for `wezterm_work.lua`, `wezterm_domains.lua`,
`domain-menu.sh`, `~/.local/bin/devvm`, and the `_devvm` completion.

Untracked machine-local configuration:

- `~/.config/wezterm/devservers`: hostname and optional alias per line; list order
  determines Cmd+Opt+1..9.
- `~/.config/wezterm/domain-menu`: empty flag enabling the new menu mode.
- `~/.config/wezterm/domain-menu-used`: remembers that remote menu cleanup may be
  needed when returning to legacy mode.
- `~/.local/share/wezterm-devservers/<short>.sock`: stable links to Enkaku forwards.
- `~/.local/state/wezterm-devservers/`: request directories, advisory lock file,
  and startup log.

The current host list, in order:

```text
devvm5324.dkl0.facebook.com
devvm58157.lla0.facebook.com
devvm66816.atn0.facebook.com
```

Keep actual hostnames and aliases machine-local rather than hardcoding them in
the tracked configuration. New domains require a fresh WezTerm process/restart;
ordinary configuration changes reload automatically.

## Commands and UI

```sh
devvm menu on             # Enable domain menu
devvm local               # Local view
devvm 58157               # Open/focus matching host
devvm                     # Initialize/gather configured domain views
devvm detach 66816        # Show host alongside the current domain
devvm merge 66816         # Return host to its own workspace/menu
devvm ls
devvm add <fqdn> [alias]
devvm rm <host>
devvm menu off            # Disable menu; clean up owned menu processes
devvm                     # Gather into previous mixed-domain view
```

Cmd+Opt+0 selects Local, Cmd+Opt+1..9 selects hosts, and Cmd+Shift+O opens the
picker. Cmd+T and splits follow the content pane's domain. Cmd+D and Cmd+Shift+D
explicitly select content even if the menu has focus. Pane navigation skips menus.

Shared config also contains Cmd+Shift+W → DetachDomain. It appeared during
concurrent workspace edits, not as part of this agent's original patch; preserve
it unless the user requests a change.

## Architecture and important decisions

### Work/personal separation

The shared package loads the work module only when installed. Meta hyperlink
rules were moved into the work package. Personal config is checked without
Enkaku/work domains. This is a **machine-level opt-in**, not simultaneous isolated
personal/work GUI profiles on one Mac. No global `wezterm-gui` wrapper, app clones,
external tab plugins, or remote metrics polling were installed.

### Remote sessions

`ek` forwards `/run/user/<uid>/wezterm/sock`; `devvm` reuses existing forwards and
starts `wezterm-mux-server` when needed. Sessions remain on the server when the
GUI disconnects. Closing a content pane, stopping the server, or rebooting the
server can end its process. Local Mac sessions are ordinary terminal sessions.

Two registered domains per host share one socket: `devserver:<short>` and
`devserver:<short>:alternate`. Older clients can retain mirrored tab graphs, and
their late background cleanup can detach a freshly reused domain ID. Alternating
IDs avoids that race. GUI pane IDs may change during reconnection; test process
identity using remote process markers, not only GUI IDs.

Detach does not close the old connection, so each host's socket goes through a
`devvm-guard` relay that every relocation restarts. Without it, a stale connection
beside the reattached domain drove a runaway focus loop; see the
[focus-loop report](../reports/runaway-focus-loop-v1.md).

Legacy mode moves client panes and hides mirrored copies in `devservers-stale`.
Menu mode initially consolidates windows using the **remote native mux CLI**,
then switches workspaces rather than moving client panes on each domain change.
Initial consolidation can flatten splits moved from other native windows;
subsequent switches preserve tabs, splits and processes.

### Menu and request transport

WezTerm has one native tab/status bar. The second bar is a one-row terminal pane
running in the **same domain as its content**, avoiding mixed-domain split issues.

The menu protocol uses `DEVVM_DRAW`, `DEVVM_PICK`, `DEVVM_REQUEST`, and
`DEVVM_MENU_EXIT`. The Bash process translates picks/requests into OSC user vars.
GUI requests are JSON files under the private local requests directory; the
receiver accepts local panes or owned menu panes, validates the path prefix,
and writes results atomically. Menu-mode requests prefer the existing menu relay
instead of opening local control tabs in remote views. A transient local request
tab is the fallback when a menu is unavailable.

Menu ownership is identified by the `DEVVM_MENU` user variable or recorded owned
pane IDs. Native remote cleanup uses the reserved `dotfiles-domain-menu` title
and sends the menu's exit protocol, not `kill-pane` to content processes.

### Focus and maintenance

Use the GUI `SwitchToWorkspace` action; setting the mux workspace alone does not
guarantee a visible GUI window. Newly visible windows need association retries.
Closed GUI objects can throw on getters, so expected stale-object calls are guarded.
Background requests do not explicitly steal OS focus.

Footer dimensions are checked against both the tab's split allocation and the
pane viewport. Wrong width/height or a changed menu script causes **only the owned
menu process** to exit and rebuild. Content processes survive, including a shell
previously split beside the footer. Frame output is clipped to available columns
and refreshed on resize. A single owned polling loop handles idle/hidden cleanup
and invalidates obsolete pollers across config reloads.

## Bugs fixed in the last iteration

1. **Cold-click output began with `!]1337`.** Lua interpreted `\033` numerically
   as decimal 33 (`!`). Structured GUI args now invoke `devvm --progress`, and Bash
   emits the actual ESC marker before connection output.
2. **Duo/YubiKey input was unavailable.** Both the Python heredoc and the host
   iteration redirected stdin. Original terminal input is preserved on fd3 for
   the wrapper; host-list iteration reads fd4. Authentication occurs before the
   shared GUI lock, so a pending approval does not block unrelated requests.
   Prepared host/failure state is passed to the locked child and cleared on normal
   entry to avoid stale inherited values. The helper does not store credentials.
3. **Cmd+D split the footer.** The old binding acted on the active menu pane.
   Protected callbacks now split the remembered/active content pane directly.
4. **Resize enlarged/corrupted the footer.** Split proportions scale and cached
   frames can reflow incorrectly. Allocation checks, owned-pane rebuilding,
   resize redraw and column clipping restore a full-width one-row menu.
5. **Connected domain clicks could be unresponsive.** Authentication no longer
   holds the shared GUI lock; connected windows are found and validated even when
   their remembered window ID is stale. Repeated menu picks are tested. An
   investigated duplicate-user-var hypothesis was disproved: WezTerm emits an
   alert even when the value repeats; no nonce workaround was added.
6. **Menu-only tabs survived content exit.** Cleanup checks run before invalid
   window returns and through maintenance polling, including hidden/idle tabs.
   Disabling also cleans unattached menus on Enkaku-connected servers; offline
   cleanup is deferred until the next connection.

An authentication tab launched **before** the stdin fixes cannot be repaired in
place. If the old `Connecting devvm5324...` operation is still pending, ask the
user to cancel that tab with Ctrl+C and retry. Do not terminate live user processes
or submit Duo/YubiKey credentials on their behalf.

## Verification

Run from the repository root:

```sh
bash wezterm-work/.local/bin/devvm.test
bash wezterm-work/.local/bin/devvm-auth.test
bash wezterm-work/.config/wezterm/config.test
bash wezterm-work/.config/wezterm/integration.test
bash wezterm-work/.config/wezterm/domain-menu.test
git diff --check
```

Latest checks passed for CLI validation/socket preservation, interactive
authentication, another request completing during pending authentication,
personal/work config isolation, and the domain-menu GUI regressions. The latter
checks actual Cmd+D/Cmd+Shift+D actions with the menu focused, window resize,
forced footer height changes, damaged-footer rebuilding with content preservation,
cold-domain authentication, repeated connected-domain clicks, domain switching,
split retention, detach/merge, menu cleanup, GUI restart and legacy reattachment.

Evidence: `/tmp/devvm-fixes-full.txt` contains the latest successful full GUI run.
The old split/resize repro failures were captured in `/tmp/devvm-key-red.txt` and
`/tmp/devvm-footer-red.txt`. These scratch files may disappear; regenerate evidence
as needed.

Important testing limits:

- GUI tests create **isolated local mux servers** and separate Mac GUI processes;
  they do not attach to the real devservers.
- Enkaku and authentication are fixtures. Linux runtime/socket paths are adapted
  to temporary Mac sockets. Actual corporate auth and all live-window behavior
  still need user confirmation.
- GUI windows can appear and change focus. Ordinary input is ignored by fixtures;
  they exit on an owned test token. Menu input is framed and unknown input ignored.
  GUI shortcuts/window closure can still disrupt a test.
- WezTerm `show-keys` can silently fall back and return zero after a config error.
  `config.test` writes/asserts evaluation witnesses; do not trust exit status alone.
- Footer IDs legitimately change during rebuild. Refresh references in tests.
  Resize checks compare geometry instead of assuming a fixed DPI.

Read-only review passes found and helped fix socket-error handling,
malformed host loading, stale-lock reclamation, menu lifecycle and launch timing.
The later focused source review reported no material regressions in the changes
it read. Final authentication-lock scope and maintenance polling adjustments were
made afterward and covered by regression tests, without another fresh review.
Review agents did not perform GUI/live-server testing.

## Workspace and backups

HEAD at handoff: `fe1262a` (`Support environment-specific dotfiles setup`). The
session did not commit its implementation. Current pending files include shared
WezTerm/zsh edits, the untracked work package, Stow ignore and docs, and the original
archive. Zsh submodule gitlink changes are unrelated pre-existing work.

Safety stashes were created and restored, but retained:

- `803a81a...`: before the latest connection/footer fixes.
- `2017da8...`: before the domain-menu prototype.
- `6bfc48b...`: before the original devserver MVP.
- `4e18233...`: before padded tabs/unified devservers.

Other stashes belong to pre-existing/concurrent work. Do not pop/drop stashes or
reset the checkout blindly. User/concurrent edits changed HEAD during this session.

The original `wezterm-devvm.tar.gz` remains untracked. It was unpacked into
`/tmp/wezterm-devvm-inspect.etAAJ7/wezterm-devvm`; all ten extracted files matched
the archive. Do not run its installer: it writes `~/.wezterm.lua` whereas this
machine uses the Stow-managed `~/.config/wezterm/wezterm.lua`, and its original
backup logic would not preserve that active config.

## Next steps

1. Ask for the user's live confirmation of domain clicks, Duo/YubiKey interaction,
   Cmd+D with the menu selected, and resizing. Do not claim hardware/live fixes
   from the synthetic tests alone.
2. If a report persists, capture current pane/layout IDs and reproduce that exact
   path in the isolated fixture before changing the architecture again.
3. Keep the current two-bar layout while it is reliable. If maintenance still
   fails in live use, revisit the user's explicitly authorized consolidated bottom
   layout; stock WezTerm has only one native bar, so clarify the achievable row
   arrangement rather than pretending it supports two native bars.
4. Continue MVP iteration, leave unrelated work intact, and commit only if requested.
