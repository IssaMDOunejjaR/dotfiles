local plugins = {
  { "kdheepak/lazygit.nvim" },

  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function() require("lazydocker").setup {} end,
    event = "VeryLazy", -- or any other event you might want to use.
  },

  { "ThePrimeagen/harpoon" },

  { "norcalli/nvim-colorizer.lua" },

  {
    'echasnovski/mini.indentscope',
    version = false,
    config = function()
      require("mini.indentscope").setup({
        draw = {
          delay = 10,
        },

        symbol = "│",
      })
    end
  },

  {
    'echasnovski/mini.splitjoin',
    version = false,
    config = function()
      require("mini.splitjoin").setup({})
    end
  },

  {
    "echasnovski/mini.surround",
    config = function()
      require("mini.surround").setup({})
    end
  },

  {
    'echasnovski/mini.move',
    version = false,
    config = function()
      require("mini.move").setup({})
    end
  },

  {
    "numToStr/Comment.nvim",
    lazy = false,
  },

  { "nvim-pack/nvim-spectre" },

  {
    "tiagovla/tokyodark.nvim",
    config = function(_, opts)
      require("tokyodark").setup(opts) -- calling setup is optional
      vim.cmd [[colorscheme tokyodark]]
    end,
  },

  {
    'stevearc/dressing.nvim',
    opts = {},
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
  },

  { "folke/neodev.nvim",     opts = {} },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
  },

  { "RRethy/vim-illuminate" },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
  },

  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },

  -- Lualine as statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        theme = "tokyodark",
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- Add indentation guides even on blank lines
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        enabled = true,
        indent = { char = "│" },
        whitespace = {
          remove_blankline_trail = true,
        },
        scope = {
          enabled = true,
        },
      })
    end,
  },

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep',
      'nvim-telescope/telescope-fzf-native.nvim',
    }
  },

  -- Lsp Zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      -- Lsps manager
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Lsp Support
      "neovim/nvim-lspconfig",

      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
      'lukas-reineke/lsp-format.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        tag = 'legacy',
        opts = {}
      },

      -- For Rust
      {
        "simrat39/rust-tools.nvim",
      }
    },
  },

  { "themaxmarchuk/tailwindcss-colors.nvim" },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  { "mfussenegger/nvim-jdtls" },
}

require("lazy").setup({
  spec = plugins,
  defaults = {
    lazy = false,
    version = false,
  },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
