return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"nvim-treesitter/nvim-treesitter-context",
	},
	config = function()
		-- Ensure dependencies are loaded safely
		local has_autotag, autotag = pcall(require, "nvim-ts-autotag")

		if has_autotag then
			autotag.setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = true,
				},
			})
		else
			vim.notify("nvim-ts-autotag not found, skipping autotag setup.", vim.log.levels.WARN)
		end

		-- Load Treesitter configuration
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true, -- Automatically install missing parsers
			highlight = {
				enable = true, -- Enable syntax highlighting
				additional_vim_regex_highlighting = { "ruby" }, -- Use Vim regex for Ruby
			},
			indent = {
				enable = true,
				disable = { "ruby" }, -- Disable indenting for Ruby
			},
		})
	end,
}
