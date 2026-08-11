--- Desktop notifications, plus the two ways this script gives up.

local config = require("noshot.config")
local shell = require("noshot.shell")

local q = shell.q

local M = {}

--- opts: icon, urgency, timeout, actions = { { id, label, fn }, ... }
--- When actions are used the notification is synchronous: the chosen action's
--- callback runs before the script exits.
function M.send(title, body, opts)
  opts = opts or {}
  local timeout = opts.timeout or config.notify_timeout
  local cmd = { "notify-send", "-a", q("Screenshot"), "-t", tostring(timeout) }

  if opts.icon and shell.exists(opts.icon) then
    cmd[#cmd + 1] = "-i " .. q(opts.icon)
    cmd[#cmd + 1] = "-h " .. q("string:image-path:file://" .. opts.icon)
  elseif opts.icon then
    cmd[#cmd + 1] = "-i " .. q(opts.icon)
  end
  if opts.urgency then
    cmd[#cmd + 1] = "-u " .. opts.urgency
  end

  local actions = config.notify_actions and opts.actions or nil
  if actions and #actions > 0 then
    for _, a in ipairs(actions) do
      cmd[#cmd + 1] = "-A " .. q(a.id .. "=" .. a.label)
    end
    local line = string.format(
      "timeout %d %s %s %s 2>/dev/null",
      math.floor(timeout / 1000) + 5,
      table.concat(cmd, " "),
      q(title),
      q(body or "")
    )
    local chosen = shell.sh(line)
    for _, a in ipairs(actions) do
      if chosen == a.id and a.fn then
        a.fn()
      end
    end
  else
    shell.run(table.concat(cmd, " ") .. " " .. q(title) .. " " .. q(body or "") .. " >/dev/null 2>&1 &")
  end
end

function M.die(title, body)
  M.send(title, body, { urgency = "critical" })
  io.stderr:write(title .. ": " .. (body or "") .. "\n")
  os.exit(1)
end

function M.require_bins(...)
  local missing = {}
  for _, bin in ipairs({ ... }) do
    if not shell.have(bin) then
      missing[#missing + 1] = bin
    end
  end
  if #missing > 0 then
    M.die("Screenshot", "Missing dependency: " .. table.concat(missing, ", "))
  end
end

return M
