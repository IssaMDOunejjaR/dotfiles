return {
	"ThePrimeagen/harpoon",
	config = function()
		local ui = require("harpoon.ui")
		local mark = require("harpoon.mark")

		vim.keymap.set("n", "<C-q>", ui.toggle_quick_menu, {})
		vim.keymap.set("n", "<C-a>", mark.add_file, {})
		vim.keymap.set("n", "<C-n>", ui.nav_next, {})
		vim.keymap.set("n", "<C-p>", ui.nav_prev, {})
	end,
}
