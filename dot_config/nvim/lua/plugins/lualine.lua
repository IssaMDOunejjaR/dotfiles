return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		-- breadcrumb source for the 'navic' component in the winbar
		"SmiteshP/nvim-navic",
	},
	config = function()
		-- always reserve the winbar line so the editor doesn't shift up/down
		-- when navic breadcrumbs appear/disappear; lualine overlays this spacer
		vim.opt.winbar = " "
		require("lualine").setup({
			options = {
				icons_enabled = true,
				component_separators = "|",
				-- don't paint the winbar on scratch/utility buffers
				disabled_filetypes = {
					winbar = { "help", "man", "qf", "checkhealth", "oil", "git", "gitcommit", "terminal", "lazy", "mason" },
				},
			},
			winbar = {
				-- nvim-navic breadcrumb (attached in lua/utils/lsp.lua on LspAttach)
				lualine_c = { "navic" },
			},
		})
	end,
}
