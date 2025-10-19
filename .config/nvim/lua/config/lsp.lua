local mason_registry = require "mason-registry"

local function ensure_installed(tool_name)
  local ok, pkg = pcall(mason_registry.get_package, tool_name)

  if ok and not pkg:is_installed() then
    pkg:install()
  end
end

local filetype_tools = {
  lua = { tools = { "lua-language-server", "stylua" } },
  c = { tools = { "clangd", "clang-format", "cpplint" } },
  cpp = { tools = { "clangd", "clang-format", "cpplint" } },
  javascript = { tools = { "vtsls", "biome" } },
  javascriptreact = { toosl = { "vtsls", "biome" } },
  typescript = { tools = { "vtsls", "biome" } },
  typescriptreact = { tools = { "vtsls", "biome" } },
  html = {
    tools = { "html-lsp", "emmet-language-server", "angular-language-server", "prettierd" },
    condition = function()
      return vim.fs.find("angular.json", { upward = true })[1] ~= nil
    end,
  },
  htmlangular = {
    tools = { "html-lsp", "emmet-language-server", "angular-language-server", "prettierd" },
    condition = function()
      return vim.fs.find("angular.json", { upward = true })[1] ~= nil
    end,
  },
  css = { tools = { "css-lsp", "tailwindcss-language-server", "prettierd" } },
  scss = { tools = { "css-lsp", "tailwindcss-language-server", "prettierd" } },
  json = { tools = { "json-lsp", "prettierd", "jsonlint" } },
  python = { tools = { "basedpyright", "black", "isort" } },
  bash = { tools = { "bash-language-server", "shfmt", "shellcheck" } },
  sh = { tools = { "bash-language-server", "shfmt", "shellcheck" } },
  zsh = { tools = { "bash-language-server", "shfmt", "shellcheck" } },
  go = { tools = { "gopls", "goimports", "gomodifytags" } },
  templ = { tools = { "gopls", "goimports", "gomodifytags", "templ" } },
  dockerfile = { tools = { "docker-language-server", "dockerfile-language-server", "hadolint" } },
  ["yaml.docker-compose"] = { tools = { "docker-language-server", "docker-compose-language-service" } },
  java = { tools = { "jdtls", "lemminx", "google-java-format", "checkstyle " } },
  sql = { tools = { "sqls", "sqlfmt", "sqlfluff " } },
  yaml = { tools = { "yaml-language-server", "yamllint", "yamlfmt" } },
  ["yaml.ansible"] = { tools = { "ansible-language-server", "ansible-lint" } },
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local entry = filetype_tools[args.match]

    if (entry and entry.condition == nil) or (entry and entry.condition ~= nil and entry.condition()) then
      for _, tool in ipairs(entry.tools) do
        ensure_installed(tool)
      end
    end
  end,
})
