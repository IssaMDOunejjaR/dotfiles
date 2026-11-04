-- GitHub Copilot: inline AI suggestions surfaced through blink.cmp via the
-- blink-copilot source (copilot.lua's own suggestion/panel UIs are disabled to
-- avoid conflicts with the completion menu).
-- Toggle with <leader>ua or :Copilot toggle.
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function(_, opts)
		require("copilot").setup(opts)

		vim.keymap.set("n", "<leader>ua", function()
			vim.cmd("Copilot toggle")
		end, { desc = "AI: Toggle Copilot" })
	end,
	opts = {
		suggestion = { enabled = false }, -- handled by blink-copilot
		panel = { enabled = false },
		filetypes = {
			markdown = true,
			help = true,
		},
	},
}
