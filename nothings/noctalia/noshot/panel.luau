--!nonstrict
-- Two tabs: pick your options, then pick a target. The command is assembled
-- from the toggles instead of hard-coding every combination.
--- service.luau resolves the script once and publishes it; the setting is the
--- fallback for the moment before the service has run.
local function run(argv: string)
  local script = noctalia.state.get("script")
  if not script or script == "" then
    local configured = noctalia.getConfig("script_path")
    script = (configured and configured ~= "") and noctalia.expandPath(configured) or nil
  end
  if not script then
    noctalia.notifyError("noshot", "Could not find noshot.lua — set its path in the plugin settings.")
    return
  end
  noctalia.runAsync(string.format("'%s' %s", script, argv))
end

local CAPTURE, RECORD = "capture", "record"

--- How long the "wait" toggle waits, from the plugin settings.
local function delaySeconds(): number
  return math.floor(tonumber(noctalia.getConfig("capture_delay")) or 5)
end

local tab = CAPTURE
local pending = nil
local open = false
local rec = nil -- live status published by service.luau

local shot = {
  edit = false,
  ocr = false,
  search = false,
  clipboard = false, -- --no-save
  delay = false,     -- --delay=N
}

local record = {
  target = noctalia.getConfig("record_target") or "monitor", -- monitor | region | window
  audio = false,
  mic = false,
}

--- Toggles hand their new value back as a string on some API versions.
local function truthy(v)
  return v == true or v == "true" or v == 1 or v == "1"
end

