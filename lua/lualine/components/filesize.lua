-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):new()

M.update_status = function()
  local file = vim.fn.expand '%:p'
  if file == nil or #file == 0 then
    return ''
  end

  local size = vim.fn.getfsize(file)
  if size <= 0 then
    return ''
  end

  local sufixes = { 'b', 'k', 'm', 'g' }

  local i = 1
  while size > 1024 and i < #sufixes do
    size = size / 1024
    i = i + 1
  end

  return string.format('%.1f%s', size, sufixes[i])
end

return M
