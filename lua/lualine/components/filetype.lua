local function filetype(options)
  return function()
    local data = vim.bo.filetype
    if #data > 0 then
      local ok, devicons = pcall(require,'nvim-web-devicons')
      if ok and not options.icon then
        local f_name,f_extension = vim.fn.expand('%:t'),vim.fn.expand('%:e')
        options.icon = devicons.get_icon(f_name,f_extension)
      else
        ok = vim.fn.exists("*WebDevIconsGetFileTypeSymbol")
        if ok ~= 0 and not options.icon then
          options.icon = vim.fn.WebDevIconsGetFileTypeSymbol()
        end
      end
      return data
    end
    return ''
  end
end

return { init = function(options) return filetype(options) end }
