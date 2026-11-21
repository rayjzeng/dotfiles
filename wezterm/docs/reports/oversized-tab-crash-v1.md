# GUI crash when attaching an oversized server tab

2026-11-19 · Diagnosed live; layout repaired by hand; fit guard added.

## What happened

At 14:46:00, attaching `devvm58157` from the Cmd+Shift+O picker aborted WezTerm:

```text
WARN  cannot resize window to match RowsAndCols { rows: 101, cols: 1496 } because window_state is MAXIMIZED
ERROR panic at glium-0.35.0/src/draw_parameters/mod.rs:740 - Viewport dimensions are too large
      … TermWindow::paint_impl → WindowView::draw_rect
ERROR panic in a function that cannot unwind → abort (SIGABRT)
```

The server stored tab 12 at 1,496 columns: panes of 480, 801, and 213 columns
side by side. The maximized window on the 2× T32p held 427 columns, and
1,496 × 14 px exceeds the usual 16,384 px GPU viewport limit.

## Cause

Read against build `05343b387085842b434d267f91b6b0ec157e4331`:

- `TermWindow::new_window` sizes a new window from its tab's stored size.
- The server's `Resize` handler resizes one pane and then rebuilds the tab's size
  from its panes (`rebuild_splits_sizes_from_contained_panes`), so a single pane
  resize carrying a stale size widens the whole tab. Pane 27's 801 columns
  matched the window width logged at 14:44:43.
- A panic inside the macOS draw callback cannot unwind, so the renderer error
  aborts the whole process.

**Not reproduced:** a private GUI attached to a genuinely 1,496-column tab did
not crash, because macOS clamped the window and the GUI shrank the tab. The live
crash also needed the maximized-window rescale path shown in the warning.

## Repair and guard

The live layout was shrunk to 427 × 99 by sending the same `Resize` PDUs a GUI
sends. The shells and the tmux client kept their processes, and the reattach
succeeded.

`devvm --group`, which runs on every attach, now calls `devvm-guard fit`. It
shrinks any server tab larger than the destination window, or the largest open
window while the destination has none yet. Pane spans are scaled so shared split
borders stay aligned. Zoomed tabs are unzoomed first, because the server skips
rebuilding a zoomed tab. If fitting fails, the attach fails too. Each fit is
logged in `trips.log`.

## Verification

`devvm-guard.test` covers the live layout and nested splits in `fit_plan`, then
inflates split and zoomed tabs on a private mux server. It checks that they fit,
that split borders stay aligned, that pane IDs are unchanged, and that a second
run changes nothing. The integration test inflates a server tab before a real
relocation and asserts the fit was recorded. A GUI attaching afterwards would
shrink the tab anyway, so only that record proves the fit happened before attach.
