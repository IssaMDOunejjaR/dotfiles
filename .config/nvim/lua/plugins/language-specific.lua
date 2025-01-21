local function is_lsp_installed(name)
	local ok, mason_registry = pcall(require, "mason-registry")

	if not ok then
		return false
	end

	return mason_registry.is_installed(name)
end

local function is_lsp_attached(name)
	local clients = vim.lsp.get_active_clients()

	for _, client in ipairs(clients) do
		if client.name == name then
			return true
		end
	end

	return false
end

return {
	{ -- Angular
		"joeveiga/ng.nvim",
		cond = function()
			return is_lsp_installed("angular-language-server") or is_lsp_attached("angularls")
		end,
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
		cond = function()
			return is_lsp_installed("rust-analyzer") or is_lsp_attached("rust_analyzer")
		end,
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
		cond = function()
			return is_lsp_installed("tailwindcss-language-server") or is_lsp_attached("tailwindcss")
		end,
		opts = {},
	},

	-- { -- Typescript
	-- 	"pmizio/typescript-tools.nvim",
	-- 	ft = { "typescript", "javascript" },
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"neovim/nvim-lspconfig",
	-- 	},
	-- 	opt = {
	-- 		server = {
	-- 			settings = {
	-- 				validate = true,
	-- 				lint = {
	-- 					cssConflict = "warning", -- Report CSS class conflicts
	-- 				},
	-- 				experimental = {
	-- 					classRegex = "([a-zA-Z0-9_-]+)",
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- 	cond = function()
	-- 		return is_lsp_installed("typescript-language-server")
	-- 	end,
	-- },

	{ -- Java
		"nvim-java/nvim-java",
		opt = true,
		event = "BufReadPre",
		cond = function()
			return is_lsp_installed("jdtls") or is_lsp_attached("jdtls")
		end,
		config = function()
			require("java").setup()
		end,
	},
}
