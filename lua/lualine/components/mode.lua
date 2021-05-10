-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Mode = require('lualine.component'):new()
local get_mode = require('lualine.utils.mode').get_mode

Mode.update_status = function()
  local data = get_mode()
  local windwidth = vim.fn.winwidth(0)
  if windwidth <= 84 then return data:sub(1,1) end
  return data
end

return Mode
