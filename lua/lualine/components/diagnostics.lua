-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local utils = require('lualine.utils.utils')

local default_color_error = '#e32636'
local default_color_warn  = '#ffdf00'
local default_color_info  = '#ffffff'

local diagnostic_sources = {
  nvim_lsp = function()
    local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    local info_count = vim.lsp.diagnostic.get_count(0, 'Information') +
    vim.lsp.diagnostic.get_count(0, 'Hint')
    return error_count, warning_count, info_count
  end,
  coc = function()
    local data = vim.b.coc_diagnostic_info
    if data then
      return data.error, data.warning, data.information
    else
      return 0, 0, 0
    end
  end,
  ale = function()
    local ok, data = pcall(vim.fn['ale#statusline#Count'], vim.fn.bufnr())
    if ok then
      return data.error, data.warning, data.info
    else
      return 0, 0, 0
    end
  end,
}

local function get_diagnostics(sources)
  local result = {}
  for index, source in ipairs(sources) do
    local error_count, warning_count, info_count = diagnostic_sources[source]()
    result[index] = {error = error_count, warn = warning_count, info = info_count}
  end
  return result
end

local function diagnostics(options)
  if options.symbols == nil then
    if options.icons_enabled then
      options.symbols = {
        error = ' ', -- xf659
        warn  = ' ', -- xf529
        info  = ' ', -- xf7fc
      }
    else
      options.symbols = {
        error = 'E:',
        warn  = 'W:',
        info  = 'I:'
      }
    end
  end
  if options.sources == nil then
    print('no sources for diagnostics configured')
    return ''
  end
  if options.sections == nil then options.sections = {'error', 'warn', 'info'} end
  if options.colored == nil then options.colored = true end
  -- apply colors
  if not options.color_error then
    options.color_error = utils.extract_highlight_colors('DiffDelete', 'foreground') or default_color_error
  end
  if not options.color_warn then
    options.color_warn = utils.extract_highlight_colors('DiffText', 'foreground') or default_color_warn
  end
  if not options.color_info then
    options.color_info = utils.extract_highlight_colors('Normal', 'foreground') or default_color_info
  end

  local highlight_groups = {}
  local function add_highlights()
    highlight_groups = {
      error = highlight.create_component_highlight_group({ fg = options.color_error }, 'diagnostics_error', options),
      warn  = highlight.create_component_highlight_group({ fg = options.color_warn }, 'diagnostics_warn', options),
      info  = highlight.create_component_highlight_group({ fg = options.color_info }, 'diagnostics_info', options),
    }
  end

  if options.colored then
    add_highlights()
    utils.expand_set_theme(add_highlights)
  end

  return function()
    local error_count, warning_count, info_count = 0,0,0
    local diagnostic_data = get_diagnostics(options.sources)
    for _, data in pairs(diagnostic_data) do
      error_count   = error_count   + data.error
      warning_count = warning_count + data.warn
      info_count    = info_count    + data.info
    end
    local result = {}
    local data = {
      error = error_count,
      warn  = warning_count,
      info  = info_count,
    }
    if options.colored then
      local colors = {}
      for name, hl in pairs(highlight_groups) do
        colors[name] = highlight.component_format_highlight(hl)
      end
      for _, section in ipairs(options.sections) do
        if data[section] ~= nil and data[section] > 0 then
          table.insert(result, colors[section]..options.symbols[section]..data[section])
        end
      end
    else
      for _, section in ipairs(options.sections) do
        if data[section] ~= nil and data[section] > 0 then
          table.insert(result,options.symbols[section]..data[section])
        end
      end
    end
    if result[1] ~= nil then
      return table.concat(result, ' ')
    else
      return ''
    end
  end
end

return {
  init = function(options) return diagnostics(options) end,
  get_diagnostics = get_diagnostics,
}
