--- `noshot config` — the effective options and where each one came from.

local args = require("noshot.args")
local config = require("noshot.config")
local json = require("noshot.json")

local M = {}

local function serialize(value)
  local kind = type(value)
  if kind == "table" then
    local parts = {}
    for _, item in ipairs(value) do
      parts[#parts + 1] = serialize(item)
    end
    if #parts > 0 then
      return "[" .. table.concat(parts, ", ") .. "]"
    end
    local keys = {}
    for k in pairs(value) do
      keys[#keys + 1] = k
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
      parts[#parts + 1] = string.format("%s: %s", json.string(k), serialize(value[k]))
    end
    return "{" .. table.concat(parts, ", ") .. "}"
  end
  if kind == "string" then
    return json.string(value)
  end
  return tostring(value)
end

local function as_json()
  local parts = {}
  for _, opt in ipairs(config.describe()) do
    parts[#parts + 1] = string.format(
      '%s: {"value": %s, "type": %s, "origin": %s}',
      json.string(opt.key),
      serialize(opt.value),
      json.string(opt.type),
      json.string(opt.origin)
    )
  end
  return "{" .. table.concat(parts, ", ") .. "}"
end

local function as_text()
  local options = config.describe()
  local lines = {}
  local width = 0
  for _, opt in ipairs(options) do
    width = math.max(width, #opt.key)
  end
  for _, opt in ipairs(options) do
    lines[#lines + 1] = string.format("%-" .. width .. "s  %s  (%s)\n", opt.key, serialize(opt.value), opt.origin)
  end
  return table.concat(lines)
end

function M.show()
  if args.flag("json", false) then
    print(as_json())
    return
  end
  io.write(as_text())
  io.write(string.format(
    [[

Layers, later wins:
  %s
  %s/*.lua
  %s/*.lua        (written by front-ends)
  $NOSHOT_<OPTION>
  --option=value, --set option=value
]],
    config.paths.config,
    config.paths.drop_in,
    config.paths.generated
  ))
end

return M
