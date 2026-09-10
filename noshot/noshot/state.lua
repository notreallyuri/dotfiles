--- The one recording in flight, tracked in a file under $XDG_RUNTIME_DIR.

local config = require("noshot.config")
local shell = require("noshot.shell")

local M = {}

local KEYS = { "pid", "comm", "backend", "mode", "file", "start", "paused" }

--- Returns the state table, or nil when nothing is recording (a stale file
--- from a crashed recorder counts as nothing and is cleaned up). `comm` is
--- checked too, so a pid the kernel has since handed to something else does
--- not read as a recording still in flight — signalling it would hit an
--- innocent process.
function M.read()
  local f = io.open(config.state_file, "r")
  if not f then
    return nil
  end
  local t = {}
  for line in f:lines() do
    local k, v = line:match("^(%w+)=(.*)$")
    if k then
      t[k] = v
    end
  end
  f:close()
  if not shell.alive(t.pid, t.comm) then
    os.remove(config.state_file)
    return nil
  end
  return t
end

function M.write(t)
  local f = io.open(config.state_file, "w")
  if not f then
    return
  end
  for _, k in ipairs(KEYS) do
    if t[k] then
      f:write(k .. "=" .. tostring(t[k]) .. "\n")
    end
  end
  f:close()
end

function M.clear() os.remove(config.state_file) end

function M.elapsed(start)
  local secs = os.time() - (tonumber(start) or os.time())
  return string.format("%02d:%02d", secs // 60, secs % 60)
end

function M.human_size(file)
  local size = shell.sh("stat -c %s " .. shell.q(file) .. " 2>/dev/null")
  local bytes = tonumber(size)
  if not bytes then
    return "?"
  end
  if bytes > 1024 * 1024 * 1024 then
    return string.format("%.1f GiB", bytes / 1024 / 1024 / 1024)
  end
  return string.format("%.1f MiB", bytes / 1024 / 1024)
end

return M
