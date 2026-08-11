local PANEL = "nothings/noshot:menu"
local rec = nil

--- Resolved by service.luau; the setting is the fallback.
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

local function apply(s)
  rec = (s and s.recording) and s or nil
  if not rec then
    barWidget.setGlyph("camera")
    barWidget.setText("")
    barWidget.setTooltip("Capture menu")
  elseif rec.mode == "replay" then
    barWidget.setGlyph("player-track-next")
    barWidget.setText("REPLAY")
    barWidget.setTooltip("Replay armed · right-click saves a clip")
  else
    barWidget.setGlyph(rec.paused and "player-pause" or "player-record")
    barWidget.setText(rec.elapsed)
    barWidget.setTooltip((rec.file or "") .. "\nclick: stop · right: pause")
  end
end

function onClick()
  if rec then
    run("record-stop")
  else
    noctalia.togglePanel(PANEL)
  end
end

function onRightClick()
  if not rec then return end
  run(rec.mode == "replay" and "replay-save" or "record-pause")
end

noctalia.state.watch("status", apply)
apply(noctalia.state.get("status"))
