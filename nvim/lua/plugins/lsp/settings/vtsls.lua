return {
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      if not result or not result.diagnostics then
        return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
      end

      local uri = result.uri
      local bufnr = vim.uri_to_bufnr(uri)

      if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
        return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
      end

      local ns = vim.api.nvim_create_namespace("vtsls_ghost_hints")
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      local filtered_diagnostics = {}
      for _, diag in ipairs(result.diagnostics) do
        if diag.code == 6133 or diag.code == 6196 then
          pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, diag.range.start.line, diag.range.start.character, {
            end_line = diag.range["end"].line,
            end_col = diag.range["end"].character,
            hl_group = "DiagnosticUnnecessary",
          })
        else
          table.insert(filtered_diagnostics, diag)
        end
      end

      result.diagnostics = filtered_diagnostics
      vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
    end,
  },

  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
  },
}
