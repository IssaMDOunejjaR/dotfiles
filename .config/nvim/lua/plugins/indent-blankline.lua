return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		require("ibl").setup({
			enabled = true,
			indent = { char = "│" },
			whitespace = {
				remove_blankline_trail = true,
			},
			scope = {
				enabled = true,
			},
		})
	end,
}
