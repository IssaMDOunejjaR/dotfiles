return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		defaults = {},
		---@type false | "classic" | "modern" | "helix"
		preset = "helix", -- default is "classic"
		-- Custom helix layout
		win = vim.g.which_key_window or {
			width = { min = 30, max = 60 },
			height = { min = 4, max = 0.85 },
			border = "single",
		},
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader><tab>", group = "Tabs" },
				{ "<leader>a", group = "AI/Angular" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>dg", group = "Go" },
				{ "<leader>f", group = "File/Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>gh", group = "Hunks" },
				{ "<leader>q", group = "Session/Quit" },
				{ "<leader>s", group = "Search/Split" },
				{ "<leader>t", group = "Toggle" },
				{ "<leader>u", group = "UI" },
				{ "<leader>x", group = "Diagnostics/Quickfix", icon = { icon = "󱖫 ", color = "green" } },
				{ "[", group = "Prev" },
				{ "]", group = "Next" },
				{ "g", group = "Goto" },
				{ "gs", group = "Surround" },
				{ "z", group = "Fold" },
			},
		},
		icons = {
			mappings = false,
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
