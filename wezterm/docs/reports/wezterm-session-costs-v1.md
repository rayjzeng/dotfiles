# WezTerm work: session costs and planning lessons

Date: 2026-11-23

This report estimates what the WezTerm work cost in Claude Code and Codex sessions from
2026-11-17 to 2026-11-23, priced in full at public API rates. It also records where
better planning would have saved money.

**Estimated total: about $103.50**, made up of $51.86 for Claude (Opus 5.5) and
$51.65 for Codex. That covers 7 Claude sessions, 3 Claude subagents and 21 Codex
sessions.

## Method

- **Claude:** usage comes from `~/.claude/projects/*/<session>.jsonl` and
  `<session>/subagents/*.jsonl`. Assistant messages are deduplicated by message id.
  Rates are Opus 5.5:

  | Token type | Price per million |
  |---|---|
  | Input | $4 |
  | Output | $20 |
  | 1-hour cache write (main sessions) | $8 |
  | 5-minute cache write (subagents) | $5 |
  | Cache read | $0.20 |

- **Codex:** usage comes from the `token_count` events in
  `~/.codex/sessions/2026/11/*/*.jsonl`, priced request by request with
  `gpt-6.1-sol` Standard rates. Requests with more than 272K input tokens are billed
  at Long rates; that cutoff is an assumption, because the pricing page doesn't state
  it.

  | Token type | Short | Long |
  |---|---|---|
  | Input | $2.00 | $4.00 |
  | Cached input | $0.10 | $0.20 |
  | Output | $10.00 | $15.00 |

  `gpt-5.6-sol` and `gpt-6.2-sol` are priced at the same rates.
- **Sessions included:** those that worked on WezTerm, the devserver tooling or
  PRs #3 and #5. The tmux/PR #3 session is counted in full even though it was partly
  tmux work, and so is the `hop` prototype session, which started as a devserver
  question.
- **Sessions left out:** a Nov 11 zkbd session, a hop handoff and a session about
  an unrelated link, which only mentioned WezTerm in passing.
- **Limit:** anything older than the retained session logs is missing, so this
  estimate is a floor.

## Sessions

| Date (UTC) | Tool | What was built | Cost |
|---|---|---|---|
| Nov 17–18 | Codex | **Original devserver build:** adapted an existing WezTerm devserver config bundle (unified devserver window), removed the title bar, thicker tab bar, built a per-domain bottom footer bar, then dropped it for a single bottom bar | **$20.29** (incl. 2 subagents) |
| Nov 17 | Claude | Closing a window without killing the mux; added the Cmd+Shift+W detach binding | $0.46 |
| Nov 18 | Codex | Recovered a hidden local session; merged tabs from the devservers workspace back into the default one | $0.36 |
| Nov 18–19 | Codex | **ANR fix plus redesign:** crash/ANR when attaching a devserver, switch to powerline bottom tabs colored by domain, README user guide, remote split/resize rendering fixes | **$21.96** (incl. 2 subagents) |
| Nov 18 | Codex | Compared the setup with the bundle it was based on; filed a GitHub issue about moving to plugins | $1.12 |
| Nov 18–19 | Codex | Link-click debugging: Cmd-click fix, hyperlink regex cases, plan for the remaining regex fixes | $2.47 (incl. 1 subagent) |
| Nov 19 | Claude | Printed link samples to test clicking in the Claude TUI | $0.30 |
| Nov 19 | Claude | **Lag and crash marathon:** runaway repaint flood guard, oversized-tab crash, resize guard, window-close race, reconnect debugging, rebase, zsh submodule check | **$21.37** |
| Nov 19 | Claude | Reconnect bug in the Cmd+Shift+O picker (same incident as the marathon) | $0.83 |
| Nov 19–20 | Claude | Tmux font fix, then shepherding PR #3: reordering commits for push, 3 rounds of review feedback, a context compaction | $8.95 |
| Nov 20 | Codex | PR #3 reviews: 3 with `gpt-6.1-sol` + 5 with `gpt-5.6-sol` | $4.19 |
| Nov 20–21 | Claude | Question about devserver connections that need two-factor auth, which turned into the `hop` standalone connection-tool prototype (WezTerm-adjacent) | $3.01 |
| Nov 20–23 | Claude | Tab grouping, cross-window tab picker, tab move keys, move-to-any-position, PR #5, Codex review fix loop, this cost analysis | **$16.92** ($11.93 main + $4.99 for 3 subagents) |
| Nov 23 | Codex | PR #5 reviews, 3 rounds | $1.27 |
| | | **Total** | **≈ $103.50** |

## Where better planning would have saved money

1. **Two marathon Codex sessions are 42% of the total ($42).** Each made about 180
   requests, and 77–98 of those carried more than 272K tokens of context. At Long-tier
   rates that added about **$15.70** over keeping each request under 272K
   ($19.44 → $12.37 and $21.39 → $12.79). Starting a fresh session from a handoff doc
   for each phase (build, ANR fix, redesign) keeps requests in the cheaper tier.
2. **The bottom bar was designed three times.** First a per-domain footer, then a
   single bottom bar when the footer wouldn't stay drawn, then powerline tabs colored
   by domain. A short design spike (mock the layout, check WezTerm's limits) before
   building would have skipped the footer entirely.
3. **The Claude marathon ($21.37) handled 8+ separate tasks in one context.** It made
   222 calls over 7 hours, and $11.74 of its cost is re-reading context from cache.
   Separate sessions per incident would roughly halve that.
4. **The same incident was investigated twice in parallel.** The picker-reconnect
   session ($0.83) ran while the marathon was debugging the same mux crash.
5. **Review rounds found bugs that design thinking would have caught first.** PR #3
   took 8 Codex review rounds ($4.19), plus Claude turns spent assessing the feedback,
   which contributed to a context compaction. PR #5 had 5 race and state bugs: tabs
   arriving mid-move, picker positions going stale, focus captured too late. A design
   step listing what can change concurrently would have caught most of them before
   review. Running a review before opening the PR also keeps fix rounds off the PR.
6. **The tab-moving UX was specified piecemeal.** "Move to the end of window N" was
   built, then rebuilt as "move to any position" by a third agent ($1.51). Settling
   the full ask ("manage tabs across windows freely") up front would have meant one
   agent run instead of two.
7. **Process friction:**
   - Live GUI tests take window focus, so the agents had to be paused and resumed;
     ask before running them.
   - New shortcuts seemed broken only because the branch wasn't checked out; a plan
     with a "deploy and verify" step avoids that.
   - A `/goal` whose wording required Codex to post its own comments needed a policy
     acceptance, which looped the stop hook (about $0.40 of overhead).
8. **All Claude work ran on Opus 5.5,** even well-specified implementation work.
   Implementation agents with tight specs (the 3 here cost $4.99) could run on
   Sonnet 5.5 for about half the price.
