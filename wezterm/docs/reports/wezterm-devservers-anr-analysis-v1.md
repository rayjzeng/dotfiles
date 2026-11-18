# WezTerm devserver attach and footer investigation

2026-11-18 · Investigation only; no implementation fix applied.

Historical report: the user subsequently authorized the native bottom bar.
Retired footer sources are preserved as text in the evidence directory; the
findings below describe the implementation at investigation time.

## Assessment

**The footer lifecycle is broken across GUI reattachment.** Existing remote menu
processes survive, but their ownership markers are missing in a fresh client's
pane objects. The client treats those menus as content and creates additional
menus. This was reproduced both with a second concurrent GUI and after stopping
the first GUI and attaching a replacement.

The live `devvm58157` layout contains five menu panes across two tabs. Three of
those menus occupy 16, 39, and 54 terminal rows. This explains the repeated domain
strips and large empty regions in the supplied screenshot. Footer recovery also
fails with an I/O error in the live resize log, and becomes substantially slower
in a delayed-transport fixture.

**The exact macOS ANR/crash is NOT ROOT-CAUSED YET.** The duplicate-pane mechanism
and impaired recovery are established; a renderer deadlock, GPU failure, or the
precise cause of the reported whole-application hang is not. The isolated runs
did not crash. No matching WezTerm crash report was found in the inspected macOS
DiagnosticReports directory, and `sample` could not inspect the live GUI process.
Absence of a crash report does not rule out a crash or forced termination.

Recommendation: replace the terminal-pane footer with one native tab/status bar,
retaining per-domain workspaces and a supported domain picker. This removes the
confirmed failure mechanism. It is not yet evidence that every reported ANR would
be eliminated.

## Scope and evidence

Reviewed the [handoff](../handoffs/wezterm-devservers-handoff-v1.md), shared
configuration, work module, domain module, menu script, connection helper, and
GUI fixture. Inspected live remote layouts through existing Enkaku forwards and
read process state on `devvm58157.lla0.facebook.com` with targeted `ek run`
commands. No live pane was closed, resized, or sent input by this investigation.

Both the Mac client and Linux server report WezTerm version
`05343b387085842b434d267f91b6b0ec157e4331`; an obvious client/server version mismatch
is therefore ruled out. Repository HEAD was `fe1262a`, with the implementation
still uncommitted. Existing implementation files and unrelated changes were
preserved; no stash, commit, deployment, or configuration toggle was performed.

Reproductions ran on the Mac using separate GUI processes, private local mux
servers, passive shell fixtures, and private configuration copies. A Unix-socket
proxy optionally delayed each forwarded chunk by 100 ms in each direction.
This is a transport-stress fixture, not an exact model of the live network's RTT
or bandwidth. Logging instrumentation changed only those private copies.

Durable observations and selected reproduction traces are in
[the evidence directory](evidence/wezterm-devservers-anr-v1/observations.json).
Full scratch logs and reproduction scripts remain at
`/tmp/wezterm-anr-evidence-v1/`; those scratch files are not durable repository
artifacts.

## What is broken

### 1. Ownership does not survive a fresh GUI attachment

In [wezterm_domains.lua](evidence/wezterm-devservers-anr-v1/wezterm_domains.lua.txt),
`is_bar()` at line 17 recognizes a pane only through:

```lua
pane:get_user_vars().DEVVM_MENU == '1'
or wezterm.GLOBAL['domain_menu_role_' .. pane:pane_id()] == true
```

The Bash menu emits `DEVVM_MENU` once, at startup. In the restart reproduction,
existing menus retain the `dotfiles-domain-menu` title, but the fresh GUI reports:

```text
UNRECOGNIZED_MENU id=2 var=nil role=nil
UNRECOGNIZED_MENU id=4 var=nil role=nil
```

These are client-side pane IDs. Native mux IDs in CLI snapshots are a different
namespace and must not be equated with them.

The startup user variable was not restored into those freshly attached client
panes. The GUI-local ownership table is also empty for them. Consequently:

1. `content_pane()` includes an old menu among its content candidates.
2. `update()` at lines 282–284 finds no recognized menu.
3. Lines 308–314 create a new same-domain bottom pane.
4. The old menu continues running on the remote mux.

The restart fixture went from one menu per tab to two per tab. The same result
occurred when a second GUI attached while the first remained alive. This disproves
the hypothesis that duplication requires a crashed or dead Bash menu process.
It also shows that avoiding simultaneous clients alone is insufficient.

The native cleanup helper already identifies menus by their reserved title,
whereas GUI ownership does not. `stop_bars()` and `clean_closed_tabs()` use the GUI
predicate and can miss inherited menus. Cleanup also handles menu-only tabs,
rather than deduplicating every menu in a content tab.

### 2. A terminal split is being maintained as window chrome

The menu is a full terminal pane, not a native footer. `size = 1` specifies one
cell when splitting; it does not establish an immutable one-row constraint for
all later layout changes.

