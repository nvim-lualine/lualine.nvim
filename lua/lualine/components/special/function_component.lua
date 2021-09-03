local FunctionComponent = require('lualine.component'):new()

FunctionComponent.update_status = function(self, is_focused)
  -- 1st element in options table is the function provided by config
  local ok, retval
  ok, retval = pcall(self.options[1], self, is_focused)
  if not ok then
    return ''
  end
  if type(retval) ~= 'string' then
    ok, retval = pcall(tostring, retval)
    if not ok then
      return ''
    end
  end
  return retval
end

return FunctionComponent
