return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    popupmenu = {
      enabled = true,
    },
    lsp = {
      hover = {
        enabled = true,
      },
      signature = {
        enabled = true,
      },
      message = {
        enabled = true,
      },
      documentation = {
        view = "hover",
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
}
