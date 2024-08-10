return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				disabled_filetypes = { "neo-tree" },
			},
			sections = {
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {},
				lualine_y = { "filetype" },
			},
			inactive_sections = {},
		})
	end,
}
