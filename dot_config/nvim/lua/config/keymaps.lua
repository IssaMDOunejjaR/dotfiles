-- ============================================================
-- SEARCH / NAVIGATION (centered)
-- ============================================================
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

vim.keymap.set("v", "*", [[y/\V<C-R>=escape(@", '/\')<CR><CR>N]], { desc = "Search selected text forward" })
vim.keymap.set("v", "#", [[y?\V<C-R>=escape(@", '?\')<CR><CR>N]], { desc = "Search selected text backward" })

-- ============================================================
-- BUFFER NAVIGATION
-- ============================================================
vim.keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Buffer: Next" })
vim.keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Buffer: Previous" })
vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Buffer: Close" })
vim.keymap.set("n", "<leader>bD", [[<Cmd>%bd|e#|bd#<CR>]], { desc = "Buffer: Close all others" })
vim.keymap.set("n", "<leader>bN", "<Cmd>enew<CR>", { desc = "Buffer: New empty" })

-- ============================================================
-- WINDOW NAVIGATION
-- ============================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window: Move left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window: Move down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window: Move up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window: Move right" })

-- ============================================================
-- SPLITS & RESIZING
-- ============================================================
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split: Vertical" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split: Horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Split: Equalize sizes" })
vim.keymap.set("n", "<leader>sx", "<Cmd>close<CR>", { desc = "Split: Close current" })

vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Resize: Increase height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Resize: Decrease height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Resize: Decrease width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Resize: Increase width" })

-- ============================================================
-- INDENTING
-- ============================================================
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", ">>", ">>", { desc = "Indent line right" })
vim.keymap.set("n", "<<", "<<", { desc = "Indent line left" })

-- ============================================================
-- LINE OPERATIONS
-- ============================================================
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor position)" })

vim.keymap.set("n", "<A-j>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("i", "<A-j>", "<Cmd>m .+1<CR>==gi", { desc = "Move line down (insert)" })
vim.keymap.set("i", "<A-k>", "<Cmd>m .-2<CR>==gi", { desc = "Move line up (insert)" })

-- ============================================================
-- PASTE
-- ============================================================
-- Paste over selection without losing yanked content
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

-- ============================================================
-- UNDO BREAKPOINTS (insert mode)
-- Pressing these creates an undo checkpoint so you can undo word by word
-- ============================================================
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", "!", "!<C-g>u")
vim.keymap.set("i", "?", "?<C-g>u")

vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo in insert mode" })

-- ============================================================
-- QUICKFIX & LOCATION LIST
-- ============================================================
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", { desc = "Quickfix: Next item" })
vim.keymap.set("n", "[q", "<Cmd>cprev<CR>", { desc = "Quickfix: Previous item" })
vim.keymap.set("n", "]l", "<Cmd>lnext<CR>", { desc = "Location: Next item" })
vim.keymap.set("n", "[l", "<Cmd>lprev<CR>", { desc = "Location: Previous item" })
vim.keymap.set("n", "<leader>co", "<Cmd>copen<CR>", { desc = "Quickfix: Open list" })
vim.keymap.set("n", "<leader>cc", "<Cmd>cclose<CR>", { desc = "Quickfix: Close list" })
vim.keymap.set("n", "<leader>lo", "<Cmd>lopen<CR>", { desc = "Location: Open list" })
vim.keymap.set("n", "<leader>lc", "<Cmd>lclose<CR>", { desc = "Location: Close list" })

-- ============================================================
-- MISC
-- ============================================================
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Config: Edit init.lua" })

-- ============================================================
-- TERMINAL
-- ============================================================
vim.keymap.set("n", "<leader>tv", "<Cmd>vsplit | terminal<CR>", { desc = "Terminal: Vertical split" })
vim.keymap.set("n", "<leader>ts", "<Cmd>split | terminal<CR>", { desc = "Terminal: Horizontal split" })
-- Double-Escape to exit terminal insert mode (single Esc is sent to the running program)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit to normal mode" })

-- ============================================================
-- SESSION  (<leader>q group)
-- ============================================================
vim.keymap.set("n", "<leader>qs", "<Cmd>SessionSave<CR>", { desc = "Session: Save" })
vim.keymap.set("n", "<leader>qr", "<Cmd>SessionRestore<CR>", { desc = "Session: Restore" })
vim.keymap.set("n", "<leader>qd", "<Cmd>SessionDelete<CR>", { desc = "Session: Delete" })
vim.keymap.set("n", "<leader>qq", "<Cmd>qa<CR>", { desc = "Quit: All" })
vim.keymap.set("n", "<leader>qQ", "<Cmd>qa!<CR>", { desc = "Quit: All (force)" })

-- ============================================================
-- UI TOGGLES  (<leader>u group)
-- ============================================================
vim.keymap.set("n", "<leader>uw", "<Cmd>set wrap!<CR>", { desc = "UI: Toggle wrap" })
vim.keymap.set("n", "<leader>un", "<Cmd>set relativenumber!<CR>", { desc = "UI: Toggle relative numbers" })
vim.keymap.set("n", "<leader>us", "<Cmd>set spell!<CR>", { desc = "UI: Toggle spell" })
vim.keymap.set("n", "<leader>ud", function()
	require("tiny-inline-diagnostic").toggle()
end, { desc = "UI: Toggle inline diagnostics" })
