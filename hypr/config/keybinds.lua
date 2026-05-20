local vars = require("variables")

local kb = vars.kb
local apps = vars.apps

hl.bind(kb.close, hl.dsp.window.close())
hl.bind(kb.float_toggle, hl.dsp.window.float())
hl.bind(kb.fullscreen, hl.dsp.window.fullscreen())

hl.bind(kb.terminal, hl.dsp.exec_cmd(apps.terminal))
hl.bind(kb.filemgr, hl.dsp.exec_cmd(apps.terminal .. " -e " .. apps.filemgr))
hl.bind(kb.copy_color, hl.dsp.exec_cmd(apps.colorpicker .. " -a"))
hl.bind(kb.lock, hl.dsp.exec_cmd(apps.lock))
hl.bind(kb.calc, hl.dsp.exec_cmd(apps.calc))

hl.bind("Print", hl.dsp.exec_cmd(apps.screenshot .. " region"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd(apps.screenshot .. " full"))
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(apps.screenshot .. " region search"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(apps.screenshot .. " region ocr"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(apps.screenshot .. " record"))
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd(apps.screenshot .. " recordsound"))

local dirs = {
  h = "left",
  l = "right",
  k = "up",
  j = "down",
  left = "left",
  right = "right",
  up = "up",
  down = "down",
}

for key, dir in pairs(dirs) do
  hl.bind(kb.go_to .. " + " .. key, hl.dsp.focus({ direction = dir }))
  hl.bind(kb.move_win .. " + " .. key, hl.dsp.window.move({ direction = dir }))
end

for i = 1, 10 do
  local key = tostring(i % 10)
  local ws = tostring(i)

  hl.bind(kb.go_to .. " + " .. key, hl.dsp.focus({ workspace = ws }))
  hl.bind(kb.move_win .. " + " .. key, hl.dsp.window.move({ workspace = ws, monitor = "current" }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

hl.bind(kb.go_to .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(kb.go_to .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("SUPER + R", hl.dsp.exec_cmd(apps.ipc .. " launcher toggle"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(apps.ipc .. " controlCenter toggle"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd(apps.ipc .. " settings toggle"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(apps.ipc .. " wallpaper toggle"))

hl.bind(kb.comm, hl.dsp.workspace.toggle_special("comm"))
hl.bind(kb.music, hl.dsp.workspace.toggle_special("music"))
hl.bind(kb.browser, hl.dsp.workspace.toggle_special("browser"))

hl.bind(kb.move_win .. " + M", hl.dsp.window.move({ workspace = "special:music" }))
hl.bind(kb.move_win .. " + C", hl.dsp.window.move({ workspace = "special:comm" }))
hl.bind(kb.move_win .. " + B", hl.dsp.window.move({ workspace = "special:browser" }))

hl.bind(kb.resize .. " + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
hl.bind(kb.resize .. " + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
hl.bind(kb.resize .. " + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
hl.bind(kb.resize .. " + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
