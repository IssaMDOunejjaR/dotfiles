return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		require("mini.move").setup()

		local indentscope = require("mini.indentscope")

		indentscope.setup({
			draw = {
				animation = indentscope.gen_animation.none(),
			},
			symbol = "│",
		})
	end,
}
