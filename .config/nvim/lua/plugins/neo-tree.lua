return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		{
			"adelarsq/image_preview.nvim",
			-- event = "VeryLazy",
			config = function()
				require("image_preview").setup()
			end,
		},
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			default_component_configs = {
				indent = {
					padding = 0,
				},
			},
			window = {
				width = 30,
			},
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
				},
				follow_current_file = {
					enabled = true,
				},
				window = {
					mappings = {
						["<leader>p"] = "image_kitty", -- " or another map
					},
				},
				commands = {
					image_kitty = function(state)
						local node = state.tree:get_node()

						if node.type == "file" then
							require("image_preview").PreviewImage(node.path)
						end
					end,
				},
				use_libuv_file_watcher = true,
			},
		})

		vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Open Neotree" })
	end,
}
