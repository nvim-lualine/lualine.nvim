-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function quickfix() return 'Quickfix List' end

local function quickfix_title() return vim.fn.getqflist({title = 0}).title end

local M = {}

M.sections = {
  lualine_a = {quickfix},
  lualine_b = {quickfix_title},
  lualine_z = {'location'}
}

M.inactive_sections = vim.deepcopy(M.sections)

M.filetypes = {'qf'}

return M
