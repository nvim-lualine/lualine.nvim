-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function get_short_cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end
local empty = {
  function()
    return ' '
  end,
  left_padding = 0,
  right_padding = 0,
}

local M = {}

M.sections = {
  lualine_a = { get_short_cwd },
  lualine_c = { empty },
}

M.filetypes = { 'nerdtree' }

return M
