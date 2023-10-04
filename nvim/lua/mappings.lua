vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Tmux
vim.keymap.set("n", "<C-j>", ":TmuxNavigatorDown<CR>")
vim.keymap.set("n", "<C-k>", ":TmuxNavigatorUp<CR>")
vim.keymap.set("n", "<C-h>", ":TmuxNavigatorLeft<CR>")
vim.keymap.set("n", "<C-l>", ":TmuxNavigatorRight<CR>")
