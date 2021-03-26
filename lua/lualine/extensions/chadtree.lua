os = require('os')

local function short_cwd ()
  local cwd = os.getenv('PWD')
  local home = os.getenv('HOME')
  return cwd:gsub(home, '~')
end

local M = {}

M.sections = {lualine_a = { short_cwd }}

M.inactive_sections = M.sections

M.filetypes = {'CHADTree'}

return M
