local wezterm = require("wezterm")
local config = wezterm.config_builder()

local ui = require("ui")

for k, v in pairs(ui) do
	config[k] = v
end

local keys = require("keys")
keys.apply_to_config(config)

return config
