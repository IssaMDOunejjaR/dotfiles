return {
	"ibhagwan/fzf-lua",

	dependencies = { "nvim-tree/nvim-web-devicons" },

	opts = {
		winopts = {
			border = "single",
			preview = {
				border = "single",
				hidden = true,
			},
		},
		keymap = {
			builtin = {
				["<C-]>"] = "toggle-preview",
			},
		},
	},

	init = function()
		require("fzf-lua").register_ui_select()
	end,

	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "[F]ind [F]iles",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "[F]ind [B]uffers",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").files({ cwd = "%:p:h" })
			end,
			desc = "[F]ind in [C]urrent directory",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "[F]ind by [G]rep",
		},
		{
			"<leader>f/",
			function()
				require("fzf-lua").lgrep_curbuf()
			end,
			desc = "[F]ind by grep in current buffer",
		},
		{
			"<leader>fid",
			function()
				require("fzf-lua").live_grep({ cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") })
			end,
			desc = "[F]ind by Grep [i]n [D]irectory",
		},
		{
			"<leader>fd",
			function()
				require("fzf-lua").files({ cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") })
			end,
			desc = "[F]ind in [D]irectory",
		},
		{
			"<leader>fw",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "[F]ind current [W]ord",
		},
		{
			"<leader>fW",
			function()
				require("fzf-lua").grep_cWORD()
			end,
			desc = "[F]ind current [W]ORD",
		},
		{
			"<leader>frf",
			function()
				require("fzf-lua").files({ resume = true })
			end,
			desc = "[F]ind [R]esume [F]iles",
		},
		{
			"<leader>frg",
			function()
				require("fzf-lua").live_grep({ resume = true })
			end,
			desc = "[F]ind [R]esume [G]rep",
		},
	},
}
