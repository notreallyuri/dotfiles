return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = { enabled = true },
    explorer = { enabled = false },
    picker = { enabled = true },
    notifier = { enabled = true },
    bufdelete = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    scroll = { enabled = true },
    scope = { enabled = true },
    words = { enabled = true },
    bigfile = { enabled = true },
    statuscolumn = { enabled = true },
    image = { enabled = true },
    quickfile = { enabled = true },
    terminal = { enabled = true },
  },
  keys = {
    {
      "<leader>gg",
      function()
        if vim.fn.executable("lazygit") == 0 then
          vim.notify("lazygit not found on $PATH", vim.log.levels.WARN)
          return
        end
        Snacks.terminal.open("lazygit", { win = { position = "float", width = 0.9, height = 0.9 } })
      end,
      desc = "Lazygit",
    },
  },
}
