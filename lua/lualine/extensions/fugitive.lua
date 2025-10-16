-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}

local function fugitive_branch()
  local icon = '' -- e0a0
  return icon .. ' ' .. vim.fn.FugitiveHead()
end

local function get_git_toplevel_basename()
  local handle = io.popen("basename `git rev-parse --show-toplevel`")
  local result = handle:read("*a")
  handle:close()
  return result:match("^%s*(.-)%s*$") -- trim any whitespace
end

M.sections = {
  lualine_a = { get_git_toplevel_basename },
  lualine_b = { fugitive_branch },
  lualine_z = { 'location' },
}

M.filetypes = { 'fugitive' }

return M
