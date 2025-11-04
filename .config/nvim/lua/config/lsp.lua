local mason_registry = require "mason-registry"

local function ensure_installed(tool_name)
  local ok, pkg = pcall(mason_registry.get_package, tool_name)

  if not ok then
    return
  end

  if ok and not pkg:is_installed() then
    pkg:install()
  end
end

local html_tools = { "html-lsp", "emmet-language-server", "prettierd" }

if vim.fs.find("angular.json", { upward = true })[1] ~= nil then
  table.insert(html_tools, "angular-language-server")
  table.insert(html_tools, "vtsls")
end

local filetype_tools = {
  lua = { "lua-language-server", "stylua", "luacheck" },

  c = { "clangd", "clang-format", "cpplint" },
  cpp = { "clangd", "clang-format", "cpplint" },

  javascript = { "vtsls", "rustywind", "prettierd", "js-debug-adapter" },
  javascriptreact = { "vtsls", "rustywind", "prettierd", "js-debug-adapter", "html-lsp", "emmet-language-server" },
  typescript = { "vtsls", "rustywind", "prettierd", "js-debug-adapter" },
  typescriptreact = { "vtsls", "rustywind", "prettierd", "js-debug-adapter", "html-lsp", "emmet-language-server" },

  html = html_tools,
  htmlangular = {
    "html-lsp",
    "emmet-language-server",
    "angular-language-server",
    "prettierd",
    "vtsls",
    "js-debug-adapter",
  },

  css = { "css-lsp", "prettierd" },
  scss = { "css-lsp", "prettierd" },

  json = { "json-lsp", "prettierd", "jsonlint" },

  python = { "basedpyright", "ruff" },

  bash = { "bash-language-server", "shfmt", "shellcheck" },
  sh = { "bash-language-server", "shfmt", "shellcheck" },
  zsh = { "bash-language-server", "shfmt", "shellcheck" },

  go = { "gopls", "goimports", "gomodifytags" },
  templ = { "gopls", "goimports", "gomodifytags", "templ" },

  dockerfile = { "docker-language-server", "dockerfile-language-server", "hadolint" },
  ["yaml.docker-compose"] = { "docker-language-server", "docker-compose-language-service" },

  java = { "jdtls", "lemminx", "google-java-format", "checkstyle " },

  sql = { "sqls", "sqlfmt", "sqlfluff " },

  yaml = { "yaml-language-server", "yamllint", "yamlfmt" },
  ["yaml.ansible"] = { "ansible-language-server", "ansible-lint" },
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local tools = filetype_tools[args.match]

    if tools then
      for _, tool in ipairs(tools) do
        ensure_installed(tool)
      end
    end
  end,
})
