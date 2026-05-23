local wzt = require("wezterm")

local M = {}

wzt.on("window-resized", function(window, pane)
  wzt.GLOBAL.cols = window:active_tab():get_size().cols
end)

wzt.on("window-config-reloaded", function(window, pane)
  if window:active_tab() then
    wzt.GLOBAL.cols = window:active_tab():get_size().cols
  end
end)

wzt.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  local cols = wzt.GLOBAL.cols or 120

  local base_width = math.floor(cols / #tabs)
  local remainder = cols % #tabs

  local target_width = base_width
  if tab.tab_index == #tabs - 1 then -- tab_index is 0-based
    target_width = base_width + remainder
  end

  target_width = target_width - 4

  local pad_left_len = math.max(0, math.floor((target_width - #title) / 2))
  local pad_right_len = math.max(0, target_width - #title - pad_left_len)

  return {
    { Text = string.rep(" ", pad_left_len) .. title .. string.rep(" ", pad_right_len) },
  }
end)

function M.apply_to_config(config)
  config.default_prog = { "zsh", "-l" }

  config.color_scheme = "Tokyo Night"

  config.font = wzt.font("Lilex Nerd Font", { weight = "Medium" })
  config.font_size = 10.5
  config.line_height = 1.0
  config.harfbuzz_features = { "liga=1", "clig=1", "calt=1" }

  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true
  config.tab_max_width = 999
  config.show_new_tab_button_in_tab_bar = false



  config.front_end = "WebGpu"
  config.max_fps = 144
  config.enable_wayland = true
  config.tab_bar_at_bottom = false

  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }


  config.window_background_opacity = 0.9
end

return M
