-- MIT license, see LICENSE for more details.
-- Extension for nvim-dap-ui

local dap_lua, _ = pcall(require, 'dap')

local function dap_status()
  if not dap_lua then
    return ''
  end

  local status = require('dap').status()

  if status == nil or status == '' then
    return ''
  else
    return 'DAP: ' .. status
  end
end

local M = {}

M.sections = {
  lualine_a = { { 'filename', file_status = false } },
  lualine_x = { dap_status },
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
