local M = {}

local ascii_path = vim.fn.stdpath("config") .. "/ascii"

function M.random()
  local files = vim.fn.glob(ascii_path .. "/*", false, true)

  if #files == 0 then
    return [[
NO HEADERS FOUND
(Check ~/.config/nvim/ascii/)
    ]]
  end

  math.randomseed(os.time())
  local file = files[math.random(#files)]

  local f = io.open(file, "r")
  if not f then
    return nil
  end

  local content = f:read("*a")
  f:close()

  return content
end

return M
