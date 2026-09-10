--- One interactive capture at a time.
---
--- Tapping the screenshot key twice used to start a second noshot on top of
--- the first. Each instance freezes the screen with its own hyprpicker
--- overlay, so the second one photographed the first one's overlay, the third
--- photographed that, and a few presses in the capture came out white. The
--- instance that loses the race now bows out instead.

local config = require("noshot.config")
local shell = require("noshot.shell")

local LOCK = config.runtime .. "/noshot-capture.lock"

local M = {}

local held = false

--- /proc/self is resolved by whoever opens it, so this reads our own process.
local function proc_self(name)
  local f = io.open("/proc/self/" .. name, "r")
  if not f then
    return nil
  end
  local line = f:read("l")
  f:close()
  return line
end

--- `set -C` makes the redirect fail when the file is already there, so of two
--- instances racing for the lock exactly one creates it.
local function claim(pid) return shell.run(string.format("(set -C; echo %s > %s) 2>/dev/null", pid, shell.q(LOCK))) end

--- The pid in the lock file, or nil when there is no lock to speak of.
local function holder()
  for _ = 1, 10 do
    local f = io.open(LOCK, "r")
    if not f then
      return nil
    end
    local pid = (f:read("l") or ""):match("%d+")
    f:close()
    if pid then
      return pid
    end
    shell.sleep("0.02") -- created but not written yet, by an instance racing us
  end
  return nil
end

--- Returns false when another noshot is already busy.
function M.acquire()
  if held then
    return true
  end

  local stat = proc_self("stat")
  local pid = stat and stat:match("^(%d+)")
  if not pid then
    return true -- no /proc to lock against: better to work than to refuse
  end

  if not claim(pid) then
    if shell.alive(holder(), proc_self("comm")) then
      return false
    end
    os.remove(LOCK) -- the holder died without cleaning up after itself
    if not claim(pid) then
      return false
    end
  end

  held = true
  return true
end

function M.release()
  if held then
    held = false
    os.remove(LOCK)
  end
end

--- Hold the lock or stop, quietly: the user is looking at the other
--- instance's selection, and a notification would land in their screenshot.
function M.hold()
  if M.acquire() then
    return
  end
  io.stderr:write("noshot: another capture is already in progress\n")
  os.exit(0)
end

return M
