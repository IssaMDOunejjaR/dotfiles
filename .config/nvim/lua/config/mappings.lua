local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Escape and Clear hlsearch" })

map("n", "j", "gj", { desc = "Up", noremap = true })
map("n", "k", "gk", { desc = "Down", noremap = true })

-- Diagnostic keymaps
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

map("n", "<leader>ba", ":bufdo bwipeout<CR>", { desc = "[B]uffer Close [A]ll" })
map("n", "<leader>bc", ":bd<CR>", { desc = "[B]uffer Close [C]urrent" })
map("n", "<leader>be", ":%bd|e#<CR>", { desc = "[B]uffer Close All [E]xcept Current" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Split windows
map("n", "<leader>wv", ":vsplit<CR>", { desc = "[W]indow [V]ertical Split" })
map("n", "<leader>wh", ":split<CR>", { desc = "[W]indow [H]orizontal Split" })

map("n", "<leader>ke", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("vsplit | terminal kubectl explain " .. word)
end, { desc = "Explain Kubernetes field" })
