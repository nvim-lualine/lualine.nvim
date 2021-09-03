local EvalFuncComponent = require('lualine.component'):new()

EvalFuncComponent.update_status = function(self)
  local component = self.options[1]
  local ok, status
  if self.options.type == nil then
    ok, status = pcall(EvalFuncComponent.lua_eval, component)
    if not ok then status = EvalFuncComponent.vim_function(component) end
  else
    if self.options.type == 'luae' then
      ok, status = pcall(EvalFuncComponent.lua_eval, component)
      if not ok then status = nil end
    elseif self.options.type == 'vimf' then
      status = EvalFuncComponent.vim_function(component)
    end
  end
  return status
end

EvalFuncComponent.lua_eval = function(code)
  local result = loadstring('return ' .. code)()
  assert(result, 'String expected got nil')
  return tostring(result)
end

EvalFuncComponent.vim_function = function(name)
  -- vim function component
  local ok, return_val = pcall(vim.api.nvim_call_function, name, {})
  if not ok then return '' end -- function call failed
  ok, return_val = pcall(tostring, return_val)
  return ok and return_val or ''
end

return EvalFuncComponent
