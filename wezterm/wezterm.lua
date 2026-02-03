local wezterm = require("wezterm")
local config = wezterm.config_builder()

local ui = require("ui")
local keys = require("keys")

ui.apply_to_config(config)
keys.apply_to_config(config)

return config
