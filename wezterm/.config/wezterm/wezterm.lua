local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()
local work
local work_config_dir = os.getenv('DEVVM_CONFIG_DIR') or wezterm.home_dir .. '/.config/wezterm'
wezterm.add_to_config_reload_watch_list(work_config_dir .. '/wezterm_work.lua')
local work_file = io.open(work_config_dir .. '/wezterm_work.lua', 'r')
if work_file then
  work_file:close()
  work = dofile(work_config_dir .. '/wezterm_work.lua')
end

config.color_scheme = 'Dracula (Official)'

config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
config.font_size = 12.0

config.scrollback_lines = 20000

-- Window settings
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.96
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 40
config.window_frame = {
  active_titlebar_bg = '#282a36',
  inactive_titlebar_bg = '#282a36',
}
config.enable_scroll_bar = true

config.hyperlink_rules = {
  {
    regex = '\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b',
    format = '$0',
  },
}

-- TUIs can open links on press; keep both halves of Command-click in the GUI.
config.mouse_bindings = {}
for _, mouse_reporting in ipairs { false, true } do
  for _, alt_screen in ipairs { false, true } do
    table.insert(config.mouse_bindings, {
      event = { Down = { streak = 1, button = 'Left' } }, mods = 'CMD',
      mouse_reporting = mouse_reporting, alt_screen = alt_screen, action = act.Nop,
    })
    table.insert(config.mouse_bindings, {
      event = { Up = { streak = 1, button = 'Left' } }, mods = 'CMD',
      mouse_reporting = mouse_reporting, alt_screen = alt_screen, action = act.OpenLinkAtMouseCursor,
    })
  end
end

-- Handlers that run on every repaint or status tick turn one persistent error into
-- a traceback per frame, flooding the log and slowing the GUI. Log the first
-- failure, then disable the handler (falling back to defaults) if it keeps failing;
-- a config reload re-enables it.
local GUARD_MAX_FAILURES, GUARD_WINDOW_SECONDS = 50, 10
local function guarded(name, handler)
  local failures, window_start, disabled = 0, 0, false
  return function(...)
    if disabled then return nil end
    local ok, result = pcall(handler, ...)
    if ok then return result end
    local now = os.time()
    if now - window_start > GUARD_WINDOW_SECONDS then failures, window_start = 0, now end
    failures = failures + 1
    if failures == 1 then
      wezterm.log_error(name .. ' failed: ' .. tostring(result))
    elseif failures >= GUARD_MAX_FAILURES then
      disabled = true
      wezterm.log_error(name .. ' disabled after ' .. failures .. ' failures in '
        .. GUARD_WINDOW_SECONDS .. 's; reload the config to re-enable')
    end
    return nil
  end
end

-- Switch color scheme for remote sessions (Enkaku mux, SSH, etc.)
local REMOTE_COLOR_SCHEME = 'Catppuccin Mocha'

local function pane_is_remote(pane)
  -- Enkaku/SSH mux panes report the mux domain name. Exclude WezTerm's internal
  -- overlay domain (launcher, connection progress): it appears for a beat before
  -- the mux pane attaches, and theming it early suppresses the post-attach
  -- repaint, leaving the connected pane on the base scheme until a manual reload.
  local domain = pane:get_domain_name()
  if domain ~= 'local' and domain ~= 'TermWizTerminalDomain' then
    return true
  end
  if pane:get_user_vars().IS_REMOTE == '1' then
    return true
  end
  local proc = pane:get_foreground_process_name()
  return proc ~= nil and proc:find('ssh') ~= nil
end

local function apply_remote_scheme(window, pane)
  local live, want = pcall(function()
    if work and work.is_managed_domain(pane:get_domain_name()) then return nil end
    return pane_is_remote(pane) and REMOTE_COLOR_SCHEME or nil
  end)
  if not live then return end
  local ok, overrides = pcall(function() return window:get_config_overrides() or {} end)
  if not ok then return end
  if overrides.color_scheme == want then
    return
  end
  overrides.color_scheme = want
  window:set_config_overrides(overrides)
end

