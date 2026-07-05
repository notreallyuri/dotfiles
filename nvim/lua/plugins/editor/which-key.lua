return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>u", group = "ui" },
      { "<leader>s", group = "search" },
      { "<leader>g", group = "git" },
      { "<leader>c", group = "code" },
      { "<leader>b", group = "buffer" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>w", group = "window" },
      { "<leader>d", group = "debug" },
      { "<leader>n", group = "npm" },
      { "<leader>t", group = "test" },
      { "<leader>gh", group = "hunk" }
    },
    win = {
      border = "single",
    }
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
  },
}
