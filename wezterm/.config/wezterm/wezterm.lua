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

wezterm.on('format-tab-title', guarded('format-tab-title', function(tab, tabs, panes, _, hover, max_width)
  local domain = tab.active_pane and tab.active_pane.domain_name or 'local'
  local label, key, index = domain == 'local' and 'Local' or domain, domain
  if work then label, key, index = work.tab_domain(tab) end
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

-- Keybindings
config.keys = {
  { key = 'P', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
  { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 't', mods = 'CMD|SHIFT', action = act.ShowTabNavigator },
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|SHIFT', action = act.ActivatePaneDirection 'Down' },
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
