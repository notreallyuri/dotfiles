local function get_random_header()
  local ascii_path = vim.fn.stdpath("config") .. "/ascii"
  local files = vim.fn.glob(ascii_path .. "/*", false, true)

  if #files == 0 then
    return [[
      NO HEADERS FOUND
      (Check ~/.config/nvim/ascii/)
    ]]
  end

  math.randomseed(os.time())
  local random_file = files[math.random(#files)]

  local file = io.open(random_file, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()

  return content
end

local random_header = get_random_header()

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = random_header,
        keys = {
          {
            icon = "󰈔 ",
            key = "f",
            desc = "Explorer",
            action = function()
              require("mini.files").open(vim.uv.cwd(), true)
            end,
          },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { text = "Snort! Snort! Snort!", align = "center" },
      },
    },
  },
}
