local function Filetype()
  local filetype = vim.bo.filetype
  if filetype:len() > 0 then
    local ok,devicons = pcall(require,'nvim-web-devicons')
    if ok then
      local f_name,f_extension = vim.fn.expand('%:t'),vim.fn.expand('%:e')
      local icon = devicons.get_icon(f_name,f_extension)
      if icon ~= nil then
        return icon .. ' ' .. filetype
      end
    return filetype
    end
    ok = (vim.fn.exists('*WebDevIconsGetFileTypeSymbol'))
    if ok ~= 0 then
      local icon = vim.call('WebDevIconsGetFileTypeSymbol')
      return icon .. ' ' .. filetype
    end
    return filetype
  end
  return ''
end

return Filetype
