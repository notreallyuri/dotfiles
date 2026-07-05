return {
  "vuki656/package-info.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  event = "BufRead package.json",
  opts = {},
  keys = {
    { "<leader>ns", function() require("package-info").show() end, desc = "Show package versions" },
    { "<leader>nc", function() require("package-info").hide() end, desc = "Hide package versions" },
    { "<leader>nu", function() require("package-info").update() end, desc = "Update package under cursor" },
    { "<leader>nd", function() require("package-info").delete() end, desc = "Delete package under cursor" },
    { "<leader>ni", function() require("package-info").install() end, desc = "Install new package" },
    { "<leader>np", function() require("package-info").change_version() end, desc = "Change package version" },
  },
}
