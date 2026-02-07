-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration
local config = wezterm.config_builder()

-- Your configuration goes here
config.color_scheme = 'Darcula (base16)'
config.colors = {
  scrollbar_thumb = '#44475A'
}

config.font = wezterm.font('JetBrains Mono')
config.font_size = 12.0

-- Window settings
config.window_background_opacity = 0.96
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = true

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
}

-- Return the configuration to wezterm
return config
