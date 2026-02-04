return {
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
}
