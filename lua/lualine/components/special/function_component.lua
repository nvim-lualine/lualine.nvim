-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

M.update_status = function(self, is_focused)
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

return M
