local function get_registry()
	local ok, registry = pcall(require, "mason-registry")

	if not ok then
		vim.notify("mason-registry not available", vim.log.levels.WARN)
		return nil
	end

	return registry
end

local function ensure_installed(registry, tool_name)
	tool_name = tool_name:match("^%s*(.-)%s*$")

	local ok, pkg = pcall(registry.get_package, tool_name)

	if not ok or not pkg then
		vim.notify("Mason: unknown tool '" .. tool_name .. "'", vim.log.levels.WARN)
		return
	end

	if not pkg:is_installed() and not pkg:is_installing() then
		vim.notify("Mason: installing " .. tool_name .. "...", vim.log.levels.INFO)
		pkg:install()
	end
end

local function install_tools(tools)
	local registry = get_registry()

	if not registry then
		return
	end

	-- Deduplicate before async work
	local seen = {}
	local pending = {}

	for _, tool in ipairs(tools) do
		tool = tool:match("^%s*(.-)%s*$")

		if not seen[tool] then
			seen[tool] = true
			table.insert(pending, tool)
		end
	end

	local function do_install()
		for _, tool in ipairs(pending) do
			ensure_installed(registry, tool)
		end
	end

	local all_packages = registry.get_all_package_names()

	if #all_packages == 0 then
		-- Registry is empty — needs to fetch from GitHub first
		vim.notify("Mason: registry empty, updating...", vim.log.levels.INFO)

		-- update() downloads the registry index from GitHub
		registry.update(function(success, err_msg)
			if success then
				do_install()
			else
				vim.notify(
					"Mason: registry update failed: " .. tostring(err_msg) .. " — run :MasonUpdate manually",
					vim.log.levels.ERROR
				)
			end
		end)
	else
		-- Registry has packages, just refresh local cache
		registry.refresh(function()
			do_install()
		end)
	end
end

-- ============================================================
-- SHARED TOOL GROUPS (avoids repetition)
-- ============================================================
local groups = {
	-- JS/TS base (shared across js/ts/jsx/tsx)
	js_base = {
		"vtsls",
		"prettierd",
		"eslint-lsp",
		"eslint_d", -- linter daemon used by nvim-lint (separate from eslint-lsp)
		"js-debug-adapter",
	},
	-- JSX/TSX extras (React)
	jsx_extras = {
		"rustywind",
		"html-lsp",
		"emmet-language-server",
		"tailwindcss-language-server",
	},
	-- HTML base
	html_base = {
		"html-lsp",
		"emmet-language-server",
		"prettierd",
		"rustywind",
		"tailwindcss-language-server",
	},
	-- Shell base
	shell_base = {
		"bash-language-server",
		"shfmt",
		"shellcheck",
	},
	-- C/C++ base
	cpp_base = {
		"clangd",
		"clang-format",
		"cpplint",
		"codelldb", -- DAP adapter (shared with Rust)
	},
}

-- Helper to merge groups and extra tools
local function merge(...)
	local result = {}
	local seen = {}

	for _, list in ipairs({ ... }) do
		for _, item in ipairs(list) do
			if not seen[item] then
				seen[item] = true
				table.insert(result, item)
			end
		end
	end

	return result
end

-- ============================================================
-- FILETYPE → TOOLS MAP
-- ============================================================
local filetype_tools = {
	lua = { "lua-language-server", "stylua", "luacheck" },

	asm = { "asm-lsp", "asmfmt" },
	nasm = { "asm-lsp", "asmfmt" },

	c = groups.cpp_base,
	cpp = groups.cpp_base,

	javascript = groups.js_base,
	typescript = groups.js_base,
	javascriptreact = merge(groups.js_base, groups.jsx_extras),
	typescriptreact = merge(groups.js_base, groups.jsx_extras),

	html = groups.html_base,
	-- Angular HTML — detected dynamically below
	htmlangular = merge(groups.html_base, {
		"angular-language-server",
		"vtsls",
		"eslint-lsp",
		"js-debug-adapter",
	}),

	css = { "css-lsp", "prettierd", "stylelint" },
	scss = { "css-lsp", "prettierd", "stylelint" },

	json = { "json-lsp", "prettierd", "jsonlint" },

	python = { "basedpyright", "ruff" },

	bash = groups.shell_base,
	sh = groups.shell_base,
	zsh = groups.shell_base,

	go   = { "gopls", "goimports", "gomodifytags", "golangci-lint", "gofumpt", "delve" },
	rust = { "codelldb" }, -- rust-analyzer is installed via rustup, not Mason
	templ = { "gopls", "templ", "goimports", "tailwindcss-language-server" },

	dockerfile = { "dockerfile-language-server", "hadolint" },
	["yaml.docker-compose"] = { "docker-compose-language-service", "yamllint", "yamlfmt" },

	java = { "jdtls", "google-java-format", "checkstyle" },

	sql = { "sqls", "sqlfmt", "sqlfluff" },

	yaml = { "yaml-language-server", "yamllint", "yamlfmt" },
	["yaml.ansible"] = { "ansible-language-server", "ansible-lint", "yamllint", "yamlfmt" },
}

-- ============================================================
-- ANGULAR DETECTION
-- ============================================================
local function get_tools_for_ft(ft, bufnr)
	local tools = filetype_tools[ft] or {}

	-- For HTML-adjacent filetypes, check if this is an Angular project
	if ft == "html" or ft == "typescript" or ft == "javascript" then
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local angular_json = vim.fs.find("angular.json", {
			upward = true,
			path = vim.fn.fnamemodify(bufname, ":h"), -- start from file's dir
		})[1]

		if angular_json then
			tools = merge(tools, {
				"angular-language-server",
				"vtsls",
				"eslint-lsp",
			})
		end
	end

	return tools
end

-- ============================================================
-- AUTOCMD: install tools when filetype is detected
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("MasonAutoInstall", { clear = true }),
	callback = function(args)
		-- Skip special buffers
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		local tools = get_tools_for_ft(args.match, args.buf)

		if #tools > 0 then
			vim.schedule(function()
				install_tools(tools)
			end)
		end
	end,
})
