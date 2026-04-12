local ok, lsp_utils = pcall(require, "utils.lsp")
local on_attach = ok and lsp_utils.on_attach or nil

local function augroup(name)
	return vim.api.nvim_create_augroup("My" .. name, { clear = true })
end

-- ============================================================
-- FILETYPE DETECTION
-- ============================================================
vim.filetype.add({
	extension = {
		env = "sh",
		templ = "templ",
	},
	pattern = {
		["docker-compose*.yml"] = "yaml.docker-compose",
		["playbook*.yml"] = "yaml.ansible",
		["site*.yml"] = "yaml.ansible",
		["roles/*/tasks/*.yml"] = "yaml.ansible",
		["roles/*/handlers/*.yml"] = "yaml.ansible",
		["group_vars/*.yml"] = "yaml.ansible",
		["host_vars/*.yml"] = "yaml.ansible",
	},
})

-- ============================================================
-- EDITOR BEHAVIOR
-- ============================================================

-- Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("LastCursorGroup"),
	callback = function(event)
		-- Don't restore position in git commit messages
		if vim.bo[event.buf].filetype == "gitcommit" then
			return
		end
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(event.buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("HighlightYank"),
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- Resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("ResizeSplits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Auto-read changed files on focus
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("AutoRead"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- ============================================================
-- FILE HANDLING
-- ============================================================

-- Close special buffers with 'q'
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("CloseWithQ"),
	pattern = {
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"loclist",
		"startuptime",
		"plug",
		"tsplayground",
		"checkhealth",
		"aerial",
		"git",
		"query", -- treesitter query editor
		"neotest-output",
		"neotest-summary",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<Cmd>close<CR>", {
			buffer = event.buf,
			silent = true,
			nowait = true,
			desc = "Close window",
		})
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("AutoCreateDir"),
	callback = function(event)
		-- Skip remote files (ssh://, oil://, etc.)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		-- Use expand to get full path (works even if file doesn't exist yet)
		local dir = vim.fn.fnamemodify(vim.fn.expand(event.match), ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("TrimWhitespace"),
	callback = function(event)
		local ignore = { markdown = true, diff = true, gitcommit = true }
		if ignore[vim.bo[event.buf].filetype] then
			return
		end

		local cursor = vim.api.nvim_win_get_cursor(0)
		-- Get all lines, trim trailing whitespace, write back
		local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
		local changed = false
		for i, line in ipairs(lines) do
			local trimmed = line:gsub("%s+$", "")
			if trimmed ~= line then
				lines[i] = trimmed
				changed = true
			end
		end
		if changed then
			vim.api.nvim_buf_set_lines(event.buf, 0, -1, false, lines)
			-- Restore cursor (line count unchanged by trim)
			pcall(vim.api.nvim_win_set_cursor, 0, cursor)
		end
	end,
})

-- vim.api.nvim_create_autocmd("FocusLost", {
-- 	group = augroup("AutoSave"),
-- 	callback = function()
-- 		local bufnr = vim.api.nvim_get_current_buf()
-- 		if vim.bo[bufnr].buftype == "" and not vim.bo[bufnr].readonly and vim.bo[bufnr].modified then
-- 			vim.cmd("silent! update")
-- 		end
-- 	end,
-- })

-- ============================================================
-- CODE QUALITY / UX
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("NoAutoComment"),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Auto spell for text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("AutoSpell"),
	pattern = { "markdown", "text", "gitcommit", "txt" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en", "fr" }
	end,
})

-- Terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup("TerminalSettings"),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.scrolloff = 0 -- no scrolloff in terminal
		vim.cmd("startinsert")
	end,
})

-- ============================================================
-- LSP
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup("LspMappings"),
	callback = function(event)
		if not on_attach then
			return
		end
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client then
			on_attach(client, event.buf)
		end
	end,
})
