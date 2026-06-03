local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()
local home = os.getenv('HOME')

config.color_scheme = 'Dracula (Official)'

config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
config.font_size = 12.0

config.scrollback_lines = 20000

-- Window settings
config.window_background_opacity = 0.96
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.enable_scroll_bar = true

config.hyperlink_rules = {
  {
    regex = '\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b',
    format = '$0',
  },
  {
    regex = '\\b([tTdDpP]\\d+)\\b',
    format = 'https://fburl.com/b/$1',
  },
  {
    regex = '^>>> Lint for (.*):$',
    format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&editor=vscode-insiders',
  },
  {
    regex = home .. '/fbsource/(.*):(\\d+):\\d+',
    format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&lines[0]=$2&editor=vscode-insiders',
  },
  {
    regex = '--> (fbcode/.*):(\\d+):\\d+',
    format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$1&lines[0]=$2&editor=vscode-insiders',
  },
  {
    regex = '^(---|\\+\\+\\+) [ab]/(fbcode/.*)',
    format = 'https://www.internalfb.com/intern/nuclide/open/arc/?project=fbsource&paths[0]=$2&editor=vscode-insiders',
  },
}

config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'CMD',
    action = act.OpenLinkAtMouseCursor },
}

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

wezterm.on('update-status', function(window, pane)
  local want = pane_is_remote(pane) and REMOTE_COLOR_SCHEME or nil
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == want then
    return
  end
  overrides.color_scheme = want
  window:set_config_overrides(overrides)
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

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = wezterm.truncate_right(resolve_tab_title(tab), math.max(max_width - 1, 1))
  return string.format(' %-11s', title)
end)

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
}

local search_mode = wezterm.gui.default_key_tables().search_mode
table.insert(search_mode, { key = 'r', mods = 'CMD', action = act.CopyMode 'CycleMatchType' })
table.insert(search_mode, { key = 'g', mods = 'CMD', action = act.CopyMode 'NextMatch' })
table.insert(search_mode, { key = 'g', mods = 'CMD|SHIFT', action = act.CopyMode 'PriorMatch' })
table.insert(search_mode, { key = 'a', mods = 'CTRL', action = act.CopyMode 'MoveToStartOfLineContent' })
table.insert(search_mode, { key = 'e', mods = 'CTRL', action = act.CopyMode 'MoveToEndOfLineContent' })
table.insert(search_mode, { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' })
config.key_tables = { search_mode = search_mode }


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

return config
