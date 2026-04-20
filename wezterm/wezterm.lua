local wzt = require("wezterm")

local config = wzt.config_builder()

local keybinds = require("keybinds")
local ui = require("ui")

keybinds.apply_to_config(config)
ui.apply_to_config(config)

config.color_scheme = "Noctalia"
return config
