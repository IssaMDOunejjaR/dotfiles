return {
	{
		"cpea2506/one_monokai.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("one_monokai").setup({
				transparent = true,
			})

			vim.cmd.colorscheme("one_monokai")

			vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#444444", bg = "NONE" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#222222" })

			vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#444444", bg = "NONE" })
			vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#444444", bg = "NONE" })
			vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { bg = "#444444" })
			vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#333333" })

			vim.api.nvim_set_hl(0, "CustomSnacksIndent", { fg = "#222222" })
			vim.api.nvim_set_hl(0, "CustomSnacksIndentScope", { fg = "#ff4d4d" })
		end,
	},
}
