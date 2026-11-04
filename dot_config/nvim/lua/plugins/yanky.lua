return {
	"gbprod/yanky.nvim",
	event = "VeryLazy",
	opts = {
		system_clipboard = {
			sync_with_ring = true,
		},
		highlight = {
			on_put = true,
		},
	},
	config = function(_, opts)
		require("yanky").setup(opts)

		vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
		vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
		vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
		vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")
	end,
}
