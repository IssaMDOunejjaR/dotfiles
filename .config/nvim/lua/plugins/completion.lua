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

		-- {
		-- 	"Kaiser-Yang/blink-cmp-git",
		-- },

		"jdrupal-dev/css-vars.nvim",
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
			documentation = { auto_show = true, auto_show_delay_ms = 500 },

			ghost_text = { enabled = true },
		},

		sources = {
			default = {
				-- "git",
				"lsp",
				"path",
				"snippets",
				"lazydev",
				"css_vars",
				"ripgrep",
				"buffer",
				"env",
			},

			providers = {
				-- git = {
				-- 	module = "blink-cmp-git",
				-- },
				ripgrep = {
					module = "blink-ripgrep",
					opts = {
						max_filesize = "1M",
					},
				},
				css_vars = {
					module = "css-vars.blink",
				},
				env = {
					module = "blink-cmp-env",
				},
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				lsp = {
					min_keyword_length = 0,
					score_offset = 50,
				},
				path = {
					min_keyword_length = 0,
					score_offset = 2,
				},
				snippets = {
					min_keyword_length = 2,
					score_offset = -1,
				},
				buffer = {
					min_keyword_length = 2,
					opts = {
						get_bufnrs = function()
							return vim.iter(vim.api.nvim_list_wins())
								:map(function(win)
									return vim.api.nvim_win_get_buf(win)
								end)
								:filter(function(buf)
									return vim.bo[buf].buftype ~= "nofile"
								end)
								:totable()
						end,
					},
					score_offset = -3,
				},
				dadbod = { module = "vim_dadbod_completion.blink" },
			},
		},

		snippets = { preset = "luasnip" },

		fuzzy = { implementation = "prefer_rust", sorts = {
			"exact",
			"score",
			"sort_text",
		} },

		signature = { enabled = true },
	},
}
