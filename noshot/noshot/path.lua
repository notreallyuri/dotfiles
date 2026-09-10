--- Path helpers, with no dependencies of their own so that config.lua — which
--- everything else needs — can use them too.

local M = {}

--- Is there a file there at all?
function M.exists(path)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  f:close()
  return true
end

--- Is there a file there with anything in it? A capture that came out zero
--- bytes is a failed capture, not a screenshot.
function M.nonempty(path)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local size = f:seek("end")
  f:close()
  return size ~= nil and size > 0
end

--- ~/Pictures/x.png -> /home/me/Pictures/x.png
function M.expand(path, home)
  if path == "~" then
    return home
  end
  if path:sub(1, 2) == "~/" then
    return home .. path:sub(2)
  end
  return (path:gsub("^%$HOME", home))
end

--- /home/me/Pictures/x.png -> ~/Pictures/x.png (plain match, not a pattern)
function M.shorten(path, home)
  if path:sub(1, #home) == home then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

return M
