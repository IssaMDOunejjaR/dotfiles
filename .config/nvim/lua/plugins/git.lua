return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gdiffsplit", "Gread" },
		keys = {
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = "[G]it [B]lame" },
			{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "[G]it [D]iff" },
			{ "<leader>gl", "<cmd>Git log<cr>", desc = "[G]it [L]og" },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
		},
		keys = {
			{ "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "[G]it Hunk [P]review" },
		},
		config = function()
			require("gitsigns").setup({
				preview_config = {
					border = nil,
				},
			})

			-- vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk_inline<CR>", { desc = "[G]it Hunk [P]review" })
			vim.keymap.set(
				"n",
				"<leader>gt",
				":Gitsigns toggle_current_line_blame<CR>",
				{ desc = "[G]it [T]oggle Blame" }
			)
		end,
	},
}
