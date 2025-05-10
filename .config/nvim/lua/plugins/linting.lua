return {
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				typescript = { "eslint_d" },
				javascript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				html = { "htmlhint" },
				css = { "stylelint" },
				scss = { "stylelint" },
				sass = { "stylelint" },
			}

			-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			-- 	callback = function()
			-- 		-- try_lint without arguments runs the linters defined in `linters_by_ft`
			-- 		-- for the current filetype
			-- 		lint.try_lint()
			--
			-- 		-- You can call `try_lint` with a linter name or a list of names to always
			-- 		-- run specific linters, independent of the `linters_by_ft` configuration
			-- 		-- require("lint").try_lint("cspell")
			-- 	end,
			-- })

			vim.keymap.set("n", "<leader>ll", function()
				lint.try_lint()
			end, { desc = "[L]sp [L]int" })
		end,
	},
}
