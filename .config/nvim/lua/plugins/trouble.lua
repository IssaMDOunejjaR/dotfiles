return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics: All (Trouble)" },
		{ "<leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics: Buffer (Trouble)" },
		{ "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix: List (Trouble)" },
		{ "<leader>xl", "<Cmd>Trouble loclist toggle<CR>", desc = "Location: List (Trouble)" },
		{ "<leader>xL", "<Cmd>Trouble lsp toggle<CR>", desc = "LSP: Definitions/References (Trouble)" },
	},
	opts = {},
}
