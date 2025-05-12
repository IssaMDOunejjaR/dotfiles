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
		-- keymaps = {
		-- 	["<leader>e"] = { "actions.open_cwd", mode = "n" },
		-- },
		view_options = {
			show_hidden = true,
		},
		float = {
			max_width = 150,
			max_height = 150,
			padding = 5,
			border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
		},
	},

	dependencies = { "nvim-tree/nvim-web-devicons" },

	keys = {
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
