-- lualine extension for lazy.nvim

local ok, lazy = pcall(require, 'lazy')
if not ok then
  return ''
end

local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'lazy 💤'
    end,
  },
  lualine_b = {
    function()
      return 'loaded: ' .. lazy.stats().loaded .. '/' .. lazy.stats().count
    end,
  },
  lualine_c = {
    {
      require('lazy.status').updates,
      cond = require('lazy.status').has_updates,
    },
  },
}

M.filetypes = { 'lazy' }

return M
