return {
	{ "echasnovski/mini.ai", version = "*", opts = {} },
	{ "echasnovski/mini.comment", version = "*", opts = {} },
	{ "echasnovski/mini.move", version = "*", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", opts = {} },
	{
		"echasnovski/mini.indentscope",
		version = "*",
		opts = {},
		config = function()
			local mini = require("mini.indentscope")

			mini.setup({
				draw = {
					animation = mini.gen_animation.none(),
				},
				symbol = "│",
			})
		end,
	},
	{ "echasnovski/mini.pairs", version = "*", opts = {} },
	-- { "echasnovski/mini.trailspace", version = "*", opts = {} },
	{ "echasnovski/mini.bufremove", version = "*", opts = {} },
}
