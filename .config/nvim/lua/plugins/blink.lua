return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
	},
	event = { "InsertEnter", "CmdlineEnter" },
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()

		require("blink.cmp").setup({
			keymap = {
				preset = "default",

				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },

				["<CR>"] = {
					function(cmp)
						if cmp.is_visible() and cmp.get_selected_item() then
							return cmp.accept()
						end
						return false -- fall through to newline
					end,
					"fallback",
				},

				["<Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_next()
						elseif require("luasnip").expand_or_jumpable() then
							return cmp.snippet_forward()
						end
						return false
					end,
					"snippet_forward",
					"fallback",
				},

				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_prev()
						elseif require("luasnip").jumpable(-1) then
							return cmp.snippet_backward()
						end
						return false
					end,
					"snippet_backward",
					"fallback",
				},
			},

			snippets = {
				preset = "luasnip",
			},

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
				kind_icons = {
					Text = "󰉿",
					Method = "󰊕",
					Function = "󰊕",
					Constructor = "󰏗",
					Field = "󰜢",
					Variable = "󰀫",
					Class = "󰠨",
					Interface = "󰕱",
					Module = "󰏗",
					Property = "󰜢",
					Unit = "󰎠",
					Value = "󰎠",
					Enum = "󰕱",
					Keyword = "󰌋",
					Snippet = "󰅱",
					Color = "󰏘",
					File = "󰈔",
					Reference = "󰈇",
					Folder = "󰉋",
					EnumMember = "󰕱",
					Constant = "󰏗",
					Struct = "󰙅",
					Event = "󰆅",
					Operator = "󰆕",
					TypeParameter = "󰊄",
				},
			},

			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},

				ghost_text = {
					enabled = false,
				},

				menu = {
					border = "single",
					draw = {
						columns = {
							{ "kind_icon", gap = 1 },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
						treesitter = { "lsp" },
					},
				},

				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					lua = { inherit_defaults = true },
				},
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						score_offset = 0,
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = -1,
					},
					snippets = {
						name = "Snippets",
						module = "blink.cmp.sources.snippets",
						opts = {
							show_autosnippets = true,
						},
						score_offset = 2,
					},
					buffer = {
						name = "Buffer",
						module = "blink.cmp.sources.buffer",
						opts = {
							-- min_keyword_length = 3,
							get_bufnrs = function()
								return { vim.api.nvim_get_current_buf() }
							end,
						},
						score_offset = -2,
						max_items = 5,
					},
				},
			},

			fuzzy = {
				prebuilt_binaries = {
					download = true,
				},
				implementation = "prefer_rust_with_warning",
			},

			signature = {
				enabled = true,
				window = {
					border = "single",
				},
			},

			cmdline = {
				enabled = true,
				keymap = {
					preset = "cmdline",
				},
				completion = {
					ghost_text = { enabled = true },
				},
			},
		})

		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#444444", bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#444444", bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#333333" })
		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { bg = "#444444" })
		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarGutter", { bg = "NONE" })
	end,
}
