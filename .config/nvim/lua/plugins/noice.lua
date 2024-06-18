return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.views = {
        hover = {
          border = {
            style = "single",
            padding = { 0, 1 },
          },
        },
      }
    end,
  },
}
