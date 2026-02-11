-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration
local config = wezterm.config_builder()

-- Your configuration goes here
config.color_scheme = 'Dracula (Official)'

config.font = wezterm.font('JetBrains Mono')
config.font_size = 12.0

-- Window settings
config.window_background_opacity = 0.96
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.enable_scroll_bar = true

-- Dynamic tab bar color based on local vs remote session
wezterm.on('update-status', function(window, pane)
  local is_remote = pane:get_domain_name() ~= 'local' or pane:get_foreground_process_name():find('ssh') ~= nil
  local overrides = window:get_config_overrides() or {}

  if is_remote then
    overrides.colors = overrides.colors or {}
    overrides.colors.tab_bar = {
      background = '#8489b8',
      active_tab = { bg_color = '#14710A', fg_color = '#f8f8f2' },
      -- new_tab = { bg_color = '#14710A', fg_color = '#9a86b5' },
      new_tab_hover = { bg_color = '#b88489', fg_color = '#f8f8f2' },
    }
  else
    overrides.colors = overrides.colors or {}
    overrides.colors.tab_bar = nil
  end

  window:set_config_overrides(overrides)
end)

-- Keybindings
config.keys = {
  { key = 'P', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCommandPalette },
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- Move between panes with Ctrl+Shift+Arrow
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = '[', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Next' },
  -- Jump between prompts with arrows
  { key = "UpArrow",   mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
  { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },
}

-- Return the configuration to wezterm
return config
