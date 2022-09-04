local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'MAN'
    end,
  },
  lualine_b = { { 'filename', file_status = false } },
  lualine_y = { 'progress' },
  lualine_z = { 'location' },
}

M.winbar = {}
M.inactive_winbar = {}

M.filetypes = { 'man' }

return M
