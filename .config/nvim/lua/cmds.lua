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
