local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local M = {}

local function get_sign(name)
    local sign = vim.fn.sign_getdefined("DiagnosticSign" .. name)[1]
    return (sign and sign.text) or nil
end

-- default symbols for diagnostics component
M.symbols = {
  icons = {
    error = get_sign('Error') or '󰅚 ', -- x000f015a
    warn = get_sign('Warn') or '󰀪 ', -- x000f002a
    info = get_sign('Info') or '󰋽 ', -- x000f02fd
    hint = get_sign('Hint') or '󰌶 ', -- x000f0336
  },
  no_icons = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
}

-- default options for diagnostics component
M.options = {
  colored = true,
  update_in_insert = false,
  always_visible = false,
  sources = { vim.fn.has('nvim-0.6') == 1 and 'nvim_diagnostic' or 'nvim_lsp', 'coc' },
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
