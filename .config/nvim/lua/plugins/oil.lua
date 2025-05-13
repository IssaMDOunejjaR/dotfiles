return {
	"stevearc/oil.nvim",

	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		default_file_explorer = false,
		lsp_file_methods = {
			autosave_changes = true,
		},
		constrain_cursor = "name",
		watch_for_changes = true,
		view_options = {
			show_hidden = true,
		},
		float = {
			max_width = 150,
			max_height = 150,
			padding = 3,
			border = "single",
		},
	},

	dependencies = { "nvim-tree/nvim-web-devicons" },

	keys = {
		{
			"<leader>e",
			function()
				require("oil").toggle_float(vim.fn.getcwd())
			end,
			desc = "Toggle Oil [E]xplorer root directory",
		},
		{
			"<leader>c",
			function()
				require("oil").toggle_float()
			end,
			desc = "Toggle Oil [C]urrent directory",
		},
	},

	lazy = false,
}
