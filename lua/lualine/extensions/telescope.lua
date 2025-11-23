-- Extension for Telescope
local M = {}
M.sections = {
  lualine_a = {
    function()
      local ok, _ = pcall(require, 'telescope')
      if ok then
        return 'Telescope'
      else
        return ''
      end
    end,
  },
}
M.filetypes = { 'TelescopePrompt' }
return M
