local function fileformat(options)
  local icon_linux  = "" -- e712
  local icon_windos = "" -- e70f
  local icon_mac    = "" -- e711
  return function()
    if options.icons_enabled and not options.icon then
      local format = vim.bo.fileformat
      if     format == 'unix' then return icon_linux
      elseif format == 'dos'  then return icon_windos
      elseif format == 'mac'  then return icon_mac end
    end
    return vim.bo.fileformat
  end
end

return { init = function(options) return fileformat(options) end }
