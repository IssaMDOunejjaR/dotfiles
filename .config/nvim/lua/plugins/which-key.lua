return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		wk.setup({
			icons = {
				mappings = false,
				rules = false,
			},
		})

		wk.add({
			{ "<leader>b", group = "[B]uffer" },
			{ "<leader>f", group = "[F]uzzy Find" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>l", group = "[L]sp" },
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>w", group = "[W]indow" },
		})
	end,
}
