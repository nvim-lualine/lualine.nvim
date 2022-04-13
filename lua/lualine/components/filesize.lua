-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local function filesize()
  local size = vim.fn.wordcount().bytes

  local sufixes = { 'b', 'k', 'm', 'g' }

  local i = 1
  while size > 1024 and i < #sufixes do
    size = size / 1024
    i = i + 1
  end

  return string.format('%.1f%s', size, sufixes[i])
end

return filesize
