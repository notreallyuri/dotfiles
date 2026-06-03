vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function() require("snacks").bufdelete() end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", function() require("snacks").bufdelete.other() end, { desc = "Delete other buffers" })

vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>wb", "<cmd>split<cr>", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wq", "<cmd>close<cr>", { desc = "Close split" })
vim.keymap.set("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other splits" })

vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to left split" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to bottom split" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to top split" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to right split" })

vim.keymap.set("i", "<C-e>", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(1, col)

  local tag = nil
  for t in before:gmatch("<([%w%-]+)[^>]->") do
    local full_tag = before:match("<" .. t .. "[^>]->")
    if full_tag and not full_tag:match("/>%s*$") then
      tag = t
    end
  end

  if tag then
    return "</" .. tag .. ">"
  end
  return "<C-e>"
end, { expr = true, desc = "Close HTML tag" })

vim.keymap.set("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  vim.notify("Inlay hints: " .. tostring(vim.lsp.inlay_hint.is_enabled()))
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>ut", function()
  Snacks.picker.colorschemes({
    confirm = function(picker, item)
      picker:close()
      if item then
        local data_path = vim.fn.stdpath("data") .. "/colorscheme"
        local clear_state = false

        local f_in = io.open(data_path, "r")
        if f_in then
          for line in f_in:lines() do
            local key, value = line:match("^(%w+)%s*=%s*(.-)%s*$")
            if key == "clear" then
              clear_state = value == "true"
            end
          end
          f_in:close()
        end

        local f_out = io.open(data_path, "w")
        if f_out then
          f_out:write("theme = " .. item.text .. "\n")
          f_out:write("clear = " .. tostring(clear_state) .. "\n")
          f_out:close()
        end

        vim.defer_fn(function()
          vim.cmd.colorscheme(item.text)
        end, 50)
      end
    end,
  })
end, { desc = "Find theme" })

vim.keymap.set("n", "<leader>uc", function()
  local data_path = vim.fn.stdpath("data") .. "/colorscheme"
  local theme = "catppuccin"
  local clear = false

  local f = io.open(data_path, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match("^(%w+)%s*=%s*(.+)$")
      if key == "theme" then
        theme = value
      elseif key == "clear" then
        clear = value == "true"
      end
    end
    f:close()
  end

  clear = not clear

  local out = io.open(data_path, "w")
  if out then
    out:write("theme = " .. theme .. "\n")
    out:write("clear = " .. tostring(clear) .. "\n")
    out:close()
  end

  local transparency = require("config.transparency")
  if clear then
    transparency.enable()
  else
    transparency.disable(theme)
  end

  vim.notify("Transparent background: " .. tostring(clear))
end, { desc = "Toggle transparent background" })
