--- Getting a capture onto the internet, and reverse searching it.

local args = require("noshot.args")
local clipboard = require("noshot.clipboard")
local config = require("noshot.config")
local notify = require("noshot.notify")
local shell = require("noshot.shell")

local q = shell.q

local M = {}

local function urlencode(s)
  return (s:gsub("[^%w%-%._~]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

--- Try each configured host in order until one returns a URL.
--- Returns the image URL, or nil plus the last failure reason.
function M.image(file)
  local reason = "no upload hosts configured"

  for _, host in ipairs(config.upload_hosts or {}) do
    local cmd = string.format(
      "curl -sS -L --fail-with-body --connect-timeout 10 --max-time 120 -A %s %s -F %s %s",
      q("Mozilla/5.0 (X11; Linux x86_64) noshot"),
      host.extra or "",
      q((host.field or "file") .. "=@" .. file),
      q(host.url)
    )

    local out, err = shell.sh_full(cmd)
    if args.flags.debug then
      io.stderr:write(string.format("%s\n  cmd: %s\n  stdout: [%s]\n  stderr: [%s]\n",
        host.url, cmd, out, err))
    end

    local url = out:match("https?://[^%s\"'<>]+")
    if url then
      return url
    end

    reason = out ~= "" and out or (err ~= "" and err or "the host returned nothing")
    if args.flags.debug then
      io.stderr:write("  -> failed: " .. reason .. "\n")
    end
  end

  return nil, reason
end

function M.search(file)
  notify.require_bins("curl")
  notify.send("Reverse search", "Uploading capture…", { icon = file, timeout = 3000 })

  local url, reason = M.image(file)
  if not url then
    notify.send("Reverse search failed", reason, { urgency = "critical", timeout = 12000 })
    io.stderr:write("upload failed: " .. reason .. "\n")
    return false
  end

  -- browser may carry arguments ("flatpak run org.mozilla.firefox"); only the
  -- first word is a program to look for, but the whole line is what runs
  local browser = config.browser
  if not shell.have(browser:match("^%S+") or "") then
    browser = "xdg-open"
  end
  shell.run("setsid -f " .. browser .. " " .. q(config.lens_url .. urlencode(url)) .. " >/dev/null 2>&1")
  clipboard.text(url)
  notify.send("Reverse search", "Opened Google Lens — image URL copied", { icon = file })
  return true
end

return M