-- update-status fires on activity/focus but not reliably while a pane sits idle
-- at the prompt, so on its own it leaves a stale scheme after a remote session
-- exits. The shell re-emits the IS_REMOTE user var on every prompt (precmd), and
-- user-var-changed fires immediately on that — reverting the moment you land back
-- at a local prompt. update-status still covers mid-session, activity-driven cases.
wezterm.on('update-status', guarded('update-status', function(window, pane)
  apply_remote_scheme(window, pane)
end))

wezterm.on('user-var-changed', function(window, pane, name, value)
  -- A background pane's prompt must not repaint the window against update-status,
  -- which follows the active pane; the two would flip the scheme on every prompt.
  if name == 'IS_REMOTE' and pane:pane_id() == window:active_pane():pane_id() then
    apply_remote_scheme(window, pane)
  end
end)

local function basename(path)
  if not path or #path == 0 then
    return nil
  end

  local normalized = path:gsub('[\\/]$', '')
  if #normalized == 0 then
    return nil
  end

  return normalized:match('([^/\\]+)$') or normalized
end

local function cwd_label(cwd)
  if not cwd then
    return nil
  end

  if type(cwd) == 'table' and cwd.file_path then
    return basename(cwd.file_path)
  end

  if type(cwd) == 'string' then
    return basename(cwd)
  end

  return nil
end

local function resolve_tab_title(tab)
  local explicit = tab.tab_title
  if explicit and #explicit > 0 then
    return explicit
  end

  local pane = tab.active_pane
  if not pane then
    return 'shell'
  end

  if pane.title and #pane.title > 0 then
    return pane.title
  end

  local cwd = cwd_label(pane.current_working_dir)
  if cwd and #cwd > 0 then
    return cwd
  end

  local proc = basename(pane.foreground_process_name)
  if proc and #proc > 0 then
    return proc
  end

  return 'shell'
end

local tab_background = '#282a36'
local domain_colors = { '#8be9fd', '#bd93f9', '#50fa7b', '#ffb86c', '#ff79c6', '#82aaff', '#f1fa8c' }

