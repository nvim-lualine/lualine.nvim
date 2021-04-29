-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local FileName = require('lualine.component'):new()

function count(base, pattern)
  return select(2, string.gsub(base, pattern, ""))
end

FileName.new = function(self, options, child)
  local new_instance = self._parent:new(options, child or FileName)
  local default_symbols = {modified = '[+]', readonly = '[-]'}
  new_instance.options.symbols =
    vim.tbl_extend('force', default_symbols, new_instance.options.symbols or {})

  -- setting defaults
  if new_instance.options.file_status == nil then
    new_instance.options.file_status = true
  end
  if new_instance.options.shorten == nil then
    new_instance.options.shorten = true
  end
  if new_instance.options.full_path == nil then
    new_instance.options.full_path = false
  end

  return new_instance
end

FileName.update_status = function(self)
  local data = vim.fn.expand('%:p')
  local winW = vim.fn.winwidth(0)
  local estimatedSpaceAvailable = winW - 40

  if not self.options.full_path then
    data = vim.fn.expand('%:t')
  elseif self.options.shorten then
    data = vim.fn.expand('%:~:.')
  end

  if data == '' then
    data = '[No Name]'
  end

  for i = 0, count(data, "/"), 1 do
    if winW <= 84 or #data > estimatedSpaceAvailable then
      data = data:gsub("([^/])[^/]+%/", "%1/", 1)
    end
  end

  if self.options.file_status then
    if vim.bo.modified then
      data = data .. self.options.symbols.modified
    elseif vim.bo.modifiable == false or vim.bo.readonly == true then
      data = data .. self.options.symbols.readonly
    end
  end
  return data
end

return FileName
