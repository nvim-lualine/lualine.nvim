local VarComponent = require('lualine.component'):new()
VarComponent.update_status = function(self)
  local component = self.options[1]
  -- vim veriable component
  -- accepts g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo:
  -- filters g portion from g:var
  local scope = component:match('[gvtwb]?o?')
  -- filters var portion from g:var
  local var_name = component:sub(#scope + 2, #component)
  -- Displays nothing when veriable aren't present
  if not (scope and var_name) then return '' end
  local return_val = vim[scope][var_name]
  if return_val == nil then return '' end
  local ok
  ok, return_val = pcall(tostring, return_val)
  return ok and return_val or ''
end

return VarComponent
