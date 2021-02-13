-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local function filename(options)
  -- setting defaults
  local file_status, shorten, full_path = true, true, false
  if options.file_status  ~= nil then file_status = options.file_status end
  if options.shorten ~= nil then shorten = options.shorten end
  if options.full_path  ~= nil then full_path = options.full_path end

  return function()
    local data
    if shorten then
      data = vim.fn.expand('%:t')
    elseif full_path then
      data = vim.fn.expand('%:p')
    else
      data = vim.fn.expand('%')
    end
    if data == '' then
      data = '[No Name]'
    elseif vim.fn.winwidth(0) <= 84 or #data > 40 then
      data = vim.fn.pathshorten(data)
    end

    if file_status then
      if vim.bo.modified then data = data .. "[+]"
      elseif vim.bo.modifiable == false then data = data .. "[-]" end
    end
    return data
  end
end

return { init = function(options) return filename(options) end }
