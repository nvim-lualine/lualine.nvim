-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local utils = require('lualine.utils.utils')
local utils_notices = require('lualine.utils.notices')

local Diagnostics = require('lualine.component'):new()

-- LuaFormatter off
Diagnostics.default_colors = {
  error = '#e32636',
  warn  = '#ffdf00',
  info  = '#ffffff',
  hint  = '#d7afaf',
}
-- LuaFormatter on

local function color_deprecation_notice(color, opt_name)
  utils_notices.add_notice(string.format([[
### Diagnostics component
Using option `%s` as string to set foreground color has been deprecated
and will soon be removed. Now this option has same semantics as regular
`color` option for components. Means now you can set bg/fg or both.
String value is still valid but it's interpreted differemtly. When a
string is used for this option it's treated as a highlight group name.
In that case `%s` will be linked to that highlight group.

You have something like this in your config.

```lua
  {'diagnostics',
    %s = '%s',
  }
```

You'll have to change it to this to retain previous behavior

```lua
  {'diagnostics',
    %s = { fg = '%s'},
  }
```
]], opt_name, opt_name, opt_name, color, opt_name, color))
end

-- Initializer
Diagnostics.new = function(self, options, child)
  local new_diagnostics = self._parent:new(options, child or Diagnostics)
  local default_symbols = new_diagnostics.options.icons_enabled and {
    error = ' ', -- xf659
    warn = ' ', -- xf529
    info = ' ', -- xf7fc
    hint = ' ' -- xf838
  } or {error = 'E:', warn = 'W:', info = 'I:', hint = 'H:'}
  new_diagnostics.symbols = vim.tbl_extend('force', default_symbols,
                                           new_diagnostics.options.symbols or {})
  if new_diagnostics.options.sources == nil then
    print('no sources for diagnostics configured')
    return ''
  end
  if new_diagnostics.options.sections == nil then
    new_diagnostics.options.sections = {'error', 'warn', 'info', 'hint'}
  end
  if new_diagnostics.options.colored == nil then
    new_diagnostics.options.colored = true
  end
  if new_diagnostics.options.update_in_insert == nil then
    new_diagnostics.options.update_in_insert = false
  end
  new_diagnostics.last_update = ''
  -- apply colors
  if not new_diagnostics.options.color_error then
    new_diagnostics.options.color_error = {fg =
        utils.extract_highlight_colors('LspDiagnosticsDefaultError', 'fg') or
            utils.extract_highlight_colors('DiffDelete', 'fg') or
            Diagnostics.default_colors.error }
  elseif type(new_diagnostics.options.color_error) == 'string'
    and vim.fn.hlexists(new_diagnostics.options.color_error) == 0 then
    new_diagnostics.options.color_error = {fg = new_diagnostics.options.color_error}
    color_deprecation_notice(new_diagnostics.options.color_error.fg, 'color_error')
  end
  if not new_diagnostics.options.color_warn then
    new_diagnostics.options.color_warn = {fg =
        utils.extract_highlight_colors('LspDiagnosticsDefaultWarning', 'fg') or
            utils.extract_highlight_colors('DiffText', 'fg') or
            Diagnostics.default_colors.warn }
  elseif type(new_diagnostics.options.color_warn) == 'string'
    and vim.fn.hlexists(new_diagnostics.options.color_warn) == 0 then
    new_diagnostics.options.color_warn = {fg = new_diagnostics.options.color_warn}
    color_deprecation_notice(new_diagnostics.options.color_warn.fg, 'color_warn')
  end
  if not new_diagnostics.options.color_info then
    new_diagnostics.options.color_info = {fg =
        utils.extract_highlight_colors('LspDiagnosticsDefaultInformation', 'fg') or
            utils.extract_highlight_colors('Normal', 'fg') or
            Diagnostics.default_colors.info}
  elseif type(new_diagnostics.options.color_info) == 'string'
    and vim.fn.hlexists(new_diagnostics.options.color_info) == 0 then
    new_diagnostics.options.color_info = {fg = new_diagnostics.options.color_info}
    color_deprecation_notice(new_diagnostics.options.color_info.fg, 'color_info')
  end
  if not new_diagnostics.options.color_hint then
    new_diagnostics.options.color_hint = {fg =
        utils.extract_highlight_colors('LspDiagnosticsDefaultHint', 'fg') or
            utils.extract_highlight_colors('DiffChange', 'fg') or
            Diagnostics.default_colors.hint}
  elseif type(new_diagnostics.options.color_hint) == 'string'
    and vim.fn.hlexists(new_diagnostics.options.color_hint) == 0 then
    new_diagnostics.options.color_hint = {fg = new_diagnostics.options.color_hint}
    color_deprecation_notice(new_diagnostics.options.color_hint.fg, 'color_hint')
  end

  if new_diagnostics.options.colored then
    new_diagnostics.highlight_groups = {
      error = highlight.create_component_highlight_group(
          new_diagnostics.options.color_error, 'diagnostics_error',
          new_diagnostics.options),
      warn = highlight.create_component_highlight_group(
          new_diagnostics.options.color_warn, 'diagnostics_warn',
          new_diagnostics.options),
      info = highlight.create_component_highlight_group(
          new_diagnostics.options.color_info, 'diagnostics_info',
          new_diagnostics.options),
      hint = highlight.create_component_highlight_group(
          new_diagnostics.options.color_hint, 'diagnostics_hint',
          new_diagnostics.options)
    }
  end

  return new_diagnostics
end

Diagnostics.update_status = function(self)
  if not self.options.update_in_insert
    and vim.api.nvim_get_mode().mode:sub(1,1) == 'i' then
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
    hint = hint_count
  }
  if self.options.colored then
    local colors = {}
    for name, hl in pairs(self.highlight_groups) do
      colors[name] = highlight.component_format_highlight(hl)
    end
    for _, section in ipairs(self.options.sections) do
      if data[section] ~= nil and data[section] > 0 then
        table.insert(result,
                     colors[section] .. self.symbols[section] .. data[section])
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
  end
}

Diagnostics.get_diagnostics = function(sources)
  local result = {}
  for index, source in ipairs(sources) do
    local error_count, warning_count, info_count, hint_count =
        Diagnostics.diagnostic_sources[source]()
    result[index] = {
      error = error_count,
      warn = warning_count,
      info = info_count,
      hint = hint_count
    }
  end
  return result
end

return Diagnostics
