return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    -- staged hunks get their own (dimmer) signs so staged vs unstaged is visible in the gutter
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    signs_staged_enable = true,
    attach_to_untracked = true,
    current_line_blame_opts = {
      delay = 500,
      virt_text_pos = "eol",
    },
    preview_config = { border = "rounded" },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Prev hunk")

      -- stage_hunk toggles: staging an already-staged hunk unstages it
      map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk (toggle)")
      map("v", "<leader>ghs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<leader>ghr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>ghu", gitsigns.stage_hunk, "Undo stage hunk (toggle)")
      map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk (popup)")
      map("n", "<leader>ghi", gitsigns.preview_hunk_inline, "Preview hunk inline (shows deleted lines)")
      map("n", "<leader>ghb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>ghd", gitsigns.diffthis, "Diff against index")
      map("n", "<leader>ghD", function() gitsigns.diffthis("~") end, "Diff against last commit")
      map("n", "<leader>ghq", function() gitsigns.setqflist("all") end, "All hunks to quickfix")

      map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>gW", gitsigns.toggle_word_diff, "Toggle word diff")

      -- hunk textobject: e.g. `vih` selects the hunk under the cursor
      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
    end,
  },
}
