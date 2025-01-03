return { -- Collection of various small independent plugins/modules
	{
		"echasnovski/mini.move",
		config = function()
			require("mini.move").setup()
		end,
	},
	{
		"echasnovski/mini.indentscope",
		config = function()
			local indentscope = require("mini.indentscope")

			indentscope.setup({
				draw = {
					animation = indentscope.gen_animation.none(),
				},
				symbol = "│",
			})
		end,
	},
}
