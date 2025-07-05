return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		image = { enabled = true },
		indent = {
			enabled = true,

			animate = {
				enabled = false,
			},
			scope = {},
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		words = { enabled = true },
	},
}
