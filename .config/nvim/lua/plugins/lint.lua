return {
	"mfussenegger/nvim-lint",
	event = "VeryLazy",
	config = function()
		require("lint").linters_by_ft = {
			c = { "cpplint" },
			cpp = { "cpplint" },
			lua = { "luacheck" },
			javascript = { "eslint" },
			typescript = { "eslint" },
			javascriptreact = { "eslint" },
			typescriptreact = { "eslint" },
			bash = { "shellcheck" },
			sh = { "shellcheck" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				-- try_lint without arguments runs the linters defined in `linters_by_ft`
				-- for the current filetype
				require("lint").try_lint()
			end,
		})
	end,
}
