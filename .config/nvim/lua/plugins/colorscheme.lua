return {
  -- {
  --   "AstroNvim/astrotheme",
  --   lazy = false,    -- load immediately
  --   priority = 1000, -- make sure it loads before other plugins
  --   config = function()
  --     require("astrotheme").setup({
  --       palette = "astrodark",
  --       style = {
  --         transparent = false, -- set true if you want transparent background
  --       },
  --     })
  --
  --     vim.cmd.colorscheme("astrodark")
  --   end,
  -- },

  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,    -- load immediately
    priority = 1000, -- make sure it loads before other plugins
    config = function()
      vim.opt.background = "dark"

      vim.cmd.colorscheme("oxocarbon")
    end
  }
}
