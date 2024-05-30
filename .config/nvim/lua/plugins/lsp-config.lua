return {
	{
		"williamboman/mason.nvim",
		dependencies = {},
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
	},
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
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
				},
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					"java-test",
					"java-debug-adapter",
					"stylua",
					"checkstyle",
					"google-java-format",
				},
			})

			mason_lspconfig.setup_handlers({
				function(server_name)
					if server_name ~= "jdtls" then
						lspconfig[server_name].setup({
							capabilities = capabilities,
						})
					end
				end,
			})

			lspconfig["tailwindcss"].setup({
				on_attach = function(_, bufnr)
					require("tailwindcss-colors").buf_attach(bufnr)
				end,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {})
		end,
	},
}
