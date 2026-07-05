return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "rust", "ron", "toml",
        "typescript", "javascript", "tsx", "html", "css",
        "regex", "bash", "markdown", "markdown_inline", "vim", "vimdoc",
        "java", "cpp", "c_sharp", "fsharp"
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      for key, textobject in pairs({
        af = "@function.outer", ["if"] = "@function.inner",
        ac = "@class.outer", ic = "@class.inner",
        aa = "@parameter.outer", ia = "@parameter.inner",
      }) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(textobject, "textobjects")
        end, { desc = "Select " .. textobject })
      end

      local move = require("nvim-treesitter-textobjects.move")
      for key, spec in pairs({
        ["]f"] = { move.goto_next_start, "@function.outer" },
        ["]c"] = { move.goto_next_start, "@class.outer" },
        ["[f"] = { move.goto_previous_start, "@function.outer" },
        ["[c"] = { move.goto_previous_start, "@class.outer" },
      }) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          spec[1](spec[2], "textobjects")
        end, { desc = "Goto " .. spec[2] })
      end
    end,
  },
}
