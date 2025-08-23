return {
	-- "navarasu/onedark.nvim",
	-- "EdenEast/nightfox.nvim",
	"bluz71/vim-moonfly-colors",
	-- "scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000, -- Ensure it loads first
	config = function()
		-- require("onedark").setup({
		-- 	style = "darker",
		-- })

		-- vim.cmd.colorscheme("onedark")
		-- vim.cmd.colorscheme("carbonfox")
		vim.cmd.colorscheme("moonfly")
		-- vim.cmd.colorscheme("cyberdream")
	end,
}
