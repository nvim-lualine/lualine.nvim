local function filetype(options)
  -- set when user wants to set a custom icon
  local icons_enabled = options.icons_enabled

  return function()
    local data = vim.bo.filetype
    if #data > 0 then
      if not icons_enabled then return data end
      if options.icon then
        return string.format('%s %s', options.icon, data)
      end
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
end

return { init = function(options) return filetype(options) end, }
