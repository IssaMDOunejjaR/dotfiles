local ui = require("harpoon.ui")
local mark = require("harpoon.mark")

vim.keymap.set("n", "<C-q>", ui.toggle_quick_menu, {})
vim.keymap.set("n", "<C-a>", mark.add_file, {})
vim.keymap.set("n", "<C-j>", ui.nav_next, {})
vim.keymap.set("n", "<C-k>", ui.nav_prev, {})
