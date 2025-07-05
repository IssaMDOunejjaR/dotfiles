return { -- Autoformat
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>bf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "[B]uffer [F]ormat",
			},
		},
		opts = {
			notify_on_error = false,
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end

				return {
					timeout_ms = 1000,
					lsp_format = "fallback",
					async = false,
					lsp_fallback = true,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua", stop_after_first = true },
				c = { "clang-format", stop_after_first = true },
				cpp = { "clang-format", stop_after_first = true },
				javascript = { "prettierd", stop_after_first = true },
				typescript = { "prettierd", stop_after_first = true },
				javascriptreact = { "prettierd", stop_after_first = true },
				typescriptreact = { "prettierd", stop_after_first = true },
				css = { "prettierd", stop_after_first = true },
				scss = { "prettierd", stop_after_first = true },
				html = { "prettierd", stop_after_first = true },
				htmlangular = { "prettierd", stop_after_first = true },
				json = { "prettierd", stop_after_first = true },
				yaml = { "prettierd", stop_after_first = true },
				markdown = { "prettierd", stop_after_first = true },
				["markdown.mdx"] = { "prettierd", stop_after_first = true },
				bash = { "beautysh", stop_after_first = true },
				sh = { "shfmt", stop_after_first = true },
				templ = { "templ", stop_after_first = true },
				rust = { "rustfmt", stop_after_first = true },
			},
		},
	},
}
