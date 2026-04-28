local wzt = require("wezterm") ---@type Wezterm

local M = {}

---@param config Config
function M.apply_to_config(config)
	config.default_prog = { "zsh", "-l" }

	config.color_scheme = "Tokyo Night"

	config.font = wzt.font("Lilex Nerd Font", { weight = "Medium" })
	config.font_size = 10.5
	config.line_height = 1.0
	config.harfbuzz_features = { "liga=1", "clig=1", "calt=1" }

	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = true
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
