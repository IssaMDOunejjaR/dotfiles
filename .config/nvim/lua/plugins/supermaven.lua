-- Supermaven: fast AI ghost-text completions (independent of blink.cmp's LSP completions).
-- Ghost text is OFF by default — toggle with <leader>us or :SupermavenToggle.
-- The blink.cmp source ("supermaven") shows Supermaven suggestions inside the
-- completion menu when ghost text is disabled or the menu is explicitly opened.
return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	config = function()
		require("supermaven-nvim").setup({
			-- Ghost text keymaps (only active when a suggestion is shown)
			keymaps = {
				accept_suggestion = "<C-y>",   -- accept full suggestion
				clear_suggestion  = "<C-]>",   -- dismiss suggestion
				accept_word       = "<C-Right>", -- accept one word
			},

			-- Start with ghost text disabled; toggled via <leader>us
			disable_inline_completion = true,

			-- The blink.cmp source still works regardless of this flag
			disable_keymaps = false,

			ignore_filetypes = {
				gitcommit = true,
				TelescopePrompt = true,
			},

			log_level = "off",
			color = {
				suggestion_color = "#6c6c6c", -- subtle grey ghost text
				cterm             = 244,
			},
		})

		-- ── Toggle helper ─────────────────────────────────────────────────
		vim.keymap.set("n", "<leader>us", function()
			local ok, api = pcall(require, "supermaven-nvim.api")
			if not ok then
				vim.notify("supermaven-nvim not loaded", vim.log.levels.WARN)
				return
			end
			if api.is_running() then
				api.stop()
				vim.notify("Supermaven: ghost text OFF", vim.log.levels.INFO)
			else
				api.start()
				vim.notify("Supermaven: ghost text ON", vim.log.levels.INFO)
			end
		end, { desc = "UI: Toggle Supermaven ghost text" })
	end,
}
