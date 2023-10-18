-- lualine extension for telescope.nvim

local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'Telescope'
    end,
  },
}

M.filetypes = { 'TelescopePrompt' }

return M
