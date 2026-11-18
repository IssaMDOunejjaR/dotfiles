return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- the rewritten main branch does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({})
		local pending = {}
		local available = ts.get_available()

		local function start(buf, lang)
			if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
				return false
			end
			local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
			if stats and stats.size > 256 * 1024 then
				return false
			end
			if pcall(vim.treesitter.start, buf, lang) then
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				return true
			end
			return false
		end

		local function install(languages)
			for _, lang in ipairs(languages) do
				pending[lang] = true
			end
			ts.install(languages):await(function(err, success)
				vim.schedule(function()
					for _, lang in ipairs(languages) do
						pending[lang] = nil
					end
					if err or not success then
						vim.notify("Treesitter: parser installation failed; check :messages and retry :TSInstall.", vim.log.levels.WARN)
					end
					-- Activate successful parsers, including buffers opened during installation.
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
						if lang and vim.list_contains(languages, lang) then
							start(buf, lang)
						end
					end
				end)
			end)
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang or vim.bo[ev.buf].buftype ~= "" then
					return
				end
				local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
				if stats and stats.size > 256 * 1024 then
					return
				end
				if start(ev.buf, lang) or pending[lang] or not vim.list_contains(available, lang) then
					return
				end
				install({ lang })
			end,
		})
		-- Install shared query/injection parsers in addition to on-demand languages.
		install({ "bash", "c", "cpp", "lua", "markdown", "markdown_inline", "vim", "vimdoc", "query" })
	end,
}
