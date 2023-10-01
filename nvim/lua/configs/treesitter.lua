require("nvim-treesitter.configs").setup({
  ensure_installed = { 'c', 'cpp', 'lua', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'css',
    'dockerfile', 'html', 'json', 'make', 'scss', 'sql', 'yaml', 'markdown' },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    lookahead = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
    },
  },
  autotag = {
    enable = true,
  },
})
