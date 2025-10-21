return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
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
        {
          "<leader>db",
          function()
            require("dap").list_breakpoints()
          end,
          desc = "List Breakpoints",
          nowait = true,
          remap = false,
        },
        {
          "<leader>de",
          function()
            require("dap").set_exception_breakpoints { "all" }
          end,
          desc = "Set Exception Breakpoints",
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
      local nio = require "nio"

      require("nvim-dap-virtual-text").setup {
        highlight_new_as_changed = true,
      }

      require("mason").setup()

      require("mason-nvim-dap").setup {
        ensure_installed = {},
        automatic_installation = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      }

      dap.configurations = {
        c = {
          {
            name = "Launch",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/a.out", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
          },
        },
      }

      dapui.setup()

      vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

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

      -- nio.autocmd.attach("dap_repl", {
      --   on_buf_write_post = function(args)
      --     local repl_buf = args.buf
      --     local repl_lines = vim.api.nvim_buf_get_lines(repl_buf, 0, -1, false)
      --     local last_line = repl_lines[#repl_lines]
      --     if last_line and last_line:match "^%s*$" == nil then
      --       dap.repl.run_command(last_line)
      --     end
      --   end,
      -- })
    end,
  },
}
