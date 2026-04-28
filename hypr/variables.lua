local M = {}

local home = os.getenv("HOME")
local user = os.getenv("USER")

M.apps = {
	terminal = "wezterm",
	browser = "zen-browser",
	filemgr = "yazi",
	menu = "rofi -show drun",
	editor = "nvim",
	colorpicker = "hyprpicker",
	lock = "hyprlock",
	calc = "rofi -show calc",
	ipc = "qs -c noctalia-shell ipc call",
}

M.media = {
	wallpaper = home .. "/.config/hypr/media/winpp.jpg",
	wallpaper2 = home .. "/.config/hypr/media/mikupp.png",
	pfp = "/var/lib/AccountsService/icons/" .. (user or ""),
	anifile = home .. "/.config/hypr/media/anitext",
}

M.kb = {
	move_win = "SUPER_SHIFT",
	go_to = "SUPER",
	resize = "SUPER + ALT",

	terminal = "SUPER + Q",
	browser = "SUPER + B",
	filemgr = "SUPER + E",
	menu = "SUPER + R",
	copy_color = "SUPER_SHIFT + C",
	lock = "SUPER + P",
	calc = "SUPER + T",

	float_toggle = "SUPER + G",
	fullscreen = "SUPER + F",
	close = "SUPER + C",
	split = "SUPER + J",

	comm = "SUPER + D",
	music = "SUPER + M",

	move_mouse = "SUPER + mouse:272",
	resize_mouse = "SUPER + mouse:273",
}

return M
