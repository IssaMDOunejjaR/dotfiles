return {
	"glepnir/lspsaga.nvim",
	event = "LspAttach",
	config = function()
		require("lspsaga").setup({
			hover = {
				max_width = 0.6,
				max_height = 0.4,
			},
			ui = {
				border = "single",
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
}
