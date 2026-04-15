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

	-- Neovim 0.12 added grt (type_definition) and grx (codelens.run) as default
	-- LSP mappings. Unmap them here so they don't silently shadow our bindings.
	-- Type defs are handled via `gy` (fzf-lua), codelens is not configured.
	pcall(vim.keymap.del, "n", "grt", { buffer = bufnr })
	pcall(vim.keymap.del, "n", "grx", { buffer = bufnr })

	-- ============================================================
	-- LSP NAVIGATION (Lspsaga)
	-- ============================================================
	keymap("n", "gd", "<Cmd>Lspsaga goto_definition<CR>", opts("LSP: Go to definition"))
	keymap("n", "gD", "<Cmd>Lspsaga peek_definition<CR>", opts("LSP: Peek definition"))
	keymap("n", "gV", "<Cmd>vsplit | Lspsaga goto_definition<CR>", opts("LSP: Go to definition (vsplit)"))
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
	keymap("n", "<leader>fl", "<Cmd>FzfLua lsp_finder<CR>", opts("LSP: Finder (def + refs)"))
	keymap("n", "<leader>fr", "<Cmd>FzfLua lsp_references<CR>", opts("LSP: References"))
	keymap("n", "<leader>ft", "<Cmd>FzfLua lsp_typedefs<CR>", opts("LSP: Type definitions"))
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
	-- GOMODIFYTAGS (Go only)
	-- Adds / removes struct field tags via the gomodifytags CLI tool.
	-- ============================================================
	if client.name == "gopls" then
		-- Add json tags to the struct under cursor (or visual selection)
		keymap("n", "<leader>gtj", function()
			local file = vim.fn.expand("%:p")
			local line = vim.fn.line(".")
			local out = vim.fn.system(
				string.format("gomodifytags -file '%s' -line %d -add-tags json -add-options json=omitempty -transform camelcase -w", file, line)
			)
			if vim.v.shell_error ~= 0 then
				vim.notify("gomodifytags: " .. out, vim.log.levels.ERROR)
			else
				vim.cmd("edit") -- reload buffer to pick up on-disk changes
			end
		end, opts("Go: Add json struct tags"))

		-- Remove json tags from the struct under cursor
		keymap("n", "<leader>gtJ", function()
			local file = vim.fn.expand("%:p")
			local line = vim.fn.line(".")
			local out = vim.fn.system(
				string.format("gomodifytags -file '%s' -line %d -remove-tags json -w", file, line)
			)
			if vim.v.shell_error ~= 0 then
				vim.notify("gomodifytags: " .. out, vim.log.levels.ERROR)
			else
				vim.cmd("edit")
			end
		end, opts("Go: Remove json struct tags"))
	end

	-- DAP keymaps are global (not buffer-local) and defined in lua/plugins/dap.lua.
end

return M
