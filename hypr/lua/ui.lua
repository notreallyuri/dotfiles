local M = {}

local colors = {
	active = "rgba(73,187,244,0.8)",
	inactive = "rgba(0,0,0,0)",
	shadow = "rgba(1a1a1aee)",
}

local speed = {
	slow = 10,
	border = 5.39,
	win = 4.79,
	pop = 4.1,
	fade = 3.03,
	fast = 1.5,
}

function M.setup()
	hl.setup({
		animations = {
			enabled = true,
		},
		general = {
			gaps_in = 5,
			gaps_out = 10,
			border_size = 2,
			["col.active_border"] = colors.active,
			["col.inactive_border"] = colors.inactive,
			resize_on_border = true,
			allow_tearing = false,
			layout = "dwindle",
		},

		decoration = {
			rounding = 16,
			rounding_power = 2.0,
			active_opacity = 1.0,
			inactive_opacity = 0.97,

			shadow = {
				enabled = true,
				range = 4,
				render_power = 3,
				color = colors.shadow,
			},

			blur = {
				enabled = true,
				size = 3,
				passes = 2,
				vibrancy = 0.1696,
			},
		},
	})

	hl.bezier("easeOutQuint", 0.23, 1, 0.32, 1)
	hl.bezier("almostLinear", 0.5, 0.5, 0.75, 1.0)
	hl.bezier("quick", 0.15, 0, 0.1, 1)
	hl.bezier("linear", 0, 0, 1, 1)

	hl.animation("global", 1, speed.slow, "default")
	hl.animation("border", 1, speed.border, "easeOutQuint")
	hl.animation("windows", 1, speed.win, "easeOutQuint")
	hl.animation("windowsIn", 1, speed.pop, "easeOutQuint", "popin 87%")
	hl.animation("windowsOut", 1, speed.fast, "linear", "popin 87%")

	hl.animation("fadeIn", 1, 1.73, "almostLinear")
	hl.animation("fadeOut", 1, speed.fast, "almostLinear")
	hl.animation("fade", 1, speed.fade, "quick")

	hl.animation("workspaces", 1, 3, "easeOutQuint", "slide")
end

return M
