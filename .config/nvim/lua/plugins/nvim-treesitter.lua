return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter").setup({
			-- ✅ List of parsers to install
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"lua",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"query", -- Required for treesitter queries
			},

			-- ✅ Modern way to configure modules (NEW API)
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
				disable = function(lang, buf)
					-- Optional: Disable for large files
					local max_filesize = 256 * 1024 -- 256KB
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},

			indent = {
				enable = true,
			},

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-Space>",
				node_incremental = "<C-Space>",
				scope_incremental = "<C-S-Space>",
				node_decremental = "<BS>",
			},
		},
		})

		-- AUTO_INSTALL FEATURE: Install parsers on-demand when opening files
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(ev.match)

				-- Skip if we can't detect language or if treesitter already active
				if not lang then
					return
				end

				-- Check if parser is installed
				local ok, parser = pcall(vim.treesitter.get_parser, ev.buf, lang)
				if ok and parser then
					-- Parser exists and working, start highlighting
					pcall(vim.treesitter.start, ev.buf, lang)
					return
				end

				-- Parser missing - AUTO INSTALL IT!
				local ts = require("nvim-treesitter")

				-- Check if this language is available for installation
				local available = ts.get_available()
				if not available or not vim.tbl_contains(available, lang) then
					return -- Language not supported by treesitter
				end

				-- Install the parser asynchronously (non-blocking)
				ts.install({ lang })

				vim.notify(
					string.format("Installing treesitter parser for: %s", lang),
					vim.log.levels.INFO,
					{ title = "nvim-treesitter" }
				)
			end,
		})
	end,
}
