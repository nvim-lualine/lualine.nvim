-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function fzf_statusline()
  return 'FZF'
end

local M = {}

M.sections = {
  lualine_a = { fzf_statusline },
}

M.filetypes = { 'fzf' }

return M
