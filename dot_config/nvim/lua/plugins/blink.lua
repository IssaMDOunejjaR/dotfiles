return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		-- Loaded automatically by blink's native vim.snippet snippet engine
		{ "rafamadriz/friendly-snippets" },
		-- Copilot blink source — shows AI suggestions inside the completion menu
		-- (needs zbirenbaum/copilot.lua, defined in plugins/copilot.lua)
		{ "fang2hou/blink-copilot" },
	},
	event = { "InsertEnter", "CmdlineEnter" },
	config = function()
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
						end
						return false
					end,
					"snippet_backward",
					"fallback",
				},
			},

			snippets = {
				preset = "default", -- native vim.snippet engine
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
			default = { "lsp", "path", "snippets", "buffer", "copilot" },
			per_filetype = {
				-- lazydev provides accurate vim.* API completions for Neovim config files
				lua = { "lazydev", "lsp", "path", "snippets", "buffer", "copilot" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 10, -- show above LSP suggestions
				},
				copilot = {
					name = "Copilot",
					module = "blink-copilot",
					score_offset = 100, -- Copilot suggestions first (per blink-copilot recipe)
					async = true,
					opts = {
						kind_name = "Copilot",
						kind_icon = "󰚩",
					},
				},
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
			implementation = "prefer_rust",
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

	end,
}
