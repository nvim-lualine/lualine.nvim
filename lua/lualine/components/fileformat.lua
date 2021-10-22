-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

-- stylua: ignore
M.icon = {
  unix = '', -- e712
  dos  = '', -- e70f
  mac  = ''  -- e711
}

M.update_status = function(self)
  if self.options.icons_enabled and not self.options.icon then
    local format = vim.bo.fileformat
    return M.icon[format] or format
  end
  return vim.bo.fileformat
end

return M
