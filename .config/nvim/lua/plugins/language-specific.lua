return {
	{ -- Angular
		"joeveiga/ng.nvim",
		config = function()
			-- Safely load ng.nvim
			local ok, ng = pcall(require, "ng")

			if not ok then
				vim.notify("Failed to load ng.nvim", vim.log.levels.ERROR)
				return
			end

			-- Keymaps for navigating Angular components and templates
			vim.keymap.set("n", "<leader>at", function()
				ng.goto_template_for_component({ reuse_window = true })
			end, { desc = "[A]ngular [T]emplate for Component" })

			vim.keymap.set("n", "<leader>ac", function()
				ng.goto_component_with_template_file({ reuse_window = true })
			end, { desc = "[A]ngular [C]omponent with Template" })
		end,
	},

	{ -- Rust
		"mrcjkb/rustaceanvim",
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					hover_actions = {
						-- replace_builtin_hover = false,
					},
					rustfmt = {
						enable = true, -- Enable rustfmt integration
					},
					rust_analyzer = {
						enable = true, -- Enable rust-analyzer for LSP
					},
				},
			}
		end,
	},

	{ -- Tailwind
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
			"neovim/nvim-lspconfig", -- optional
		},
		opts = {}, -- your configuration
	},

	{ -- Typescript
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("typescript-tools").setup({
				tools = {
					rename_file = {
						enable = true,
					},
				},
			})
		end,
	},
}
