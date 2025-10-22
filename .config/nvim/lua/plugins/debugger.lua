return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>d", group = "Debugging" },
        {
          "<leader>dt",
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "Toggle Breakpoint",
          nowait = true,
          remap = false,
        },
        {
          "<leader>dc",
          function()
            require("dap").continue()
          end,
          desc = "Continue",
          nowait = true,
          remap = false,
        },
        {
          "<leader>di",
          function()
            require("dap").step_into()
          end,
          desc = "Step Into",
          nowait = true,
          remap = false,
        },
        {
          "<leader>do",
          function()
            require("dap").step_over()
          end,
          desc = "Step Over",
          nowait = true,
          remap = false,
        },
        {
          "<leader>du",
          function()
            require("dap").step_out()
          end,
          desc = "Step Out",
          nowait = true,
          remap = false,
        },
        {
          "<leader>db",
          function()
            require("dap").step_back()
          end,
          desc = "Step Back",
          nowait = true,
          remap = false,
        },
        {
          "<leader>dr",
          function()
            require("dap").repl.open()
          end,
          desc = "Open REPL",
          nowait = true,
          remap = false,
        },
        {
          "<leader>dl",
          function()
            require("dap").run_last()
          end,
          desc = "Run Last",
          nowait = true,
          remap = false,
        },
        {
          "<leader>dq",
          function()
            require("dap").terminate()
            require("dapui").close()
            require("nvim-dap-virtual-text").toggle()
          end,
          desc = "Terminate",
          nowait = true,
          remap = false,
        },
        -- {
        --   "<leader>db",
        --   function()
        --     require("dap").list_breakpoints()
        --   end,
        --   desc = "List Breakpoints",
        --   nowait = true,
        --   remap = false,
        -- },
        {
          "<leader>de",
          function()
            require("dapui").eval()
          end,
          desc = "Eval",
          nowait = true,
          remap = false,
        },
        {
          "<leader>dk",
          function()
            require("dap.ui.widgets").hover()
          end,
          desc = "Hover",
          nowait = true,
          remap = false,
        },
        {
          "<leader>da",
          function()
            require("dap").restart()
          end,
          desc = "Restart",
          nowait = true,
          remap = false,
        },
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      require("nvim-dap-virtual-text").setup {
        highlight_new_as_changed = true,
      }

      require("mason-nvim-dap").setup {
        ensure_installed = {},
        automatic_installation = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      }

      dap.adapters = {
        gdb = {
          type = "executable",
          command = "gdb",
          name = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        },
        cppdbg = {
          id = "cppdbg",
          type = "executable",
          command = vim.fn.stdpath "data" .. "/mason/bin/OpenDebugAD7",
        },
      }

      dap.configurations = {
        c = {
          {
            name = "Launch with GDB + reverse",
            type = "cppdbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopAtEntry = true,
            setupCommands = {
              {
                text = "-enable-pretty-printing",
                description = "Enable pretty printing",
              },
              -- { text = '-interpreter-exec console "target record-full"', description = "Enable reverse debugging" },
            },
            MIMode = "gdb",
            miDebuggerPath = "gdb",
          },
          {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            args = {},
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
            setupCommands = {
              {
                -- text = '-interpreter-exec console "record"',
                text = "target record-full",
                description = "Enable reverse debugging",
              },
            },
          },
          {
            name = "Select and attach to process",
            type = "gdb",
            request = "attach",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            pid = function()
              local name = vim.fn.input "Executable name (filter): "
              return require("dap.utils").pick_process { filter = name }
            end,
            cwd = "${workspaceFolder}",
          },
          {
            name = "Attach to gdbserver :1234",
            type = "gdb",
            request = "attach",
            target = "localhost:1234",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
        },
      }

      dapui.setup {
        controls = { enabled = false },
        floating = { border = "single" },
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 1.0,
              },
            },
            position = "bottom",
            size = 15,
          },
        },
      }

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end

      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
