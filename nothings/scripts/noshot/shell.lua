--- Thin wrappers around the shell: quoting, running, reading output, and the
--- handful of file helpers everything else needs.

local config = require("noshot.config")

local M = {}

--- Single-quote a value so the shell treats it as one literal argument.
function M.q(s)
  return "'" .. (tostring(s):gsub("'", "'\\''")) .. "'"
end

function M.run(cmd)
  local ok, _, code = os.execute(cmd)
  return ok == true or ok == 0, code or 0
end

--- Run a command and return its trimmed stdout.
function M.sh(cmd)
  local pipe = io.popen(cmd, "r")
  if not pipe then
    return ""
  end
  local out = pipe:read("a") or ""
  pipe:close()
  return (out:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Like sh(), but keeps stderr and the exit status apart from stdout.
function M.sh_full(cmd)
  local out_path, err_path = os.tmpname(), os.tmpname()
  local ok = M.run(string.format("%s >%s 2>%s", cmd, M.q(out_path), M.q(err_path)))
  local function slurp(p)
    local f = io.open(p, "r")
    if not f then
      return ""
    end
    local s = f:read("a") or ""
    f:close()
    os.remove(p)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
  end
  return slurp(out_path), slurp(err_path), ok
end

local have_cache = {}

function M.have(bin)
  if have_cache[bin] == nil then
    have_cache[bin] = M.run("command -v " .. M.q(bin) .. " >/dev/null 2>&1")
  end
  return have_cache[bin]
end

function M.exists(path)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local size = f:seek("end")
  f:close()
  return size and size > 0
end

function M.sleep(seconds)
  M.run("sleep " .. seconds)
end

function M.ensure_dir(dir)
  M.run("mkdir -p " .. M.q(dir))
end

local FALLBACK_FORMAT = "%Y-%m-%d_%H-%M-%S"

--- Build a path that doesn't exist yet — two captures in the same second used
--- to silently overwrite each other.
function M.unique_path(dir, ext)
  -- name_format comes from the outside, so a bad one falls back instead of
  -- taking the capture down with it
  local ok, stamp = pcall(os.date, config.name_format)
  if not ok or type(stamp) ~= "string" or stamp == "" then
    io.stderr:write(string.format("noshot: name_format %q is not a valid date format, using %q\n",
      tostring(config.name_format), FALLBACK_FORMAT))
    stamp = os.date(FALLBACK_FORMAT)
  end

  local base = string.format("%s/%s", dir, stamp)
  local path = base .. ext
  local n = 1
  while M.exists(path) do
    path = string.format("%s-%d%s", base, n, ext)
    n = n + 1
  end
  return path
end

--- /home/me/Pictures/x.png -> ~/Pictures/x.png (plain match, not a pattern)
function M.shorten(path)
  local home = config.home
  if path:sub(1, #home) == home then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

return M
