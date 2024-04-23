local M = {}

M.sections = {
  lualine_a = {
    function()
      return string.upper(vim.bo.filetype)
    end,
  },
}

M.filetypes = { 'alpha' }

return M
