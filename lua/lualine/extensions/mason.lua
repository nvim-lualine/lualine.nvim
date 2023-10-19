-- lualine extension for mason.nvim

local ok, mason_registry = pcall(require, 'mason-registry')
if not ok then
  return ''
end

local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'Mason'
    end,
  },
  lualine_b = {
    function()
      return 'Installed: ' .. #mason_registry.get_installed_packages() .. '/' .. #mason_registry.get_all_package_specs()
    end,
  },
}

M.filetypes = { 'mason' }

return M
