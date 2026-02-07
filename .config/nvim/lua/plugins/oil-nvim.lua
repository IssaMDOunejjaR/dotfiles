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
	opts = {
		default_file_explorer = true,
		skip_confirm_for_simple_edits = true,
		use_default_keymaps = true,
		view_options = {
			show_hidden = true,
			-- is_hidden_file = function(name, _)
			-- 	-- dotfiles are always considered hidden
			-- 	if vim.startswith(name, ".") then
			-- 		return true
			-- 	end
			--
			-- 	local dir = require("oil").get_current_dir()
			--
			-- 	-- if no local directory (e.g. for ssh connections), always show
			-- 	if not dir then
			-- 		return false
			-- 	end
			--
			-- 	-- Check if file is gitignored
			-- 	return vim.list_contains(git_ignored[dir], name)
			-- end,
			-- is_hidden_file = function(name)
			--   local ignore_folders = { "node_modules", "dist", "build", "coverage", "__pycache__" }
			--   return vim.startswith(name, ".") or vim.tbl_contains(ignore_folders, name)
			-- end,
		},
		-- Configuration for the floating window in oil.open_float
		float = {
			padding = 2,
			max_width = 120,
			max_height = max_height(),
			border = "single",
			win_options = {
				winblend = 0,
			},
		},
		-- Custom Keymap
		keymaps = {
			["<C-c>"] = false,
			["<C-s>"] = {
				desc = "Save all changes",
				callback = function()
					require("oil").save({ confirm = false })
				end,
			},
			["q"] = "actions.close",
			["<C-y>"] = "actions.copy_entry_path",
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
