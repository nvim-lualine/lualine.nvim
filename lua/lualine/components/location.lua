-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function location()
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  return string.format('%3d:%-2d', line, col)
end

return location
