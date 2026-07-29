local wzt = require("wezterm") ---@type Wezterm
local act = wzt.action
local resurrect = wzt.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local M = {}

---@param config Config
function M.apply_to_config(config)
	config.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = 1000 }

	-- Mirrors the ghostty "w" prefix (ctrl+shift+space>w>v/h/q): window/pane
	-- management lives behind LEADER+w so the chord muscle memory carries over.
	config.key_tables = {
		pane_manage = {
			{ key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- side by side
			{ key = "h", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- stacked
			{ key = "q", action = act.CloseCurrentPane({ confirm = true }) },
			{ key = "z", action = act.TogglePaneZoomState },
			{
				key = "r",
				action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 3000 }),
			},
			{ key = "Escape", action = act.PopKeyTable },
		},
		resize_pane = {
			{ key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
			{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
			{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 3 }) },
			{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
			{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 3 }) },
			{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 3 }) },
			{ key = "Escape", action = act.PopKeyTable },
			{ key = "Enter", action = act.PopKeyTable },
		},
	}

	config.keys = {
		{
			key = "w",
			mods = "LEADER",
			action = act.ActivateKeyTable({ name = "pane_manage", timeout_milliseconds = 1500 }),
		},
		{
			key = "o",
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
		{
			key = "s",
			mods = "LEADER",
			action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }),
		},
		{
			key = "S",
			mods = "LEADER|SHIFT",
			action = wzt.action_callback(function(window, pane)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			end),
		},
		{
			key = "L",
			mods = "LEADER|SHIFT",
			action = wzt.action_callback(function(window, pane)
				resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, label)
					local kind = string.match(id, "^([^/]+)")
					id = string.match(id, "([^/]+)$")
					id = string.match(id, "(.+)%..+$")
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if kind == "workspace" then
						local state = resurrect.state_manager.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
					end
				end)
			end),
		},
	}
end

return M
