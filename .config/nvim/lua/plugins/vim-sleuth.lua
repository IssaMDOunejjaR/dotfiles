return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	event = "BufReadPost",
	config = function()
		-- Disable sleuth for specific filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "help" },
			callback = function()
				vim.b.sleuth_disabled = true
			end,
		})
	end,
}
