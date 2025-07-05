return {
	{
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"neovim/nvim-lspconfig",
			{
				"laytan/tailwind-sorter.nvim",
				build = "cd formatter && npm ci && npm run build",
				config = true,
			},
		},
		opts = {},
	},
}
