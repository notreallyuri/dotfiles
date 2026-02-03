return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}

      opts.formatters["biome-check"] = {
        condition = function(ctx)
          return vim.fs.find({ "biome.json", "biome.jsonc" }, {
            upward = true,
            path = ctx.dirname,
          })[1] ~= nil
        end,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}

      local javascript_fallback = { "biome-check", "prettier", stop_after_first = true }

      opts.formatters.prettier = {
        prepend_args = { "--trailing-comma", "none" },
      }

      opts.formatters_by_ft["javascript"] = javascript_fallback
      opts.formatters_by_ft["typescript"] = javascript_fallback
      opts.formatters_by_ft["javascriptreact"] = javascript_fallback
      opts.formatters_by_ft["typescriptreact"] = javascript_fallback
      opts.formatters_by_ft["json"] = javascript_fallback
      opts.formatters_by_ft["jsonc"] = javascript_fallback

      opts.formatters_by_ft["html"] = { "prettier" }
      opts.formatters_by_ft["css"] = { "prettier" }
    end,
  },
}
