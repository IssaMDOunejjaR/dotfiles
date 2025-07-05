vim.o.sessionoptions = "localoptions"

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.markdown_recommended_style = 0

local opt = vim.opt

opt.lazyredraw = true -- Redraw only when necessary

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"

-- [[ Setting options ]]
-- See `:help opt`
--  NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

opt.laststatus = 3
opt.fixeol = false
opt.number = true
opt.relativenumber = true
opt.numberwidth = 1
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2
opt.undofile = true
opt.undolevels = 10000
opt.smartindent = true
opt.completeopt = { "menuone", "noselect" }
opt.wrap = true
opt.linebreak = true
opt.scrolloff = 10
opt.sidescrolloff = 10
opt.termguicolors = true
opt.breakindent = true
opt.incsearch = true
opt.signcolumn = "yes"
opt.swapfile = false
opt.backup = false
opt.virtualedit = "block"
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.conceallevel = 3 -- so that `` is visible in markdown files
opt.fillchars:append({ eob = " " })
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.ruler = false
opt.shiftround = true -- Round indent
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Preview substitutions live, as you type!
opt.inccommand = "nosplit"

-- Show which line your cursor is on
opt.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
opt.confirm = true
