-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
  default_config = 'lualine.components.diagnostics.config',
  sources = 'lualine.components.diagnostics.sources',
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
}

local M = lualine_require.require('lualine.component'):extend()

M.diagnostics_sources = modules.sources.sources
M.get_diagnostics = modules.sources.get_diagnostics

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
  -- Apply default options
  self.options = vim.tbl_deep_extend('keep', self.options or {}, modules.default_config.options)
  -- Apply default symbols
  self.symbols = vim.tbl_extend(
    'keep',
    self.options.symbols or {},
    self.options.icons_enabled ~= false and modules.default_config.symbols.icons
      or modules.default_config.symbols.no_icons
  )
  -- Initialize highlight groups
  if self.options.colored then
    self.highlight_groups = {
      error = modules.highlight.create_component_highlight_group(
        self.options.diagnostics_color.error,
        'diagnostics_error',
        self.options
      ),
      warn = modules.highlight.create_component_highlight_group(
        self.options.diagnostics_color.warn,
        'diagnostics_warn',
        self.options
      ),
      info = modules.highlight.create_component_highlight_group(
        self.options.diagnostics_color.info,
        'diagnostics_info',
        self.options
      ),
      hint = modules.highlight.create_component_highlight_group(
        self.options.diagnostics_color.hint,
        'diagnostics_hint',
        self.options
      ),
    }
  end

  -- Error out no source
  if #self.options.sources < 1 then
    print 'no sources for diagnostics configured'
    return ''
  end
  -- Initialize variable to store last update so we can use it in insert
  -- mode for no update_in_insert
  self.last_update = ''
end

function M:update_status()
  if not self.options.update_in_insert and vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
    return self.last_update
  end
  local error_count, warning_count, info_count, hint_count = 0, 0, 0, 0
  local diagnostic_data = modules.sources.get_diagnostics(self.options.sources)
  -- sum all the counts
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

  local always_visible = false
  if type(self.options.always_visible) == 'boolean' then
    always_visible = self.options.always_visible
  elseif type(self.options.always_visible) == 'function' then
    always_visible = self.options.always_visible()
  end

  -- format the counts with symbols and highlights
  if self.options.colored then
    local colors = {}
    for name, hl in pairs(self.highlight_groups) do
      colors[name] = modules.highlight.component_format_highlight(hl)
    end
    for _, section in ipairs(self.options.sections) do
      if data[section] ~= nil and (always_visible or data[section] > 0) then
        table.insert(result, colors[section] .. self.symbols[section] .. data[section])
      end
    end
  else
    for _, section in ipairs(self.options.sections) do
      if data[section] ~= nil and (always_visible or data[section] > 0) then
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

return M
