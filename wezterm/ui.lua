local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
	config.font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"Symbols Nerd Font",
	})
	config.font_size = 10.5
	config.line_height = 1.0

	config.use_fancy_tab_bar = false
	config.tab_bar_at_bottom = false

	config.hide_tab_bar_if_only_one_tab = true

	config.window_frame = {
		active_titlebar_bg = "#1E1E2E",
		inactive_titlebar_bg = "#181825",
	}

	config.window_padding = {
		left = 0,
		right = 0,
		bottom = 0,
		top = 0,
	}

	config.window_background_opacity = 0.95

	config.colors = {
		foreground = "#CDD6F4",
		background = "#1E1E2E",

		cursor_bg = "#F5E0DC",
		cursor_fg = "#1E1E2E",
		cursor_border = "#F5E0DC",

		selection_fg = "#1E1E2E",
		selection_bg = "#F5E0DC",

		ansi = {
			"#45475A",
			"#F38BA8",
			"#A6E3A1",
			"#F9E2AF",
			"#89B4FA",
			"#F5C2E7",
			"#94E2D5",
			"#BAC2DE",
		},

		brights = {
			"#585B70",
			"#F38BA8",
			"#A6E3A1",
			"#F9E2AF",
			"#89B4FA",
			"#F5C2E7",
			"#94E2D5",
			"#A6ADC8",
		},

		tab_bar = {
			background = "#11111B",

			active_tab = {
				bg_color = "#CBA6F7",
				fg_color = "#11111B",
			},

			inactive_tab = {
				bg_color = "#181825",
				fg_color = "#CDD6F4",
			},
		},
		visual_bell = "#F9E2AF",
	}
end

return M
