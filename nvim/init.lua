-- bootstrap lazy.nvim, LazyVim and your plugins
package.path = package.path .. ";" .. vim.fn.expand("~/.config/nothings/?.lua")
require("config.lazy")
