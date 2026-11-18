local M = {}

local function executable(command)
	return vim.fn.executable(command) == 1
end

function M.setup()
	-- GUI/terminal `-e nvim` launches may bypass .zshrc. Respect an active fnm
	-- project selection, otherwise expose the managed default to Mason and LSPs.
	if executable("fnm") and (not vim.env.FNM_MULTISHELL_PATH or not executable("node")) then
		local result = vim.system({ "fnm", "exec", "--using", "default", "node", "-p", "process.execPath" }, { text = true }):wait(5000)
		local node = vim.trim(result.stdout or "")
		if result.code == 0 and node:sub(1, 1) == "/" then
			vim.env.PATH = vim.fs.dirname(node) .. ":" .. vim.env.PATH
		end
	end
	local java_home = vim.env.JAVA_HOME or ((vim.env.SDKMAN_DIR or (vim.env.HOME .. "/.sdkman")) .. "/candidates/java/current")
	if vim.fn.executable(java_home .. "/bin/java") == 1 then
		vim.env.JAVA_HOME = java_home
		vim.env.PATH = java_home .. "/bin:" .. vim.env.PATH
	end
end

function M.java_ready()
	if not executable("java") or not executable("javac") then
		return false
	end
	local result = vim.system({ "java", "-version" }, { text = true }):wait()
	local version = ((result.stderr or "") .. (result.stdout or "")):match('version "(%d+)')
	-- Current JDTLS requires Java 25 to launch, regardless of project source level.
	return result.code == 0 and tonumber(version or "0") >= 25
end

function M.can_install(tool, pkg)
	local source = pkg.spec.source.id
	local required = {}
	local hint = "run the core setup and restart Neovim from Zsh"
	if source:match("^pkg:npm/") then
		required = { "node", "npm" }
	elseif source:match("^pkg:golang/") then
		required = { "go" }
	elseif source:match("^pkg:cargo/") then
		required = { "cargo", "rustc" }
		hint = "run setup/install.sh --rust"
	elseif source:match("^pkg:luarocks/") then
		required = { "luarocks" }
	end
	if tool == "jdtls" or tool == "google-java-format" or tool == "checkstyle" then
		if not M.java_ready() then
			vim.notify_once("Java tools paused: select a JDK 25+ using SDKMAN, then restart Neovim.", vim.log.levels.WARN)
			return false
		end
	end
	for _, command in ipairs(required) do
		if not executable(command) then
			vim.notify_once("Mason: " .. tool .. " needs " .. command .. "; " .. hint, vim.log.levels.WARN)
			return false
		end
	end
	return true
end

return M
