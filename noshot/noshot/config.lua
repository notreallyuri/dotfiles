--- Every option noshot has, and the layers allowed to change them.
---
--- Later layers win:
---   1. the defaults below
---   2. ~/.config/nothings/noshot.conf.lua        (hand written)
---   3. ~/.config/nothings/noshot.conf.d/*.lua    (hand written drop-ins)
---   4. ~/.local/state/noshot/*.lua               (written by front-ends)
---   5. NOSHOT_* environment variables
---   6. --key=value / --set key=value on the command line
---
--- Layer 4 is where a shell plugin (Noctalia) parks the settings it manages,
--- so the same values apply to a keybind that never goes through the shell.

local path = require("noshot.path")

local home = os.getenv("HOME")
if not home then
  os.execute('notify-send "Screenshot" "$HOME is not set!"')
  os.exit(1)
end

local function env_dir(name, fallback)
  local dir = os.getenv(name)
  if not dir or dir == "" then
    return fallback
  end
  return dir
end

local config_home = env_dir("XDG_CONFIG_HOME", home .. "/.config")
local state_home = env_dir("XDG_STATE_HOME", home .. "/.local/state")

--- The settable options and their types. Anything not listed here is refused
--- with a message instead of being quietly ignored, so a typo in a conf file
--- or a --flag is visible.
local SCHEMA = {
  image_dir = "path",
  video_dir = "path",
  name_format = "string",

  copy = "bool",
  save = "bool",
  freeze = "bool",
  cursor = "bool",
  record_cursor = "bool",

  editor_cmd = "string",
  browser = "string",
  viewer = "string",
  ocr_lang = "string",
  slurp_args = "string",

  upload_hosts = "table",
  lens_url = "string",

  recorder = "string",
  fps = "number",
  quality = "string",
  replay_seconds = "number",
  audio_desktop = "string",
  audio_mic = "string",

  notify_actions = "bool",
  notify_timeout = "number",
}

local M = {
  image_dir = home .. "/Pictures/Screenshots",
  video_dir = home .. "/Videos/Recordings",
  name_format = "%Y-%m-%d_%H-%M-%S",

  copy = true,
  save = true,
  freeze = true,
  -- the pointer is noise in a screenshot and the point of a screencast
  cursor = false,
  record_cursor = true,

  editor_cmd = "satty -f {file} -o {file} --copy-command wl-copy"
    .. " --early-exit --actions-on-enter save-to-file --init-tool brush",
  browser = "zen-browser",
  viewer = "xdg-open",
  ocr_lang = "eng",

  slurp_args = "-d -w 2",
  upload_hosts = {
    {
      url = "https://litterbox.catbox.moe/resources/internals/api.php",
      field = "fileToUpload",
      extra = "-F 'reqtype=fileupload' -F 'time=24h'",
    },
    {
      url = "https://catbox.moe/user/api.php",
      field = "fileToUpload",
      extra = "-F 'reqtype=fileupload' --http1.1",
    },
  },
  lens_url = "https://lens.google.com/uploadbyurl?url=",

  recorder = "gpu",
  fps = 60,
  quality = "very_high",
  replay_seconds = 120,
  audio_desktop = "default_output",
  audio_mic = "default_input",

  notify_actions = true,
  notify_timeout = 7000,
}

--- Where each option's current value came from, for `noshot config`.
local origins = {}
for key in pairs(SCHEMA) do
  origins[key] = "default"
end

local function warn(where, message) io.stderr:write(string.format("noshot: %s: %s\n", where, message)) end

local TRUE = { ["true"] = true, ["1"] = true, yes = true, on = true }
local FALSE = { ["false"] = true, ["0"] = true, no = true, off = true }

--- Turn an outside value (always a string, off the environment or the command
--- line) into the type the option is declared with.
local function coerce(key, value)
  local want = SCHEMA[key]
  if not want then
    return nil, "unknown option"
  end

  if want == "bool" then
    if type(value) == "boolean" then
      return value
    end
    local text = tostring(value):lower()
    if TRUE[text] then
      return true
    end
    if FALSE[text] then
      return false
    end
    return nil, "expected true or false, got " .. string.format("%q", tostring(value))
  end

  if want == "number" then
    local n = tonumber(value)
    if not n then
      return nil, "expected a number, got " .. string.format("%q", tostring(value))
    end
    return n
  end

  if want == "table" then
    if type(value) ~= "table" then
      return nil, "expected a table (set it from a conf file, not a flag)"
    end
    return value
  end

  if type(value) == "table" then
    return nil, "expected a string"
  end
  value = tostring(value)
  if want == "path" then
    value = path.expand(value, home)
  end
  return value
end

--- /home/me/Pictures/x.png -> ~/Pictures/x.png
function M.shorten(file) return path.shorten(file, home) end

--- Merge a table of options into the config, reporting anything unusable.
local function apply(tbl, origin)
  for key, raw in pairs(tbl) do
    local value, err = coerce(key, raw)
    if err then
      warn(origin, key .. ": " .. err)
    else
      M[key] = value
      origins[key] = origin
    end
  end
end

local function load_file(file)
  if not path.exists(file) then
    return
  end
  local ok, user = pcall(dofile, file)
  if not ok then
    warn(M.shorten(file), tostring(user))
  elseif type(user) ~= "table" then
    warn(M.shorten(file), "expected the file to return a table")
  else
    apply(user, M.shorten(file))
  end
end

local function load_dir(dir)
  local pipe = io.popen("LC_ALL=C ls -1 '" .. dir:gsub("'", "'\\''") .. "'/*.lua 2>/dev/null")
  if not pipe then
    return
  end
  for line in pipe:lines() do
    load_file(line)
  end
  pipe:close()
end

load_file(config_home .. "/nothings/noshot.conf.lua")
load_dir(config_home .. "/nothings/noshot.conf.d")
load_dir(state_home .. "/noshot")

-- NOSHOT_OCR_LANG=por noshot region --ocr
for key in pairs(SCHEMA) do
  local raw = os.getenv("NOSHOT_" .. key:upper())
  if raw and raw ~= "" then
    apply({ [key] = raw }, "$NOSHOT_" .. key:upper())
  end
end

--- The last layer: options given on the command line, either as `--key=value`
--- (dashes and underscores both work) or `--set key=value`. Called from the
--- CLI once the arguments are parsed, since every module reads options lazily.
function M.apply_args(args)
  for _, pair in ipairs(args.sets or {}) do
    local key, value = pair:match("^([%w_%-]+)=(.*)$")
    if not key then
      warn("--set", string.format("expected key=value, got %q", pair))
    else
      apply({ [(key:gsub("%-", "_"))] = value }, "--set")
    end
  end

  for key in pairs(SCHEMA) do
    local value = args.flags[key]
    if value == nil then
      value = args.flags[(key:gsub("_", "-"))]
    end
    if value ~= nil then
      apply({ [key] = value }, "--" .. (key:gsub("_", "-")))
    end
  end
end

--- Every option, sorted, with its type and where its value came from.
function M.describe()
  local out = {}
  for key, kind in pairs(SCHEMA) do
    out[#out + 1] = { key = key, type = kind, value = M[key], origin = origins[key] }
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

M.paths = {
  config = config_home .. "/nothings/noshot.conf.lua",
  drop_in = config_home .. "/nothings/noshot.conf.d",
  generated = state_home .. "/noshot",
}

-- derived, not configurable
M.home = home
M.runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
M.state_file = M.runtime .. "/noshot-record.state"
M.log_file = M.runtime .. "/noshot-record.log"

return M
