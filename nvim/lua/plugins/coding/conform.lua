return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = function()
    local util = require("conform.util")
    return {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "leptosfmt", "rustfmt" },
        typescript = { "biome_sort", "prettier", stop_after_first = true },
        typescriptreact = { "biome_sort", "prettier", stop_after_first = true },
        javascript = { "biome_sort", "prettier", stop_after_first = true },
        javascriptreact = { "biome_sort", "prettier", stop_after_first = true },
        html = { "prettier" },
        css = { "biome", "prettier", stop_after_first = true },
        markdown = { "markdownlint-cli2", "markdown-toc" },
        cs = { "csharpier" },
        fsharp = { "fantomas" }
      },
      formatters = {
        biome_sort = {
          command = util.from_node_modules("biome"),
          args = { "check", "--write", "--unsafe", "--stdin-file-path", "$FILENAME" },
          cwd = util.root_file({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }),
          require_cwd = true,
        },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    }
  end,
}
