local function max_height()
	local height = vim.fn.winheight(0)

	if height >= 40 then
		return 30
	elseif height >= 30 then
		return 20
	else
		return 10
	end
end

return {
	"stevearc/oil.nvim",
	lazy = false,
	opts = {
		default_file_explorer = true,
		skip_confirm_for_simple_edits = true,
		view_options = {
			show_hidden = true,
		},
		-- Configuration for the floating window in oil.open_float
		float = {
			padding = 2,
			max_width = 120,
			max_height = max_height, -- function ref: evaluated each time the float opens
			border = "single",
			win_options = {
				winblend = 0,
			},
		},
		-- Preview window config (oil 2.x+)
		preview_split = {
			border = "single",
		},
		-- Custom Keymap
		keymaps = {
			["<C-s>"] = {
				desc = "Save all changes",
				callback = function()
					require("oil").save({ confirm = false })
				end,
			},
			["q"] = "actions.close",
			["<C-y>"] = "actions.copy_entry_path",
			["<C-p>"] = "actions.preview",
			["<C-r>"] = "actions.refresh",
		},
	},
	-- Use g? to see default key mappings
	keys = {
		{
			"<leader>e",
			function()
				require("oil").toggle_float()
			end,
			desc = "Open explorer",
		},
		{
			"<leader>E",
			function()
				require("oil").toggle_float(vim.fn.getcwd())
			end,
			desc = "Open explorer root directory",
		},
	},
}
