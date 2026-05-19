-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function get_short_cwd()
  return vim.fn.fnamemodify(require('nvim-tree.core').get_cwd(), ':~')
end

local M = {}

M.sections = {
  lualine_a = { get_short_cwd },
}

M.filetypes = { 'NvimTree' }

return M
