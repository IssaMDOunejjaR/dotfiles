return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost", "InsertLeave" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			c = { "cpplint" },
			cpp = { "cpplint" },
			-- lua = { "luacheck" },

			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			htmlangular = { "eslint_d" },

			bash = { "shellcheck" },
			sh = { "shellcheck" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })

		-- Simple debounce helper
		local timer = vim.uv.new_timer()
		local function debounced_lint()
			timer:stop()
			timer:start(
				300,
				0,
				vim.schedule_wrap(function()
					-- Only lint if buffer is modifiable and has a real file
					local bufnr = vim.api.nvim_get_current_buf()
					if not vim.api.nvim_buf_is_valid(bufnr) then
						return
					end
					if vim.bo[bufnr].buftype ~= "" then
						return -- skip non-file buffers (terminal, quickfix, etc.)
					end

					lint.try_lint()
				end)
			)
		end

		vim.api.nvim_create_autocmd({
			"BufEnter",
			"BufReadPost",
			"BufWritePost",
			"InsertLeave",
			"TextChanged",
		}, {
			group = lint_augroup,
			callback = debounced_lint,
		})

		-- Optional: manual lint command
		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Lint: run linters on current buffer" })

		-- Optional: show which linters are active
		vim.keymap.set("n", "<leader>li", function()
			local ft = vim.bo.filetype
			local linters = lint.linters_by_ft[ft] or {}
			if #linters == 0 then
				vim.notify("No linters configured for: " .. ft, vim.log.levels.WARN)
			else
				vim.notify("Active linters: " .. table.concat(linters, ", "), vim.log.levels.INFO)
			end
		end, { desc = "Lint: show active linters" })
	end,
}
