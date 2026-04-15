return {
	{ "echasnovski/mini.ai", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.move", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", event = "BufReadPost", opts = {} },
	{
		"echasnovski/mini.indentscope",
		version = "*",
		event = "BufReadPost",
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
	{ "echasnovski/mini.pairs", version = "*", event = "InsertEnter", opts = {} },
	{ "echasnovski/mini.bufremove", version = "*", event = "VeryLazy", opts = {} },
}