`update()` at lines 291–301 requires both the split allocation and viewport to be
exactly one row and the full tab width. A mismatch sends `DEVVM_MENU_EXIT` and
returns. Recreation waits for another update to observe removal. This involves
remote process exit, pane removal, another split, terminal resize, startup OSC
delivery, and redraw. Repeated layout changes therefore affect real terminal
sessions rather than just repainting a strip.

There is no explicit per-tab creation/retirement transaction in this path. There
are several entry points: `update-status`, `window-resized`, menu startup alerts,
and a one-second poll. The shared poll owner limits obsolete pollers, but does
not make those different entry points a single lifecycle transaction. Whether
overlapping creation contributes additional duplicates remains unproven; the
missing ownership markers already suffice to reproduce duplication.

Live layout captured through the native remote mux:

| Tab | Pane | Role | Rows | Top row |
|---|---:|---|---:|---:|
| 8 | 5 | Claude/tmux content | 40 | 0 |
| 8 | 10 | Menu | 16 | 41 |
| 8 | 17 | Menu | 1 | 58 |
| 8 | 18 | Menu | 1 | 60 |
| 8 | 19 | Menu | 39 | 62 |
| 10 | 11 | Shell content | 46 | 0 |
| 10 | 12 | Menu | 54 | 47 |

All panes were 427 columns wide. The first tab's menus consume 57 content rows,
plus split separators. The five menu processes were alive, waiting for input,
and reporting 0.0% CPU in the process snapshot. The oversized panes were not
merely a visual overlay or a spinning Bash loop. A second server, `devvm66816`,
also had an oversized nine-row menu, so the geometry defect is not unique to
`devvm58157`.

### 3. Recovery can fail and stall progress

The live GUI log records:

```text
12:19:27.005 while processing window-resized event:
Input/output error (os error 5)
[C]: in method 'send_text'
wezterm_domains.lua:300: in upvalue 'update'
wezterm_domains.lua:406: in function <...:398>
```

This is the invalid-footer retirement branch. Its `send_text()` is not protected
in the resize handler, so failure aborts that event's recovery. The poll catches
some errors around `update()`, but does not turn an unsuccessful retirement into
a completed repair. Other captured errors involve stale pane/window references
in the shared theme handler and domain update path; those are additional lifecycle
weaknesses, not proof of a renderer crash.

In the private damaged-footer reproduction, increasing a menu from one to 16
rows gave these results:

| Transport | Observation |
|---|---|
| No added delay | Old menu replaced by a one-row menu by the next one-second sample |
| Delayed proxy | Expanded menu remained through sample 12; absent at sample 13; replacement still absent at sample 17 |

The delayed fixture's native mux continued answering layout queries in roughly
10–15 ms. This establishes impaired client-side maintenance without a stalled
native mux. It does not measure keyboard latency or prove that the macOS GUI
thread was blocked throughout that interval.

### 4. Direct `ek c -W` still encounters the persisted damage

Enkaku's persistent WezTerm mode connects to the remote mux. Changing the attach
command does not remove menus already stored in that mux's tab graph. The direct
path therefore inherits the enlarged and duplicate panes and the reduced content
viewport.

The domain module refuses unmanaged/mixed windows through `window_host()`, so an
Enkaku-generated domain name outside `by_domain` need not create new menus. The
reported direct attach path was not replayed against the live session, and its
exact generated domain/configuration was not captured. Claiming that every
`ek c -W` invocation actively runs the footer manager would go beyond the evidence.

### 5. Drawing is coupled to the problem, but paint alone was not established

[domain-menu.sh](evidence/wezterm-devservers-anr-v1/domain-menu.sh.txt) clears its
viewport and scrollback on a draw, then prints the formatted frame. The Lua side
caches frame text and width, so an unchanged menu should not be sent at every
poll. Plain attach, including delayed attach, remained stable in the isolated
fixture. The inspected menu processes were idle.

The confirmed expensive/error-prone operation is lifecycle and geometry repair:
remote pane creation/removal and resulting terminal layout changes. Large
scrollback and a live TUI may increase the repaint/reflow cost of those changes,
but that contribution was not profiled. Blaming ANSI colors, the connection dot,
the fancy tab font, or unconditional footer repaint would be unsupported.

### 6. Focus can land on a menu instead of the shell

A second restart run recorded the native active pane changing from shell pane 0
to menu pane 5 at samples 11 and 12, before returning to the shell at sample 13.
No test input was sent during that run. This establishes a transient focus problem
in the fixture, though native active-pane state alone does not prove where the
user's Mac keyboard input went during the reported incident.

The menu disables echo and ignores input that does not match its protocol.
Keyboard input delivered there therefore produces no normal shell response.
Missing ownership also undermines the content-focus and split/navigation guards,
which use the same `is_bar()` predicate. This is a concrete way for a remote
session to appear unresponsive while the GUI process and mux remain alive;
it should be distinguished from a renderer ANR.

## Split bars versus one unified native bar

The comparison preserves per-domain workspaces and domain-scoped tabs in both
options. A unified bar does not require reverting to the older mixed-domain MVP.

