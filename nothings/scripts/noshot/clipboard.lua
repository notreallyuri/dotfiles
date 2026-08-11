--- Wayland clipboard.

local notify = require("noshot.notify")
local shell = require("noshot.shell")

local M = {}

function M.image(file)
  notify.require_bins("wl-copy")
  -- without an explicit type wl-copy advertises text/plain and pastes garbage
  return shell.run("wl-copy --type image/png < " .. shell.q(file))
end

function M.text(text)
  local pipe = io.popen("wl-copy --trim-newline", "w")
  if not pipe then
    return false
  end
  pipe:write(text)
  return pipe:close() and true or false
end

return M
