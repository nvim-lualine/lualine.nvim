-- MIT license, see LICENSE for more details.
-- Extension for fern file explorer.
local M = {}

local function fern_path()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end

M.sections = {
  lualine_a = { fern_path },
}

M.filetypes = { 'fern' }

return M
