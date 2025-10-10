return {
  "ibhagwan/fzf-lua",
  opts = {
    winopts = {
      border = "single",
      preview = {
        border = "single",
        hidden = true,
      },
    },
    keymap = {
      builtin = {
        ["<C-]>"] = "toggle-preview",
      },
    },
  },
}
