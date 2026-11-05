-- nvim-navic: LSP breadcrumbs (symbol path under the cursor).
-- Attached in lua/utils/lsp.lua on LspAttach; rendered by lualine's 'navic'
-- component in the winbar. Picked over drop-bar.nvim as the lighter option.
return {
	"SmiteshP/nvim-navic",
	lazy = true,
	opts = {
		-- navic's internal lazy mode: only parse on demand, never on attach
		lazy = true,
		highlight = true,
		separator = " > ",
		depth_limit = 0,
	},
}
