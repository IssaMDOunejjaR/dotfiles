return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  lazy = false,
  config = function()
    vim.g.rustaceanvim = {
      tools = {
        float_win_config = {
          open_split = "horizontal",
        },
        hover_actions = {
          replace_builtin_hover = false,
        },
      },
    }
  end,
}
