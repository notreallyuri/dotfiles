local M = {}

function M.setup()
	-- ==========================================
	-- Basic Fixes & Ignored Events
	-- ==========================================
	hl.window_rule({
		name = "maximize_ignore",
		match = { class = ".*" },
		suppress_event = "maximize",
	})

	hl.window_rule({
		name = "xwayland-drag-fix",
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
		name = "no_anim_for_selection",
		match = { namespace = "noctalia-shell:regionSelector" },
		no_anim = true,
	})

	hl.layer_rule({
		name = "noctalia",
		match = { namespace = "noctalia-background-.*$" },
		ignore_alpha = 0.5,
		blur = true,
		blur_popups = true,
	})

	-- ==========================================
	-- Special Workspaces
	-- ==========================================
	hl.window_rule({
		name = "special_workspace_comm",
		match = { class = "^(discord|whatsapp|vesktop)$" },
		workspace = "special:comm",
	})

	hl.window_rule({
		name = "special_workspace_music",
		match = { class = "^(Cider|spotify)$" },
		workspace = "special:music",
	})

	hl.window_rule({
		name = "special_workspace_browser",
		match = { class = "^(zen|firefox|chromium)$" },
		workspace = "special:browser",
	})

	-- ==========================================
	-- Special Visual Rules
	-- ==========================================
	hl.window_rule({
		name = "fix_share_picker",
		match = { class = "^(hyprland-share-picker)$" },
		workspace = "unset",
		float = true,
		center = true,
		["border_color"] = "rgb(ff5555)",
	})

	hl.window_rule({
		name = "opaque",
		match = { class = "^(discord|krita)$" },
		opacity = "1.0 override 1.0 override",
	})

	hl.window_rule({
		name = "imv_style",
		match = { class = "^(imv)$" },
		float = true,
		center = true,
		size = "800 600",
	})

	hl.window_rule({
		name = "zen_transparency",
		match = { class = "^(zen)$" },
		opacity = "0.99999 override",
	})

	-- ==========================================
	-- Steam Specific
	-- ==========================================
	hl.window_rule({
		name = "steam_no_rounding_menus",
		match = {
			class = "^(steam)$",
			title = "^$",
			xwayland = true,
			float = true,
		},
		rounding = 0,
	})

	hl.window_rule({
		name = "steam_no_rounding_notifications",
		match = {
			class = "^(steam)$",
			title = "^notificationtoasts_[0-9]+_desktop$",
			float = true,
		},
		rounding = 0,
	})

	hl.window_rule({
		name = "steam_friend_list_fix",
		match = {
			class = "^(steam)$",
			title = "^(Friends List)$",
		},
		float = true,
		size = "300 600",
		center = true,
	})

	hl.window_rule({
		name = "steam_settings_fix",
		match = {
			class = "^(steam)$",
			title = "^(Steam Settings)$",
		},
		float = true,
		size = "1000 800",
		center = true,
	})

	hl.window_rule({
		name = "steam_rs",
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
		name = "tag_games_classes",
		match = { class = "^(gamescope|steam_proton|retroarch|steam_app_\\d+|HytaleClient)$" },
		tag = "games",
	})

	hl.window_rule({
		name = "tag_games_titles",
		match = { title = "^(Minecraft.*)$" },
		tag = "games",
	})

	hl.window_rule({
		name = "tag_games_exe",
		match = {
			class = "^(.*\\.exe)$",
			title = "^(.+)$",
		},
		tag = "games",
	})

	hl.window_rule({
		name = "apply_games_rules",
		match = { tag = "games" },
		workspace = "5",
		no_blur = true,
		fullscreen = true,
	})

	hl.window_rule({
		name = "elsword_fix",
		match = {
			class = "^(steam_app_0)$",
			title = "^$",
		},
		no_focus = true,
	})
end

return M