local function captureCmd(target)
  local parts = { target }
  if target == "window" then
    parts[#parts + 1] = "--pick"
  end
  if shot.edit then
    parts[#parts + 1] = "--edit"
  end
  if shot.ocr then
    parts[#parts + 1] = "--ocr"
  end
  if shot.search then
    parts[#parts + 1] = "--search"
  end
  if shot.clipboard then
    parts[#parts + 1] = "--no-save"
  end
  if shot.delay then
    parts[#parts + 1] = "--delay=" .. delaySeconds()
  end
  return table.concat(parts, " ")
end

local function recordCmd(replay)
  local parts = { replay and "replay" or "record" }
  if record.target == "region" then
    parts[#parts + 1] = "--region"
  elseif record.target == "window" then
    parts[#parts + 1] = "--window --pick"
  end
  if record.audio then
    parts[#parts + 1] = "--audio"
  end
  if record.mic then
    parts[#parts + 1] = "--mic"
  end
  return table.concat(parts, " ")
end

local render

--- Anything that draws an overlay (slurp, grim) has to wait for the panel to
--- be gone, so it runs from onClose instead.
local function later(cmd)
  pending = cmd
  panel.close()
end

--- Signals to a running recorder are safe to send with the panel still open —
--- the status watch re-renders us afterwards.
local function now(cmd)
  run(cmd)
end

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local function header()
  return ui.row({ align = "center", gap = 8 }, {
    ui.glyph({ name = rec and "player-record" or "camera", size = 18,
      color = rec and "primary" or "on_surface" }),
    ui.label({
      text = "noshot",
      fontSize = 16,
      fontWeight = "bold",
      color = "on_surface",
      flexGrow = 1,
    }),
    ui.button({ glyph = "close", variant = "ghost", controlSize = "sm",
      onClick = "onCloseClicked" }),
  })
end

local function tabs()
  local function item(id, text, glyph)
    return ui.button({
      key = "tab-" .. id,
      text = text,
      glyph = glyph,
      variant = tab == id and "primary" or "ghost",
      selected = tab == id,
      controlSize = "sm",
      flexGrow = 1,
      onClick = function()
        tab = id
        render()
      end,
    })
  end
  return ui.row({ gap = 4, align = "stretch" }, {
    item(CAPTURE, "Screenshot", "camera"),
    item(RECORD, "Recording", "player-record"),
  })
end

local function sectionLabel(text)
  return ui.label({ text = text, fontSize = 11, fontWeight = "medium",
    color = "on_surface_variant" })
end

--- A label + switch line; the whole row is clickable, not just the switch.
local function switchRow(glyph, text, checked, onSet)
  local function flip()
    onSet(not checked)
    render()
  end
  return ui.row({
    align = "center",
    gap = 8,
    paddingH = 6,
    paddingV = 4,
    radius = 8,
    onClick = flip,
  }, {
    ui.glyph({ name = glyph, size = 14,
      color = checked and "primary" or "on_surface_variant" }),
    ui.label({ text = text, fontSize = 13, flexGrow = 1,
      color = checked and "on_surface" or "on_surface_variant" }),
    ui.toggle({
      checked = checked,
      onChange = function(v)
        onSet(truthy(v))
        render()
      end,
    }),
  })
end

local function targetButton(id, text, glyph)
  return ui.button({
    key = "shot-" .. id,
    text = text,
    glyph = glyph,
    controlSize = "md",
    flexGrow = 1,
    onClick = function()
      later(captureCmd(id))
    end,
  })
end

local function chip(id, text, glyph)
  return ui.button({
    key = "target-" .. id,
    text = text,
    glyph = glyph,
    variant = record.target == id and "primary" or "outline",
    selected = record.target == id,
    controlSize = "sm",
    flexGrow = 1,
    onClick = function()
      record.target = id
      render()
    end,
  })
end

--------------------------------------------------------------------------------
-- tabs
--------------------------------------------------------------------------------

local function captureTab()
  return {
    sectionLabel("OPTIONS"),
    switchRow("brush", "Annotate in satty", shot.edit,
      function(v) shot.edit = v end),
    switchRow("text-caption", "OCR — copy text instead", shot.ocr,
      function(v) shot.ocr = v end),
    switchRow("search", "Reverse search on Lens", shot.search,
      function(v) shot.search = v end),
    switchRow("clipboard", "Clipboard only", shot.clipboard,
      function(v) shot.clipboard = v end),
    switchRow("clock", string.format("Wait %d seconds", delaySeconds()), shot.delay,
      function(v) shot.delay = v end),

    ui.separator({ spacing = 4 }),

    sectionLabel("CAPTURE"),
    ui.row({ gap = 6, align = "stretch" }, {
      targetButton("region", "Region", "crop"),
      targetButton("window", "Window", "app-window"),
    }),
    ui.row({ gap = 6, align = "stretch" }, {
      targetButton("screen", "Monitor", "device-desktop"),
      targetButton("all", "All", "layout-grid"),
    }),
    ui.button({
      text = "Re-run on last capture",
      glyph = "history",
      variant = "ghost",
      controlSize = "sm",
      onClick = function()
        later(captureCmd("last"))
      end,
    }),
  }
end

local function liveTab()
  local isReplay = rec.mode == "replay"
  return {
    ui.column({ gap = 2, align = "stretch", paddingV = 4 }, {
      ui.label({
        text = isReplay and "Replay buffer armed" or (rec.paused and "Paused" or "Recording"),
        fontSize = 14,
        fontWeight = "bold",
        color = "primary",
      }),
      ui.label({
        text = isReplay and "The last seconds are kept in RAM" or (rec.elapsed or "00:00"),
        fontSize = 13,
        color = "on_surface_variant",
      }),
    }),

    ui.separator({ spacing = 4 }),

    isReplay and ui.button({
      text = "Save clip",
      glyph = "device-floppy",
      variant = "primary",
      onClick = function()
        now("replay-save")
      end,
    }) or ui.button({
      text = rec.paused and "Resume" or "Pause",
      glyph = rec.paused and "player-play" or "player-pause",
      onClick = function()
        now("record-pause")
      end,
    }),

    ui.button({
      text = isReplay and "Disarm buffer" or "Stop and save",
      glyph = "player-stop",
      variant = "destructive",
      onClick = function()
        now("record-stop")
      end,
    }),
  }
end

local function recordTab()
  if rec then
    return liveTab()
  end
  return {
    sectionLabel("SOURCE"),
    ui.row({ gap = 4, align = "stretch" }, {
      chip("monitor", "Monitor", "device-desktop"),
      chip("region", "Region", "crop"),
      chip("window", "Window", "app-window"),
    }),

    sectionLabel("AUDIO"),
    switchRow("volume", "Desktop audio", record.audio,
      function(v) record.audio = v end),
    switchRow("microphone", "Microphone", record.mic,
      function(v) record.mic = v end),

    ui.separator({ spacing = 4 }),

    ui.button({
      text = "Start recording",
      glyph = "player-record",
      variant = "primary",
      onClick = function()
        later(recordCmd(false))
      end,
    }),
    ui.button({
      text = "Arm replay buffer",
      glyph = "rotate-clockwise",
      variant = "outline",
      controlSize = "sm",
      onClick = function()
        later(recordCmd(true))
      end,
    }),
  }
end

--------------------------------------------------------------------------------
-- render
--------------------------------------------------------------------------------

render = function()
  local body = tab == CAPTURE and captureTab() or recordTab()

  panel.render(ui.column({ flexGrow = 1, gap = 8, align = "stretch" }, {
    header(),
    tabs(),
    ui.scroll({ flexGrow = 1, gap = 6, align = "stretch" }, body),
  }))
end

local function onStatus(s)
  local was = rec ~= nil
  rec = (s and s.recording) and s or nil
  if not open then
    return
  end
  -- follow the action: a recording that starts or stops swaps the tab for you
  if (rec ~= nil) ~= was then
    tab = rec and RECORD or CAPTURE
  end
  render()
end

-- registered once, not per open, so re-opening doesn't stack watchers
noctalia.state.watch("status", onStatus)

function onOpen(_context)
  pending = nil
  open = true
  local s = noctalia.state.get("status")
  rec = (s and s.recording) and s or nil
  tab = rec and RECORD or CAPTURE
  render()
end

function onClose()
  open = false
  if pending then
    run(pending)
    pending = nil
  end
end

function onCloseClicked()
  panel.close()
end
