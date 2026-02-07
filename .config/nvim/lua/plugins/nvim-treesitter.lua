return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	lazy = false,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"lua",
				"markdown",
				"markdown_inline",
			},
			auto_install = true, -- auto-install any other parsers on opening new language files
			sync_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					scope_incremental = "<TAB>",
					node_decremental = "<S-TAB>",
				},
			},
		})
	end,
}
