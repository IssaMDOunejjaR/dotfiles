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

    local mason = require "mason-lspconfig"
    local servers = mason.get_installed_servers()
    local Lsp = require "utils.lsp"

    require("mason-lspconfig").setup {
      ensure_installed = {},
      automatic_enable = true,
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        on_attach = Lsp.on_attach,
      })
    end

    vim.lsp.config("bashls", {
      filetypes = { "bash", "sh", "zsh" },
    })
  end,
}
