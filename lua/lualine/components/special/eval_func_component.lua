local EvalFuncComponent = require('lualine.component'):new()

EvalFuncComponent.update_status = function(self)
  local component = self.options[1]
  local ok, status = EvalFuncComponent.evallua(component)
  if not ok then status = EvalFuncComponent.vim_function(component) end
  return status
end

EvalFuncComponent.evallua = function(code)
  if loadstring(string.format('return %s ~= nil', code)) and
      loadstring(string.format([[return %s ~= nil]], code))() then
    -- lua veriable component
    return true, loadstring(string.format(
                                [[
    local ok, return_val = pcall(tostring, %s)
    if ok then return return_val end
    return '']], code))()
  end
  return false, ''
end

EvalFuncComponent.vim_function = function(name)
  -- vim function component
  local ok, return_val = pcall(vim.fn[name])
  if not ok then return '' end -- function call failed
  ok, return_val = pcall(tostring, return_val)
  if ok then
    return return_val
  else
    return ''
  end
end

return EvalFuncComponent
