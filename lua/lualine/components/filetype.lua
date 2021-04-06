-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local FileType = require('lualine.component'):new()

FileType.update_status = function(self)
  local data = vim.bo.filetype
  if #data > 0 then
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
      self.options.icon = devicons.get_icon(f_name, f_extension)
    else
      ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
      if ok ~= 0 then
        self.options.icon = vim.fn.WebDevIconsGetFileTypeSymbol()
      end
    end
    return data
  end
  return ''
end

return FileType
