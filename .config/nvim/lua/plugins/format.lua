return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { "stylua" },

			c = { "clang-format" },
			cpp = { "clang-format" },

			go = { "goimports", "gomodifytags", "gofmt" },
			templ = { "goimports", "gomodifytags", "templ" },

			python = { "ruff_format" },

			bash = { "shfmt", "shellcheck" },
			sh = { "shfmt", "shellcheck" },

			java = { "shfmt", "shellcheck" },

			["html"] = { "prettierd" },
			["htmlangular"] = { "prettierd", "eslint_d" },

			["json"] = { "prettierd" },

			["markdown"] = { "prettierd" },
			["markdown.mdx"] = { "prettierd" },

			["javascript"] = { "prettierd", "eslint_d" },
			["javascriptreact"] = { "rustywind", "prettierd", "eslint_d" },
			["typescript"] = { "prettierd", "eslint_d" },
			["typescriptreact"] = { "rustywind", "prettierd", "eslint_d" },
			["svelte"] = { "rustywind", "prettierd", "eslint_d" },

			css = { "prettierd" },
			scss = { "prettierd" },
		},

		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},

		-- Set up format-on-save
		-- format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			return { timeout_ms = 8000, lsp_format = "fallback" }
		end,
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
