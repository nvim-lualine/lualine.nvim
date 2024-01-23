-- Copyright (c) 2020-2021 hoob3rt
-- Copyright (c) 2023 rstrlcpy
-- MIT license, see LICENSE for more details.
local function location()
  local cursor = vim.fn.getcurpos()
  local line = vim.fn.getline('.')
  local pos = cursor[3]
  local line_num = cursor[2]
  local character = string.sub(line, pos, pos)
  if character == "" then
    return string.format('%3d:%-2d:0x00', line_num, pos)
  end

  local ascii_value = string.byte(character)
  return string.format('%3d:%-2d:0x%x', line_num, pos, ascii_value)
end

return location
