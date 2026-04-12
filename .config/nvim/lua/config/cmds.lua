vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		vim.b.disable_autoformat = true
		vim.notify("Auto-format disabled for this buffer", vim.log.levels.INFO, { title = "Formatting" })
	else
		vim.g.disable_autoformat = true
		vim.notify("Auto-format disabled globally", vim.log.levels.INFO, { title = "Formatting" })
	end
end, {
	desc = "Disable autoformat-on-save (! for buffer only)",
	bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
	vim.notify("Auto-format enabled", vim.log.levels.INFO, { title = "Formatting" })
end, {
	desc = "Re-enable autoformat-on-save",
})
