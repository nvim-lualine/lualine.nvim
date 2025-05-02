-- MIT license, see LICENSE for more details.
-- Extension for lf file explorer.

local function lf_statusline()
  local buf = vim.api.nvim_buf_get_name(0)
  local match = buf:match('^term://[^:]*:(lf)')
  if match then return 'Lf' end
  -- TODO: return default statusline if
  -- toggleterm extension isn't enabled
  return 'ToggleTerm #' .. vim.b.toggle_number
end

local M = {}

M.sections = {
  lualine_a = { lf_statusline }
}

M.filetypes = { 'toggleterm' }

return M
