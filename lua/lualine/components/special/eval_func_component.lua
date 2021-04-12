local EvalFuncComponent = require('lualine.component'):new()

EvalFuncComponent.update_status = function(self)
  local component = self.options[1]
  local ok, status = pcall(EvalFuncComponent.eval_lua, component)
  if not ok then status = EvalFuncComponent.vim_function(component) end
  return status
end

EvalFuncComponent.eval_lua = function(code)
  return tostring(loadstring('return '..code)())
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
