local wzt = require("wezterm")
local act = wzt.action

local module = {}

function module.apply_to_config(config)
	config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
	config.keys = {
		{
			key = "w",
			mods = "LEADER",
			action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
		},
		{
			key = "n",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Enter name for new workspace",
				action = wzt.action_callback(function(window, pane, line)
					if line then
						window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},
		{
			key = "RightArrow",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(1),
		},
		{
			key = "LeftArrow",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(-1),
		},
		{
			key = "r",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wzt.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}
end

return module
