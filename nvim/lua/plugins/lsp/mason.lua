return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "lua_ls", "biome", "tailwindcss", "marksman", "jdtls", "clangd", "omnisharp", "vtsls", "eslint-lsp" },
    automatic_installation = true,

  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier",
        "markdownlint-cli2",
        "markdown-toc",
        "java-test", "java-debug-adapter"
      },
    })
  end
}
