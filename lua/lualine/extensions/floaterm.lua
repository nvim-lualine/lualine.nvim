-- Extension for Floaterm
local M = {}

M.sections = {
  lualine_a = {
    function()
      if vim.bo.filetype == 'floaterm' then
        return 'Floaterm'
      else
        return ''
      end
    end,
  },
}

M.filetypes = { 'floaterm' }

return M
