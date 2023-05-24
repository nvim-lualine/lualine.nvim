-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local M = require('lualine.component'):extend()

local default_options = {
	format = '%3d:%-2d'
}

function M:init(options)
	M.super.init(self, options)
	self.options = vim.tbl_extend('keep', self.options or {}, default_options)
end

function M:update_status()
  local line = vim.fn.line('.')
  local col = vim.fn.virtcol('.')
  return string.format(self.options.format, line, col)
end	

return M
