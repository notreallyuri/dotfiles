--!nonstrict
-- Three jobs:
--   * find the noshot script and publish it for the other entries
--   * publish the recording status the widget and panel render
--   * mirror the settings above into a config drop-in noshot reads, so a
--     Hyprland keybind that never touches Noctalia still gets them
--
-- It also answers IPC, which is what makes the plugin usable without the
-- dotfiles it came from:
--
--   noctalia msg plugin nothings/noshot:state all region --edit
--   noctalia msg plugin nothings/noshot:state all run "screen --delay=5"
--   noctalia msg plugin nothings/noshot:state all panel

local home = noctalia.getenv("HOME") or ""
local runtime = noctalia.getenv("XDG_RUNTIME_DIR") or "/tmp"
local statePath = runtime .. "/noshot-record.state"

local stateHome = noctalia.getenv("XDG_STATE_HOME")
if not stateHome or stateHome == "" then
  stateHome = home .. "/.local/state"
end
local syncDir = stateHome .. "/noshot"
local syncPath = syncDir .. "/50-noctalia.lua"

--------------------------------------------------------------------------------
-- where the script is
--------------------------------------------------------------------------------

local PANEL = "nothings/noshot:menu"

--- The setting wins, then the copy shipped in bin/, then $PATH. Everything
--- else reads the answer off the shared state, so this stays the only place
--- that knows how the script is found.
local function resolveScript(): string?
  local configured = noctalia.getConfig("script_path")
  if configured and configured ~= "" then
    local path = noctalia.expandPath(configured)
    if noctalia.fileExists(path) then
      return path
    end
  end

  local dir = noctalia.pluginDir()
  if dir then
    local bundled = dir .. "/bin/noshot.lua"
    if noctalia.fileExists(bundled) then
      return bundled
    end
  end

  for _, name in ipairs({ "noshot", "noshot.lua" }) do
    if noctalia.commandExists(name) then
      return name
    end
  end

  return nil
end

local script: string? = nil
local complained = false

local function publishScript()
  script = resolveScript()
  noctalia.state.set("script", script)
  if not script and not complained then
    complained = true
    noctalia.notifyError("noshot", "Could not find noshot.lua — set its path in the plugin settings.")
  end
end

--- Run a noshot command line. Shared by IPC and by anything else here.
local function run(argv: string)
  if not script then
    publishScript()
  end
  if not script then
    return
  end
  noctalia.runAsync(string.format("'%s' %s", script, argv))
end

--------------------------------------------------------------------------------
-- settings -> ~/.local/state/noshot/50-noctalia.lua
--------------------------------------------------------------------------------

-- These carry the same defaults as noshot's own, so the settings page shows
-- real values rather than blanks. A key is only left out when its value would
-- be nonsense (a cleared text field, a non-positive number), and noshot then
-- falls back to its built-in default for that one.
local FORWARD = {
  { key = "image_dir",      kind = "string" },
  { key = "video_dir",      kind = "string" },
  { key = "name_format",    kind = "string" },
  { key = "browser",        kind = "string" },
  { key = "viewer",         kind = "string" },
  { key = "ocr_lang",       kind = "string" },
  { key = "editor_cmd",     kind = "string" },
  { key = "slurp_args",     kind = "string" },
  { key = "audio_desktop",  kind = "string" },
  { key = "audio_mic",      kind = "string" },
  { key = "recorder",       kind = "string" },
  { key = "quality",        kind = "string" },
  { key = "fps",            kind = "number" },
  { key = "replay_seconds", kind = "number" },
  { key = "notify_timeout", kind = "number" },
  { key = "copy",           kind = "bool" },
  { key = "save",           kind = "bool" },
  { key = "freeze",         kind = "bool" },
  { key = "cursor",         kind = "bool" },
  { key = "notify_actions", kind = "bool" },
}

--- Bool settings come back as a string on some API versions.
local function truthy(v): boolean
  return v == true or v == "true" or v == 1 or v == "1"
