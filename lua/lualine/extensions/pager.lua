local M = {}

M.sections = {
  lualine_a = {
    function()
      return string.upper(vim.bo.filetype)
    end,
  },
  lualine_b = { { 'filename', file_status = false } },
  lualine_y = { 'progress' },
}

M.filetypes = {
  'help',
  'man',
}

return M
