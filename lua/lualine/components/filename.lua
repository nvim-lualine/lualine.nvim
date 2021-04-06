-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local FileName = require('lualine.component'):new()

FileName.new = function(self, options, child)
  local new_instence = self._parent:new(options, child or FileName)

  -- setting defaults
  if new_instence.options.file_status == nil then
    new_instence.options.file_status = true
  end
  if new_instence.options.shorten == nil then
    new_instence.options.shorten = true
  end
  if new_instence.options.full_path == nil then
    new_instence.options.full_path = false
  end

  return new_instence
end

FileName.update_status = function(self)
  local data = vim.fn.expand('%:p')
  if not self.options.full_path then
    data = vim.fn.expand('%:t')
  elseif self.options.shorten then
    data = vim.fn.expand('%:~:.')
  end

  if data == '' then
    data = '[No Name]'
  elseif vim.fn.winwidth(0) <= 84 or #data > 40 then
    data = vim.fn.pathshorten(data)
  end

  if self.options.file_status then
    if vim.bo.modified then
      data = data .. '[+]'
    elseif vim.bo.modifiable == false or vim.bo.readonly == true then
      data = data .. '[-]'
    end
  end
  return data
end

return FileName
