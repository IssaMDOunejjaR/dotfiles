return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
      },
      "neovim/nvim-lspconfig",
    },
    lazy = false,
    config = function()
      local servers = {
        html = {
          filetypes = {
            "html",
            "templ",
          },
        },
        gopls = {},
        rust_analyzer = {},
        htmx = {
          filetypes = {
            "html",
            "templ",
          },
        },
        tailwindcss = {
          filetypes = {
            "html",
            "templ",
          },
        },
        templ = {
          filetypes = {
            "templ",
          },
        },
        lua_ls = {},
        tsserver = {},
        clangd = {},
        jdtls = {},
        -- stylua = {},
        -- java_test = {},
        -- ["java-debug"] = {},
      }

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")

      require("mason").setup({})

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
      })

      for lsp, _ in pairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