end

local function literal(entry): string?
  local raw = noctalia.getConfig(entry.key)
  if raw == nil then
    return nil
  end

  if entry.kind == "bool" then
    return truthy(raw) and "true" or "false"
  end

  if entry.kind == "number" then
    local n = tonumber(raw)
    if not n or n <= 0 then
      return nil
    end
    return tostring(math.floor(n))
  end

  local text = tostring(raw)
  if text == "" then
    return nil
  end
  return string.format("%q", text)
end

local function render(): string
  local lines = {
    "-- Written by the Noctalia plugin nothings/noshot.",
    "-- Edits here are overwritten; change the values in the plugin settings,",
    "-- or turn the sync off and use ~/.config/nothings/noshot.conf.lua.",
    "return {",
  }
  for _, entry in ipairs(FORWARD) do
    local value = literal(entry)
    if value then
      lines[#lines + 1] = string.format("  %s = %s,", entry.key, value)
    end
  end
  lines[#lines + 1] = "}"
  return table.concat(lines, "\n") .. "\n"
end

local function sync()
  if not truthy(noctalia.getConfig("sync_settings")) then
    if noctalia.fileExists(syncPath) then
      noctalia.removeFile(syncPath)
    end
    return
  end

  local wanted = render()
  if noctalia.fileExists(syncPath) and noctalia.readFile(syncPath) == wanted then
    return -- nothing changed, don't churn the file
  end
  noctalia.mkdirAll(syncDir)
  noctalia.writeFile(syncPath, wanted)
end

--------------------------------------------------------------------------------
-- recording status
--------------------------------------------------------------------------------

local published = nil

local function parse()
  if not noctalia.fileExists(statePath) then return nil end
  local raw = noctalia.readFile(statePath)
  if not raw then return nil end

  local t = {}
  for line in raw:gmatch("[^\n]+") do
    local k, v = line:match("^(%w+)=(.*)$")
    if k then t[k] = v end
  end
  -- the recorder died without cleaning up
  if not t.pid or not noctalia.fileExists("/proc/" .. t.pid) then return nil end

  local secs = os.time() - (tonumber(t.start) or os.time())
  return {
    recording = true,
    mode      = t.mode,
    paused    = t.paused == "1",
    file      = t.file,
    elapsed   = string.format("%02d:%02d", secs // 60, secs % 60),
  }
end

noctalia.setUpdateInterval(1000)

function update()
  local s = parse()
  local key = s and (s.mode .. s.elapsed .. tostring(s.paused)) or "idle"
  if key ~= published then
    published = key
    noctalia.state.set("status", s or { recording = false })
  end
end

--------------------------------------------------------------------------------
-- IPC
--------------------------------------------------------------------------------

-- Everything the CLI takes, so `noctalia msg plugin … all region --edit` and
-- `noshot region --edit` are the same thing.
local COMMANDS = {
  region = true, screen = true, full = true, fullscreen = true, window = true,
  all = true, last = true, record = true, ["record-stop"] = true,
  ["record-pause"] = true, replay = true, ["replay-save"] = true, config = true,
  help = true,
}

function onIpc(event: string, payload: string?)
  local args = payload or ""

  if event == "run" then
    -- the whole command line in the payload: run "screen --delay=5"
    if args == "" then
      noctalia.notifyError("noshot", "run needs a command, e.g. run \"region --edit\"")
      return
    end
    run(args)
  elseif event == "panel" then
    noctalia.togglePanel(PANEL)
  elseif event == "sync" then
    sync()
  elseif event == "rescan" then
    publishScript()
  elseif COMMANDS[event] then
    run(args ~= "" and (event .. " " .. args) or event)
  else
    noctalia.notifyError("noshot", string.format("Unknown IPC event %q", event))
  end
end

function onConfigChanged()
  publishScript()
  sync()
end

publishScript()
sync()
update()
