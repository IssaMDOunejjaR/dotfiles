local opts = {
  splitbelow = true,
  expandtab = true,
  relativenumber = true,
  number = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  undofile = true,
  smartindent = true,
  ignorecase = true,
  completeopt = { "menuone", "noselect" },
  clipboard = "unnamedplus",
  wrap = true,
  linebreak = true,
  scrolloff = 18,
  termguicolors = true,
  timeoutlen = 300,
  smartcase = true,
  breakindent = true,
  hlsearch = false,
  incsearch = true,
  signcolumn = 'yes',
  swapfile = false,
  backup = false,
  updatetime = 50,
  virtualedit = "block",
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end
