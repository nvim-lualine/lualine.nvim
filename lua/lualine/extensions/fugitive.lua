-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}

local function fugitive_branch()
  local icon = '' -- e0a0
  return icon .. ' ' .. vim.fn.FugitiveHead()
end
local empty = {function() return ' ' end, left_padding=0, right_padding=0}


M.sections = {
  lualine_a = {fugitive_branch},
  lualine_c = {empty},
  lualine_z = {'location'}
}

M.filetypes = {'fugitive'}

return M
