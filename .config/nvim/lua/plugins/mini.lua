return {
	{
		"echasnovski/mini.move",
		event = "BufReadPost",
		config = function()
			require("mini.move").setup()
		end,
	},

	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},

	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
	},

	{
		"echasnovski/mini.statusline",
		opts = {
			set_vim_settings = false,
			content = {
				active = function()
					local MiniStatusline = require("mini.statusline")
					local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
					local git = MiniStatusline.section_git({ trunc_width = 40 })
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
					return MiniStatusline.combine_groups({
						{ hl = mode_hl, strings = { mode:upper() } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
						"%<", -- Mark general truncate point
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=", -- End left alignment
						{
							hl = "MiniStatuslineFileinfo",
							strings = {
								vim.bo.filetype ~= ""
									and require("mini.icons").get("filetype", vim.bo.filetype)
										.. " "
										.. vim.bo.filetype,
							},
						},
						{ hl = mode_hl, strings = { "%l:%v" } },
					})
				end,
			},
		},
	},
}
