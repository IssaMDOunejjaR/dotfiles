return {
	{ "echasnovski/mini.ai", version = "*", event = "VeryLazy", opts = {} },
	{
		"echasnovski/mini.move",
		version = "*",
		event = "VeryLazy",
		opts = {
			-- Explicit mappings so only normal/visual modes get <A-hjkl>.
			-- Insert-mode <A-j>/<A-k> line moves stay in config/keymaps.lua
			-- (mini.move does not map insert mode) — this also removes the old
			-- overlap with hand-written <A-j>/<A-k> line movers.
			mappings = {
				left = "<A-h>",
				right = "<A-l>",
				down = "<A-j>",
				up = "<A-k>",
				line_left = "<A-h>",
				line_right = "<A-l>",
				line_down = "<A-j>",
				line_up = "<A-k>",
			},
		},
	},
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
	-- mini.cursorword removed: redundant with the higher-quality
	-- LSP document_highlight (see utils/lsp.lua)
}
