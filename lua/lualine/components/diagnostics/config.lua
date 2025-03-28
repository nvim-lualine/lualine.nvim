local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local M = {}

local function get_sign(severity)
  local config = vim.diagnostic.config() or {}
  local signs = config.signs or {}
  if type(signs) == 'function' then
    signs = signs(0, 0)
  end
  return (type(signs) == 'table' and signs.text and signs.text[severity]) or nil
end
-- https://github.com/folke/trouble.nvim/blob/85bedb7eb7fa331a2ccbecb9202d8abba64d37b3/lua/trouble/format.lua#L97

-- default symbols for diagnostics component
M.symbols = {
  icons = {
    error = get_sign(vim.diagnostic.severity.ERROR) or '󰅚 ', -- x000f015a
    warn = get_sign(vim.diagnostic.severity.WARN) or '󰀪 ', -- x000f002a
    info = get_sign(vim.diagnostic.severity.INFO) or '󰋽 ', -- x000f02fd
    hint = get_sign(vim.diagnostic.severity.HINT) or '󰌶 ', -- x000f0336
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
