return {
  "mrcjkb/rustaceanvim",
  opts = function(_, opts)
    opts.tools = {
      hover_actions = {
        replace_builtin_hover = false,
      },
    }
  end,
}
