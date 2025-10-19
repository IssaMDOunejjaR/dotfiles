return {
  -- Disable Snack picker and use fzf-lua instead
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        enabled = false,
      },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    optional = true,
    keys = {
      {
        "<leader>st",
        "<cmd>TodoFzfLua<cr>",
        desc = "Todo",
      },
      {
        "<leader>sT",
        function()
          require("todo-comments.fzf").todo { keywords = { "TODO", "FIX", "FIXME" } }
        end,
        desc = "Todo/Fix/Fixme",
      },
    },
  },

  {
    "ibhagwan/fzf-lua",

    -- optional for icon support
    dependencies = { "echasnovski/mini.icons" },

    opts = {
      winopts = {
        border = "single",
        preview = {
          border = "single",
          hidden = true,
        },
      },
      keymap = {
        builtin = {
          ["<C-]>"] = "toggle-preview",
        },
      },
    },

    keys = {
      {
        "<leader>,",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>/",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>s/",
        function()
          require("fzf-lua").live_grep { cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") }
        end,
        desc = "Grep in folder",
      },
      {
        "<leader>f/",
        function()
          require("fzf-lua").files { cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") }
        end,
        desc = "Find in folder",
      },
      {
        "<leader>:",
        function()
          require("fzf-lua").command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader><space>",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          require("fzf-lua").files { cwd = vim.fn.stdpath "config" }
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").git_files()
        end,
        desc = "Find Git Files",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Recent Files",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>fw",
        function()
          require("fzf-lua").grep_cword()
        end,
        desc = "Word under cursor",
      },
      {
        "<leader>gc",
        function()
          require("fzf-lua").git_commits()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gs",
        function()
          require("fzf-lua").git_status()
        end,
        desc = "Git Status",
      },
      {
        "<leader>gS",
        function()
          require("fzf-lua").git_stash()
        end,
        desc = "Git Stash",
      },
      {
        "<leader>sb",
        function()
          require("fzf-lua").blines()
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>sB",
        function()
          require("fzf-lua").grep_buffers()
        end,
        desc = "Grep Open Buffers",
      },
      {
        "<leader>sg",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Grep",
      },
      {
        '<leader>s"',
        function()
          require("fzf-lua").registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>sc",
        function()
          require("fzf-lua").command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          require("fzf-lua").commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          require("fzf-lua").diagnostics_workspace()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>sD",
        function()
          require("fzf-lua").diagnostics_document()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sh",
        function()
          require("fzf-lua").help_tags()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          require("fzf-lua").highlights()
        end,
        desc = "Highlights",
      },
      {
        "<leader>sj",
        function()
          require("fzf-lua").jumps()
        end,
        desc = "Jumps",
      },
      {
        "<leader>sk",
        function()
          require("fzf-lua").keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>sl",
        function()
          require("fzf-lua").loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sm",
        function()
          require("fzf-lua").marks()
        end,
        desc = "Marks",
      },
      {
        "<leader>sM",
        function()
          require("fzf-lua").man_pages()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>sq",
        function()
          require("fzf-lua").quickfix()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>uC",
        function()
          require("fzf-lua").colorschemes()
        end,
        desc = "Colorschemes",
      },
      -- LSP
      {
        "gd",
        function()
          require("fzf-lua").lsp_definitions()
        end,
        desc = "Goto Definition",
      },
      {
        "gD",
        function()
          require("fzf-lua").lsp_declarations()
        end,
        desc = "Goto Declaration",
      },
      {
        "gr",
        function()
          require("fzf-lua").lsp_references()
        end,
        desc = "References",
      },
      {
        "gi",
        function()
          require("fzf-lua").lsp_implementations()
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("fzf-lua").lsp_typedefs()
        end,
        desc = "Goto Type Definition",
      },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "LSP Symbols",
      },
      {
        "<leader>sS",
        function()
          require("fzf-lua").lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
    },
  },
}
