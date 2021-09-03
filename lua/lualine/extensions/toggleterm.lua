-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function toggleterm_statusline()
  return 'ToggleTerm #' .. vim.b.toggle_number
end
local empty = {
  function()
    return ' '
  end,
  left_padding = 0,
  right_padding = 0,
}

local M = {}

M.sections = {
  lualine_a = { toggleterm_statusline },
  lualine_c = { empty },
}

M.filetypes = { 'toggleterm' }

return M
