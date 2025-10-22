local Lsp = require "utils.lsp"

---Run the first available formatter followed by more formatters
---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
  local conform = require "conform"

  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end

  return select(1, ...)
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },

      c = { "clang-format" },
      cpp = { "clang-format" },

      go = { "goimports", "gomodifytags", "gofmt" },
      templ = { "goimports", "gomodifytags", "templ" },

      python = { "ruff_format" },

      bash = { "shfmt", "shellcheck" },
      sh = { "shfmt", "shellcheck" },

      java = { "shfmt", "shellcheck" },

      ["html"] = { "prettierd", "prettier", stop_after_first = true },
      ["htmlangular"] = { "prettierd", "prettier", stop_after_first = true },

      ["json"] = { "biome", "prettierd", "dprint", stop_after_first = true },

      ["markdown"] = { "prettierd", "prettier", "dprint", stop_after_first = true },
      ["markdown.mdx"] = { "prettierd", "prettier", "dprint", stop_after_first = true },

      ["javascript"] = { "prettierd", "prettier", stop_after_first = true },
      ["javascriptreact"] = function(bufnr)
        return { "rustywind", first(bufnr, "prettierd", "prettier") }
      end,
      ["typescript"] = { "prettierd", "prettier", stop_after_first = true },
      ["typescriptreact"] = function(bufnr)
        return { "rustywind", first(bufnr, "prettierd", "prettier") }
      end,
      ["svelte"] = function(bufnr)
        return { "rustywind", first(bufnr, "prettierd", "prettier") }
      end,

      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
    },
    formatters = {
      biome = {
        condition = function()
          local path = Lsp.biome_config_path()
          -- Skip if biome.json is in nvim
          local is_nvim = path and string.match(path, "nvim")

          if path and not is_nvim then
            return true
          end

          return false
        end,
      },
      deno_fmt = {
        condition = function()
          return Lsp.deno_config_exist()
        end,
      },
      dprint = {
        condition = function()
          return Lsp.dprint_config_exist()
        end,
      },
      prettier = {
        condition = function()
          local path = Lsp.biome_config_path()
          -- Skip if biome.json is in nvim
          local is_nvim = path and string.match(path, "nvim")

          if path and not is_nvim then
            return false
          end

          return true
        end,
      },
      prettierd = {
        condition = function()
          local path = Lsp.biome_config_path()
          -- Skip if biome.json is in nvim
          local is_nvim = path and string.match(path, "nvim")

          if path and not is_nvim then
            return false
          end

          return true
        end,
      },
    },

    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    -- format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
