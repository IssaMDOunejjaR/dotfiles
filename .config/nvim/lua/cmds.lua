local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
	command = ":silent !kitty @ set-spacing padding=0 margin=0",
})

autocmd("VimLeavePre", {
	command = ":silent !kitty @ set-spacing padding=20 margin=10",
})

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

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

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "docker-compose.yml" },
	command = "set filetype=" .. "yaml.docker-compose",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "markdown", "text", "terminal", "dashboard" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})
