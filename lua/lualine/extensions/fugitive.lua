-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}

local function fugitive_branch()
  local icon = '' -- e0a0
  return icon .. ' ' .. vim.fn.FugitiveHead()
end

M.sections = {
  lualine_a = { fugitive_branch },
  lualine_z = { 'location' },
}

M.filetypes = { 'fugitive' }

return M
