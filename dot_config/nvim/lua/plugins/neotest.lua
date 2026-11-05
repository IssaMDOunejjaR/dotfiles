-- Neotest: test runner. Fully lazy — the plugin loads only when one of the
-- keys below is pressed (the mappings used to live in config/keymaps.lua).
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-neotest/neotest-go",
		"nvim-neotest/neotest-jest",
		"nvim-neotest/neotest-python",
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Test: Run nearest",
		},
		{
			"<leader>tT",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Test: Run file",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Test: Summary",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open()
			end,
			desc = "Test: Output",
		},
	},
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
