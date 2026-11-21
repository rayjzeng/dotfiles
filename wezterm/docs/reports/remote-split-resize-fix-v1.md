# Remote split and resize fix

2026-11-18 · Fixed and applied to the two connected servers. Changes are uncommitted.

## Cause

The merge connected to a server and then moved its panes into new tabs. WezTerm
kept the old server tab numbers inside those panes. Resize messages therefore
used the wrong tab, and extra hidden copies kept different layout measurements.

The reproduction showed a 140-column, 35-row tab dropping to 80 columns and
24 rows after a split, while the window stayed the same size. This explains
uneven splits, clipped TUI output, and unreliable redraws during mouse resizing.

## What I tried

- Compared the visible layout with the server and hidden tab copies.
- Reproduced the size reset with private servers and the actual split actions.
- Tried the newer split action; changing the shortcut alone did not fix it.
- Checked the implementation matching the installed WezTerm build and tested
  connecting prepared server tabs directly into the main window.

## Final solution

Prepare the server's tabs **before connecting**, then attach them directly to
the destination window. This keeps the correct tab numbers and removes the
competing copies. No resize repair loop or extra footer was added.

Existing splits in the grouped server window are preserved. Initial gathering
from several server windows can still flatten panes moved from other windows.

## Verification

Cmd+D and Cmd+Shift+D produce even splits. Shrinking and enlarging the window
keeps every pane inside its bounds, with matching terminal dimensions. Reconnect,
detach/merge, and recovery from an extra connection alias pass the GUI tests.

Both live server shells retained their original process IDs. A real-connection
check created the configured-shell split in **0.19 seconds**, with first output
by **0.77 seconds**. These measure server creation/output, not physical keyboard
input. All five repository checks pass.

The video attachment arrived as a file icon; resizing was verified through the
same GUI size-change path and the supplied screenshots.
