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

local key_table_hints = {
  pane_manage = "v split-right   h split-down   q close   z zoom   r resize",
  resize_pane = "hjkl/arrows resize   esc/enter done",
}

wzt.on("update-status", function(window, pane)
  local table_name = window:active_key_table()
  local active = table_name ~= nil or window:leader_is_active()

  if not active then
    window:set_right_status("")
    return
  end

  local label
  if table_name then
    label = " " .. table_name:upper() .. "  " .. (key_table_hints[table_name] or "") .. " "
  else
    label = " LEADER "
  end

  window:set_right_status(wzt.format({
    { Background = { Color = "#58a6ff" } },
    { Foreground = { Color = "#010409" } },
    { Text = label },
  }))
end)

local domain_colors = {
  notreallyserver = "#f7768e",
}

local function git_branch(pane)
  if pane.domain_name ~= "local" then
    return nil
  end

  local cwd = pane.current_working_dir
  if not cwd or not cwd.file_path then
    return nil
  end

  local head = io.open(cwd.file_path .. "/.git/HEAD", "r")
  if not head then
    return nil
  end

  local content = head:read("*l")
  head:close()

  return content and content:match("ref: refs/heads/(.+)")
end

wzt.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local process = pane.foreground_process_name or ""
  process = process:match("([^/\\]+)$") or process

  local core = process ~= "" and process or pane.title

  local branch = git_branch(pane)
  if branch then
    core = core .. " [" .. branch .. "]"
  end

  local accent = domain_colors[pane.domain_name]
  local accent_prefix = accent and "● " or ""
  local label = accent_prefix .. (tab.tab_index + 1) .. " " .. core

  local cols = wzt.GLOBAL.cols or 120

  local base_width = math.floor(cols / #tabs)
  local remainder = cols % #tabs

  local target_width = base_width
  if tab.tab_index == #tabs - 1 then
    target_width = base_width + remainder
  end

  target_width = target_width - 4

  local pad_left_len = math.max(0, math.floor((target_width - #label) / 2))
  local pad_right_len = math.max(0, target_width - #label - pad_left_len)

  local pad_left = string.rep(" ", pad_left_len)
  local rest = (tab.tab_index + 1) .. " " .. core .. string.rep(" ", pad_right_len)

  local tab_bar = config.resolved_palette and config.resolved_palette.tab_bar
  local style = tab_bar and (tab.is_active and tab_bar.active_tab or tab_bar.inactive_tab)
  local bg = (style and style.bg_color) or (tab.is_active and "#58a6ff" or "#010409")
  local fg = (style and style.fg_color) or (tab.is_active and "#010409" or "#c9d1d9")

  local segments = {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
  }

  if tab.is_active then
    table.insert(segments, { Attribute = { Intensity = "Bold" } })
  end

  table.insert(segments, { Text = pad_left })

  if accent then
    table.insert(segments, { Foreground = { Color = accent } })
    table.insert(segments, { Text = "● " })
    table.insert(segments, { Foreground = { Color = fg } })
  end

  table.insert(segments, { Text = rest })

  return segments
end)

function M.apply_to_config(config)
  config.default_prog = { "zsh", "-l" }

  config.color_scheme = "Tokyo Night"

  config.font = wzt.font("Lilex Nerd Font")
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
