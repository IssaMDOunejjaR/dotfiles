local opts = {
  expandtab = true,
  relativenumber = true,
  number = true,
  tabstop = 2,
  undofile = true,
  smartindent = true,
  ignorecase = true,
  completeopt = { "menuone", "noselect" },
  clipboard = "unnamedplus",
  wrap = true,
  linebreak = true,
  scrolloff = 8,
  termguicolors = true,
  shiftwidth = 2,
  updatetime = 250,
  timeoutlen = 300,
  smartcase = true,
  breakindent = true,
  hlsearch = false,
  signcolumn = 'yes',
}

for k, v in pairs(opts) do
  vim.opt[k] = v
end
