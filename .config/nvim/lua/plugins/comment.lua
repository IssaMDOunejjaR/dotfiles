return {
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"numToStr/Comment.nvim",
		event = "BufReadPost",
		dependencies = {
			-- plugin to allow us to automatically comment tsx elements with the comment plugin
			{ "JoosepAlviste/nvim-ts-context-commentstring", event = "BufReadPost" },
		},
		config = function()
			-- gain access to the comment plugins functions
			local comment = require("Comment")
			-- gain access to tsx commenting plugins functions
			local ts_context_comment_string = require("ts_context_commentstring.integrations.comment_nvim")

			-- setup the comment plugin to use ts_context_comment_string to check if we are attempting to comment out a tsx element
			-- if we are use ts_context_comment_string to comment it out
			comment.setup({
				pre_hook = ts_context_comment_string.create_pre_hook(),
				mapping = {
					basic = false,
					extra = false,
				},
				toggler = {
					line = "<leader>/",
				},
				opleader = {
					line = "<leader>/",
				},
			})
		end,
	},
}
