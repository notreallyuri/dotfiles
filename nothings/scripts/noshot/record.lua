--- Screen recording and the instant-replay buffer.

local actions = require("noshot.actions")
local args = require("noshot.args")
local clipboard = require("noshot.clipboard")
local config = require("noshot.config")
local hyprland = require("noshot.hyprland")
local notify = require("noshot.notify")
local shell = require("noshot.shell")
local state = require("noshot.state")

local q, sh = shell.q, shell.sh

local M = {}

local function backend()
  local name = args.flags.backend or config.recorder
  if name == "gpu" and not shell.have("gpu-screen-recorder") then
    name = "wf"
  end
  if name == "wf" and not shell.have("wf-recorder") then
    notify.die("Recording", "Install gpu-screen-recorder or wf-recorder")
  end
  return name
end

--- Where to record: an output name or a region geometry.
local function target()
  if args.flag("region", false) then
    return { geom = hyprland.select_region(), label = "region" }
  elseif args.flag("window", false) then
    local geom = args.flag("pick", false) and hyprland.select_window() or hyprland.window_geom()
    if not geom then
      notify.die("Recording", "No active window to record")
    end
    return { geom = geom, label = "window" }
  elseif type(args.flags.output) == "string" then
    return { output = args.flags.output, label = args.flags.output }
  elseif args.flag("pick", false) then
    return { geom = hyprland.select_output(), label = "monitor" }
  end
  local output = hyprland.focused_output()
  if output == "" then
    output = "screen" -- gpu-screen-recorder's "whatever is focused" target
  end
  return { output = output, label = output }
end

local function audio_sources(name)
  local want_desktop = args.flag("audio", false)
  local want_mic = args.flag("mic", false)
  if not want_desktop and not want_mic then
    return nil
  end

  if name == "gpu" then
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

--- "x,y wxh" (slurp) -> "wxh+x+y" (gpu-screen-recorder)
local function to_gsr_region(geom)
  local x, y, w, h = geom:match("^(%-?%d+),(%-?%d+) (%d+)x(%d+)$")
  if not x then
    return nil
  end
  return string.format("%sx%s+%s+%s", w, h, x, y)
end

--- Start `cmd` detached and return its pid.
local function spawn_pid(cmd)
  local line = string.format(
    "setsid sh -c %s >/dev/null 2>&1 & echo $!",
    q("exec " .. cmd .. " >>" .. q(config.log_file) .. " 2>&1")
  )
  return sh(line):match("%d+")
end

local function build_cmd(name, where, file, replay)
  local audio = audio_sources(name) or ""
  local cursor = args.flag("cursor", true) and "yes" or "no"

  if name == "gpu" then
    local window, extra = where.output or "screen", ""
    if where.geom then
      local region = to_gsr_region(where.geom)
      if not region then
        notify.die("Recording", "Could not parse the selected region")
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
      args.num("fps", config.fps),
      q(args.flags.quality or config.quality),
      cursor,
      replay and ("-r " .. args.num("seconds", config.replay_seconds) .. " -replay-storage ram") or "",
      audio,
      out
    )
  end

  if replay then
    notify.die("Recording", "Replay mode needs gpu-screen-recorder")
  end
  local scope = ""
  if where.geom then
    scope = "-g " .. q(where.geom)
  elseif where.output and where.output ~= "screen" then
    scope = "-o " .. q(where.output)
  end
  return string.format("wf-recorder %s %s -r %d -f %s", scope, audio, args.num("fps", config.fps), q(file))
end

local function start(replay)
  local name = backend()
  local where = target()
  shell.ensure_dir(config.video_dir)
  local file = shell.unique_path(config.video_dir, ".mp4")
  os.remove(config.log_file)

  local pid = spawn_pid(build_cmd(name, where, file, replay))
  shell.sleep("0.6")
  if not pid or not shell.run("kill -0 " .. pid .. " >/dev/null 2>&1") then
    local err = sh("tail -n 3 " .. q(config.log_file) .. " 2>/dev/null")
    notify.die("Recording failed", err ~= "" and err or "The recorder exited immediately")
  end

  state.write({
    pid = pid,
    backend = name,
    mode = replay and "replay" or "record",
    file = replay and config.video_dir or file,
    start = os.time(),
  })

  if replay then
    notify.send(
      "Replay buffer armed",
      string.format("Keeping the last %ds of %s", args.num("seconds", config.replay_seconds), where.label)
    )
  else
    notify.send(
      "Recording started",
      string.format("%s · %s%s", where.label, name == "gpu" and "GPU" or "CPU",
        audio_sources(name) and " · audio" or "")
    )
  end
end

function M.stop()
  local st = state.read()
  if not st then
    notify.send("Recording", "Nothing is being recorded")
    return
  end

  shell.run("kill -s INT " .. st.pid .. " >/dev/null 2>&1")
  for _ = 1, 100 do -- give the muxer time to finalise the file
    if not shell.run("kill -0 " .. st.pid .. " >/dev/null 2>&1") then
      break
    end
    shell.sleep("0.1")
  end
  state.clear()

  if st.mode == "replay" then
    notify.send("Replay buffer stopped", "")
    return
  end

  if not shell.exists(st.file) then
    notify.die("Recording", "The recorder produced no file — see " .. config.log_file)
  end

  local file = st.file
  notify.send(
    "Recording saved",
    string.format("%s · %s · %s", shell.shorten(file), state.elapsed(st.start), state.human_size(file)),
    {
      actions = {
        {
          id = "open",
          label = "Play",
          fn = function()
            actions.open(file)
          end
        },
        {
          id = "folder",
          label = "Folder",
          fn = function()
            actions.open(config.video_dir)
          end
        },
        {
          id = "path",
          label = "Copy path",
          fn = function()
            clipboard.text(file)
          end
        },
        {
          id = "delete",
          label = "Delete",
          fn = function()
            os.remove(file)
            notify.send("Recording", "Deleted")
          end
        },
      },
    }
  )
end

function M.toggle(replay)
  if state.read() then
    M.stop()
  else
    start(replay)
  end
end

function M.pause()
  local st = state.read()
  if not st then
    notify.send("Recording", "Nothing is being recorded")
    return
  end
  if st.backend ~= "gpu" then
    notify.send("Recording", "Pause needs gpu-screen-recorder", { urgency = "critical" })
    return
  end
  shell.run("kill -s USR2 " .. st.pid .. " >/dev/null 2>&1")
  st.paused = st.paused == "1" and "0" or "1"
  state.write(st)
  notify.send("Recording", st.paused == "1" and "Paused" or "Resumed")
end

function M.replay_save()
  local st = state.read()
  if not st or st.mode ~= "replay" then
    notify.send("Replay", "The replay buffer is not armed", { urgency = "critical" })
    return
  end
  shell.run("kill -s USR1 " .. st.pid .. " >/dev/null 2>&1")
  notify.send("Replay saved", "Clip written to " .. shell.shorten(config.video_dir))
end

--- Machine readable status, for a bar widget: noshot status
function M.status()
  local function json(s)
    return '"' .. tostring(s):gsub('[\\"]', "\\%0") .. '"'
  end

  local st = state.read()
  if not st then
    print('{"recording":false,"mode":"idle","paused":false,"elapsed":"","file":"","text":""}')
    return
  end

  local el = state.elapsed(st.start)
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

return M
