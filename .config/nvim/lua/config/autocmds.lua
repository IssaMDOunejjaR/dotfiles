local autocmd = vim.api.nvim_create_autocmd

if vim.env.TERM == "xterm-kitty" then
	autocmd("VimEnter", {
		command = ":silent !kitty @ set-spacing padding=0 margin=0",
	})

	autocmd("VimLeavePre", {
		command = ":silent !kitty @ set-spacing padding=20 margin=10",
	})
end

local function augroup(name)
	return vim.api.nvim_create_augroup("my_nvim_" .. name, { clear = true })
end

-- Create a custom Neovim command to run shell commands and display output in a temporary buffer
vim.api.nvim_create_user_command("Run", function(opts)
	-- Run the shell command and capture the output
	local output = vim.fn.systemlist(opts.args)

	-- Create a new scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

	-- Open the scratch buffer in a new split window
	vim.api.nvim_command("split")
	vim.api.nvim_win_set_buf(0, buf)

	-- Make the buffer read-only
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end, { nargs = 1, complete = "shellcmd" })

vim.b.disable_autoformat = false
vim.g.disable_autoformat = false

vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Disable autoformat on save",
	bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = "Re-enable autoformat on save",
})

vim.api.nvim_create_user_command("FormatRange", function(args)
	local range = nil

	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]

		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end

	require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "docker-compose.yml" },
	command = "set filetype=" .. "yaml.docker-compose",
})

autocmd("FileType", {
	pattern = { "help", "markdown", "text", "terminal", "dashboard" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- make it easier to close man-files when opened inline
autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Fix conceallevel for json files
autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Set filetype for .env and .env.* files
autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("env_filetype"),
	pattern = { "*.env", ".env.*" },
	callback = function()
		vim.opt_local.filetype = "sh"
	end,
})

-- Set filetype for .toml files
autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("toml_filetype"),
	pattern = { "*.tomg-config*" },
	callback = function()
		vim.opt_local.filetype = "toml"
	end,
})
