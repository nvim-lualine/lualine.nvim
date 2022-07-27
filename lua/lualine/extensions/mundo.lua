local M = {}

M.sections = {
  lualine_a = {
    function()
      local ft = vim.opt_local.filetype:get()
      return (ft == 'Mundo') and 'Change tree' or (ft == 'MundoDiff') and 'Change diff'
    end,
  },
  lualine_y = { 'progress' },
  lualine_z = { 'location' },
}

M.filetypes = {
  'Mundo',
  'MundoDiff',
}

return M
