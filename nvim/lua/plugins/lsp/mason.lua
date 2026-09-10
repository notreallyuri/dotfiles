return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "lua_ls", "biome", "tailwindcss", "marksman", "jdtls", "clangd", "vtsls", "eslint-lsp" },
    automatic_installation = true,
    -- jdtls is installed here but started by ftplugin/java.lua via nvim-jdtls;
    -- letting mason-lspconfig also enable it spawns a second, unconfigured
    -- client with no debug/test bundles attached.
    automatic_enable = { exclude = { "jdtls" } },
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

    -- roslyn-language-server isn't an nvim-lspconfig server (roslyn.nvim ships
    -- its own config), so it can't go through mason-lspconfig above. csharpier
    -- and netcoredbg are likewise plain tools rather than LSP servers.
    if vim.fn.executable("dotnet") == 1 then
      vim.list_extend(ensure_installed, { "roslyn-language-server", "csharpier", "netcoredbg" })
    end

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
    })
  end
}