local function domain_color(key, index)
  if key == 'local' then return '#6272a4' end
  if index then return domain_colors[(index - 1) % #domain_colors + 1] end
  local hash = 0
  for i = 1, #key do hash = (hash * 33 + key:byte(i)) % 2147483647 end
  return domain_colors[hash % #domain_colors + 1]
end

-- Returns the tab's display label, grouping key, and optional color index.
local function tab_domain(tab)
  if work then return work.tab_domain(tab) end
  local domain = tab.active_pane and tab.active_pane.domain_name or 'local'
  return domain == 'local' and 'Local' or domain, domain
end

local function mux_tab_domain(tab)
  return tab_domain { active_pane = { domain_name = tab:active_pane():get_domain_name() } }
end

wezterm.on('format-tab-title', guarded('format-tab-title', function(tab, tabs, panes, _, hover, max_width)
  local label, key, index = tab_domain(tab)
  local color = domain_color(key, index)
  local background = (tab.is_active or hover) and color or tab_background
  local foreground = (tab.is_active or hover) and tab_background or color
  local title = tostring((tab.tab_index or 0) + 1) .. ' ' .. label .. ' · ' .. resolve_tab_title(tab)
  if max_width < 4 then
    return { { Foreground = { Color = foreground } }, { Background = { Color = background } },
      { Text = wezterm.truncate_right(title, math.max(max_width, 0)) } }
  end
  title = wezterm.truncate_right(title, max_width - 4)
  return {
    { Background = { Color = background } }, { Foreground = { Color = tab_background } }, { Text = utf8.char(0xe0b0) },
    { Foreground = { Color = foreground } }, { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = tab_background } }, { Foreground = { Color = color } }, { Text = utf8.char(0xe0b0) },
  }
end))

config.colors = { tab_bar = {
  background = tab_background,
  new_tab = { bg_color = tab_background, fg_color = '#f8f8f2' },
  new_tab_hover = { bg_color = '#6272a4', fg_color = '#f8f8f2' },
} }

local function index_of(list, value)
  for i, item in ipairs(list) do
    if item == value then return i end
  end
end

-- Where a tab with `key` belongs among `keys`, as a 0-based insert position: after
-- the first same-domain run that contains or follows the focused tab, wrapping to
-- the first run, so a domain split across groups grows the group you're working in.
local function grouped_insert_position(keys, focused, key)
  local first_run_end
  for i = 1, #keys do
    if keys[i] == key and keys[i + 1] ~= key then
      if i >= focused then return i end
      first_run_end = first_run_end or i
    end
  end
  return first_run_end or #keys
end

-- WezTerm has no tab-created event, so each window remembers the tabs it has
-- seen; anything new is moved into its domain group relative to the tab that was
-- focused before it appeared.
local seen_tabs = {}
-- Panes the user moved into another window on purpose. Grouping takes their tab as
-- seen where it lands instead of moving it. They are registered before the move,
-- because run_child_process yields and status ticks can run mid-move.
local placed_panes = {}

-- A tab the user positions by hand counts as placed, even if no status tick has
-- seen it yet; otherwise grouping would pull it back on the next tick.
local function mark_tab_placed(mux_window, tab_id)
  local seen = seen_tabs[mux_window:window_id()]
  if seen then seen.ids[tab_id] = true end
end

local function group_new_tabs(window, pane)
  local mux_window = window:mux_window()
  local order, ids, keys, unseen = {}, {}, {}, {}
  local previous = seen_tabs[mux_window:window_id()]
  for _, tab in ipairs(mux_window:tabs()) do
    local id = tab:tab_id()
    table.insert(order, id)
    ids[id] = true
    keys[id] = select(2, mux_tab_domain(tab))
    if previous and not previous.ids[id] then
      local pane_id = tab:active_pane():pane_id()
      if placed_panes[pane_id] then placed_panes[pane_id] = nil else table.insert(unseen, id) end
    end
  end
  local active = mux_window:active_tab():tab_id()
  seen_tabs[mux_window:window_id()] = { ids = ids, active = active }
  if #unseen == 0 then return end

  local desired = {}
  for _, id in ipairs(order) do
    if not index_of(unseen, id) then table.insert(desired, id) end
  end
  for _, id in ipairs(unseen) do
    local desired_keys = {}
    for i, existing in ipairs(desired) do desired_keys[i] = keys[existing] end
    local focused = index_of(desired, previous.active) or #desired
    table.insert(desired, grouped_insert_position(desired_keys, focused, keys[id]) + 1, id)
  end

  -- MoveTab only acts on the active tab; queued actions run in order.
  local current, moved = { table.unpack(order) }, false
  for target, id in ipairs(desired) do
    local from = index_of(current, id)
    if from ~= target then
      window:perform_action(act.ActivateTab(from - 1), pane)
      window:perform_action(act.MoveTab(target - 1), pane)
      table.insert(current, target, table.remove(current, from))
      moved = true
    end
  end
  if moved then window:perform_action(act.ActivateTab(index_of(desired, active) - 1), pane) end
end

wezterm.on('update-status', guarded('group-new-tabs', group_new_tabs))

-- Spawning through the mux returns the tab synchronously, so it is grouped before
-- the next repaint instead of jumping on the following status tick.
local function spawn_grouped_tab(window, pane)
  -- The focused tab may have changed since the last status tick.
  local mux_window = window:mux_window()
  local seen = seen_tabs[mux_window:window_id()]
  if seen then seen.active = mux_window:active_tab():tab_id() end
  local cwd = pane:get_current_working_dir()
  local tab = mux_window:spawn_tab {
    domain = { DomainName = pane:get_domain_name() }, cwd = cwd and cwd.file_path,
  }
  tab:activate()
  group_new_tabs(window, pane)
end

wezterm.on('trigger-vi-with-scrollback', function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(text)
  f:flush()
  f:close()

  wezterm.background_child_process { 'wezterm', 'start', '--', 'vi', name }

  wezterm.sleep_ms(1000)
  os.remove(name)
end)

-- WezTerm handles tab-bar clicks natively, so config can't add tab dragging; this
-- picker jumps to any tab in the workspace or moves the current tab to any position.
local function workspace_windows()
  local workspace = wezterm.mux.get_active_workspace()
  local windows = {}
  for _, window in ipairs(wezterm.mux.all_windows()) do
    if window:get_workspace() == workspace then table.insert(windows, window) end
  end
  table.sort(windows, function(a, b) return a:window_id() < b:window_id() end)
  return windows
end

local function mux_tab_title(tab)
  local title = tab:get_title()
  return #title > 0 and title or tab:active_pane():get_title()
end

local function mux_tab_label(tab)
  return mux_tab_domain(tab) .. ' · ' .. mux_tab_title(tab)
end

-- The move entry comes last so Enter on the first match still jumps.
local function tab_picker_choices(windows)
  local choices = {}
  for w, window in ipairs(windows) do
    for t, tab in ipairs(window:tabs()) do
      table.insert(choices, { id = 'tab:' .. tab:tab_id(), label = 'Window ' .. w .. ' · Tab ' .. t .. ' · '
        .. mux_tab_label(tab) })
    end
  end
  table.insert(choices, { id = 'move', label = 'Move this tab…' })
  return choices
end

-- Drop positions as `slot:<window id>:<MoveTab index>`. In the source's own window
-- the tab leaves its place first, so later tabs shift down one, and positions that
-- would leave it where it is are skipped.
local function tab_slot_choices(windows, source_id)
  local choices = {}
  for w, window in ipairs(windows) do
    local tabs, from = window:tabs(), nil
    for t, tab in ipairs(tabs) do
      if tab:tab_id() == source_id then from = t end
    end
    local function add(position, label)
      if position == from then return end
      table.insert(choices, { id = 'slot:' .. window:window_id() .. ':' .. (position - 1),
        label = 'Window ' .. w .. ' · ' .. label })
    end
    add(1, 'first')
    for t, tab in ipairs(tabs) do
      add((from and t >= from) and t or t + 1, 'after Tab ' .. t .. ' · ' .. mux_tab_label(tab))
    end
  end
  table.insert(choices, { id = 'new-window', label = 'New window' })
  return choices
end

-- Moving client panes of a mux domain leaves their stored remote tab IDs stale
-- (see relocate_host in wezterm_work.lua), so only plain local tabs may move.
local function cross_window_move_error(tab)
  local domain = tab:active_pane():get_domain_name()
  if work and work.is_managed_domain(domain) then
    return 'Devserver tabs move with their server: use devvm detach or devvm open'
  end
  if domain ~= 'local' then return 'Only local tabs can move to another window' end
  if #tab:panes() > 1 then return 'Unsplit this tab before moving it to another window' end
end

-- No Lua API moves a pane into an existing window. Several GUIs may be running, so
-- address this GUI's socket rather than whichever one the CLI would pick.
local function move_pane_to_window(pane, window_id)
  local socket = wezterm.home_dir .. '/.local/share/wezterm/gui-sock-' .. wezterm.procinfo.pid()
  local ok, _, stderr = wezterm.run_child_process { '/usr/bin/env', 'WEZTERM_UNIX_SOCKET=' .. socket,
    wezterm.executable_dir .. '/wezterm', '-n', 'cli', '--no-auto-start', 'move-pane-to-new-tab',
    '--pane-id', tostring(pane:pane_id()), '--window-id', tostring(window_id) }
  return ok, stderr
end

local function focus_tab(window, tab)
  tab:activate()
  window:gui_window():focus()
end

local function show_tab_mover(window, pane, source)
  window:perform_action(act.InputSelector { title = 'Move tab to', fuzzy = true,
    choices = tab_slot_choices(workspace_windows(), source:tab_id()),
    action = wezterm.action_callback(function(gui, active_pane, id)
      if not id then return end
      local window_id, index = id:match('^slot:(%d+):(%d+)$')
      window_id, index = tonumber(window_id), tonumber(index)
      if window_id == gui:window_id() then
        mark_tab_placed(gui:mux_window(), source:tab_id())
        return gui:perform_action(act.MoveTab(index), active_pane)
      end
      local refusal = cross_window_move_error(source)
      if refusal then return gui:toast_notification('WezTerm', refusal, nil, 4000) end
      -- Moving a pane creates a fresh tab, which drops an explicit title.
      local moving, title = source:active_pane(), source:get_title()
      if id == 'new-window' then
        local tab, destination = moving:move_to_new_window(wezterm.mux.get_active_workspace())
        tab:set_title(title)
        return focus_tab(destination, tab)
      end
      placed_panes[moving:pane_id()] = true
      local ok, stderr = move_pane_to_window(moving, window_id)
      if not ok then
        placed_panes[moving:pane_id()] = nil
        return gui:toast_notification('WezTerm', 'Moving the tab failed: ' .. stderr, nil, 4000)
      end
      -- Other tabs may arrive while the CLI runs, so find the moved tab by its pane;
      -- MoveTab only acts on the active tab.
      local moved, destination_gui = moving:tab(), wezterm.mux.get_window(window_id):gui_window()
      moved:set_title(title)
      moved:activate()
      destination_gui:perform_action(act.MoveTab(index), moving)
      destination_gui:focus()
    end),
  }, pane)
end

local function move_tab_relative(offset)
  return wezterm.action_callback(function(window, pane)
    mark_tab_placed(window:mux_window(), window:active_tab():tab_id())
    window:perform_action(act.MoveTabRelative(offset), pane)
  end)
end

local function show_tab_picker(window, pane)
  local source = window:active_tab()
  window:perform_action(act.InputSelector { title = 'Tabs', fuzzy = true,
    choices = tab_picker_choices(workspace_windows()),
    action = wezterm.action_callback(function(gui, active_pane, id)
      if not id then return end
      if id == 'move' then return show_tab_mover(gui, active_pane, source) end
      local tab = wezterm.mux.get_tab(tonumber(id:match('^tab:(%d+)$')))
      focus_tab(tab:window(), tab)
    end),
  }, pane)
end

-- Keybindings
config.keys = {
  { key = 'P', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
  { key = 't', mods = 'CMD', action = wezterm.action_callback(spawn_grouped_tab) },
  { key = 't', mods = 'CMD|SHIFT', action = wezterm.action_callback(show_tab_picker) },
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'LeftArrow', mods = 'CMD|OPT|SHIFT', action = move_tab_relative(-1) },
  { key = 'RightArrow', mods = 'CMD|OPT|SHIFT', action = move_tab_relative(1) },
  { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },
  { key = 'e', mods = 'CMD', action = act.EmitEvent 'trigger-vi-with-scrollback' },
  { key = 'k', mods = 'CMD', action = act.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'f', mods = 'CMD', action = act.Search { Regex = '' } },
  -- Leave mux sessions running on the server; Cmd+W would kill the remote tab
  { key = 'w', mods = 'CMD|SHIFT', action = act.DetachDomain 'CurrentPaneDomain' },
}

local search_mode = wezterm.gui.default_key_tables().search_mode
table.insert(search_mode, { key = 'r', mods = 'CMD', action = act.CopyMode 'CycleMatchType' })
table.insert(search_mode, { key = 'g', mods = 'CMD', action = act.CopyMode 'NextMatch' })
table.insert(search_mode, { key = 'g', mods = 'CMD|SHIFT', action = act.CopyMode 'PriorMatch' })
table.insert(search_mode, { key = 'a', mods = 'CTRL', action = act.CopyMode 'MoveToStartOfLineContent' })
table.insert(search_mode, { key = 'e', mods = 'CTRL', action = act.CopyMode 'MoveToEndOfLineContent' })
table.insert(search_mode, { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' })
config.key_tables = { search_mode = search_mode }

if work then work.apply_to_config(config) end

-- Merge local overrides into config (local values win)
local function merge(base, overrides)
  for k, v in pairs(overrides) do
    if type(v) == 'table' and type(base[k]) == 'table' and not v[1] then
      merge(base[k], v)
    else
      base[k] = v
    end
  end
end

-- Source machine-local overrides if they exist
local ok, local_overrides = pcall(require, 'wezterm_local')
if ok and type(local_overrides) == 'table' then
  merge(config, local_overrides)
end

-- Derived after local overrides so a local font change reaches the tab bar too,
-- unless the frame sets its own font.
config.window_frame.font = config.window_frame.font or config.font
config.window_frame.font_size = config.window_frame.font_size or config.font_size

return config
