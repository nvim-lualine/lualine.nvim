-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
}

local Diagnostics = lualine_require.require('lualine.component'):new()

local function check_deprecated_options(options)
  if options.color_error or options.color_warn or options.color_info or options.color_hint then
    options.diagnostics_color = options.diagnostics_color or {}
    require('lualine.utils.notices').add_notice(string.format [[
### diagnostics.options.colors
Previously colors in diagnostics section was set with color_error, color_warning..
separate options . They've been unified under diagnostics_color options.
Now it should be something like:
```lua
{ 'diagnostics',
  sources = {'nvim_lsp'},
  diagnostics_color = {
    error = color_error,
    warning = color_warning,
    info = color_info,
    hint = color_hint,
  }
}
```
]])
    options.diagnostics_color.error = options.color_error
    options.diagnostics_color.warning = options.color_warning
    options.diagnostics_color.info = options.color_info
    options.diagnostics_color.hint = options.color_hint
  end
end

local default_symbols = {
  icons = {
    error = ' ', -- xf659
    warn = ' ', -- xf529
    info = ' ', -- xf7fc
    hint = ' ', -- xf838
  },
  no_icons = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
}

local default_options = {
  colored = true,
  update_in_insert = false,
  sources = { 'nvim_lsp', 'coc' },
  sections = { 'error', 'warn', 'info', 'hint' },
  diagnostics_color = {
    error = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticError', 'LspDiagnosticsDefaultError', 'DiffDelete' },
        '#e32636'
      ),
    },
    warn = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticWarn', 'LspDiagnosticsDefaultWarning', 'DiffText' },
        '#ffa500'
      ),
    },
    info = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticInfo', 'LspDiagnosticsDefaultInformation', 'Normal' },
        '#ffffff'
      ),
    },
    hint = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'DiagnosticHint', 'LspDiagnosticsDefaultHint', 'DiffChange' },
        '#273faf'
      ),
    },
  },
}
-- Initializer
Diagnostics.new = function(self, options, child)
  -- Run super()
  local new_diagnostics = self._parent:new(options, child or Diagnostics)
  -- Apply default options
  new_diagnostics.options = vim.tbl_deep_extend('keep', new_diagnostics.options or {}, default_options)
  check_deprecated_options(new_diagnostics.options)
  -- Apply default symbols
  new_diagnostics.symbols = vim.tbl_extend(
    'keep',
    new_diagnostics.options.symbols or {},
    new_diagnostics.options.icons_enabled ~= false and default_symbols.icons or default_symbols.no_icons
  )
  -- Initialize highlight groups
  if new_diagnostics.options.colored then
    new_diagnostics.highlight_groups = {
      error = modules.highlight.create_component_highlight_group(
        new_diagnostics.options.diagnostics_color.error,
        'diagnostics_error',
        new_diagnostics.options
      ),
      warn = modules.highlight.create_component_highlight_group(
        new_diagnostics.options.diagnostics_color.warn,
        'diagnostics_warn',
        new_diagnostics.options
      ),
      info = modules.highlight.create_component_highlight_group(
        new_diagnostics.options.diagnostics_color.info,
        'diagnostics_info',
        new_diagnostics.options
      ),
      hint = modules.highlight.create_component_highlight_group(
        new_diagnostics.options.diagnostics_color.hint,
        'diagnostics_hint',
        new_diagnostics.options
      ),
    }
  end

  -- Error out no source
  if #new_diagnostics.options.sources < 1 then
    print 'no sources for diagnostics configured'
    return ''
  end
  -- Initialize variable to store last update so we can use it in insert
  -- mode for no update_in_insert
  new_diagnostics.last_update = ''
  return new_diagnostics
end

Diagnostics.update_status = function(self)
  if not self.options.update_in_insert and vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
    return self.last_update
  end
  local error_count, warning_count, info_count, hint_count = 0, 0, 0, 0
  local diagnostic_data = self.get_diagnostics(self.options.sources)
  for _, data in pairs(diagnostic_data) do
    error_count = error_count + data.error
    warning_count = warning_count + data.warn
    info_count = info_count + data.info
    hint_count = hint_count + data.hint
  end
  local result = {}
  local data = {
    error = error_count,
    warn = warning_count,
    info = info_count,
    hint = hint_count,
  }
  if self.options.colored then
    local colors = {}
    for name, hl in pairs(self.highlight_groups) do
      colors[name] = modules.highlight.component_format_highlight(hl)
    end
    for _, section in ipairs(self.options.sections) do
      if data[section] ~= nil and data[section] > 0 then
        table.insert(result, colors[section] .. self.symbols[section] .. data[section])
      end
    end
  else
    for _, section in ipairs(self.options.sections) do
      if data[section] ~= nil and data[section] > 0 then
        table.insert(result, self.symbols[section] .. data[section])
      end
    end
  end
  self.last_update = ''
  if result[1] ~= nil then
    self.last_update = table.concat(result, ' ')
  end
  return self.last_update
end

Diagnostics.diagnostic_sources = {
  nvim_lsp = function()
    local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    local info_count = vim.lsp.diagnostic.get_count(0, 'Information')
    local hint_count = vim.lsp.diagnostic.get_count(0, 'Hint')
    return error_count, warning_count, info_count, hint_count
  end,
  nvim = function()
    local diagnostics = vim.diagnostic.get(0)
    local count = { 0, 0, 0, 0 }
    for _, diagnostic in ipairs(diagnostics) do
      count[diagnostic.severity] = count[diagnostic.severity] + 1
    end
    return count[vim.diagnostic.severity.ERROR],
      count[vim.diagnostic.severity.WARN],
      count[vim.diagnostic.severity.INFO],
      count[vim.diagnostic.severity.HINT]
  end,
  coc = function()
    local data = vim.b.coc_diagnostic_info
    if data then
      return data.error, data.warning, data.information, data.hint
    else
      return 0, 0, 0, 0
    end
  end,
  ale = function()
    local ok, data = pcall(vim.fn['ale#statusline#Count'], vim.fn.bufnr())
    if ok then
      return data.error + data.style_error, data.warning + data.style_warning, data.info, 0
    else
      return 0, 0, 0, 0
    end
  end,
  vim_lsp = function()
    local ok, data = pcall(vim.fn['lsp#get_buffer_diagnostics_counts'])
    if ok then
      return data.error, data.warning, data.information
    else
      return 0, 0, 0
    end
  end,
}

Diagnostics.get_diagnostics = function(sources)
  local result = {}
  for index, source in ipairs(sources) do
    if type(source) == 'string' then
      local error_count, warning_count, info_count, hint_count = Diagnostics.diagnostic_sources[source]()
      result[index] = {
        error = error_count,
        warn = warning_count,
        info = info_count,
        hint = hint_count,
      }
    elseif type(source) == 'function' then
      local source_result = source()
      source_result = type(source_result) == 'table' and source_result or {}
      result[index] = {
        error = source_result.error or 0,
        warn = source_result.warn or 0,
        info = source_result.info or 0,
        hint = source_result.hint or 0,
      }
    end
  end
  return result
end

return Diagnostics
