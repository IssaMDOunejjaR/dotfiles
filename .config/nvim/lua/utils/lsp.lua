local M = {}

M.on_attach = function(client, bufnr)
	if not client then
		return
	end

	local opts = function(desc)
		return {
			silent = true,
			buffer = bufnr,
			desc = desc,
		}
	end

	local keymap = vim.keymap.set

	-- ============================================================
	-- LSP NAVIGATION (Lspsaga)
	-- ============================================================
	keymap("n", "gd", "<Cmd>Lspsaga goto_definition<CR>", opts("LSP: Go to definition"))
	keymap("n", "gD", "<Cmd>Lspsaga peek_definition<CR>", opts("LSP: Peek definition"))
	keymap("n", "gS", "<Cmd>vsplit | Lspsaga goto_definition<CR>", opts("LSP: Go to definition (split)"))
	keymap("n", "gcD", vim.lsp.buf.declaration, opts("LSP: Go to declaration"))

	-- Hover
	keymap("n", "K", "<Cmd>Lspsaga hover_doc<CR>", opts("LSP: Hover documentation"))

	-- ============================================================
	-- CODE ACTIONS & RENAME
	-- ============================================================
	keymap("n", "<leader>ca", "<Cmd>Lspsaga code_action<CR>", opts("LSP: Code action"))
	keymap("n", "<leader>cr", "<Cmd>Lspsaga rename<CR>", opts("LSP: Rename symbol"))

	-- ============================================================
	-- DIAGNOSTICS
	keymap("n", "<leader>cd", "<Cmd>Lspsaga show_line_diagnostics<CR>", opts("LSP: Line diagnostics"))
	keymap("n", "<leader>cD", "<Cmd>Lspsaga show_cursor_diagnostics<CR>", opts("LSP: Cursor diagnostics"))
	keymap("n", "[d", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", opts("LSP: Previous diagnostic"))
	keymap("n", "]d", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts("LSP: Next diagnostic"))

	-- Jump only to errors (skip warnings)
	keymap("n", "[e", function()
		require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
	end, opts("LSP: Previous error"))
	keymap("n", "]e", function()
		require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
	end, opts("LSP: Next error"))

	-- ============================================================
	-- FZF-LUA LSP PICKERS
	-- ============================================================
	keymap("n", "<leader>fd", "<Cmd>FzfLua lsp_finder<CR>", opts("LSP: Finder (def + refs)"))
	keymap("n", "<leader>fr", "<Cmd>FzfLua lsp_references<CR>", opts("LSP: References"))
	keymap("n", "<leader>ft", "<Cmd>FzfLua lsp_typedefs<CR>", opts("LSP: Type definitions"))
	keymap("n", "<leader>fs", "<Cmd>FzfLua lsp_document_symbols<CR>", opts("LSP: Document symbols"))
	keymap("n", "<leader>fw", "<Cmd>FzfLua lsp_workspace_symbols<CR>", opts("LSP: Workspace symbols"))
	keymap("n", "<leader>fi", "<Cmd>FzfLua lsp_implementations<CR>", opts("LSP: Implementations"))

	-- ============================================================
	-- ORGANIZE IMPORTS
	-- ============================================================
	if client:supports_method("textDocument/codeAction") then
		keymap("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
			})
		end, opts("LSP: Organize imports"))
	end

	-- ============================================================
	-- INLAY HINTS (Neovim 0.10+)
	-- ============================================================
	if client:supports_method("textDocument/inlayHint") then
		-- Enable inlay hints by default
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

		keymap("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, opts("LSP: Toggle inlay hints"))
	end

	-- ============================================================
	-- DOCUMENT HIGHLIGHT ON CURSOR HOLD
	-- Highlights all references to symbol under cursor
	-- ============================================================
	if client:supports_method("textDocument/documentHighlight") then
		local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd("CursorHold", {
			group = highlight_augroup,
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = highlight_augroup,
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
		-- Clean up when LSP detaches
		vim.api.nvim_create_autocmd("LspDetach", {
			group = highlight_augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({
					group = highlight_augroup,
					buffer = bufnr,
				})
			end,
		})
	end

	-- ============================================================
	-- DAP KEYMAPS (Rust only)
	-- ============================================================
	if client.name == "rust-analyzer" then
		local ok, dap = pcall(require, "dap")
		if ok then
			keymap("n", "<leader>dc", dap.continue, opts("DAP: Continue / Start"))
			keymap("n", "<leader>do", dap.step_over, opts("DAP: Step over"))
			keymap("n", "<leader>di", dap.step_into, opts("DAP: Step into"))
			keymap("n", "<leader>du", dap.step_out, opts("DAP: Step out"))
			keymap("n", "<leader>db", dap.toggle_breakpoint, opts("DAP: Toggle breakpoint"))
			keymap("n", "<leader>dr", dap.repl.open, opts("DAP: Open REPL"))
		else
			vim.notify("rust-analyzer attached but nvim-dap not found — DAP keymaps not set", vim.log.levels.WARN)
		end
	end
end

return M
