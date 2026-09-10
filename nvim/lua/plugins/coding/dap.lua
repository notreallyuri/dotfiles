-- Everything nvim-dap needs lives in this one spec on purpose: lazy.nvim keeps
-- only the last `config` function when a plugin is declared by several specs,
-- so a second nvim-dap spec elsewhere would silently discard this one.
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason-org/mason.nvim",
      opts = {
        ensure_installed = { "codelldb", "js-debug-adapter", "netcoredbg" },
        automatic_installation = true,
      },
    },
  },
  ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
  },
  config = function()
    require("nvim-dap-virtual-text").setup()

    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- Rust uses codelldb through rustaceanvim, and Java registers its own
    -- adapter from nvim-jdtls' setup_dap (see ftplugin/java.lua), so neither
    -- is configured here.

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

    -- mason-nvim-dap installs netcoredbg but registers no launch configuration
    -- for it, so C# gets its adapter and configurations spelled out here.
    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        request = "launch",
        name = "Launch dll",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        cwd = "${workspaceFolder}",
      },
      {
        type = "coreclr",
        request = "attach",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
      },
    }
  end,
}
