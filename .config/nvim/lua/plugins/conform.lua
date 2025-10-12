return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      html = { "prettier" },
      htmlangular = { "prettier" },
      scss = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      lua = { "stylua" },
    },
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
}
