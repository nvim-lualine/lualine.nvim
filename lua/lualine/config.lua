local M = {}

M.options = {
  icons_enabled = true,
  theme = 'gruvbox',
  component_separators = {'', ''},
  section_separators = {'', ''}
}

M.sections = {
  lualine_a = {'mode'},
  lualine_b = {'branch'},
  lualine_c = {'filename'},
  lualine_x = {'encoding', 'fileformat', 'filetype'},
  lualine_y = {'progress'},
  lualine_z = {'location'}
}

M.inactive_sections = {
  lualine_a = {},
  lualine_b = {},
  lualine_c = {'filename'},
  lualine_x = {'location'},
  lualine_y = {},
  lualine_z = {}
}

M.tabline = {}

M.extensions = {}

return M
