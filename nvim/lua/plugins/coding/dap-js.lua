return {
  "mfussenegger/nvim-dap",
  ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  config = function()
    local dap = require("dap")

    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          -- assumes vitest; swap runtimeArgs[1] for jest's bin if a project uses jest instead
          type = "pwa-node",
          request = "launch",
          name = "Debug current test file (vitest)",
          runtimeExecutable = "node",
          runtimeArgs = { "${workspaceFolder}/node_modules/.bin/vitest", "run", "${file}" },
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
      }
    end
  end,
}
