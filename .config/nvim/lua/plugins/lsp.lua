return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} }, -- LSP/DAP/Linter installer & manager
		"mason-org/mason-lspconfig.nvim",
	},
	config = function()
		-- require("utils.diagnostics").setup()
		-- require("servers")

		require("mason").setup({
			ui = {
				border = "single",
			},
		})

		require("mason-lspconfig").setup({ ensure_installed = {}, automatic_enable = true })

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

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					workspace = {
						-- size in KB; raise above ~660
						maxPreload = 20000,
						preloadFileSize = 20000,
						ignoreDir = {
							vim.fn.stdpath("data") .. "/mason",
						},
					},
					misc = {
						-- reduce noise like “Too large file … skipped”
						logLevel = "warning", -- or "error"
					},
				},
			},
		})

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = border,
			max_width = 50,
			max_height = 25,
		})
	end,
}
