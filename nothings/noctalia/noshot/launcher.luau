-- launcher.luau
local delay = math.floor(tonumber(noctalia.getConfig("capture_delay")) or 5)

--- Resolved by service.luau; the setting is the fallback.
local function scriptPath(): string?
  local script = noctalia.state.get("script")
  if script and script ~= "" then
    return script
  end
  local configured = noctalia.getConfig("script_path")
  return (configured and configured ~= "") and noctalia.expandPath(configured) or nil
end

local actions = {
  { id = "region",              title = "Region",              subtitle = "select a rectangle", glyph = "crop" },
  { id = "region --edit",       title = "Region → annotate",   subtitle = "open in satty",      glyph = "brush" },
  { id = "region --ocr",        title = "Region → OCR",        subtitle = "copy text instead",  glyph = "text-recognition" },
  { id = "region --search",     title = "Region → Lens",       subtitle = "upload + reverse search", glyph = "search" },
  { id = "region --no-save",    title = "Region → clipboard",  subtitle = "nothing hits disk",  glyph = "clipboard" },
  { id = "window --pick",       title = "Window",              subtitle = "click one",          glyph = "app-window" },
  { id = "screen",              title = "Monitor",             subtitle = "focused output",     glyph = "device-desktop" },
  { id = "screen --delay=" .. delay, title = string.format("Monitor in %ds", delay),
    subtitle = "delayed capture", glyph = "clock" },
  { id = "all",                 title = "All monitors",        subtitle = "stitched",           glyph = "layout-grid" },
  { id = "last --edit",         title = "Annotate last capture", subtitle = "re-run on newest", glyph = "history" },
  { id = "record",              title = "Record monitor",      subtitle = "toggle",             glyph = "player-record" },
  { id = "record --audio",      title = "Record + desktop audio", subtitle = "toggle",          glyph = "volume" },
  { id = "record --region",     title = "Record region",       subtitle = "toggle",             glyph = "crop" },
  { id = "replay",              title = "Arm replay buffer",   subtitle = "last 120s in RAM",   glyph = "rotate-clockwise" },
}

function onQuery(text)
  local out = {}
  for _, a in ipairs(actions) do
    if text == "" then
      out[#out + 1] = a
    else
      local score = noctalia.fuzzyScore(text, a.title .. " " .. a.id)
      if score then
        out[#out + 1] = { id = a.id, title = a.title, subtitle = a.subtitle, glyph = a.glyph, score = score }
      end
    end
  end
  launcher.setResults(text, out)
end

function onActivate(id)
  local script = scriptPath()
  if not script then
    noctalia.notifyError("noshot", "Could not find noshot.lua — set its path in the plugin settings.")
    return
  end
  -- the launcher has to be gone before grim or slurp draws anything
  noctalia.runAsync(string.format("sleep 0.2 && '%s' %s", script, id))
end
