return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {
			ui = {
				border = "single",
			},
		} },
		"mason-org/mason-lspconfig.nvim",
		-- Required for require("vtsls").commands.* in the vtsls on_attach below
		"yioneko/nvim-vtsls",
	},
	config = function()
		require("mason-lspconfig").setup({ ensure_installed = {}, automatic_enable = true })

		-- Merge blink.cmp capabilities into every LSP server so completion
		-- works correctly even in edge cases not covered by automatic_enable.
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})

		vim.lsp.config("bashls", {
			filetypes = { "bash", "sh", "zsh" },
		})

		vim.lsp.config("html", {
			filetypes = { "html", "htmlangular", "templ" },
		})

		vim.lsp.config("emmet_language_server", {
			filetypes = {
				"html", "htmlangular", "templ",
				"javascriptreact", "typescriptreact",
				"css", "scss",
			},
		})

		-- Explicit filetypes so templ and Angular templates get Tailwind completion.
		-- mason-lspconfig defaults do not include templ or htmlangular.
		vim.lsp.config("tailwindcss", {
			filetypes = {
				"html", "htmlangular", "templ",
				"javascript", "typescript",
				"javascriptreact", "typescriptreact",
				"svelte", "vue",
				"css", "scss",
			},
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

		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					gofumpt = true, -- stricter formatting (requires gofumpt installed)
					analyses = {
						unusedparams = true,
						unusedvariable = true,
						shadow = true,
					},
					staticcheck = true, -- enables staticcheck analyses
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false, -- stops "Do you want to configure" prompts
						maxPreload = 2000,
						preloadFileSize = 3000, -- lua-ls ships meta files up to ~2.5 MB (UnityEngine.lua)
						ignoreDir = {
							vim.fn.stdpath("data") .. "/mason",
							vim.fn.stdpath("data") .. "/lazy",
						},
					},
					-- lazydev.nvim handles vim.* globals — no need for globals = { "vim" } here
					diagnostics = {
						globals = {},
					},
					misc = {
						logLevel = "warning",
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
	end,
}
