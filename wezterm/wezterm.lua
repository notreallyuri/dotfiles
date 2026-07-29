local wzt = require("wezterm")

local config = wzt.config_builder()

local keybinds = require("keybinds")
local ui = require("ui")
local resurrect = wzt.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

keybinds.apply_to_config(config)
ui.apply_to_config(config)

config.color_scheme = "Noctalia"

-- SSH profiles: hostnames/users resolve via ~/.ssh/config
config.ssh_domains = {
  {
    name = "notreallyserver",
    remote_address = "notreallyserver",
  },
}

-- Session persistence: autosave workspace state, restore on launch
resurrect.state_manager.periodic_save()
wzt.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

return config
