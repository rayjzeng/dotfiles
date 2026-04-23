local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()
local home = os.getenv('HOME')

config.color_scheme = 'Dracula (Official)'

config.font = wezterm.font('JetBrains Mono')
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

-- Switch color scheme for remote sessions
wezterm.on('update-status', function(window, pane)
  local is_remote = pane:get_domain_name() ~= 'local' or pane:get_foreground_process_name():find('ssh') ~= nil
  local overrides = window:get_config_overrides() or {}

  if is_remote then
    overrides.color_scheme = 'Catppuccin Mocha'
  else
    overrides.color_scheme = nil
  end

  window:set_config_overrides(overrides)
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = string.format(' %-11s', tab.active_pane.title)
  return title
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
}

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
