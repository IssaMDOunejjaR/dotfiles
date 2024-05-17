return {
	"echasnovski/mini.indentscope",
	version = false,
	config = function()
		require("mini.indentscope").setup({
			draw = {
				delay = 10,
			},

			symbol = "│",
		})
	end,
}
