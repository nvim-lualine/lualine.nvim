local M = {  }

function M.setTheme(theme)
  return require('lualine.themes.'..theme)
end

function M.drawSection(section, separator)
  local status = ''
  for index, statusFunction in pairs(section) do
    local localstatus = statusFunction()
    if localstatus:len() > 0 then
      if separator:len() > 0 then
        if index > 1 then
          status = status .. separator .. ' '
        end
        status = status .. localstatus
        status = status .. ' '
      else
        status = status .. localstatus
        status = status .. ' '
      end
    end
  end
  if status:len() > 0 then
    if separator:len() > 0 and table.maxn(section) > 1 then
      return ' ' .. status .. ' '
    end
    return ' ' .. status
  end
  return ''
end

return M
