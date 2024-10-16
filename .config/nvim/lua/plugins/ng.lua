return {
	"joeveiga/ng.nvim",
	config = function()
		local ng = require("ng")

		vim.keymap.set("n", "<leader>at", function()
			ng.goto_template_for_component({ reuse_window = true })
		end, {})

		vim.keymap.set("n", "<leader>ac", function()
			ng.goto_component_with_template_file({ reuse_window = true })
		end, {})
	end,
}
