--- What happens to a capture once it exists: open, annotate, OCR, notify.

local args = require("noshot.args")
local clipboard = require("noshot.clipboard")
local config = require("noshot.config")
local lock = require("noshot.lock")
local notify = require("noshot.notify")
local path = require("noshot.path")
local shell = require("noshot.shell")
local upload = require("noshot.upload")

local q = shell.q

local M = {}

--- xdg-open hands the file to the real viewer and returns straight away, so
--- there is no exit to wait for: a throwaway capture has to outlive it.
local VIEWER_GRACE = 60

function M.open(file)
  shell.run("setsid -f " .. config.viewer .. " " .. q(file) .. " >/dev/null 2>&1")
end

function M.edit(file)
  local editor = config.editor_cmd:match("^%S+")
  if not shell.have(editor) then
    notify.send("Screenshot", editor .. " is not installed", { urgency = "critical" })
    return false
  end
  local cmd = (config.editor_cmd:gsub("{file}", function()
    return q(file)
  end))
  return shell.run(cmd .. " >/dev/null 2>&1")
end

function M.ocr(file)
  notify.require_bins("tesseract")
  local lang = type(args.flags.ocr) == "string" and args.flags.ocr or config.ocr_lang
  local text = shell.sh(string.format("tesseract %s - -l %s 2>/dev/null", q(file), q(lang)))
  if text == "" then
    notify.send("OCR", "No text found in the capture", { icon = file, urgency = "critical" })
    return false
  end
  if not clipboard.text(text) then
    notify.send("OCR", "Failed to copy text to the clipboard", { urgency = "critical" })
    return false
  end
  local preview = text:gsub("%s+", " ")
  if #preview > 120 then
    preview = preview:sub(1, 120) .. "…"
  end
  notify.send("OCR — text copied", preview, { icon = file })
  return true
end

--- Apply the requested actions to a finished capture and report the result.
--- `temp` marks a capture that only exists to be copied — it is deleted at the
--- end. `last` deliberately passes false: that file is one the user kept.
function M.process(file, temp)
  if args.flag("edit", false) then
    M.edit(file)
    if not path.nonempty(file) then
      lock.release()
      os.exit(0) -- editor discarded the capture
    end
  end

  local did_something = false
  if args.flag("ocr", false) then
    M.ocr(file)
    did_something = true
  end
  if args.flag("search", false) then
    upload.search(file)
    did_something = true
  end

  if config.copy and not args.flag("ocr", false) then
    clipboard.image(file)
  end

  local opened = args.flag("open", false)
  if opened then
    M.open(file)
  end

  if temp then
    if opened then
      shell.run("setsid -f sh -c "
        .. q(string.format("sleep %d; rm -f %s", VIEWER_GRACE, q(file)))
        .. " >/dev/null 2>&1")
    else
      os.remove(file)
    end
    if not did_something then
      -- --no-copy --no-save leaves nothing behind; don't claim otherwise
      notify.send("Screenshot", config.copy and "Copied to the clipboard" or "Discarded")
    end
    return
  end

  if did_something then
    return -- the action already notified, don't stack a second popup
  end

  notify.send("Screenshot saved", config.shorten(file), {
    icon = file,
    actions = {
      {
        id = "open",
        label = "Open",
        fn = function()
          M.open(file)
        end
      },
      {
        id = "edit",
        label = "Edit",
        fn = function()
          M.edit(file)
          clipboard.image(file)
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
          notify.send("Screenshot", "Deleted")
        end
      },
    },
  })
end

return M
