---@type vim.lsp.Config
return {
	on_attach = function(client, _)
		client.server_capabilities.renameProvider = false
	end,
}
