return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              procMacro = {
                ignored = {
                  ["leptos_macro"] = { "server" },
                },
              },
            },
          },
        },
        tailwindcss = {
          filetypes_include = { "rust" },
          settings = {
            tailwindCSS = {
              includeLanguages = {
                rust = "html",
              },
              experimental = {
                classAttributes = {
                  "class",
                  "class:",
                },
                classRegex = {
                  { "cn!?\\s*\\(([^)]*)\\)", "[\"']([^\"']*)[\"']" },
                },
              },
            },
          },
        },
      },
    },
  },
}
