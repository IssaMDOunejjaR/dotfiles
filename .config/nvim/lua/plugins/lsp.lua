return {
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			-- "jay-babu/mason-nvim-dap.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
			{
				-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
				-- used for completion, annotations and signatures of Neovim apis
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			vim.diagnostic.config({
				severity_sort = true,
				update_in_insert = false, -- Disable diagnostics while typing
				virtual_text = { spacing = 4, prefix = "●" }, -- Adjust visual clutter
				signs = true,
				underline = true,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local builtin = require("telescope.builtin")

					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"

						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("<leader>lR", builtin.lsp_references, "[L]sp Goto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("<leader>lI", builtin.lsp_implementations, "[L]sp Goto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>lD", builtin.lsp_type_definitions, "[L]sp Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>lS", builtin.lsp_document_symbols, "[L]sp Document [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>lW", builtin.lsp_dynamic_workspace_symbols, "[L]sp [W]orkspace Symbols")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>lr", vim.lsp.buf.rename, "[L]sp [R]ename")

					-- Show diagnostics
					map("<leader>ld", vim.diagnostic.open_float, "[L]sp [D]iagnostics")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>la", vim.lsp.buf.code_action, "[L]sp Code [A]ction")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					map("<leader>li", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end, "[L]sp [I]nlay Hint")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end
				end,
			})

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				cssls = {},
				jsonls = {},
				html = {},
				bashls = {},
				yamlls = {},
				lemminx = {},
				ts_ls = {},
				angularls = {},
				tailwindcss = {},
				eslint_d = {},
				prettierd = {},
				emmet_language_server = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})

			vim.list_extend(ensure_installed, {
				"stylua",
			})

			-- require("mason-nvim-dap").setup({
			-- 	-- ensure_installed = { "java-test" },
			-- 	automatic_installation = true,
			-- })

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_enable = {
					exclude = {
						"rust_analyzer",
						"tailwindcss",
						"ts_ls",
					},
				},
				automatic_installation = false,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("angularls", {
				on_attach = function(client, bufnr)
					client.server_capabilities.renameProvider = false
				end,
			})

			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ max_width = 80, max_height = 20, border = "solid" })
			end)
		end,
	},
}
