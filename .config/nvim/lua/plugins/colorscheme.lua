return {
  {
    "cpea2506/one_monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("one_monokai").setup {
        transparent = true,
      }

      vim.cmd.colorscheme "one_monokai"

      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#444444", bg = "#000000" })
    end,
  },
}
