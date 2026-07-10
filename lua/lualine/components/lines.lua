-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function lines()
  local line = vim.fn.line('.')
  local total = vim.fn.line('$')
  local col = vim.fn.charcol('.')
  return string.format('%3d/%d:%-2d', line, total, col)
end

return lines
