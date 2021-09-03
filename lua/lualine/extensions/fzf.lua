-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function fzf_statusline() return 'FZF' end
local empty = {function() return ' ' end, left_padding=0, right_padding=0}

local M = {}

M.sections = {
  lualine_a = {fzf_statusline},
  lualine_c = {empty}
}

M.filetypes = {'fzf'}

return M
