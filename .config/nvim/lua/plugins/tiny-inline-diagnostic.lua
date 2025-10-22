return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup {
      preset = "nonerdfont",
      multilines = {
        enabled = true,
        always_show = true,
        trim_whitespaces = true,
        tabstop = 2,
      },
    }

    vim.diagnostic.config { virtual_text = false }
  end,
}
