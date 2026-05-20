return {
  "saghen/blink.cmp",
  version = "*",
  dependencies = "rafamadriz/friendly-snippets",
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<C-space>"] = { "show", "fallback" },
      ["<Esc>"] = { "fallback" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
    },
  },
}
