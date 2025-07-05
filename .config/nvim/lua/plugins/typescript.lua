return {
	{
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {},
	},

	{ "dmmulroy/ts-error-translator.nvim", opts = {} },

	{
		"jellydn/typecheck.nvim",
		dependencies = { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
		ft = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
		opts = {
			debug = true,
			mode = "trouble",
		},
	},
}
