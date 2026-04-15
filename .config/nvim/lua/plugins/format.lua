return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },

			c = { "clang_format" },
			cpp = { "clang_format" },

			go = { "goimports", "gofumpt" },
			templ = { "goimports", "templ", "rustywind" },

			python = { "ruff_format" },

			bash = { "shfmt" },
			sh = { "shfmt" },

			java = { "google-java-format" },

			html = { "rustywind", "prettierd" },
			htmlangular = { "rustywind", "prettierd" },

			json = { "prettierd" },
			jsonc = { "prettierd" },

			markdown = { "prettierd" },
			["markdown.mdx"] = { "prettierd" },

			javascript = { "prettierd" },
			javascriptreact = { "rustywind", "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "rustywind", "prettierd" },
			svelte = { "rustywind", "prettierd" },

			css = { "prettierd" },
			scss = { "prettierd" },

			sql = { "sqlfmt" },

			yaml = { "yamlfmt" },
			["yaml.docker-compose"] = { "yamlfmt" },
			["yaml.ansible"] = { "yamlfmt" },
		},

		-- Set default options
		default_format_opts = {
			-- "first": use LSP formatting first, then conform
			-- "fallback": use LSP only if no conform formatter found
			-- "never": never use LSP formatting
			lsp_format = "fallback",
		},

		-- Set up format-on-save
		-- format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			return { timeout_ms = 1500, lsp_format = "fallback" }
		end,
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
