-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function filetype()
  local data = vim.bo.filetype
  if #data > 0 then
    local ok,devicons = pcall(require,'nvim-web-devicons')
    if ok then
      local f_name,f_extension = vim.fn.expand('%:t'),vim.fn.expand('%:e')
      local icon = devicons.get_icon(f_name,f_extension)
      if icon ~= nil then
        return icon .. ' ' .. data
      end
    return data
    end
    ok = vim.fn.exists("*WebDevIconsGetFileTypeSymbol")
    if ok ~= 0 then
      local icon = vim.fn.WebDevIconsGetFileTypeSymbol()
      return icon .. ' ' .. data
    end
    return data
  end
  return ''
end

return filetype
