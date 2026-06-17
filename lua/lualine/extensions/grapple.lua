local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'Grapple'
    end,
  },
}

M.filetypes = { 'grapple' }

return M