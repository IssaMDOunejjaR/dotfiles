return {
	"williamboman/mason.nvim",

	dependencies = {
		"jay-babu/mason-nvim-dap.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
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
			virtual_text = { spacing = 3, prefix = "●" }, -- Adjust visual clutter
			signs = true,
			underline = true,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local fzf = require("fzf-lua")

				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc, mode)
					mode = mode or "n"

					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
				end

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map("gd", fzf.lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("<leader>lR", fzf.lsp_references, "[L]sp Goto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("<leader>lI", fzf.lsp_implementations, "[L]sp Goto [I]mplementation")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("<leader>lD", fzf.lsp_typedefs, "[L]sp Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("<leader>lS", fzf.lsp_document_symbols, "[L]sp Document [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map("<leader>lW", fzf.lsp_live_workspace_symbols, "[L]sp [W]orkspace Symbols")

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("<leader>lr", vim.lsp.buf.rename, "[L]sp [R]ename")

				-- Show diagnostics
				map("<leader>ld", vim.diagnostic.open_float, "[L]sp [D]iagnostics")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>la", fzf.lsp_code_actions, "[L]sp Code [A]ction")

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map("gD", fzf.lsp_declarations, "[G]oto [D]eclaration")

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

		local enabled_servers = {
			cssls = {},
			jsonls = {},
			html = {},
			bashls = {},
			yamlls = {},
			lemminx = {},
			angularls = {},
			eslint_d = {},
			prettierd = {},
			emmet_language_server = {},
			lua_ls = {},
		}

		local excluded_servers = {
			rust_analyzer = {},
			tailwindcss = {},
			ts_ls = {},
		}

		local servers = {}

		vim.list_extend(servers, enabled_servers)
		vim.list_extend(servers, excluded_servers)

		require("mason").setup()

		vim.list_extend(servers, {
			stylua = {},
		})

		-- require("mason-nvim-dap").setup({
		-- 	ensure_installed = { "java-test" },
		-- 	automatic_installation = true,
		-- })

		require("mason-tool-installer").setup({ ensure_installed = servers })

		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ max_width = 80, max_height = 20, border = "solid" })
		end)

		vim.lsp.enable({
			"lua_ls",
			"cssls",
			"jsonls",
			"html",
			"bashls",
			"yamlls",
			"lemminx",
			"angularls",
			"eslint_d",
			"prettierd",
			"emmet_language_server",
		})
	end,
}
