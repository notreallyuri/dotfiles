return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "rust", "ron", "toml",
        "typescript", "javascript", "tsx", "html", "css",
        "regex", "bash", "markdown", "markdown_inline", "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts)
    end,
  },
}
