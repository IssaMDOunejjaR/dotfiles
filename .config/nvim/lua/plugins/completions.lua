return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      require("lsp-zero").extend_cmp()
      require("luasnip.loaders.from_vscode").lazy_load()

      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      local cmp_action = require("lsp-zero").cmp_action()

      cmp.setup({
        preselect = "item",
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-f>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),
          ["<CR>"] = cmp.mapping.confirm({
            select = true,
          }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = cmp_action.luasnip_supertab(),
          ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
}
