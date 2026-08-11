--- Command line parsing: `command --flag --key=value --no-flag`.
--- `--set key=value` is collected separately so it can be repeated.

local M = {
  flags = {},
  positional = {},
  sets = {},
  command = "help",
}

function M.parse(argv)
  local flags, positional, sets = {}, {}, {}

  local i = 1
  while i <= #argv do
    local a = argv[i]
    local key, value = a:match("^%-%-([%w_%-]+)=(.*)$")
    if a == "--set" then
      i = i + 1
      sets[#sets + 1] = argv[i] or ""
    elseif key == "set" then
      sets[#sets + 1] = value
    elseif key then
      flags[key] = value
    elseif a:match("^%-%-no%-") then
      flags[a:sub(6)] = false
    elseif a:match("^%-%-") then
      flags[a:sub(3)] = true
    else
      positional[#positional + 1] = a
    end
    i = i + 1
  end

  -- Backwards compatible positional action: `noshot region ocr`
  local legacy = positional[2]
  if legacy and flags[legacy] == nil then
    if legacy == "ocr" or legacy == "search" or legacy == "edit" or legacy == "open" then
      flags[legacy] = true
    elseif legacy == "copy" then
      flags.save = false
    end
  end

  M.flags = flags
  M.positional = positional
  M.sets = sets
  M.command = positional[1] or "help"
  return M
end

function M.flag(name, default)
  local v = M.flags[name]
  if v == nil then
    return default
  end
  return v
end

function M.num(name, default)
  return tonumber(M.flags[name]) or default
end

return M
