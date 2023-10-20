local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local M = {}

-- default symbols for diagnostics component
M.symbols = {
  icons = {
    error = '󰅚 ', -- x000f015a
    warn = '󰀪 ', -- x000f002a
    info = '󰋽 ', -- x000f02fd
    hint = '󰌶 ', -- x000f0336
  },
  no_icons = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
}

-- default options for diagnostics component
M.options = {
  colored = true,
  update_in_insert = false,
  always_visible = false,
  sources = { 'nvim_diagnostic', 'coc' },
  sections = { 'error', 'warn', 'info', 'hint' },
}

function M.apply_default_colors(opts)
  local default_diagnostics_color = {
    error = {
      fg = utils.extract_color_from_hllist(
        { 'fg', 'sp' },
        { 'DiagnosticError', 'LspDiagnosticsDefaultError', 'DiffDelete' },
        '#e32636'
      ),
    },
    warn = {
      fg = utils.extract_color_from_hllist(
        { 'fg', 'sp' },
        { 'DiagnosticWarn', 'LspDiagnosticsDefaultWarning', 'DiffText' },
        '#ffa500'
      ),
    },
    info = {
      fg = utils.extract_color_from_hllist(
        { 'fg', 'sp' },
        { 'DiagnosticInfo', 'LspDiagnosticsDefaultInformation', 'Normal' },
        '#ffffff'
      ),
    },
    hint = {
      fg = utils.extract_color_from_hllist(
        { 'fg', 'sp' },
        { 'DiagnosticHint', 'LspDiagnosticsDefaultHint', 'DiffChange' },
        '#273faf'
      ),
    },
  }
  opts.diagnostics_color = vim.tbl_deep_extend('keep', opts.diagnostics_color or {}, default_diagnostics_color)
end

return M
