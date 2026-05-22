vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = true, desc = "Close quickfix" })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "rust-analyzer" then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
