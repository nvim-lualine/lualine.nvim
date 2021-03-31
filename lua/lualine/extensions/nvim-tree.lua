local M = {}

M.sections = {lualine_a = {vim.fn.getcwd}}

M.inactive_sections = M.sections

M.filetypes = {'NvimTree'}

return M
