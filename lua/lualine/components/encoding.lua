-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function encoding()
  local result = vim.opt.fileencoding:get()
  if vim.opt.bomb:get() then
    result = result .. ' [BOM]'
  end

  return result
end

return encoding
