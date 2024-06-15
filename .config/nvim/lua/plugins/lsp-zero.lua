return {
	{ "neovim/nvim-lspconfig" },
	{
		"williamboman/mason.nvim",
		lazy = false,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
	},
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	{
		"VonHeikemen/lsp-zero.nvim",
		config = function()
			local lsp_zero = require("lsp-zero")

			lsp_zero.extend_lspconfig()

			lsp_zero.on_attach(function(_, bufnr)
				lsp_zero.default_keymaps({ bufnr = bufnr })
				lsp_zero.buffer_autoformat()

				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
				vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
				vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = bufnr })
				vim.keymap.set(
					"n",
					"<leader>eh",
					"<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>",
					{ buffer = bufnr }
				)
			end)

			lsp_zero.set_sign_icons({
				error = "✘",
				warn = "▲",
				hint = "⚑",
				info = "»",
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()

			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = {
					"html",
					"gopls",
					"rust_analyzer",
					"htmx",
					"tailwindcss",
					"templ",
					"lua_ls",
					"tsserver",
					"clangd",
					"jdtls",
					"bashls",
					"yamlls",
				},
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,
					rust_analyzer = lsp_zero.noop,
					jdtls = lsp_zero.noop,
				},
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					"java-test",
					"java-debug-adapter",
					"stylua",
					"checkstyle",
					"google-java-format",
					"eslint_d",
					"prettier",
					"rustfmt",
					"shfmt",
				},
			})

			local callback = function()
				vim.lsp.buf.format({
					filter = function(client)
						return client.name == "templ"
					end,
				})
			end

			vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = callback })
		end,
	},
}
