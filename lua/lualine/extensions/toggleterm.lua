-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function toggleterm_statusline()
  return 'ToggleTerm #' .. vim.b.toggle_number
end

local M = {}

M.sections = {
  lualine_a = { toggleterm_statusline },
}

M.filetypes = { 'toggleterm' }

return M
