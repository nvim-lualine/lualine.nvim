-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local function filesize()
  local size = vim.fn.wordcount().bytes

  local suffixes = { 'b', 'k', 'm', 'g' }

  local i = 1
  while size > 1024 and i < #suffixes do
    size = size / 1024
    i = i + 1
  end

  local format = i == 1 and '%d%s' or '%.1f%s'
  return string.format(format, size, suffixes[i])
end

return filesize
