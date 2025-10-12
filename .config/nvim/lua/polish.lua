-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.api.nvim_create_user_command("ToggleFormat", function()
  if vim.g.disable_autoformat then
    vim.g.disable_autoformat = false
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Toggle Auto Format",
})
