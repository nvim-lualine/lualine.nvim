local lualine_require = require('lualine_require')

local M = lualine_require.require('lualine.component'):extend()

local modules = lualine_require.lazy_require {
  spinner = 'lualine.components.spinner.spinner',
}

local default_options = {
  id = 'default',
  spinner = modules.spinner.default_options,
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)

  self._sp = modules.spinner.new(self.options.id, self.options.spinner)
end

function M:update_status()
  return self._sp.text
end

return M
