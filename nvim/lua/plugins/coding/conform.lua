return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "leptosfmt", "rustfmt" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      markdown = { "markdownlint-cli2", "markdown-toc" }
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  }
}
