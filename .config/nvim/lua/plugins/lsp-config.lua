return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local function scandir(directory)
				local i, t, popen = 0, {}, io.popen
				local pfile = popen('ls -a "' .. directory .. '"')
				if pfile ~= nil then
					for filename in pfile:lines() do
						if filename ~= "." and filename ~= ".." then
							i = i + 1
							t[i] = filename
						end
					end
					pfile:close()
					return t
				end
			end

			local function table_contains(table, value)
				for _, val in ipairs(table) do
					if value == val then
						return true
					end
				end

				return false
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")
			local execluded_servers = { "stylua" }
			local servers = scandir(vim.fn.stdpath("data") .. "/mason/packages")

			for _, lsp in ipairs(servers) do
				if lsp == "lua-language-server" then
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
					})
				elseif not table_contains(execluded_servers, lsp) then
					lspconfig[lsp].setup({
						capabilities = capabilities,
					})
				end
			end

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
