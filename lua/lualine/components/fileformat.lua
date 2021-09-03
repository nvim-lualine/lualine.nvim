-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local FileFormat = require('lualine.component'):new()

-- stylua: ignore
FileFormat.icon = {
  unix = '', -- e712
  dos  = '', -- e70f
  mac  = ''  -- e711
}

FileFormat.update_status = function(self)
  if self.options.icons_enabled and not self.options.icon then
    local format = vim.bo.fileformat
    return FileFormat.icon[format] or format
  end
  return vim.bo.fileformat
end

return FileFormat