```text
Split layout:
  [ tab 1 ][ tab 2 ][ + ]
  terminal content
  [ Local ][ devvm5324 ][ devvm58157 ][ devvm66816 ]  <- remote terminal pane

Unified layout, at either top or bottom:
  [ current domain ]  [ tab 1 ][ tab 2 ][ + ]  [ compact domain status ]
  terminal content
```

| Concern | Top tabs plus terminal footer | Unified native tab/status bar |
|---|---|---|
| Visual hierarchy | Domains and tabs have separate, generous regions | Domains and tabs share horizontal space; clearer compact layout is needed |
| Terminal space | At least a menu row and separator; corruption can consume most rows | No extra terminal split or separator |
| Remote latency | Draw, pick, retirement, and creation traverse the remote PTY/mux | Bar display and opening a picker can be local; actual connection still depends on the remote host |
| Reattach | Requires persistent ownership and cleanup of inherited processes | Native chrome belongs to the GUI, so no remote footer is inherited |
| Multiple clients | Clients can add independent menus to the same persistent tab | Each GUI displays its own chrome without adding remote panes |
| Resize | Must maintain split geometry and protect content from footer repair | Native bar follows window geometry without creating/removing remote terminals |
| Focus and shortcuts | Footer is focusable; split/navigation/tab creation need guards | No footer pane to receive terminal focus or accidental splits |
| Pointer selection | Existing OSC hyperlinks support individual domain clicks | Native status text does not establish equivalent individual click targets; use a supported picker trigger |
| Scaling to many hosts/tabs | Separate row has more room, but current clipping can hide later hosts | Show current host plus compact status; put the full host list in a picker |
| Maintenance | Bash protocol, ownership, cache, polling, geometry, cleanup, and request relay | Native status formatting and picker, plus connection/workspace orchestration |
| Migration | Repair ownership and transaction handling; clean existing menus | Clean existing owned menus and replace the menu-based request relay; retain live content processes |

**Recommended shape:** one native bar, preferably at the bottom to retain the
domain/status location, with the selected domain at the left, normal tabs in the
middle, and bounded status at the right. Keep Cmd+Opt+0–9 and Cmd+Shift+O. A
documented `new-tab-button-click` handler can open the domain picker on right-click
while retaining ordinary left-click tab creation.

WezTerm documents one tab bar, movable with `tab_bar_at_bottom`, with
`set_left_status()` and `set_right_status()` areas. Left status is not implicitly
clipped; right status is clipped to the available space. Any unified design must
budget host/status text explicitly. The current terminal-pane hyperlink handler
does not establish clickable native status segments. Permanently visible,
individually clickable host pills would need separate API verification or a
different UI compromise; they should not be promised as a trivial migration.

Keeping split bars is defensible if separate rows and individual host clicks are
essential. It would require robust ownership across restart, recognition and
deduplication of inherited menus, one lifecycle operation per tab, resilient
retirement, and testing with multiple clients and delayed transport. That is
substantially more terminal/mux machinery for a visual preference.

Neither choice automatically repairs the five menus already on `devvm58157`.
A later implementation must explicitly remove only owned menu processes,
preserve content/process identity, and replace request delivery that currently
relies on the menu. No such cleanup or migration was performed here.

## Verification and remaining diagnosis

Observed reproductions:

- Plain attach: stable with and without added transport delay.
- Scheduled window resize: no duplicates in the inspected samples.
- Forced oversized menu: immediate local recovery; delayed/incomplete recovery
  under transport stress.
- Second concurrent GUI: menus doubled from two to four across two tabs.
- GUI replacement after termination: menus doubled, with inherited title present
  and both ownership markers absent.
- Two concurrent GUIs without menu mode: two content panes remained; no menus were
  created.

The handoff's tests exercise synthetic Mac mux servers and passive fixtures.
Their earlier passing results do not contradict these failures. The restart
path here attaches directly to the existing domain, rather than going through
the full `devvm` orchestration. `devvm --group` filters menus from its grouping
candidates, but does not itself remove those menus. GUI-side stopping still
depends on the deficient ownership predicate. Direct attachment can bypass even
that stopping attempt.

To settle the remaining ANR question, capture the actual hung process stack and
correlate it with client/native pane snapshots and footer lifecycle events. The
exact next stack command is `sample <hung-wezterm-gui-pid> 10 -file
/tmp/wezterm-hung-stack.txt`; the attempted live sample was denied by macOS, so
an authorized OS sampling path is needed. Inspect whether the main thread is
waiting on a mux/Lua operation, doing terminal reflow, or blocked in rendering.
Then replay direct Enkaku attachment in a private configuration with already
persisted menus and realistic output/scrollback. Do not equate a responsive mux
CLI or a living GUI process with a responsive UI.

Public API references checked during this investigation:

- [Tab bar placement](https://wezterm.org/config/lua/config/tab_bar_at_bottom.html)
- [Left status](https://wezterm.org/config/lua/window/set_left_status.html)
- [Right status](https://wezterm.org/config/lua/window/set_right_status.html)
- [New-tab button events](https://wezterm.org/config/lua/window-events/new-tab-button-click.html)
- [Pane split size and top-level behavior](https://wezterm.org/config/lua/pane/split.html)
