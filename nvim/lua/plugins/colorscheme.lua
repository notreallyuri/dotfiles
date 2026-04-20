return {
  {
    "thedenisnikulin/vim-cyberpunk",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
  {
    "water-sucks/darkrose.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
    config = function(_, opts)
      require("lazyvim").setup(opts)

      local function clear_bg()
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
      end

      clear_bg()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
    end,
  },
}
