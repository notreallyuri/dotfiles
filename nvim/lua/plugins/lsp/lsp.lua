return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.config("jdtls", {})
    vim.lsp.config("lua_ls", {})
    vim.lsp.config("biome", {})
    vim.lsp.config("marksman", {})

    vim.lsp.config("vtsls", require("plugins.lsp.settings.vtsls"))
    vim.lsp.config("tailwindcss", require("plugins.lsp.settings.tailwindcss"))
    vim.lsp.config("clangd", require("plugins.lsp.settings.clangd"))
    vim.lsp.config("eslint", { settings = { workingDirectories = { mode = "auto" } } })

    vim.lsp.config("omnisharp", {
      cmd = { "omnisharp" },
      handlers = {
        ["textDocument/definition"] = function(...)
          return require("omnisharp_extended").handler(...)
        end,
      },
      enable_roslyn_analyzers = true,
      organize_imports_on_format = true,
      enable_import_completion = true,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", {
            buffer = args.buf,
            desc = "Switch Source/Header (C/C++)",
          })
        end
      end,
    })

    vim.lsp.enable({ "lua_ls", "vtsls", "biome", "eslint", "tailwindcss", "marksman", "clangd", "omnisharp" })
    vim.lsp.enable("rust_analyzer", false)
    vim.lsp.enable("copilot", false)
  end,
}
