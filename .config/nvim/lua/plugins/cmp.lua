return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"onsails/lspkind.nvim", -- Adds VS Code-like pictograms/icons to the completion menu
		"saadparwaiz1/cmp_luasnip", -- Enables LuaSnip as a source for nvim-cmp autocompletion
		{
			"L3MON4D3/LuaSnip", -- Snippet engine for Neovim (write and expand code snippets)
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"rafamadriz/friendly-snippets", -- Large collection of pre-made snippets for various languages
		"hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for LSP-based autocompletion
		"hrsh7th/cmp-buffer", -- nvim-cmp source for words from the current buffer
		"hrsh7th/cmp-path", -- nvim-cmp source for filesystem paths
		"hrsh7th/cmp-nvim-lsp-signature-help", -- function signatures
		{
			"xzbdmw/colorful-menu.nvim",
			config = function()
				-- You don't need to set these options.
				require("colorful-menu").setup({})
			end,
		},
	},
	config = function()
		local lspkind = require("lspkind")
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			window = {
				completion = cmp.config.window.bordered({
					winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					winhighlight = "Normal:NormalFloat,FloatBorder:CmpDocBorder,Search:None",
				}),
			},

			formatting = {
				fields = { "icon", "abbr", "menu" },

				format = function(entry, vim_item)
					local kind = lspkind.cmp_format({
						mode = "symbol",
					})(entry, vim.deepcopy(vim_item))
					local highlights_info = require("colorful-menu").cmp_highlights(entry)

					-- highlight_info is nil means we are missing the ts parser, it's
					-- better to fallback to use default `vim_item.abbr`. What this plugin
					-- offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
					if highlights_info ~= nil then
						vim_item.abbr_hl_group = highlights_info.highlights
						vim_item.abbr = highlights_info.text
					end

					local strings = vim.split(kind.kind, "%s", { trimempty = true })
					vim_item.kind = " " .. (strings[1] or "") .. " "
					vim_item.menu = ""

					return vim_item
				end,
			},

			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),

			sources = {
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "nvim_lsp_signature_help" },
			},
		})

		vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#444444", bg = "NONE" })
		vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#444444", bg = "NONE" })
		vim.api.nvim_set_hl(0, "CmpSel", { bg = "#333333" })
		vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#444444" })
		vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
	end,
}
