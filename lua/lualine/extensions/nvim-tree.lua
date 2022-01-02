-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local nerdtree = require('lualine.extensions.nerdtree')

local M = {}

M.sections = vim.deepcopy(nerdtree.sections)

M.filetypes = { 'NvimTree' }

return M
