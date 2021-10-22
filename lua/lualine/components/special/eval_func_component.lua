-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

function M:update_status()
  local component = self.options[1]
  local ok, status
  if self.options.type == nil then
    ok, status = pcall(M.lua_eval, component)
    if not ok then
      status = M.vim_function(component)
    end
  else
    if self.options.type == 'lua_expr' then
      ok, status = pcall(M.lua_eval, component)
      if not ok then
        status = nil
      end
    elseif self.options.type == 'vim_fun' then
      status = M.vim_function(component)
    end
  end
  return status
end

---evaluate the lua code and return it's result as string
---@param code string
---@return string
function M.lua_eval(code)
  local result = loadstring('return ' .. code)()
  assert(result, 'String expected got nil')
  return tostring(result)
end

---call vim function (name) and return it's result as string
---@param name string
---@return string
function M.vim_function(name)
  -- vim function component
  local ok, return_val = pcall(vim.api.nvim_call_function, name, {})
  if not ok then
    return ''
  end -- function call failed
  ok, return_val = pcall(tostring, return_val)
  return ok and return_val or ''
end

return M
