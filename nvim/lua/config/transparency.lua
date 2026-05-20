local M = {}

M.clear_bg = function()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
end

M.enable = function()
  M.clear_bg()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("Transparency", { clear = true }),
    callback = M.clear_bg,
  })
end

M.disable = function(theme)
  vim.api.nvim_create_augroup("Transparency", { clear = true })
  vim.cmd.colorscheme(theme)
end

return M
