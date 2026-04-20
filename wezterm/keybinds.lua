local wzt = require("wezterm")
local act = wzt.action

local M = {}

function M.apply_to_config(config)
	config.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = 1000 }
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
			mods = "LEADER",
			action = act.ActivateTabRelative(1),
		},
		{
			key = "LeftArrow",
			mods = "LEADER",
			action = act.ActivateTabRelative(-1),
		},
		{
			key = "r",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wzt.action_callback(function(window, _, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			key = '"',
			mods = "LEADER",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "%",
			mods = "LEADER",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "h",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Left"),
		},
		{
			key = "l",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Right"),
		},
		{
			key = "k",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Up"),
		},
		{
			key = "j",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Down"),
		},
	}
end

return M
