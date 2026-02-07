local on_attach = require("utils.lsp").on_attach

local function augroup(name)
	return vim.api.nvim_create_augroup("My" .. name, { clear = true })
end

-- Restore last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("LastCursorGroup"),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight the yanked text for 200ms
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("HighlightYank"),
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("ResizeSplits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("ManUnlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("AutoCreateDir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		-- support both new and old versions of neovim
		local uv = vim.uv or vim.loop
		local file = uv.fs_realpath and uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Set filetype for .env and .env.* files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("env_filetype"),
	pattern = { "*.env", ".env.*" },
	callback = function()
		vim.opt_local.filetype = "sh"
	end,
})

-- Set filetype for .toml files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("toml_filetype"),
	pattern = { "*.toml*" },
	callback = function()
		vim.opt_local.filetype = "toml"
	end,
})

-- Set filetype for docker-compose files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("set_file_type"),
	pattern = "docker-compose*.yml",
	callback = function()
		vim.bo.filetype = "yaml.docker-compose"
	end,
})

-- Set filetype for ansible files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("set_file_type"),
	pattern = {
		"playbook*.yml",
		"site*.yml",
		"roles/*/tasks/*.yml",
		"roles/*/handlers/*.yml",
		"group_vars/*.yml",
		"host_vars/*.yml",
	},
	callback = function()
		vim.bo.filetype = "yaml.ansible"
	end,
})

-- on attach function shortcuts
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup("LspMappings"),
	callback = on_attach,
})
