#!/usr/bin/env lua
--- noshot — capture, annotate and record helper for Hyprland.
--- Run `noshot help` for the full command list.
--- The moving parts live in ./noshot/; this file is only the CLI.

--- Where the modules live. Usually just the directory noshot.lua sits in, but
--- when it is reached through a symlink on $PATH that directory is ~/.local/bin
--- and holds nothing, so resolve the link before giving up.
local function dir_of(path) return path:match("^(.*)/[^/]+$") or "." end

local function readable(path)
  local f = io.open(path, "r")
  if not f then
    return false
  end
  f:close()
  return true
end

local self = arg[0] or ""
local here = dir_of(self)

if not readable(here .. "/noshot/args.lua") then
  local pipe = io.popen("readlink -f '" .. self:gsub("'", "'\\''") .. "' 2>/dev/null")
  if pipe then
    local real = pipe:read("*l")
    pipe:close()
    if real and real ~= "" then
      here = dir_of(real)
    end
  end
end

package.path = table.concat({
  here .. "/?.lua",
  package.path,
}, ";")

local args = require("noshot.args").parse(arg)
local capture = require("noshot.capture")
local config = require("noshot.config")
local dump = require("noshot.dump")
local lock = require("noshot.lock")
local notify = require("noshot.notify")
local record = require("noshot.record")

-- the command line is the last config layer; everything reads options lazily
config.apply_args(args)

local usage = [[
noshot — capture, annotate and record on Hyprland

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
  config              print every option, its value and where it came from

RECORDING FLAGS
  --audio             capture desktop audio
  --mic               capture the microphone (combine with --audio)
  --region --window   record a selection or a window instead of a monitor
  --output=DP-1       record a specific monitor
  --no-cursor         leave the pointer out (recordings keep it by default)
  --fps=N  --seconds=N  --backend=gpu|wf  --quality=very_high

OPTIONS
  Any option `noshot config` lists can be set for a single run, either as
  --ocr-lang=por or --set ocr_lang=por, and from $NOSHOT_OCR_LANG. Otherwise
  they come from ~/.config/nothings/noshot.conf.lua (return a table), the
  drop-ins beside it, and whatever a front-end wrote to ~/.local/state/noshot.
]]

local commands = {
  region = function() capture.take("region") end,
  screen = function() capture.take("screen") end,
  full = function() capture.take("screen") end,
  fullscreen = function() capture.take("screen") end,
  window = function() capture.take("window") end,
  all = function() capture.take("all") end,
  last = capture.last,

  record = function() record.toggle(false) end,
  recordsound = function() -- legacy alias
    args.flags.audio = true
    record.toggle(false)
  end,
  ["record-stop"] = record.stop,
  ["record-pause"] = record.pause,
  replay = function() record.toggle(true) end,
  ["replay-save"] = record.replay_save,
  status = record.status,
  config = dump.show,

  help = function() io.write(usage) end,
}

local handler = commands[args.command]
if not handler then
  notify.send("Screenshot", string.format("Unknown command: %q", args.command), { urgency = "critical" })
  io.write(usage)
  os.exit(1)
end

-- `status` is polled by bar widgets; keep it free of the dependency check,
-- which is a fork of its own every tick
local QUIET = { config = true, help = true, status = true }
if not QUIET[args.command] then
  notify.require_bins("notify-send")
end

handler()
lock.release()
