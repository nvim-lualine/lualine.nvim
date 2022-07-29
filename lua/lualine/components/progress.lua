-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function progress()
  local cur = vim.fn.line('.')
  local total = vim.fn.line('$')
  if cur == 1 then
    return 'Top'
  elseif cur == total then
    return 'Bot'
  else
    return math.floor(cur / total * 100) .. '%%'
  end
end

return progress
