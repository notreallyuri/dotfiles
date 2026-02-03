local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply_to_config(config)
	-- Set the leader key (CTRL + a)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	config.keys = {
		-- Project Picker (Leader + p)
		{
			key = "p",
			mods = "LEADER",
			action = act.InputSelector({
				title = "Select Project",
				choices = {
					{ label = "Manga Reader (Torigen)", id = "torigen" },
					{ label = "VN Engine (Rust)", id = "vn_engine" },
					{ label = "University", id = "school" },
				},
				action = wezterm.action_callback(function(window, pane, id, _)
					if not id then
						return
					end

					local paths = {
						torigen = wezterm.home_dir .. "/projects/torigen",
						vn_engine = wezterm.home_dir .. "/projects/vn-engine",
						school = wezterm.home_dir .. "/Documents/college",
					}

					window:perform_action(
						act.SwitchToWorkspace({
							name = id:upper(),
							spawn = { cwd = paths[id] or wezterm.home_dir },
						}),
						pane
					)
				end),
			}),
		},

		-- Workspace Navigation
		{ key = "n", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
		{ key = "p", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },

		-- Pane Management (More intuitive than defaults)
		{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	}
end

return M
