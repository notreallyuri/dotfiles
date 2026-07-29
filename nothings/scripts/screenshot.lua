#!/usr/bin/env lua
--- screenshot.lua — capture, annotate and record helper for Hyprland.
--- Run `screenshot.lua help` for the full command list.

local home = os.getenv("HOME")
if not home then
  os.execute('notify-send "Screenshot" "$HOME is not set!"')
  os.exit(1)
end

local runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"

--------------------------------------------------------------------------------
-- config
--------------------------------------------------------------------------------

local config = {
  image_dir = home .. "/Pictures/Screenshots",
  video_dir = home .. "/Videos/Recordings",
  name_format = "%Y-%m-%d_%H-%M-%S",

  copy = true,
  save = true,
  freeze = true,
  cursor = false,

  editor_cmd = "satty -f {file} -o {file} --copy-command wl-copy"
      .. " --early-exit --actions-on-enter save-to-file --init-tool brush",
  browser = "zen-browser",
  viewer = "xdg-open",
  ocr_lang = "eng",

  slurp_args = "-d -w 2",
  upload_url = "https://catbox.moe/user/api.php",
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

-- optional overrides: return a table of the keys above
do
  local ok, user = pcall(dofile, home .. "/.config/nothings/screenshot.conf.lua")
  if ok and type(user) == "table" then
    for k, v in pairs(user) do
      config[k] = v
    end
  end
end

local state_file = runtime .. "/nothings-record.state"
local log_file = runtime .. "/nothings-record.log"

--------------------------------------------------------------------------------
-- shell helpers
--------------------------------------------------------------------------------

--- Single-quote a value so the shell treats it as one literal argument.
local function q(s)
  return "'" .. (tostring(s):gsub("'", "'\\''")) .. "'"
end

local function run(cmd)
  local ok, _, code = os.execute(cmd)
  return ok == true or ok == 0, code or 0
end

--- Run a command and return its trimmed stdout.
local function sh(cmd)
  local pipe = io.popen(cmd, "r")
  if not pipe then
    return ""
  end
  local out = pipe:read("a") or ""
  pipe:close()
  return (out:gsub("^%s+", ""):gsub("%s+$", ""))
end

local have_cache = {}
local function have(bin)
  if have_cache[bin] == nil then
    have_cache[bin] = run("command -v " .. q(bin) .. " >/dev/null 2>&1")
  end
  return have_cache[bin]
end

local function exists(path)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local size = f:seek("end")
  f:close()
  return size and size > 0
end

local function sleep(seconds)
  run("sleep " .. seconds)
end

--- /home/me/Pictures/x.png -> ~/Pictures/x.png (plain match, not a pattern)
local function shorten(path)
  if path:sub(1, #home) == home then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

--------------------------------------------------------------------------------
-- notifications
--------------------------------------------------------------------------------

--- opts: icon, urgency, timeout, actions = { { id, label, fn }, ... }
--- When actions are used the notification is synchronous: the chosen action's
--- callback runs before the script exits.
local function notify(title, body, opts)
  opts = opts or {}
  local timeout = opts.timeout or config.notify_timeout
  local cmd = { "notify-send", "-a", q("Screenshot"), "-t", tostring(timeout) }

  if opts.icon and exists(opts.icon) then
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
    local chosen = sh(line)
    for _, a in ipairs(actions) do
      if chosen == a.id and a.fn then
        a.fn()
      end
    end
  else
    run(table.concat(cmd, " ") .. " " .. q(title) .. " " .. q(body or "") .. " >/dev/null 2>&1 &")
  end
end

local function die(title, body)
  notify(title, body, { urgency = "critical" })
  io.stderr:write(title .. ": " .. (body or "") .. "\n")
  os.exit(1)
end

local function require_bins(...)
  local missing = {}
  for _, bin in ipairs({ ... }) do
    if not have(bin) then
      missing[#missing + 1] = bin
    end
  end
  if #missing > 0 then
    die("Screenshot", "Missing dependency: " .. table.concat(missing, ", "))
  end
end

--------------------------------------------------------------------------------
-- argument parsing
--------------------------------------------------------------------------------

local flags, positional = {}, {}
for i = 1, #arg do
  local a = arg[i]
  local key, value = a:match("^%-%-([%w%-]+)=(.*)$")
  if key then
    flags[key] = value
  elseif a:match("^%-%-no%-") then
    flags[a:sub(6)] = false
  elseif a:match("^%-%-") then
    flags[a:sub(3)] = true
  else
    positional[#positional + 1] = a
  end
end

local command = positional[1] or "help"

-- Backwards compatible positional action: `screenshot.lua region ocr`
local legacy = positional[2]
if legacy and flags[legacy] == nil then
  if legacy == "ocr" or legacy == "search" or legacy == "edit" or legacy == "open" then
    flags[legacy] = true
  elseif legacy == "copy" then
    flags.save = false
  end
end

local function flag(name, default)
  local v = flags[name]
  if v == nil then
    return default
  end
  return v
end

local function num_flag(name, default)
  local v = tonumber(flags[name])
  return v or default
end

--------------------------------------------------------------------------------
-- hyprland / geometry
--------------------------------------------------------------------------------

local function focused_output()
  require_bins("hyprctl", "jq")
  return sh("hyprctl -j monitors | jq -r '.[] | select(.focused) | .name'")
end

local function active_window_geom()
  require_bins("hyprctl", "jq")
  local geom = sh(
    [[hyprctl -j activewindow | jq -r 'if .size then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else "" end']]
  )
  if geom == "" or geom:match("^0,0 0x0$") then
    return nil
  end
  return geom
end

local frozen_pid = nil

local function freeze()
  if not config.freeze or not have("hyprpicker") or frozen_pid then
    return
  end
  frozen_pid = sh("hyprpicker -r -z >/dev/null 2>&1 & echo $!"):match("%d+")
  -- wait for the frozen overlay to actually map, instead of guessing a delay
  for _ = 1, 60 do
    if sh("hyprctl -j layers | jq -r '..|.namespace? // empty'"):find("hyprpicker", 1, true) then
      return
    end
    sleep("0.02")
  end
end

local function unfreeze()
  if frozen_pid then
    run("kill " .. frozen_pid .. " >/dev/null 2>&1")
    frozen_pid = nil
    sleep("0.05")
  end
end

--- Run an interactive selection with the screen frozen underneath.
local function select_frozen(cmd)
  freeze()
  local geom = sh(cmd)
  unfreeze()
  if geom == "" then
    os.exit(0) -- selection cancelled
  end
  return geom
end

local function select_region()
  require_bins("slurp")
  return select_frozen("slurp " .. config.slurp_args .. " 2>/dev/null")
end

local function select_output()
  require_bins("slurp")
  return select_frozen("slurp -o " .. config.slurp_args .. " 2>/dev/null")
end

--- Click a window to capture it. Only windows currently on screen are
--- offered, which includes whatever special workspace happens to be open.
local function select_window()
  require_bins("slurp", "jq", "hyprctl")
  local visible = [["$(hyprctl -j monitors | jq -c ']]
      .. [[[.[].activeWorkspace.id, .[].specialWorkspace.id] | map(select(. != null and . != 0))')"]]
  local boxes = "hyprctl -j clients | jq -r --argjson ws " .. visible .. " "
      .. [['[.[] | select(.hidden == false and .size[0] > 0 and (.workspace.id | IN($ws[])))]]
      .. [[ | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"] | unique[]']]
  return select_frozen(boxes .. " | slurp -r " .. config.slurp_args .. " 2>/dev/null")
end

--- "x,y wxh" (slurp) -> "wxh+x+y" (gpu-screen-recorder)
local function to_gsr_region(geom)
  local x, y, w, h = geom:match("^(%-?%d+),(%-?%d+) (%d+)x(%d+)$")
  if not x then
    return nil
  end
  return string.format("%sx%s+%s+%s", w, h, x, y)
end

--------------------------------------------------------------------------------
-- capture
--------------------------------------------------------------------------------

local function timestamp()
  return os.date(config.name_format)
end

local function ensure_dir(dir)
  run("mkdir -p " .. q(dir))
end

--- Build a path that doesn't exist yet — two captures in the same second used
--- to silently overwrite each other.
local function unique_path(dir, ext)
  local base = string.format("%s/%s", dir, timestamp())
  local path = base .. ext
  local n = 1
  while exists(path) do
    path = string.format("%s-%d%s", base, n, ext)
    n = n + 1
  end
  return path
end

local function grim(file, args)
  local cmd = "grim "
  if flag("cursor", config.cursor) then
    cmd = cmd .. "-c "
  end
  if flags.scale then
    cmd = cmd .. "-s " .. q(flags.scale) .. " "
  end
  return run(cmd .. (args or "") .. q(file) .. " 2>/dev/null")
end

--- Capture `mode` into `file`. Returns true on success.
local function capture(mode, file)
  require_bins("grim")

  if mode == "region" then
    return grim(file, "-g " .. q(select_region()) .. " ")
  elseif mode == "window" then
    local geom
    if flag("pick", false) then
      geom = select_window()
    else
      geom = active_window_geom()
      if not geom then
        die("Screenshot", "No active window to capture")
      end
    end
    return grim(file, "-g " .. q(geom) .. " ")
  elseif mode == "all" then
    return grim(file, "")
  elseif mode == "screen" then
    local output = flags.output
    if type(output) == "string" and output ~= "" then
      return grim(file, "-o " .. q(output) .. " ")
    elseif flag("pick", false) then
      return grim(file, "-g " .. q(select_output()) .. " ")
    end
    output = focused_output()
    if output == "" then
      return grim(file, "")
    end
    return grim(file, "-o " .. q(output) .. " ")
  end
  die("Screenshot", "Unknown capture mode: " .. tostring(mode))
end

--------------------------------------------------------------------------------
-- post-processing
--------------------------------------------------------------------------------

local function copy_image(file)
  require_bins("wl-copy")
  -- without an explicit type wl-copy advertises text/plain and pastes garbage
  return run("wl-copy --type image/png < " .. q(file))
end

local function copy_text(text)
  local pipe = io.popen("wl-copy --trim-newline", "w")
  if not pipe then
    return false
  end
  pipe:write(text)
  return pipe:close() and true or false
end

local function open_file(file)
  run("setsid -f " .. config.viewer .. " " .. q(file) .. " >/dev/null 2>&1")
end

local function edit_image(file)
  local editor = config.editor_cmd:match("^%S+")
  if not have(editor) then
    notify("Screenshot", editor .. " is not installed", { urgency = "critical" })
    return false
  end
  local cmd = (config.editor_cmd:gsub("{file}", function()
    return q(file)
  end))
  return run(cmd .. " >/dev/null 2>&1")
end

local function ocr_image(file)
  require_bins("tesseract")
  local lang = type(flags.ocr) == "string" and flags.ocr or config.ocr_lang
  local text = sh(string.format("tesseract %s - -l %s 2>/dev/null", q(file), q(lang)))
  if text == "" then
    notify("OCR", "No text found in the capture", { icon = file, urgency = "critical" })
    return false
  end
  if not copy_text(text) then
    notify("OCR", "Failed to copy text to the clipboard", { urgency = "critical" })
    return false
  end
  local preview = text:gsub("%s+", " ")
  if #preview > 120 then
    preview = preview:sub(1, 120) .. "…"
  end
  notify("OCR — text copied", preview, { icon = file })
  return true
end

local function search_image(file)
  require_bins("curl")
  notify("Reverse search", "Uploading capture…", { icon = file, timeout = 3000 })

  local url = sh(string.format(
    "curl -sS --connect-timeout 10 --max-time 60 -F %s -F %s %s 2>/dev/null",
    q("reqtype=fileupload"),
    q("fileToUpload=@" .. file),
    q(config.upload_url)
  ))

  if not url:match("^https?://") then
    notify("Reverse search failed", url ~= "" and url or "Upload returned nothing", { urgency = "critical" })
    return false
  end

  local browser = config.browser:match("^%S+")
  if not have(browser) then
    browser = "xdg-open"
  end
  run("setsid -f " .. browser .. " " .. q(config.lens_url .. url) .. " >/dev/null 2>&1")
  copy_text(url)
  notify("Reverse search", "Opened Google Lens — image URL copied", { icon = file })
  return true
end

--- Apply the requested actions to a finished capture and report the result.
local function process(file)
  local keep = flag("save", config.save)

  if flag("edit", false) then
    edit_image(file)
    if not exists(file) then
      os.exit(0) -- editor discarded the capture
    end
  end

  local did_something = false
  if flag("ocr", false) then
    ocr_image(file)
    did_something = true
  end
  if flag("search", false) then
    search_image(file)
    did_something = true
  end

  if flag("copy", config.copy) and not flag("ocr", false) then
    copy_image(file)
  end
  if flag("open", false) then
    open_file(file)
  end

  if not keep then
    os.remove(file)
    if not did_something then
      notify("Screenshot", "Copied to the clipboard")
    end
    return
  end

  if did_something then
    return -- the action already notified, don't stack a second popup
  end

  notify("Screenshot saved", shorten(file), {
    icon = file,
    actions = {
      {
        id = "open",
        label = "Open",
        fn = function()
          open_file(file)
        end
      },
      {
        id = "edit",
        label = "Edit",
        fn = function()
          edit_image(file)
          copy_image(file)
        end
      },
      {
        id = "path",
        label = "Copy path",
        fn = function()
          copy_text(file)
        end
      },
      {
        id = "delete",
        label = "Delete",
        fn = function()
          os.remove(file)
          notify("Screenshot", "Deleted")
        end
      },
    },
  })
end

local function do_capture(mode)
  local delay = num_flag("delay", 0)
  if delay > 0 then
    notify("Screenshot", string.format("Capturing in %ds…", delay), { timeout = delay * 1000 })
    sleep(delay)
  end

  local keep = flag("save", config.save)
  local dir = keep and config.image_dir or runtime
  ensure_dir(dir)
  local file = unique_path(dir, ".png")

  if not capture(mode, file) or not exists(file) then
    os.remove(file)
    die("Screenshot", "Capture failed")
  end
  process(file)
end

--------------------------------------------------------------------------------
-- recording state
--------------------------------------------------------------------------------

local State = {}

function State.read()
  local f = io.open(state_file, "r")
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
  if not t.pid or not run("kill -0 " .. t.pid .. " >/dev/null 2>&1") then
    os.remove(state_file)
    return nil
  end
  return t
end

function State.write(t)
  local f = io.open(state_file, "w")
  if not f then
    return
  end
  for _, k in ipairs({ "pid", "backend", "mode", "file", "start", "paused" }) do
    if t[k] then
      f:write(k .. "=" .. tostring(t[k]) .. "\n")
    end
  end
  f:close()
end

function State.clear()
  os.remove(state_file)
end

local function elapsed_string(start)
  local secs = os.time() - (tonumber(start) or os.time())
  return string.format("%02d:%02d", secs // 60, secs % 60)
end

local function human_size(file)
  local size = sh("stat -c %s " .. q(file) .. " 2>/dev/null")
  local bytes = tonumber(size)
  if not bytes then
    return "?"
  end
  if bytes > 1024 * 1024 * 1024 then
    return string.format("%.1f GiB", bytes / 1024 / 1024 / 1024)
  end
  return string.format("%.1f MiB", bytes / 1024 / 1024)
end

--------------------------------------------------------------------------------
-- recording
--------------------------------------------------------------------------------

local function recorder_backend()
  local backend = flags.backend or config.recorder
  if backend == "gpu" and not have("gpu-screen-recorder") then
    backend = "wf"
  end
  if backend == "wf" and not have("wf-recorder") then
    die("Recording", "Install gpu-screen-recorder or wf-recorder")
  end
  return backend
end

--- Where to record: an output name or a region geometry.
local function record_target()
  if flag("region", false) then
    return { geom = select_region(), label = "region" }
  elseif flag("window", false) then
    local geom = flag("pick", false) and select_window() or active_window_geom()
    if not geom then
      die("Recording", "No active window to record")
    end
    return { geom = geom, label = "window" }
  elseif type(flags.output) == "string" then
    return { output = flags.output, label = flags.output }
  elseif flag("pick", false) then
    return { geom = select_output(), label = "monitor" }
  end
  local output = focused_output()
  if output == "" then
    output = "screen" -- gpu-screen-recorder's "whatever is focused" target
  end
  return { output = output, label = output }
end

local function audio_sources(backend)
  local want_desktop = flag("audio", false)
  local want_mic = flag("mic", false)
  if not want_desktop and not want_mic then
    return nil
  end

  if backend == "gpu" then
    local parts = {}
    if want_desktop then
      parts[#parts + 1] = config.audio_desktop
    end
    if want_mic then
      parts[#parts + 1] = config.audio_mic
    end
    return "-a " .. q(table.concat(parts, "|"))
  end

  -- wf-recorder takes a single pulse device
  local device
  if want_mic and not want_desktop then
    device = sh("pactl get-default-source 2>/dev/null")
  else
    device = sh("pactl get-default-sink 2>/dev/null")
    device = device ~= "" and (device .. ".monitor") or ""
  end
  if device == "" then
    return "--audio"
  end
  return "--audio=" .. q(device)
end

--- Start `cmd` detached and return its pid.
local function spawn_pid(cmd)
  local line = string.format(
    "setsid sh -c %s >/dev/null 2>&1 & echo $!",
    q("exec " .. cmd .. " >>" .. q(log_file) .. " 2>&1")
  )
  return sh(line):match("%d+")
end

local function build_record_cmd(backend, target, file, replay)
  local audio = audio_sources(backend) or ""
  local cursor = flag("cursor", true) and "yes" or "no"

  if backend == "gpu" then
    local window, extra = target.output or "screen", ""
    if target.geom then
      local region = to_gsr_region(target.geom)
      if not region then
        die("Recording", "Could not parse the selected region")
      end
      window, extra = "region", "-region " .. q(region)
    end
    -- in replay mode -o is the directory clips land in, so the container
    -- format has to be spelled out separately
    local out = "-o " .. q(replay and config.video_dir or file) .. (replay and " -c mp4" or "")
    return string.format(
      "gpu-screen-recorder -w %s %s -f %d -q %s -cursor %s %s %s %s",
      q(window),
      extra,
      num_flag("fps", config.fps),
      q(flags.quality or config.quality),
      cursor,
      replay and ("-r " .. num_flag("seconds", config.replay_seconds) .. " -replay-storage ram") or "",
      audio,
      out
    )
  end

  if replay then
    die("Recording", "Replay mode needs gpu-screen-recorder")
  end
  local scope = ""
  if target.geom then
    scope = "-g " .. q(target.geom)
  elseif target.output and target.output ~= "screen" then
    scope = "-o " .. q(target.output)
  end
  return string.format("wf-recorder %s %s -r %d -f %s", scope, audio, num_flag("fps", config.fps), q(file))
end

local function record_start(replay)
  local backend = recorder_backend()
  local target = record_target()
  ensure_dir(config.video_dir)
  local file = unique_path(config.video_dir, ".mp4")
  os.remove(log_file)

  local pid = spawn_pid(build_record_cmd(backend, target, file, replay))
  sleep("0.6")
  if not pid or not run("kill -0 " .. pid .. " >/dev/null 2>&1") then
    local err = sh("tail -n 3 " .. q(log_file) .. " 2>/dev/null")
    die("Recording failed", err ~= "" and err or "The recorder exited immediately")
  end

  State.write({
    pid = pid,
    backend = backend,
    mode = replay and "replay" or "record",
    file = replay and config.video_dir or file,
    start = os.time(),
  })

  if replay then
    notify(
      "Replay buffer armed",
      string.format("Keeping the last %ds of %s", num_flag("seconds", config.replay_seconds), target.label)
    )
  else
    notify(
      "Recording started",
      string.format("%s · %s%s", target.label, backend == "gpu" and "GPU" or "CPU",
        audio_sources(backend) and " · audio" or "")
    )
  end
end

local function record_stop()
  local st = State.read()
  if not st then
    notify("Recording", "Nothing is being recorded")
    return
  end

  run("kill -s INT " .. st.pid .. " >/dev/null 2>&1")
  for _ = 1, 100 do -- give the muxer time to finalise the file
    if not run("kill -0 " .. st.pid .. " >/dev/null 2>&1") then
      break
    end
    sleep("0.1")
  end
  State.clear()

  if st.mode == "replay" then
    notify("Replay buffer stopped", "")
    return
  end

  if not exists(st.file) then
    die("Recording", "The recorder produced no file — see " .. log_file)
  end

  local file = st.file
  notify("Recording saved", string.format("%s · %s · %s", shorten(file), elapsed_string(st.start), human_size(file)), {
    actions = {
      {
        id = "open",
        label = "Play",
        fn = function()
          open_file(file)
        end
      },
      {
        id = "folder",
        label = "Folder",
        fn = function()
          open_file(config.video_dir)
        end
      },
      {
        id = "path",
        label = "Copy path",
        fn = function()
          copy_text(file)
        end
      },
      {
        id = "delete",
        label = "Delete",
        fn = function()
          os.remove(file)
          notify("Recording", "Deleted")
        end
      },
    },
  })
end

local function record_toggle(replay)
  if State.read() then
    record_stop()
  else
    record_start(replay)
  end
end

local function record_pause()
  local st = State.read()
  if not st then
    notify("Recording", "Nothing is being recorded")
    return
  end
  if st.backend ~= "gpu" then
    notify("Recording", "Pause needs gpu-screen-recorder", { urgency = "critical" })
    return
  end
  run("kill -s USR2 " .. st.pid .. " >/dev/null 2>&1")
  st.paused = st.paused == "1" and "0" or "1"
  State.write(st)
  notify("Recording", st.paused == "1" and "Paused" or "Resumed")
end

local function replay_save()
  local st = State.read()
  if not st or st.mode ~= "replay" then
    notify("Replay", "The replay buffer is not armed", { urgency = "critical" })
    return
  end
  run("kill -s USR1 " .. st.pid .. " >/dev/null 2>&1")
  notify("Replay saved", "Clip written to " .. shorten(config.video_dir))
end

--- Machine readable status, for a bar widget: screenshot.lua status
local function status()
  local function json(s)
    return '"' .. tostring(s):gsub('[\\"]', "\\%0") .. '"'
  end

  local st = State.read()
  if not st then
    print('{"recording":false,"mode":"idle","paused":false,"elapsed":"","file":"","text":""}')
    return
  end

  local el = elapsed_string(st.start)
  local text = st.mode == "replay" and "REPLAY" or ((st.paused == "1" and "PAUSED " or "REC ") .. el)
  print(string.format(
    '{"recording":true,"mode":%s,"paused":%s,"elapsed":%s,"file":%s,"text":%s}',
    json(st.mode),
    st.paused == "1" and "true" or "false",
    json(el),
    json(st.file or ""),
    json(text)
  ))
end

--------------------------------------------------------------------------------
-- misc commands
--------------------------------------------------------------------------------

local function last_capture()
  local file = sh("ls -1t " .. q(config.image_dir) .. "/*.png 2>/dev/null | head -n1")
  if file == "" or not exists(file) then
    die("Screenshot", "No previous capture found")
  end
  process(file)
end

local usage = [[
screenshot.lua — capture, annotate and record on Hyprland

CAPTURE
  region              select a rectangle (screen is frozen while you drag)
  screen              the focused monitor      --pick | --output=DP-1
  window              the focused window       --pick  to click one
  all                 every monitor stitched together
  last                re-run actions on the newest capture

CAPTURE FLAGS
  --edit              annotate in satty before saving/copying
  --ocr[=lang]        run OCR and copy the text instead of the image
  --search            upload and reverse-search on Google Lens
  --open              open the capture in the viewer
  --no-copy           don't touch the clipboard
  --no-save           clipboard only, nothing written to disk
  --no-freeze         don't freeze the screen while selecting
  --cursor            include the mouse cursor
  --delay=N           wait N seconds before capturing
  --scale=N           capture at scale factor N

RECORDING
  record              toggle recording (start/stop)
  record-stop         stop and save
  record-pause        pause/resume (gpu-screen-recorder)
  replay              toggle the instant-replay buffer
  replay-save         write the last --seconds to disk
  status              JSON status line for a bar widget

RECORDING FLAGS
  --audio             capture desktop audio
  --mic               capture the microphone (combine with --audio)
  --region --window   record a selection or a window instead of a monitor
  --output=DP-1       record a specific monitor
  --fps=N  --seconds=N  --backend=gpu|wf  --quality=very_high

Config overrides: ~/.config/nothings/screenshot.conf.lua (return a table)
]]

--------------------------------------------------------------------------------
-- dispatch
--------------------------------------------------------------------------------

local commands = {
  region = function()
    do_capture("region")
  end,
  screen = function()
    do_capture("screen")
  end,
  full = function()
    do_capture("screen")
  end,
  fullscreen = function()
    do_capture("screen")
  end,
  window = function()
    do_capture("window")
  end,
  all = function()
    do_capture("all")
  end,
  last = last_capture,

  record = function()
    record_toggle(false)
  end,
  recordsound = function() -- legacy alias
    flags.audio = true
    record_toggle(false)
  end,
  ["record-stop"] = record_stop,
  ["record-pause"] = record_pause,
  replay = function()
    record_toggle(true)
  end,
  ["replay-save"] = replay_save,
  status = status,

  help = function()
    io.write(usage)
  end,
}

local handler = commands[command]
if not handler then
  notify("Screenshot", string.format("Unknown command: %q", command), { urgency = "critical" })
  io.write(usage)
  os.exit(1)
end

require_bins("notify-send")
handler()
