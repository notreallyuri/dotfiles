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
    local ensure_installed = { "java-test", "java-debug-adapter" }

    -- prettier/markdownlint-cli2/markdown-toc are npm-backed; skip them on
    -- machines without npm instead of failing on every startup
    if vim.fn.executable("npm") == 1 then
      vim.list_extend(ensure_installed, { "prettier", "markdownlint-cli2", "markdown-toc" })
    end

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
    })
  end
}
