-- keybinds.lu
local M = {}

function M.setup(vars)
	local kb = vars.kb
	local apps = vars.apps

	-- ### Basic Actions ###
	hl.bind(kb.close, hl.dsp.window.kill_active())
	hl.bind(kb.float_toggle, hl.dsp.window.toggle_floating())
	hl.bind(kb.split, hl.dsp.window.toggle_split())
	hl.bind(kb.fullscreen, hl.dsp.window.fullscreen(0))

	-- ### Basic Applications ###
	hl.bind(kb.terminal, hl.dsp.exec_cmd(apps.terminal))
	hl.bind(kb.filemgr, hl.dsp.exec_cmd(apps.terminal .. " " .. apps.filemgr))
	hl.bind(kb.copy_color, hl.dsp.exec_cmd(apps.colorpicker .. " -a"))
	hl.bind(kb.lock, hl.dsp.exec_cmd(apps.lock))
	hl.bind(kb.calc, hl.dsp.exec_cmd(apps.calc))

	-- ### Basic Navigation ###
	-- Vim keys & Arrows
	local dirs = { h = "l", l = "r", k = "u", j = "d", left = "l", right = "r", up = "u", down = "d" }
	for key, dir in pairs(dirs) do
		-- Move focus
		hl.bind(kb.go_to .. " + " .. key, hl.dsp.window.move_focus(dir))
		-- Move window
		hl.bind(kb.move_win .. " + " .. key, hl.dsp.window.move_window(dir))
	end

	-- ### Workspaces (1-10) ###
	for i = 1, 10 do
		local key = tostring(i % 10) -- Maps 1-9 and handles 0 as 10
		hl.bind(kb.go_to .. " + " .. key, hl.dsp.workspace.switch(tostring(i)))
		hl.bind(kb.move_win .. " + " .. key, hl.dsp.window.move_to_workspace(tostring(i)))
	end

	-- Mouse scroll workspaces
	hl.bind(kb.go_to .. " + mouse_down", hl.dsp.workspace.switch("e+1"))
	hl.bind(kb.go_to .. " + mouse_up", hl.dsp.workspace.switch("e-1"))

	-- ### Noctalia Shell IPC ###
	hl.bind("SUPER + R", hl.dsp.exec_cmd(apps.ipc .. " launcher toggle"))
	hl.bind("SUPER + comma", hl.dsp.exec_cmd(apps.ipc .. " settings toggle"))
	hl.bind("SUPER + S", hl.dsp.exec_cmd(apps.ipc .. " controlCenter toggle"))
	hl.bind("SUPER + W", hl.dsp.exec_cmd(apps.ipc .. " wallpaper toggle"))

	-- ### Printscreen ###
	hl.bind("Print", hl.dsp.exec_cmd(apps.ipc .. " plugin:screen-shot-and-record screenshot"))
	hl.bind("SUPER_SHIFT + S", hl.dsp.exec_cmd(apps.ipc .. " plugin:screen-shot-and-record ocr"))
	hl.bind("SUPER_SHIFT + G", hl.dsp.exec_cmd(apps.ipc .. " plugin:screen-shot-and-record search"))
	hl.bind("SUPER_SHIFT + R", hl.dsp.exec_cmd(apps.ipc .. " plugin:screen-shot-and-record record"))
	hl.bind("SUPER_SHIFT_ALT + R", hl.dsp.exec_cmd(apps.ipc .. " plugin:screen-shot-and-record recordsound"))

	-- ### Window Resizing (binde equivalent) ###
	local resizes = {
		left = "-10 0",
		right = "10 0",
		up = "0 -10",
		down = "0 10",
		h = "-10 0",
		l = "10 0",
		k = "0 -10",
		j = "0 10",
	}
	for key, val in pairs(resizes) do
		-- Passing the '{ repeating = true }' flag for binde behavior
		hl.bind(
			kb.reize .. " + " .. key,
			hl.dsp.window.resize_active({ x = val:match("(-?%d+)"), y = val:match("%s(-?%d+)") }),
			{ repeating = true }
		)
	end

	-- ### Mouse Window Management (bindm equivalent) ###
	hl.bind(kb.move_mouse, hl.dsp.window.move_window(), { mouse = true })
	hl.bind(kb.resize_mouse, hl.dsp.window.resize_window(), { mouse = true })

	-- ### Special Workspaces ###
	hl.bind(kb.music, hl.dsp.workspace.toggle_special("music"))
	hl.bind(kb.comm, hl.dsp.workspace.toggle_special("comm"))
	hl.bind(kb.browser, hl.dsp.workspace.toggle_special("browser"))

	hl.bind(kb.move_win .. " + M", hl.dsp.window.move_to_workspace("special:music"))
	hl.bind(kb.move_win .. " + D", hl.dsp.window.move_to_workspace("special:comm"))
	hl.bind(kb.move_win .. " + B", hl.dsp.window.move_to_workspace("special:browser"))

	-- ### Media Control ###
	-- bindrl equivalent (repeating + release)
	hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { repeating = true, release = true })
	hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { repeating = true, release = true })
	hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { repeating = true, release = true })

	-- bindel equivalent (repeating + locked)
	hl.bind(
		"XF86AudioRaiseVolume",
		hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
		{ repeating = true, locked = true }
	)
	hl.bind(
		"XF86AudioLowerVolume",
		hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
		{ repeating = true, locked = true }
	)
	hl.bind(
		"XF86AudioMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
		{ repeating = true, locked = true }
	)
	hl.bind(
		"XF86AudioMicMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
		{ repeating = true, locked = true }
	)
	hl.bind(
		"XF86MonBrightnessUp",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
		{ repeating = true, locked = true }
	)
	hl.bind(
		"XF86MonBrightnessDown",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
		{ repeating = true, locked = true }
	)

	-- bindl equivalent (locked)
	hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
	hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
end

return M
