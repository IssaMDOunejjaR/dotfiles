return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "css", "latex", "norg", "scss", "typst", "vue", "svelte" } },
  },

  -- -- Diagnostics UI
  -- {
  --   "folke/trouble.nvim",
  --   optional = true,
  --   specs = {
  --     "folke/snacks.nvim",
  --     opts = function(_, opts)
  --       return vim.tbl_deep_extend("force", opts or {}, {
  --         picker = {
  --           actions = require("trouble.sources.snacks").actions,
  --           win = {
  --             input = {
  --               keys = {
  --                 ["<c-t>"] = {
  --                   "trouble_open",
  --                   mode = { "n", "i" },
  --                 },
  --               },
  --             },
  --           },
  --         },
  --       })
  --     end,
  --   },
  -- },

  -- Session
  -- {
  --   "folke/persistence.nvim",
  --   lazy = false,
  --   -- event = "BufReadPre", -- this will only start session saving when an actual file was opened
  --   opts = {
  --     dir = vim.fn.stdpath "state" .. "/sessions/", -- where to save
  --     branch = false,
  --   },
  --   config = function(_, opts)
  --     local persistence = require "persistence"
  --
  --     persistence.setup(opts)
  --
  --     -- auto-save session on exit
  --     vim.api.nvim_create_autocmd("VimLeavePre", {
  --       callback = function()
  --         persistence.save()
  --       end,
  --     })
  --
  --     -- Auto-restore last session if no args are passed
  --     vim.api.nvim_create_autocmd("VimEnter", {
  --       nested = true,
  --       callback = function()
  --         if vim.fn.argc() == 0 then
  --           persistence.load()
  --         end
  --       end,
  --     })
  --   end,
  -- },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = {
        -- NOTE: brew install imagemagick to install on Mac, refer https://imagemagick.org/script/download.php for more detail
        -- For mermaidjs: npm install -g @mermaid-js/mermaid-cli
        enabled = false,
        doc = {
          -- enable image viewer for documents
          -- a treesitter parser must be available for the enabled languages.
          enabled = true,
          -- render the image inline in the buffer
          -- if your env doesn't support unicode placeholders, this will be disabled
          -- takes precedence over `opts.float` on supported terminals
          inline = false,
          -- render the image in a floating window
          -- only used if `opts.inline` is disabled
          float = true,
        },
      },
      explorer = {
        enabled = false,
      },
      picker = {
        enabled = false,
        ---@class snacks.picker.sources.Config
        sources = {
          files = {
            hidden = true, -- show hidden files
            follow = true,
          },
        },
        ----@class snacks.picker.layout.Config
        layout = {
          layout = {
            backdrop = true,
          },
        },
        ----@class snacks.picker.formatters.Config
        formatters = {
          file = {
            filename_first = true, -- display filename before the file path
          },
        },
        ---@class snacks.picker.previewers.Config
        previewers = {
          git = {
            native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
            cmd = { "delta " },
          },
        },
        ---@class snacks.picker.icons.Config
        icons = {
          files = {
            enabled = false, -- show file icons
          },
        },
        ---@class snacks.picker.win.Config
        win = {
          -- input window
          input = {
            keys = {
              -- Close picker
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              -- Hidden
              ["<a-.>"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<a-h"] = false,
            },
          },
        },
      },
      dashboard = {
        enabled = false,
      },
      bigfile = { enabled = true },
      scratch = { enabled = true },
      zen = {
        enabled = false,
      },
      indent = {
        enabled = true,
      },
      input = { enabled = false },
      scroll = { enabled = false },
      notifier = {
        enabled = true,
        --- Available style: "compact"|"fancy"|"minimal"
        style = "fancy", -- similar to the default nvim-notify style
        level = vim.log.levels.WARN, -- Show only warning and above
      },
      quickfile = { enabled = true },
      statuscolumn = {
        enabled = true,
      },
      words = { enabled = true },
      lazygit = { enabled = false },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
        -- LazyGit full screen
        lazygit = {
          width = 0,
          height = 0,
        },
      },
      -- Learn this tip from LazyVim
      terminal = {
        enabled = false,
      },
    },
    -- keys = {
    --   {
    --     "<c-/>",
    --     function()
    --       Snacks.terminal()
    --     end,
    --     desc = "Toggle Terminal",
    --   },
    --   {
    --     "<c-_>",
    --     function()
    --       Snacks.terminal()
    --     end,
    --     desc = "which_key_ignore",
    --   },
    --   -- Zen mode
    --   {
    --     "<leader>cz",
    --     function()
    --       Snacks.zen()
    --     end,
    --     desc = "Toggle Zen Mode",
    --   },
    --   {
    --     "<leader>tz",
    --     function()
    --       Snacks.zen.zoom()
    --     end,
    --     desc = "Toggle Zoom",
    --   },
    --
    --   -- Notifier
    --   {
    --     "<leader>uH",
    --     function()
    --       Snacks.notifier.show_history()
    --     end,
    --     desc = "Notification History",
    --   },
    --   {
    --     "<leader>un",
    --     function()
    --       Snacks.notifier.hide()
    --     end,
    --     desc = "Dismiss All Notifications",
    --   },

    -- Note
    -- {
    --   "<leader>no",
    --   function()
    --     Snacks.scratch()
    --   end,
    --   desc = "Open Note/Scratch Buffer",
    -- },
    -- {
    --   "<leader>ns",
    --   function()
    --     Snacks.scratch.select()
    --   end,
    --   desc = "Select Note/Scratch Buffer",
    -- },

    -- Buffer
    -- {
    --   "<S-q>",
    --   function()
    --     Snacks.bufdelete()
    --   end,
    --   desc = "Delete Buffer",
    -- },
    -- {
    --   "<leader>bd",
    --   function()
    --     Snacks.bufdelete()
    --   end,
    --   desc = "Delete Buffer",
    -- },

    --   {
    --     "<leader>cR",
    --     function()
    --       Snacks.rename.rename_file()
    --     end,
    --     desc = "Rename File",
    --   },
    --   {
    --     "<leader>gg",
    --     function()
    --       Snacks.lazygit()
    --     end,
    --     desc = "Lazygit",
    --   },

    -- {
    --   "<leader>go",
    --   function()
    --     Snacks.gitbrowse()
    --   end,
    --   desc = "Git Open on browser",
    --   mode = {
    --     "n",
    --     "v",
    --   },
    -- },

    --   {
    --     "<leader>gf",
    --     function()
    --       Snacks.lazygit.log_file()
    --     end,
    --     desc = "Lazygit Current File History",
    --   },
    --   {
    --     "<leader>gl",
    --     function()
    --       Snacks.lazygit.log()
    --     end,
    --     desc = "Lazygit Log (cwd)",
    --   },
    --   {
    --     "<leader>gL",
    --     function()
    --       Snacks.git.blame_line()
    --     end,
    --     desc = "Git Blame Line",
    --   },
    --   {
    --     "]]",
    --     function()
    --       Snacks.words.jump(vim.v.count1)
    --     end,
    --     desc = "Next Reference",
    --     mode = { "n", "t" },
    --   },
    --   {
    --     "[[",
    --     function()
    --       Snacks.words.jump(-vim.v.count1)
    --     end,
    --     desc = "Prev Reference",
    --     mode = { "n", "t" },
    --   },
    -- },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
          Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
          Snacks.toggle.diagnostics():map "<leader>ud"
          Snacks.toggle.line_number():map "<leader>ul"
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map "<leader>uc"
          Snacks.toggle.treesitter():map "<leader>uT"
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>ub"
          Snacks.toggle.inlay_hints():map "<leader>uh"
          Snacks.toggle.indent():map "<leader>ug"
          Snacks.toggle.dim():map "<leader>uD"
        end,
      })
    end,
  },
}
