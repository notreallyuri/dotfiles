return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls", "tailwindcss", "marksman" },
      automatic_installation = true,
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "markdownlint-cli2",
        "markdown-toc"
      },
    })

    vim.lsp.config("lua_ls", {})
    vim.lsp.config("vtsls", {
      settings = {
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = { completeFunctionCalls = true },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
        javascript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = { completeFunctionCalls = true },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
      },
    })
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
        "rust"
      },
    })
    vim.lsp.config("marksman", {})

    vim.lsp.enable({ "lua_ls", "vtsls", "tailwindcss", "marksman" })
    vim.lsp.enable("rust_analyzer", false)
  end,
}
