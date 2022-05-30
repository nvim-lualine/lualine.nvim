-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

-- stylua: ignore
local symbols = {
  unix = '', -- e712
  dos = '', -- e70f
  mac = '', -- e711
}

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
  -- Apply default symbols
  self.symbols = vim.tbl_extend('keep', self.options.symbols or {}, symbols)
end

-- Function that runs every time statusline is updated
function M:update_status()
  local format = vim.bo.fileformat
  if self.options.icons_enabled then
    return self.symbols[format] or format
  else
    return format
  end
end

return M
