return {
	{
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

				vim.keymap.set("n", "<leader>aT", function()
					ng.get_template_tcb()
				end, { desc = "[A]ngular Template [T]ypeCheck" })
			end

			vim.keymap.set("n", "<leader>at", function()
				ng.goto_template_for_component({ reuse_window = true })
			end, { desc = "[A]ngular [T]emplate for Component" })

			vim.keymap.set("n", "<leader>ac", function()
				ng.goto_component_with_template_file({ reuse_window = true })
			end, { desc = "[A]ngular [C]omponent with Template" })

			local wk_ok, wk = pcall(require, "which-key")

			if wk_ok then
				wk.add({
					{ "<leader>a", name = "[A]ngular" },
				})
			end
		end,
	},
}
