return {
	"sainnhe/edge",
	priority = 1000, -- Ensure it loads first
	config = function()
		vim.g.edge_style = "neon"
		vim.g.edge_better_performance = 1
		vim.g.edge_float_style = "bright"
		vim.g.edge_diagnostic_text_highlight = 1
		vim.g.edge_diagnostic_line_highlightd = 1
		vim.g.edge_diagnostic_virtual_text = "colored"
		vim.g.edge_inlay_hints_background = "dimmed"

		vim.cmd.colorscheme("edge")
	end,
}
