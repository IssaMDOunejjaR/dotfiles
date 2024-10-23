return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		require("ibl").setup({
			enabled = true,
			indent = { char = "│", tab_char = "│" },
			whitespace = {
				remove_blankline_trail = true,
			},
			scope = {
				enabled = false,
			},
			exclude = {
				filetypes = { "help", "alpha", "NvimTree", "lazy" },
			},
		})
	end,
}
