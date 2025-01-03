return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",

		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},

		{ "nvim-telescope/telescope-ui-select.nvim" },

		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },

		"nvim-telescope/telescope-file-browser.nvim",

		"BurntSushi/ripgrep", -- Ensure `rg` is installed for grep functionality
		"sharkdp/fd", -- Ensure `fd` is installed for file searching
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local themes = require("telescope.themes")
		local fb_actions = require("telescope._extensions.file_browser.actions")

		-- Setup function for telescope
		telescope.setup({
			defaults = {
				mappings = {
					n = {
						["q"] = actions.close,
						["<C-p>"] = require("telescope.actions.layout").toggle_preview,
					},
				},
				preview = {
					hide_on_startup = true, -- hide previewer when picker starts
				},
			},
			extensions = {
				["ui-select"] = {
					themes.get_dropdown(),
				},
				fzf = {
					fuzzy = true, -- Enable fuzzy matching
					override_generic_sorter = true, -- Override the default sorter
					override_file_sorter = true, -- Override the default file sorter
				},
				file_browser = {
					hijack_netrw = true,
					mappings = {
						["n"] = {
							["<C-d>"] = fb_actions.remove, -- Delete files
							["<C-r>"] = fb_actions.rename, -- Rename files
						},
					},
				},
			},
		})

		telescope.load_extension("file_browser")

		-- Keymap for file browsing
		vim.keymap.set("n", "<leader>c", function()
			telescope.extensions.file_browser.file_browser({
				path = "%:p:h", -- Start in the current file's directory
				hidden = true, -- Show hidden files
				respect_gitignore = true,
			})
		end, { desc = "File Browser Current Folder" })

		vim.keymap.set("n", "<leader>e", function()
			telescope.extensions.file_browser.file_browser({
				path = vim.fn.getcwd(), -- Start in the current file's directory
				hidden = true, -- Show hidden files
				respect_gitignore = true,
			})
		end, { desc = "File Browser" })

		vim.keymap.set("n", "<leader>sf", function()
			local folder = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file")
			require("telescope.builtin").live_grep({
				prompt_title = "Search in " .. folder,
				cwd = folder,
			})
		end, { desc = "[S]earch [F]older for Word" })

		vim.keymap.set("n", "<leader>sw", function()
			local folder = vim.fn.input("Search Folder: ", vim.fn.getcwd(), "file")
			require("telescope.builtin").grep_string({
				prompt_title = "Find Word in " .. folder,
				cwd = folder,
				search = vim.fn.expand("<cword>"), -- Word under the cursor
			})
		end, { desc = "[S]earch [W]ord in Folder" })

		-- Load extensions safely
		local extensions = { "fzf", "ui-select" }

		for _, ext in ipairs(extensions) do
			pcall(telescope.load_extension, ext)
		end

		-- Key mappings for Telescope
		local mappings = {
			{ key = "<leader>fh", action = builtin.help_tags, desc = "[F]ind [H]elp" },
			{ key = "<leader>fk", action = builtin.keymaps, desc = "[F]ind [K]eymaps" },
			{ key = "<leader>ff", action = builtin.find_files, desc = "[F]ind [F]iles" },
			{ key = "<leader>fs", action = builtin.builtin, desc = "[F]ind [S]elect Telescope" },
			{ key = "<leader>fw", action = builtin.grep_string, desc = "[F]ind current [W]ord" },
			{ key = "<leader>fg", action = builtin.live_grep, desc = "[F]ind by [G]rep" },
			{ key = "<leader>fd", action = builtin.diagnostics, desc = "[F]ind [D]iagnostics" },
			{ key = "<leader>fr", action = builtin.resume, desc = "[F]ind [R]esume" },
			{ key = "<leader>f.", action = builtin.oldfiles, desc = "[F]ind Recent Files" },
			{ key = "<leader>fb", action = builtin.buffers, desc = "[F]ind Existing [B]uffers" },
			{
				key = "<leader>fc",
				action = function()
					builtin.current_buffer_fuzzy_find(themes.get_dropdown({ winblend = 20, previewer = false }))
				end,
				desc = "[F]uzzily search in [C]urrent buffer",
			},
			{
				key = "<leader>f/",
				action = function()
					builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
				end,
				desc = "[F]ind [/] in Open Files",
			},
			{
				key = "<leader>fn",
				action = function()
					builtin.find_files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "[F]ind [N]eovim files",
			},
		}

		-- Set up key mappings
		for _, map in ipairs(mappings) do
			vim.keymap.set("n", map.key, map.action, { desc = map.desc })
		end

		vim.keymap.set("n", "<leader>fa", function()
			require("telescope.builtin").find_files({
				prompt_title = "Angular Files",
				cwd = vim.fn.getcwd(), -- Or specify a custom folder
				file_ignore_patterns = { "node_modules/*" },
				find_command = {
					"rg",
					"--files",
					"--glob",
					"**/*.ts",
					"--glob",
					"**/*.html",
					"--glob",
					"**/*.scss",
				},
			})
		end, { desc = "Find Angular files" })
	end,
}
