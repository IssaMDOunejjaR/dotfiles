return {
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		-- Snippet Engine
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			build = (function()
				-- Build Step is needed for regex support in snippets.
				-- This step is not supported in many windows environments.
				-- Remove the below condition to re-enable on windows.
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {
				-- `friendly-snippets` contains a variety of premade snippets.
				--    See the README about individual language/framework/plugin snippets:
				--    https://github.com/rafamadriz/friendly-snippets
				{
					"rafamadriz/friendly-snippets",
					config = function()
						require("luasnip.loaders.from_vscode").lazy_load()
					end,
				},
			},
			opts = {},
		},

		"folke/lazydev.nvim",
		"mikavilpas/blink-ripgrep.nvim",
		"bydlw98/blink-cmp-env",
	},
	--- @module 'blink.cmp'
	--- @type blink.cmp.Config
	opts = {
		keymap = {
			preset = "enter",

			["<C-space>"] = {
				"show",
			},

			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },

			["<C-h>"] = { "snippet_backward", "fallback" },
			["<C-l>"] = { "snippet_forward", "fallback" },
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "normal",
		},

		completion = {
			list = {
				selection = {
					preselect = false,
				},
			},

			-- By default, you may press `<c-space>` to show the documentation.
			-- Optionally, set `auto_show = true` to show the documentation after a delay.
			documentation = { auto_show = true, auto_show_delay_ms = 0 },

			ghost_text = { enabled = true },
		},

		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
				"dadbod",
				"lazydev",
				-- "env",
			},

			providers = {
				-- env = {
				-- 	module = "blink-cmp-env",
				-- },
				lazydev = {
					module = "lazydev.integrations.blink",
					min_keyword_length = 0,
					score_offset = 100,
				},
				lsp = {
					name = "lsp",
					enabled = true,
					module = "blink.cmp.sources.lsp",
					min_keyword_length = 0,
					score_offset = 90,
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					score_offset = 25,
					fallbacks = { "snippets", "buffer" },
					opts = {
						trailing_slash = false,
						label_trailing_slash = true,
						get_cwd = function(context)
							return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
						end,
						show_hidden_files_by_default = true,
					},
				},
				snippets = {
					name = "snippets",
					enabled = true,
					max_items = 15,
					min_keyword_length = 2,
					module = "blink.cmp.sources.snippets",
					score_offset = 85,
				},
				buffer = {
					name = "Buffer",
					enabled = true,
					max_items = 5,
					module = "blink.cmp.sources.buffer",
					min_keyword_length = 1,
					score_offset = 15,
					opts = {
						get_bufnrs = function()
							return vim.iter(vim.api.nvim_list_bufs())
								:filter(function(buf)
									return vim.bo[buf].buftype ~= "nofile"
								end)
								:totable()
						end,
					},
				},
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
					min_keyword_length = 0,
					score_offset = 85,
				},
			},
		},

		snippets = { preset = "luasnip" },

		fuzzy = {
			implementation = "prefer_rust",
			sorts = {
				"exact",
				"score",
				"sort_text",
			},
		},

		signature = { enabled = true },
	},
}
