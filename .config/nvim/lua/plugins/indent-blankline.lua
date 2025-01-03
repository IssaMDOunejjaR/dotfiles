return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = "BufReadPost",
	config = function()
		require("ibl").setup({
			enabled = true,
			indent = { char = "│", tab_char = "│" },
			whitespace = {
				remove_blankline_trail = true,
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
			},
			exclude = {
				filetypes = { "help", "alpha", "NvimTree", "lazy", "terminal", "markdown" },
			},
		})
	end,
}
