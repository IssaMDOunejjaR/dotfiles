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
		"nvimdev/lspsaga.nvim",
		config = function()
			require("lspsaga").setup({
				event = "LspAttach",
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		opts = {
			inlay_hints = {
				enabled = true,
			},
		},
		config = function()
			local function has_value(table, value)
				for _, val in ipairs(table) do
					if val == value then
						return true
					end
				end

				return false
			end

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
					"bashls",
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

			local excluded = { "jdtls", "rust_analyzer" }

			mason_lspconfig.setup_handlers({
				function(server_name)
					if not has_value(excluded, server_name) then
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
			vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {})
			vim.keymap.set(
				"n",
				"<leader>eh",
				":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>",
				{}
			)
		end,
	},
}
