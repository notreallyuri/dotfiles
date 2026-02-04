local dashboard = require("lua.dashboard.init")

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = dashboard.header,
        keys = dashboard.keys,
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { text = dashboard.footer, align = "center" },
      },
    },
  },
}
