return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "FzfLua" }, -- also load on command
	keys = {
		-- Resume
		{
			"<leader>fr",
			function()
				require("fzf-lua").resume()
			end,
			desc = "Find: Resume last search",
		},

		-- Files
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "Find: Files",
		},
		{
			"<leader>fF",
			function()
				require("fzf-lua").files({
					cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file"),
				})
			end,
			desc = "Find: Files in folder",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").git_files()
			end,
			desc = "Find: Git files",
		},
		{
			"<leader>fo",
			function()
				require("fzf-lua").oldfiles()
			end,
			desc = "Find: Recent files",
		},

		-- Grep
		{
			"<leader>sg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "Search: Live grep",
		},
		{
			"<leader>sG",
			function()
				require("fzf-lua").live_grep({
					cwd = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file"),
				})
			end,
			desc = "Search: Live grep in folder",
		},
		{
			"<leader>sc",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "Search: Word under cursor",
		},
		{
			"<leader>sc",
			function()
				require("fzf-lua").grep_visual()
			end,
			mode = "v",
			desc = "Search: Visual selection",
		},
		{
			"<leader>sb",
			function()
				require("fzf-lua").grep_curbuf()
			end,
			desc = "Search: In current buffer",
		},

		-- Buffers & UI
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "Find: Buffers",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").help_tags()
			end,
			desc = "Find: Help tags",
		},
		{
			"<leader>fk",
			function()
				require("fzf-lua").keymaps()
			end,
			desc = "Find: Keymaps",
		},
		{
			"<leader>f:",
			function()
				require("fzf-lua").command_history()
			end,
			desc = "Find: Command history",
		},

		-- Diagnostics
		{
			"<leader>fd",
			function()
				require("fzf-lua").diagnostics_document()
			end,
			desc = "Find: Diagnostics (document)",
		},
		{
			"<leader>fD",
			function()
				require("fzf-lua").diagnostics_workspace()
			end,
			desc = "Find: Diagnostics (workspace)",
		},

		-- LSP symbols
		{
			"<leader>fs",
			function()
				require("fzf-lua").lsp_document_symbols()
			end,
			desc = "Find: Document symbols",
		},
		{
			"<leader>fS",
			function()
				require("fzf-lua").lsp_workspace_symbols()
			end,
			desc = "Find: Workspace symbols",
		},

		{
			"gr",
			function()
				require("fzf-lua").lsp_references()
			end,
			desc = "LSP: References",
		},
		{
			"gd",
			function()
				require("fzf-lua").lsp_definitions()
			end,
			desc = "LSP: Definitions",
		},
		{
			"gi",
			function()
				require("fzf-lua").lsp_implementations()
			end,
			desc = "LSP: Implementations",
		},
		{
			"gy",
			function()
				require("fzf-lua").lsp_typedefs()
			end,
			desc = "LSP: Type definitions",
		},

		-- Todo (requires todo-comments.nvim)
		{
			"<leader>st",
			"<cmd>TodoFzfLua<cr>",
			desc = "Search: Todo comments",
		},
	},

	opts = {
		winopts = {
			height = 0.85,
			width = 0.85,
			row = 0.35,
			col = 0.50,
			border = "single",
			preview = {
				border = "single",
				hidden = true, -- toggle with <C-]>
				layout = "vertical",
				vertical = "up:50%",
			},
		},

		keymap = {
			builtin = {
				["<C-]>"] = "toggle-preview",
				["<C-u>"] = "preview-page-up",
				["<C-d>"] = "preview-page-down",
				["<C-f>"] = "preview-page-down",
				["<C-b>"] = "preview-page-up",
			},
			fzf = {
				["ctrl-q"] = "select-all+accept", -- send all to quickfix
			},
		},

		-- files() provider config
		files = {
			fd_opts = table.concat({
				"--type",
				"f",
				"--hidden", -- show hidden files
				"--follow", -- follow symlinks
				"--exclude",
				".git",
				"--exclude",
				"node_modules",
				"--exclude",
				".cache",
			}, " "),
		},

		-- live_grep provider config
		grep = {
			rg_opts = table.concat({
				"--hidden",
				"--follow",
				"--smart-case",
				"--glob",
				"!.git",
				"--glob",
				"!node_modules",
				"--column",
				"--line-number",
				"--no-heading",
				"--color=always",
			}, " "),
		},

		-- fzf display options
		fzf_opts = {
			["--layout"] = "reverse",
			["--marker"] = "+",
		},
	},

	config = function(_, opts)
		require("fzf-lua").setup(opts)
		-- Override vim.ui.select with fzf-lua
		-- Note: Neovim 0.12 improved built-in vim.ui.select
		-- fzf-lua's version is still superior for fuzzy finding
		-- require("fzf-lua").register_ui_select()
	end,
}
