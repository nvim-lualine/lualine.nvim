local M = {  }

function M.setTheme(theme)
  return require('lualine.themes.'..theme)
end

function M.drawSection(section, separator)
  local status = {}
  for _, statusFunction in pairs(section) do
    local localstatus = statusFunction()
    if #localstatus > 0 then
      table.insert(status, localstatus)
    end
  end
  if #status == 0 then
    return ''
  end
  local sep = ' '
  if #separator > 0 then
    sep = ' ' .. separator .. ' '
  end
  return ' ' .. table.concat(status, sep) .. ' '
end

return M
