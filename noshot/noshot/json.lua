--- Just enough JSON to quote a string properly.
--- `noshot config --json` and `noshot status` both feed bar widgets, and Lua's
--- %q is not JSON: it writes an embedded newline as a backslash followed by a
--- real line break, which no parser accepts.

local M = {}

local ESCAPES = {
  ['"'] = '\\"',
  ["\\"] = "\\\\",
  ["\b"] = "\\b",
  ["\f"] = "\\f",
  ["\n"] = "\\n",
  ["\r"] = "\\r",
  ["\t"] = "\\t",
}

function M.string(s)
  local body = tostring(s):gsub(
    '[%c"\\]',
    function(c) return ESCAPES[c] or string.format("\\u%04X", string.byte(c)) end
  )
  return '"' .. body .. '"'
end

return M
