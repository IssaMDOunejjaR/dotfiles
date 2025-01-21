return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>bf",
			function(bufnr)
				if (bufnr) then
					require("conform").format({ async = not vim.bo[bufnr].readonly, lsp_fallback = true })
				end
			end,
			mode = "",
			desc = "[B]uffer [F]ormat",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			local disable_filetypes = { ["plaintext"] = true, ["markdown"] = true }

			return {
				timeout_ms = 500,
				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			-- asm = { "asmfmt" },
			-- java = { "google-java-format" },
			-- templ = { "templ" },

			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },

			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},

	-- config = function()
	-- 	vim.keymap.set("n", "<leader>lf", function() end, {})
	-- end,
}
