local M = {}

M.sections = {
  --lualine_a = {function() return vim.fn['tagbar#currentfile']() end}
  lualine_a = {
    function()
      return 'tagbar'
    end,
  },
}

M.filetypes = { 'tagbar' }

return M
