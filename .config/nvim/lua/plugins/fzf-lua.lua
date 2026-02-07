return {
	"ibhagwan/fzf-lua",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<leader>fa",
			function()
				require("fzf-lua").resume()
			end,
			desc = "Resume Find",
		},
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "FZF Files",
		},
		{
			"<leader>sg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "FZF Live Grep",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "FZF Buffers",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").help_tags()
			end,
			desc = "FZF Help Tags",
		},
		{
			"<leader>fx",
			function()
				require("fzf-lua").diagnostics_document()
			end,
			desc = "FZF Diagnostics Document",
		},
		{
			"<leader>fX",
			function()
				require("fzf-lua").diagnostics_workspace()
			end,
			desc = "FZF Diagnostics Workspace",
		},
		{
			"<leader>fs",
			function()
				require("fzf-lua").lsp_document_symbols()
			end,
			desc = "FZF Document Symbols",
		},
		{
			"<leader>fS",
			function()
				require("fzf-lua").lsp_workspace_symbols()
			end,
			desc = "FZF Workspace Symbols",
		},
		{
			"<leader>st",
			"<cmd>TodoFzfLua<cr>",
			desc = "Todo",
		},
		{
			"<leader>s/",
			function()
				require("fzf-lua").live_grep({ cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") })
			end,
			desc = "Grep in folder",
		},
		{
			"<leader>f/",
			function()
				require("fzf-lua").files({ cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file") })
			end,
			desc = "Find file in folder",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "Word under cursor",
		},
	},
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
	config = function(_, opts)
		require("fzf-lua").setup(opts)
		require("fzf-lua").register_ui_select()
	end,
}
