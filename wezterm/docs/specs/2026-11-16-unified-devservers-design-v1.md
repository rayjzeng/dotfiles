# Unified WezTerm Devservers

**Invariant format:** tenx/v1

**Spec ID:** dotfiles-wezterm-devservers

## Intent

Group persistent devserver sessions in one WezTerm window while keeping the
personal configuration usable without work tools. Keep the existing font,
navigation, search, shell integration, and hidden system title bar.

## Approaches

1. Import the archive wholesale: includes connection handling, but also replaces
   personal styling, installs a global wezterm-gui wrapper, and has fragile window
   selection. Rejected.
2. Install an optional work package: reuse the shared configuration and add named
   remote domains, a host picker, and a dedicated devvm command. Recommended for
   work machines.
3. Run separate work and personal GUI processes: useful for concurrent profiles
   on one machine, but requires explicit config and CLI socket routing. Deferred
   unless the user requests concurrent profiles.

## Design

The user selected one native bottom Powerline-style tab bar on 2026-11-18 after
live footer corruption. All local and remote tabs belong to the unified main
window, with domain/server labels and colors. Active tabs are filled and bold;
Cmd+Shift+T opens the tab navigator for overflow. A per-domain selector is deferred.

The optional work package registers paired named mux domains and keeps connection,
local request transport, and open/detach/merge orchestration. Moves preserve
processes and scrollback but may flatten splits into tabs. Local anchor tabs keep
main and detached windows alive. The shared renderer uses PaneInformation
snapshots; it performs no pane spawning, child processes, or network operations.

The terminal-menu program and maintenance module are removed. GUI attachment and
upgrade reload retire owned menus by their reserved title; the helper cleans
native remote menus before attachment. Stale prototype flags are ignored, and
old scheduled pollers are invalidated on reload. Content processes remain alive.

## Requirements

### REQ-001: Native Powerline tabs without the system title bar

**Applies when:** The shared WezTerm configuration is active.

**Obligation:** One native Powerline-style tab bar MUST sit at the bottom while
the system title bar remains hidden.

**Acceptance criteria:** Use the current mono font, classic native tab rendering,
and bounded Powerline segments; window_decorations remains RESIZE.

**Verification needs:** Load the config with the installed WezTerm and inspect
the rendered tab bar when a desktop screenshot is available.

### REQ-002: Optional work functionality

**Applies when:** The wezterm-work package is not installed.

**Obligation:** The shared configuration MUST work without Enkaku and MUST NOT
register work shortcuts or work hyperlink rules.

**Acceptance criteria:** Personal config loads with work tools absent; work
scripts and completions are installed only by the work package.

**Verification needs:** Config evaluation in separate personal and work targets;
Stow previews and source inspection.

### REQ-003: Explicit unified view

**Applies when:** devvm is invoked with the work package installed.

**Obligation:** Configured devserver sessions MUST be gathered into one main
window in the devservers workspace.

**Acceptance criteria:** Repeated calls reuse the main window and existing
sessions; host labels identify remote tabs.

**Verification needs:** Runtime session-identity and window-membership checks.

### REQ-004: Local session behavior

**Applies when:** Normal WezTerm startup or a local pane is active.

**Obligation:** Startup, tabs, and splits MUST remain local unless a remote
domain is explicitly selected.

**Acceptance criteria:** Plain startup creates a local shell; Cmd+T and splits
follow the current pane's domain.

**Verification needs:** Config evaluation and runtime pane-domain checks.

### REQ-005: Remote persistence

**Applies when:** The GUI or connection closes while the remote mux stays alive.

**Obligation:** Remote sessions MUST remain attachable through Enkaku.

**Acceptance criteria:** Reattachment retains remote process identity; merging
does not kill existing panes.

**Verification needs:** Isolated mux integration test; inspect connection
handling against the installed Enkaku contract.

### REQ-006: Detach and merge

**Applies when:** A connected host is detached or merged.

**Obligation:** The host's panes MUST move between the main window and a separate
window without restarting their processes.

**Acceptance criteria:** Explicit detach/merge commands move only matching panes;
split panes become individual tabs. Main-window identity remains stable.

**Verification needs:** Runtime moves with multiple hosts and unequal tab counts.

### REQ-007: Machine-local hosts and useful errors

**Applies when:** A host is selected, added, or unavailable.

**Obligation:** Host resolution MUST use machine-local configuration and reject
ambiguous selections; unavailable hosts MUST report errors independently.

**Acceptance criteria:** Aliases and unique hostname fragments select one host;
ambiguous fragments fail; one failed connection does not discard healthy sessions.

**Verification needs:** CLI tests for list parsing, ambiguity, and failures.

### REQ-008: All domains share the tab bar

**Applies when:** The work package is installed.

**Obligation:** The unified window MUST expose local and configured server tabs
without a per-domain workspace selector.

**Acceptance criteria:** Tabs identify their domain/server through labels and
colors; alternate domain IDs for a server share its color. The tab navigator
exposes tabs that do not fit visibly in the bar.

**Verification needs:** Config-renderer checks and real mux window-membership
checks with multiple hosts and live process markers.

### REQ-009: Terminal content owns its viewport

**Applies when:** The shared configuration is active.

**Obligation:** Tab rendering MUST NOT spawn terminal chrome or resize content.

**Acceptance criteria:** The renderer consumes snapshots. No footer program,
menu request relay, or maintenance/resize poller is loaded or started.

**Verification needs:** Direct/repeated GUI attachment against private muxes
retains the same native content panes and creates no menu processes.

### REQ-010: Legacy menu migration

**Applies when:** Persistent menus from the previous prototype exist.

**Obligation:** Owned menus MUST be retired without ending content sessions.

**Acceptance criteria:** Recognize the reserved title across fresh GUI attachment,
clean duplicate and oversized menus, and retry offline native cleanup at the
next helper connection. Ignore stale prototype flags.

**Verification needs:** Seed duplicate native menu panes before attachment;
check their removal and retained content process markers.

## Non-goals

A per-domain selector, permanent detached-window placement, split geometry after
moves, local-session persistence, concurrent personal/work GUI profile isolation,
remote metrics polling, and automatic collection of unconfigured servers.

## State

The user authorized this native bottom bar revision on 2026-11-18. Leave the
implementation uncommitted for live iteration. This supersedes the 2026-11-17
terminal-pane domain-menu prototype.
