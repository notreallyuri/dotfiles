return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls", "tailwindcss" },
      automatic_installation = true,
    })

    vim.lsp.config("lua_ls", {})
    vim.lsp.config("ts_ls", {})
    vim.lsp.config("tailwindcss", {
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              { [[class="([^"]*)"]] },
              { [[class=move\s*\|\|\s*\{?"?([^"}\)]*)"?\}?]] },
              { [[cn!\(([^)]*)\)]],                          [["([^"]*)"]] },
              { [[cn!\s*\(([^)]*)\)]] },
            },
          },
          includeLanguages = {
            rust = "html",
          },
        },
      },
      filetypes = {
        "html", "css", "typescript", "typescriptreact",
        "javascript", "javascriptreact",
        "rust",
      },
    })

    vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss" })
    vim.lsp.enable("rust_analyzer", false)
  end,
}
