return {
  "nvim-lualine/lualine.nvim",
  config = function()
    function isRecording()
      local reg = vim.fn.reg_recording()
      if reg == "" then
        return ""
      end -- not recording
      return "recording to " .. reg
    end

    require("lualine").setup({
      sections = {
        lualine_x = {
          {
            isRecording,
          },
        },
      },
      options = {
        icons_enabled = true,
        theme = "dracula",
        component_separators = "│",
        section_separators = "",
      },
    })
  end,
}
