return {
	"navarasu/onedark.nvim",
	priority = 1000, -- Ensure it loads first
	config = function()
		-- Load the colorscheme here.
		-- Like many other themes, this one has different styles, and you could load
		-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
		-- vim.cmd.colorscheme("onedark")
		local onedark = require("onedark")

		onedark.setup({
			style = "warmer",
		})

		onedark.load()

		-- You can configure highlights by doing something like:
		vim.cmd.hi("Comment gui=none")
	end,
}
