-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local utils = require('lualine.utils.utils')

local M = {}

M.sections = {lualine_a = {utils.get_short_cwd}}

M.inactive_sections = M.sections

M.filetypes = {'nerdtree'}

return M
