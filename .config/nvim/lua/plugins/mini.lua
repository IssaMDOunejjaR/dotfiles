return { -- Collection of various small independent plugins/modules
	{
		"echasnovski/mini.move",
		event = "BufReadPost",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		"echasnovski/mini.indentscope",
		event = "BufReadPost",
		config = function()
			local indentscope = require("mini.indentscope")

			indentscope.setup({
				draw = {
					animation = indentscope.gen_animation.none(),
				},
				symbol = "│",
			})

			-- Disable indent scope in specific file types
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "help", "markdown", "text", "terminal", "dashboard" },
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
}
