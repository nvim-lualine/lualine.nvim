-- lualine extension for mason.nvim

local mason_registry
local function maybe_set_registry()
  local ok, registry = pcall(require, 'mason-registry')
  if ok then
    mason_registry = registry
  end
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
      maybe_set_registry()
      return 'Installed: ' .. #mason_registry.get_installed_packages() .. '/' .. #mason_registry.get_all_package_specs()
    end,
  },
}

M.filetypes = { 'mason' }

return M
