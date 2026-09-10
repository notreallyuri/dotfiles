--- Pointing grim at the right pixels.

local actions = require("noshot.actions")
local args = require("noshot.args")
local config = require("noshot.config")
local hyprland = require("noshot.hyprland")
local lock = require("noshot.lock")
local notify = require("noshot.notify")
local path = require("noshot.path")
local shell = require("noshot.shell")

local q = shell.q

local M = {}

local function grim(file, extra)
  local cmd = "grim "
  if config.cursor then
    cmd = cmd .. "-c "
  end
  -- a bare --scale carries no factor; grim would be handed "true"
  local scale = args.num("scale")
  if scale then
    cmd = cmd .. "-s " .. q(scale) .. " "
  end
  return shell.run(cmd .. (extra or "") .. q(file) .. " 2>/dev/null")
end

--- Capture `mode` into `file`. Returns true on success.
local function capture(mode, file)
  notify.require_bins("grim")

  if mode == "region" then
    return grim(file, "-g " .. q(hyprland.select_region()) .. " ")
  elseif mode == "window" then
    local geom
    if args.flag("pick", false) then
      geom = hyprland.select_window()
    else
      geom = hyprland.window_geom()
      if not geom then
        notify.die("Screenshot", "No active window to capture")
      end
    end
    return grim(file, "-g " .. q(geom) .. " ")
  elseif mode == "all" then
    return grim(file, "")
  elseif mode == "screen" then
    local output = args.flags.output
    if type(output) == "string" and output ~= "" then
      return grim(file, "-o " .. q(output) .. " ")
    elseif args.flag("pick", false) then
      return grim(file, "-g " .. q(hyprland.select_output()) .. " ")
    end
    output = hyprland.focused_output()
    if output == "" then
      return grim(file, "")
    end
    return grim(file, "-o " .. q(output) .. " ")
  end
  notify.die("Screenshot", "Unknown capture mode: " .. tostring(mode))
end

function M.take(mode)
  -- before the delay, so a second press during the countdown drops out too
  lock.hold()

  local delay = args.num("delay", 0)
  if delay > 0 then
    notify.send("Screenshot", string.format("Capturing in %ds…", delay), { timeout = delay * 1000 })
    shell.sleep(delay)
  end

  local dir = config.save and config.image_dir or config.runtime
  shell.ensure_dir(dir)
  local file = shell.unique_path(dir, ".png")

  if not capture(mode, file) or not path.nonempty(file) then
    os.remove(file)
    notify.die("Screenshot", "Capture failed")
  end
  -- with save off the file only exists to be copied, so it is ours to delete
  actions.process(file, not config.save)
end

--- Re-run the requested actions on the newest capture on disk. The file
--- belongs to the user, so it is never the throwaway kind.
function M.last()
  local file = shell.sh("ls -1t " .. q(config.image_dir) .. "/*.png 2>/dev/null | head -n1")
  if file == "" or not path.nonempty(file) then
    notify.die("Screenshot", "No previous capture found")
  end
  actions.process(file, false)
end

return M
