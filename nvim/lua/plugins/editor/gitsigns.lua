return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(gitsigns.next_hunk)
        return "<Ignore>"
      end, "Next hunk")
      map("n", "[h", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(gitsigns.prev_hunk)
        return "<Ignore>"
      end, "Prev hunk")

      map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk")
      map("v", "<leader>ghs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<leader>ghr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>ghu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>ghd", gitsigns.diffthis, "Diff this")
      map("n", "<leader>gB", gitsigns.toggle_current_line_blame, "Toggle line blame")
    end,
  },
}
