return {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ", "htmlangular" },
  init_options = {
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    provideFormatter = false,
  },
}
