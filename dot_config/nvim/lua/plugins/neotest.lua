return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/neotest-go",
		"nvim-neotest/neotest-jest",
		"nvim-neotest/neotest-python",
	},
	event = "VeryLazy",
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-go"),
				require("neotest-jest"),
				require("neotest-python"),
			},
			icons = {
				expanded = "󰔍",
				collapsed = "󰔍",
				running = "󰐛",
				passed = "󰸁",
				failed = "󰅙",
			},
		})
	end,
}
