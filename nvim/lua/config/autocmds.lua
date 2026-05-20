vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = true, desc = "Close quickfix" })
  end,
})
