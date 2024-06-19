return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
      }
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
