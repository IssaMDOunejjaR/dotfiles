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
		opts = {
			automatic_installation = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local servers = {
				html = {
					filetypes = {
						"html",
						"templ",
					},
				},
				gopls = {},
				rust_analyzer = {},
				htmx = {
					filetypes = {
						"html",
						"templ",
					},
				},
				tailwindcss = {
					filetypes = {
						"html",
						"templ",
					},
				},
				templ = {
					filetypes = {
						"templ",
					},
				},
				lua_ls = {},
				tsserver = {},
				clangd = {},
				jdtls = {},
				-- stylua = {},
				-- java_test = {},
				-- ["java-debug"] = {},
			}

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
			})

			for lsp, _ in pairs(servers) do
				lspconfig[lsp].setup({
					capabilities = capabilities,
				})
			end

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
