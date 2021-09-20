local config = {
  options = {
    icons_enabled = true,
    theme = 'nord',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', { 'diagnostics', sources = { 'nvim_lsp', 'coc' } } },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}

local lualine = require'lualine'
lualine.setup(config)
vim.g.actual_curbuf = tostring(vim.fn.bufnr())
vim.g.actual_curwin = tostring(vim.fn.bufwinid(vim.fn.bufnr()))
local num = 10000
local bench = require('plenary.profile').benchmark
local time = bench(num, function()
  lualine.statusline(true)
end)
print(string.format('render %s time : *%s* ms', num, time))
vim.g.actual_curbuf = nil
vim.g.actual_curwin = nil
