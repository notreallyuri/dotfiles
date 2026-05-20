return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      close_command = function(n) require("snacks").bufdelete(n) end,
      right_mouse_command = function(n) require("snacks").bufdelete(n) end,
      offsets = {
        {
          filetype = "minifiles",
          text = "Files",
          highlight = "Directory",
          text_align = "center",
        },
      },
    },
  },
}
