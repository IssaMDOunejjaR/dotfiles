return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Git: Diffview open" },
		{ "<leader>gD", "<Cmd>DiffviewClose<CR>", desc = "Git: Diffview close" },
		{ "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Git: File history" },
		{ "<leader>gH", "<Cmd>DiffviewFileHistory<CR>", desc = "Git: Repo history" },
	},
	opts = {},
}
