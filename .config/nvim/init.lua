require("options")
require("mappings")
require("autocmds")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

--require("lazy").setup({
--	{ -- Useful plugin to show you pending keybinds.
--		"folke/which-key.nvim",
--		event = "VimEnter", -- Sets the loading event to 'VimEnter'
--		config = function() -- This is the function that runs, AFTER loading
--			require("which-key").setup()
--
--			-- Document existing key chains
--			require("which-key").add({
--				{ "<leader>c", group = "[C]ode" },
--				{ "<leader>d", group = "[D]ocument" },
--				{ "<leader>r", group = "[R]ename" },
--				{ "<leader>s", group = "[S]earch" },
--				{ "<leader>w", group = "[W]orkspace" },
--				{ "<leader>t", group = "[T]oggle" },
--				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
--			})
--		end,
--	},
--
--})
