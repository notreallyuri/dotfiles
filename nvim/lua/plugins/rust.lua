return {
  {
    "Saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>cR", function()
              vim.cmd.RustLsp("codeAction")
            end, { desc = "Rust code action", buffer = bufnr })
            vim.keymap.set("n", "<leader>dr", function()
              vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust debuggables", buffer = bufnr })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              procMacro = {
                enable = true,
                ignored = {
                  leptos_macro = { "server" },
                },
              },
              files = {
                exclude = { ".git", "node_modules", "target", ".venv" },
                watcher = "client",
              },
            },
          },
        },
      }
    end,
  },
}
