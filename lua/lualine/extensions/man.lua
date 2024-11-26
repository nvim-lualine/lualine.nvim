local pager = require('lualine.extensions.pager')
local M = {}

M.sections = vim.deepcopy(pager.sections)

M.filetypes = { 'man' }

return M
