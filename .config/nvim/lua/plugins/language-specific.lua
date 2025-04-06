return {
	{ -- Angular
		"joeveiga/ng.nvim",
		config = function()
			-- Safely load ng.nvim
			local ng_ok, ng = pcall(require, "ng")

			if ng_ok then
				vim.keymap.set("n", "<leader>at", function()
					ng.goto_template_for_component({ reuse_window = true })
				end, { desc = "[A]ngular [T]emplate for Component" })

				vim.keymap.set("n", "<leader>ac", function()
					ng.goto_component_with_template_file({ reuse_window = true })
				end, { desc = "[A]ngular [C]omponent with Template" })
			end

			local wk_ok, wk = pcall(require, "which-key")

			if wk_ok then
				wk.add({
					{ "<leader>a", name = "[A]ngular" },
				})
			end
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
			{
				"laytan/tailwind-sorter.nvim",
				build = "cd formatter && npm ci && npm run build",
				config = true,
			},
			{
				"razak17/tailwind-fold.nvim",
				opts = {},
				ft = { "html", "typescriptreact" },
			},
		},
		opts = {},
	},

	{ -- Typescript
		"pmizio/typescript-tools.nvim",
		ft = { "typescript", "javascript" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		opt = {
			server = {
				settings = {
					validate = true,
					lint = {
						cssConflict = "warning", -- Report CSS class conflicts
					},
					experimental = {
						classRegex = "([a-zA-Z0-9_-]+)",
					},
				},
			},
		},
	},

	{ -- Java
		"nvim-java/nvim-java",
		opt = true,
		event = "BufReadPre",
		config = function()
			require("java").setup()
		end,
	},
}
