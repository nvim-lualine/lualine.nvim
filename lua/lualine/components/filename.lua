-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local function filename(options)
  -- setting defaults
  if options.file_status == nil then options.file_status = true end
  if options.shorten == nil then options.shorten = true end
  if options.full_path == nil then options.full_path = false end

  return function()
    local data
    if not options.full_path then
      data = vim.fn.expand('%:t')
    elseif options.shorten then
      data = vim.fn.expand('%:~:.')
    else
      data = vim.fn.expand('%:p')
    end
    if data == '' then
      data = '[No Name]'
    elseif vim.fn.winwidth(0) <= 84 or #data > 40 then
      data = vim.fn.pathshorten(data)
    end

    if options.file_status then
      if vim.bo.modified then
        data = data .. '[+]'
      elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        data = data .. '[-]'
      end
    end
    return data
  end
end

return {init = function(options) return filename(options) end}
