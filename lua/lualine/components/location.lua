-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

function M:update_status()
  local line = vim.fn.line('.')
  local col = vim.fn.charcol('.')
  if self.options.total_lines_in_location then
    local total_line = vim.fn.line('$')
    return string.format('%3d/%d:%-2d', line, total_line, col)
  else
    return string.format('%3d:%-2d', line, col)
  end
end

return M
