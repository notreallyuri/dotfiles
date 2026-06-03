local data_path = vim.fn.stdpath("data") .. "/colorscheme"
local theme = "catppuccin"
local clear = false

local f = io.open(data_path, "r")
if f then
  for line in f:lines() do
    local key, value = line:match("^(%w+)%s*=%s*(.-)%s*$")
    if key == "theme" then
      theme = value
    elseif key == "clear" then
      clear = value == "true"
    end
  end
  f:close()
end

local theme_ok, err = pcall(vim.cmd.colorscheme, theme)
if not theme_ok then
  vim.notify("Failed to load theme '" .. theme .. "'. Error: " .. tostring(err), vim.log.levels.WARN)
end

if clear then
  local trans_ok, transparency = pcall(require, "config.transparency")
  if trans_ok then
    pcall(transparency.enable)
  else
    vim.notify("Transparency module 'config.transparency' not found.", vim.log.levels.WARN)
  end
end
