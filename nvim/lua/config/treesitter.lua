if vim.fn.executable("tree-sitter") == 0 then
  vim.api.nvim_echo({
    { "Warning: tree-sitter compiler not found. Native parsers cannot compile.\n", "WarningMsg" },
  }, true, {})
end

local languages = { "lua", "rust", "typescript", "tsx", "html", "css" }

for _, lang in ipairs(languages) do
  if not pcall(vim.treesitter.language.add, lang) then
    pcall(function()
      vim.cmd("silent! EditQuery " .. lang)
    end)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = languages,
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
