return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = {
      timeout_ms = 3000,
      lsp_fallback = true,
    },
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
  },
}
