return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				component_separators = "|",
			},
		})
	end,
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
