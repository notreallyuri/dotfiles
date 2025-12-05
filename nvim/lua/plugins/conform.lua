return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      -- Register a conditional biome-check formatter
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
      for _, ft in ipairs({
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "json",
        "jsonc",
        "html",
        "css",
        "astro",
        "svelte",
        "vue",
      }) do
        opts.formatters_by_ft[ft] = { "biome-check" }
      end
    end,
  },
}
