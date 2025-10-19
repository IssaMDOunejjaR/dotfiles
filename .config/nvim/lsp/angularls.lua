local bun_global = vim.fn.expand "$HOME/.bun/install/global/node_modules"

local function get_ts_probe_locations()
  local npm = vim.fn.system("npm root -g"):gsub("\n", "")
  local local_node = vim.fn.getcwd() .. "/node_modules"

  return table.concat({ bun_global .. "/node_modules", npm, local_node }, ":")
end

---@type vim.lsp.Config
return {
  cmd = {
    "ngserver",
    "--stdio",
    "--tsProbeLocations",
    get_ts_probe_locations(),
    "--ngProbeLocations",
    bun_global .. "/@angular/language-server/bin",
    "--angularCoreVersion",
    "",
  },
  filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
  root_markers = { "angular.json", "nx.json" },
}
