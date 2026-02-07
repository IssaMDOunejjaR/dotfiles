return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} }, -- LSP/DAP/Linter installer & manager
    "mason-org/mason-lspconfig.nvim",
		-- "creativenull/efmls-configs-nvim", -- Preconfigured EFM Language Server setups
		-- "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for LSP-based completion
	},
	config = function()
		-- require("utils.diagnostics").setup()
		-- require("servers")

    require("mason").setup {
      ui = {
        border = "single",
      },
    }

    local mason = require "mason-lspconfig"
    local servers = mason.get_installed_servers()
    -- local Lsp = require "utils.lsp"

    require("mason-lspconfig").setup {
      ensure_installed = {},
      automatic_enable = true,
    }

    -- for _, server in ipairs(servers) do
    --   vim.lsp.config(server, {
    --     on_attach = Lsp.on_attach,
    --   })
    -- end

    vim.lsp.config("bashls", {
      filetypes = { "bash", "sh", "zsh" },
    })

    vim.lsp.config("vtsls", {
      on_attach = function()
        vim.keymap.set("n", "gS", function()
          require("vtsls").commands.goto_source_definition(0)
        end, { desc = "Go to Source Definition" })
      end,
    })
	end,
}
