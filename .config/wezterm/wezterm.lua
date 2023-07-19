local wezterm = require 'wezterm';

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = " " .. wezterm.truncate_right(tab.active_pane.title, max_width - 2) .. " "

    return { { Text = title } }
end)

local config = wezterm.config_builder()

config.color_scheme = 'nordfox'
config.font = wezterm.font("HackGen Console NF", { weight = "Regular" })
config.font_size = 16.0
config.line_height = 1.1
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.6,
}
config.enable_scroll_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
    font = wezterm.font("HackGen Console NF", { weight = "Bold" }),
    font_size = 16.0,
}
config.adjust_window_size_when_changing_font_size = false
config.initial_cols = 120
config.initial_rows = 36
config.keys = {
    { key = "w",  mods = "CMD",       action = wezterm.action.CloseCurrentPane { confirm = true } },
    { key = "w",  mods = 'SHIFT|CMD', action = wezterm.action.CloseCurrentTab { confirm = true } },
    { key = "\\", mods = 'CTRL',      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = "-",  mods = 'CTRL',      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'q',  mods = 'CTRL',      action = wezterm.action.PaneSelect { alphabet = '0123456789' } },
    { key = '1',  mods = 'CTRL',      action = wezterm.action.ShowTabNavigator },
}
config.audible_bell = "Disabled"
return config
