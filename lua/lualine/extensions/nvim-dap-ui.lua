-- MIT license, see LICENSE for more details.
-- Extension for nvim-dap-ui
local M = {}

M.sections = {
  lualine_a = { { 'filename', file_status = false } },
}

M.filetypes = {
  'dap-repl',
  'dapui_console',
  'dapui_watches',
  'dapui_stacks',
  'dapui_breakpoints',
  'dapui_scopes',
}

return M
