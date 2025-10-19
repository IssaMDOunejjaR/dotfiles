return {
  "williamboman/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup {
      ui = {
        border = "single",
      },
    }

    require("mason-lspconfig").setup {
      ensure_installed = {},
      automatic_enable = true,
    }

    vim.lsp.config("bashls", {
      filetypes = { "bash", "sh", "zsh" },
    })
  end,
}
