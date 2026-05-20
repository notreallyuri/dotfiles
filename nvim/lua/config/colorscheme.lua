local data_path = vim.fn.stdpath("data") .. "/colorscheme"
local theme = "catppuccin"
local clear = false

local f = io.open(data_path, "r")
if f then
  for line in f:lines() do
    local key, value = line:match("^(%w+)%s*=%s*(.+)$")
    if key == "theme" then
      theme = value
    elseif key == "clear" then
      clear = value == "true"
    end
  end
  f:close()
end

vim.cmd.colorscheme(theme)

if clear then
  require("config.transparency").enable()
end
