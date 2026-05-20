-- ==========================================
-- Basic Fixes & Ignored Events
-- ==========================================
hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- ==========================================
-- Layer Rules (Noctalia Shell)
-- ==========================================
hl.layer_rule({
	match = { namespace = "noctalia-shell:regionSelector" },
	no_anim = true,
})

hl.layer_rule({
	match = { namespace = "noctalia-background-.*$" },
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

-- ==========================================
-- Special Workspaces
-- ==========================================
hl.window_rule({
	match = { class = "^(discord|whatsapp|vesktop)$" },
	workspace = "special:comm",
})

hl.window_rule({
	match = { class = "^(Cider|spotify)$" },
	workspace = "special:music",
})

hl.window_rule({
	match = { class = "^(zen|firefox|chromium)$" },
	workspace = "special:browser",
})

-- ==========================================
-- Special Visual Rules
-- ==========================================
hl.window_rule({
	match = { class = "^(hyprland-share-picker)$" },
	workspace = "unset",
	float = true,
	center = true,
	["border_color"] = "rgb(ff5555)",
})

hl.window_rule({
	match = { class = "^(discord|krita)$" },
	opacity = "1.0 override 1.0 override",
})

hl.window_rule({
	match = { class = "^(imv)$" },
	float = true,
	center = true,
	size = "800 600",
})

hl.window_rule({
	match = { class = "^(zen)$" },
	opacity = "0.99999 override",
})

-- ==========================================
-- Steam Specific
-- ==========================================
hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^$",
		xwayland = true,
		float = true,
	},
	rounding = 0,
})

hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^notificationtoasts_[0-9]+_desktop$",
		float = true,
	},
	rounding = 0,
})

hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Friends List)$",
	},
	float = true,
	size = "300 600",
	center = true,
})

hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Steam Settings)$",
	},
	float = true,
	size = "1000 800",
	center = true,
})

hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Recordings & Screenshots)$",
	},
	float = true,
	size = "1280 720",
})

-- ==========================================
-- Game Tags and Exceptions
-- ==========================================
hl.window_rule({
	match = { class = "^(gamescope|steam_proton|retroarch|steam_app_\\d+|HytaleClient)$" },
	tag = "games",
})

hl.window_rule({
	match = { title = "^(Minecraft.*)$" },
	tag = "games",
})

hl.window_rule({
	match = {
		class = "^(.*\\.exe)$",
		title = "^(.+)$",
	},
	tag = "games",
})

hl.window_rule({
	match = { tag = "games" },
	workspace = "5",
	no_blur = true,
	fullscreen = true,
})

hl.window_rule({
	match = {
		class = "^(steam_app_0)$",
		title = "^$",
	},
	no_focus = true,
})
