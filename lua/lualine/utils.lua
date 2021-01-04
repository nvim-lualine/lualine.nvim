local M = {  }

function M.draw_section(section, separator)
  local status = {}
  for _, status_function in pairs(section) do
    local localstatus = status_function()
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
