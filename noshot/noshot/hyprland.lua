--- Asking Hyprland where things are, and letting the user point at them.

local config = require("noshot.config")
local lock = require("noshot.lock")
local notify = require("noshot.notify")
local shell = require("noshot.shell")

local q, sh = shell.q, shell.sh

local M = {}

--- If noshot is killed between freeze() and unfreeze() — a Ctrl-C, a crash —
--- nothing is left to take the overlay down, and the desktop looks stuck.
--- The watchdog bounds that to something a user can wait out.
local FREEZE_WATCHDOG = 120

function M.focused_output()
  notify.require_bins("hyprctl", "jq")
  return sh("hyprctl -j monitors | jq -r '.[] | select(.focused) | .name'")
end

function M.window_geom()
  notify.require_bins("hyprctl", "jq")
  local geom = sh(
    [[hyprctl -j activewindow | jq -r 'if .size then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else "" end']]
  )
  if geom == "" or geom:match("^0,0 0x0$") then
    return nil
  end
  return geom
end

local frozen_pid = nil

local function freeze()
  if not config.freeze or not shell.have("hyprpicker") or frozen_pid then
    return
  end
  local cmd = "hyprpicker -r -z"
  if shell.have("timeout") then
    cmd = "timeout " .. FREEZE_WATCHDOG .. " " .. cmd
  end
  frozen_pid = sh(cmd .. " >/dev/null 2>&1 & echo $!"):match("%d+")
  -- wait for the frozen overlay to actually map, instead of guessing a delay
  for _ = 1, 60 do
    if sh("hyprctl -j layers | jq -r '..|.namespace? // empty'"):find("hyprpicker", 1, true) then
      return
    end
    shell.sleep("0.02")
  end
end

local function unfreeze()
  if frozen_pid then
    shell.run("kill " .. frozen_pid .. " >/dev/null 2>&1")
    frozen_pid = nil
    shell.sleep("0.05")
  end
end

--- Run an interactive selection with the screen frozen underneath. Only one
--- noshot may be doing this at a time — see noshot/lock.lua.
local function select_frozen(cmd)
  lock.hold()
  freeze()
  local geom = sh(cmd)
  unfreeze()
  if geom == "" then
    lock.release()
    os.exit(0) -- selection cancelled
  end
  return geom
end

function M.select_region()
  notify.require_bins("slurp")
  return select_frozen("slurp " .. config.slurp_args .. " 2>/dev/null")
end

function M.select_output()
  notify.require_bins("slurp")
  return select_frozen("slurp -o " .. config.slurp_args .. " 2>/dev/null")
end

--- Click a window to capture it. Only windows currently on screen are
--- offered, which includes whatever special workspace happens to be open.
function M.select_window()
  notify.require_bins("slurp", "jq", "hyprctl")
  local visible = [["$(hyprctl -j monitors | jq -c ']]
      .. [[[.[].activeWorkspace.id, .[].specialWorkspace.id] | map(select(. != null and . != 0))')"]]
  local boxes = "hyprctl -j clients | jq -r --argjson ws " .. visible .. " "
      .. [['[.[] | select(.hidden == false and .size[0] > 0 and (.workspace.id | IN($ws[])))]]
      .. [[ | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"] | unique[]']]
  return select_frozen(boxes .. " | slurp -r " .. config.slurp_args .. " 2>/dev/null")
end

return M
