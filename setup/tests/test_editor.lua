-- Run only with nvim -u NONE: all plugin/network interactions are stubbed.
local root = assert(arg[1], "pass the dotfiles checkout path")
vim.opt.runtimepath = { root .. "/dot_config/nvim", vim.env.VIMRUNTIME }
vim.o.eventignore = "" -- nvim -l disables events by default
vim.bo.buftype = ""
package.path = root .. "/dot_config/nvim/lua/?.lua;" .. package.path
local commands = { node = true, npm = true, go = true, luarocks = true }
vim.fn.executable = function(command)
	return commands[command] and 1 or 0
end
vim.notify_once = function() end
vim.notify = function() end
vim.schedule = function(callback)
	callback()
end
local java_major = 25
local fnm_calls = 0
vim.system = function(argv)
	if argv[1] == "fnm" then
		assert(argv[4] == "default")
		fnm_calls = fnm_calls + 1
		return { wait = function() return { code = 0, stdout = "/fake/node/bin/node\n" } end }
	end
	return { wait = function() return { code = 0, stderr = 'openjdk version "' .. java_major .. '.0.1"' } end }
end

local toolchain = require("utils.toolchain")
local old_path, old_java, old_sdkman, old_multishell = vim.env.PATH, vim.env.JAVA_HOME, vim.env.SDKMAN_DIR, vim.env.FNM_MULTISHELL_PATH
vim.env.JAVA_HOME, vim.env.SDKMAN_DIR, vim.env.FNM_MULTISHELL_PATH = nil, "/fake/sdkman", nil
commands.fnm, commands["/fake/sdkman/candidates/java/current/bin/java"] = true, true
toolchain.setup()
assert(vim.env.PATH:find("/fake/node/bin", 1, true))
assert(vim.env.JAVA_HOME == "/fake/sdkman/candidates/java/current")
vim.env.FNM_MULTISHELL_PATH = "/active/project/selection"
toolchain.setup()
assert(fnm_calls == 1, "an active fnm selection must not be overridden")
vim.env.PATH, vim.env.JAVA_HOME, vim.env.SDKMAN_DIR, vim.env.FNM_MULTISHELL_PATH = old_path, old_java, old_sdkman, old_multishell
commands.fnm = false
local function package_for(source)
	return { spec = { source = { id = source } } }
end
assert(not toolchain.can_install("asm-lsp", package_for("pkg:cargo/asm-lsp@1")))
commands.cargo, commands.rustc = true, true
assert(toolchain.can_install("asm-lsp", package_for("pkg:cargo/asm-lsp@1")))
assert(toolchain.can_install("vtsls", package_for("pkg:npm/vtsls@1")))
commands.npm = false
assert(not toolchain.can_install("vtsls", package_for("pkg:npm/vtsls@1")))
commands.npm = true
assert(not toolchain.java_ready())
commands.java, commands.javac = true, true
assert(toolchain.java_ready())
java_major = 24
assert(not toolchain.can_install("jdtls", package_for("pkg:generic/jdtls@1")))
java_major = 25
assert(toolchain.can_install("jdtls", package_for("pkg:generic/jdtls@1")))

local installed = {}
package.loaded["mason-registry"] = {
	get_all_package_names = function() return { "ready" } end,
	refresh = function(callback) callback() end,
	get_package = function(name)
		local pkg = package_for("pkg:generic/" .. name .. "@1")
		pkg.is_installed = function() return false end
		pkg.is_installing = function() return false end
		pkg.install = function() installed[name] = true end
		return pkg
	end,
}
require("utils.lsp-auto-install")
for ft, tools in pairs({
	jsonc = { "json-lsp", "prettierd" },
	markdown = { "prettierd" },
	["markdown.mdx"] = { "prettierd" },
	svelte = { "svelte-language-server", "rustywind", "prettierd", "eslint_d" },
	templ = { "rustywind", "gopls" },
	htmlangular = { "eslint_d", "angular-language-server" },
}) do
	installed = {}
	vim.api.nvim_get_autocmds({ group = "MasonAutoInstall" })[1].callback({ match = ft, buf = vim.api.nvim_get_current_buf() })
	for _, tool in ipairs(tools) do
		assert(installed[tool], ft .. " is missing " .. tool)
	end
end

-- Exercise real LSP spec setup while replacing its plugin dependencies.
local enabled, mason_options = {}, nil
package.loaded["mason-lspconfig"] = { setup = function(options) mason_options = options end }
package.loaded["blink.cmp"] = { get_lsp_capabilities = function() return {} end }
vim.lsp.config = function() end
vim.lsp.enable = function(name) enabled[name] = true end
commands["rust-analyzer"] = true
dofile(root .. "/dot_config/nvim/lua/plugins/lsp.lua").config()
assert(enabled.rust_analyzer)
assert(vim.list_contains(mason_options.automatic_enable.exclude, "rust_analyzer"))
enabled = {}
commands["rust-analyzer"], commands.java = false, false
dofile(root .. "/dot_config/nvim/lua/plugins/lsp.lua").config()
assert(not enabled.rust_analyzer)
assert(vim.list_contains(mason_options.automatic_enable.exclude, "jdtls"))

local parsers, requests, starts = {}, {}, {}
package.loaded["nvim-treesitter"] = {
	setup = function(options) assert(vim.tbl_isempty(options)) end,
	get_available = function() return { "lua", "rust" } end,
	install = function(languages)
		local request = { languages = languages }
		requests[#requests + 1] = request
		return { await = function(_, callback) request.complete = callback end }
	end,
}
vim.treesitter.start = function(buf, lang)
	assert(parsers[lang], "parser not installed")
	starts[buf] = lang
end
local spec = dofile(root .. "/dot_config/nvim/lua/plugins/nvim-treesitter.lua")
assert(spec.lazy == false and spec.event == nil)
spec.config()
local first = vim.api.nvim_get_current_buf()
vim.bo[first].filetype = "lua"
vim.api.nvim_get_autocmds({ group = "TreesitterAutoInstall" })[1].callback({ match = "lua", buf = first })
assert(#requests == 1, "baseline parser installation must be deduplicated")
parsers.lua = true
requests[1].complete(nil, true)
assert(starts[first] == "lua")
local second = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(second)
vim.bo[second].filetype = "rust"
vim.api.nvim_get_autocmds({ group = "TreesitterAutoInstall" })[1].callback({ match = "rust", buf = second })
assert(#requests == 2)
parsers.rust = true
requests[2].complete(nil, true)
assert(starts[second] == "rust")
assert(vim.bo[second].indentexpr:find("nvim%-treesitter"))
print("Editor regression checks passed: toolchain guards, mappings, Rust LSP, async Treesitter activation.")
