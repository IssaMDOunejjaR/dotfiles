vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

require("options")
require("mappings")

require("lazy").setup("plugins", {
	performance = {
		rtp = {
			-- disabled_plugins = { "gzip", "zip", "tar", "netrw" },
		},
	},
	change_detection = {
		notify = false,
	},
	checker = {
		enabled = true,
		notify = false,
	},
})

require("cmds")
