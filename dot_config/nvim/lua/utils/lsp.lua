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
	-- LSP NAVIGATION (native — Neovim 0.12)
	-- ============================================================
	keymap("n", "gd", vim.lsp.buf.definition, opts("LSP: Go to definition"))
	keymap("n", "gD", vim.lsp.buf.declaration, opts("LSP: Go to declaration"))
	keymap("n", "gV", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts("LSP: Go to definition (vsplit)"))
	-- alias kept for muscle memory (same target as gD)
	keymap("n", "gcD", vim.lsp.buf.declaration, opts("LSP: Go to declaration"))

	-- Hover
	keymap("n", "K", vim.lsp.buf.hover, opts("LSP: Hover documentation"))

	-- ============================================================
	-- CODE ACTIONS & RENAME
	-- ============================================================
	keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts("LSP: Code action"))
	-- inc-rename: live-preview rename. Expr mapping that pre-fills the cmdline
	-- with the word under the cursor; triggers the `IncRename` cmd lazy-load.
	keymap("n", "<leader>cr", function()
		return ":IncRename " .. vim.fn.expand("<cword>")
	end, {
		silent = true,
		buffer = bufnr,
		desc = "LSP: Rename symbol (live preview)",
		expr = true,
	})

	-- ============================================================
	-- DIAGNOSTICS
	keymap("n", "<leader>cd", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts("LSP: Line diagnostics"))
	keymap("n", "<leader>cD", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts("LSP: Cursor diagnostics"))
	keymap("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, opts("LSP: Previous diagnostic"))
	keymap("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, opts("LSP: Next diagnostic"))

	-- Jump only to errors (skip warnings)
	keymap("n", "[e", function()
		vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
	end, opts("LSP: Previous error"))
	keymap("n", "]e", function()
		vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
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
		-- Off by default — toggle with <leader>th
		vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

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
			-- List form: no shell quoting issues with special characters in paths
			local out = table.concat(
				vim.fn.system({
					"gomodifytags",
					"-file", file,
					"-line", line,
					"-add-tags", "json",
					"-add-options", "json=omitempty",
					"-transform", "camelcase",
					"-w",
				}),
				"\n"
			)
			if vim.v.shell_error ~= 0 then
				vim.notify("gomodifytags: " .. out, vim.log.levels.ERROR)
			else
				vim.cmd("checktime") -- reload buffer to pick up on-disk changes
			end
		end, opts("Go: Add json struct tags"))

		-- Remove json tags from the struct under cursor
		keymap("n", "<leader>gtJ", function()
			local file = vim.fn.expand("%:p")
			local line = vim.fn.line(".")
			local out = table.concat(
				vim.fn.system({ "gomodifytags", "-file", file, "-line", line, "-remove-tags", "json", "-w" }),
				"\n"
			)
			if vim.v.shell_error ~= 0 then
				vim.notify("gomodifytags: " .. out, vim.log.levels.ERROR)
			else
				vim.cmd("checktime")
			end
		end, opts("Go: Remove json struct tags"))
	end

	-- DAP keymaps are global (not buffer-local) and defined in lua/plugins/dap.lua.
end

return M
