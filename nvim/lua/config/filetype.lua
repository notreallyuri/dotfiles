vim.filetype.add({
  extension = {
    env = "conf",
  },
  filename = {
    [".env"] = "conf",
    [".env.local"] = "conf",
    [".env.development"] = "conf",
    [".env.production"] = "conf",
    [".env.test"] = "conf",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "conf",
  },
})
