return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {
			ui = {
				border = "single",
			},
		} },
		"mason-org/mason-lspconfig.nvim",
	},
	config = function()
		require("mason-lspconfig").setup({ ensure_installed = {}, automatic_enable = true })

		vim.lsp.config("bashls", {
			filetypes = { "bash", "sh", "zsh" },
		})

		vim.lsp.config("html", {
			filetypes = { "html", "templ" },
		})

		vim.lsp.config("emmet_language_server", {
			filetypes = { "html", "templ" },
		})

		vim.lsp.config("vtsls", {
			on_attach = function(_, bufnr)
				vim.keymap.set("n", "gS", function()
					require("vtsls").commands.goto_source_definition(0)
				end, {
					buffer = bufnr,
					desc = "LSP: Go to Source Definition",
				})
			end,
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					-- Tell lua_ls about neovim globals
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false, -- stops "Do you want to configure" prompts
						maxPreload = 20000,
						preloadFileSize = 20000,
						ignoreDir = {
							vim.fn.stdpath("data") .. "/mason",
						},
					},
					diagnostics = {
						-- Recognize vim global without lazydev.nvim
						globals = { "vim" },
					},
					misc = {
						-- reduce noise like “Too large file … skipped”
						logLevel = "warning", -- or "error"
					},
					telemetry = {
						-- Don't send telemetry data
						enable = false,
					},
				},
			},
		})
	end,
}
