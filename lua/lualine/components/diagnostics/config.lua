local require = require('lualine_require').require
local utils = require 'lualine.utils.utils'
local M = {}

M.symbols = {
  icons = {
    error = ' ', -- xf659
    warn = ' ', -- xf529
    info = ' ', -- xf7fc
    hint = ' ', -- xf838
  },
  no_icons = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
}

M.options = {
  colored = true,
  update_in_insert = false,
  sources = { 'nvim_lsp', 'coc' },
  sections = { 'error', 'warn', 'info', 'hint' },
  diagnostics_color = {
    error = {
      fg = utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticError', 'LspDiagnosticsDefaultError', 'DiffDelete' },
        '#e32636'
      ),
    },
    warn = {
      fg = utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticWarn', 'LspDiagnosticsDefaultWarning', 'DiffText' },
        '#ffa500'
      ),
    },
    info = {
      fg = utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticInfo', 'LspDiagnosticsDefaultInformation', 'Normal' },
        '#ffffff'
      ),
    },
    hint = {
      fg = utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticHint', 'LspDiagnosticsDefaultHint', 'DiffChange' },
        '#273faf'
      ),
    },
  },
}

return M
