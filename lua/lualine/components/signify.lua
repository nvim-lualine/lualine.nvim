vim.fn.timer_start(3000, function()
if vim.api.nvim_echo then
  vim.api.nvim_echo({{'lualine.nvim: Signify component has been renamed to diff please change it in your configuration.', 'WarningMsg'}}, true, {})
else
  print('lualine.nvim: Signify component has been renamed to diff please change it in your configuration.', 'ErrorMsg')
end
end)
return require'lualine.components.diff'
