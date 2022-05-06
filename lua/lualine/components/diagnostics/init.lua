-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
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
  modules.default_config.apply_default_colors(self.options)
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
      error = self:create_hl(self.options.diagnostics_color.error, 'error'),
      warn = self:create_hl(self.options.diagnostics_color.warn, 'warn'),
      info = self:create_hl(self.options.diagnostics_color.info, 'info'),
      hint = self:create_hl(self.options.diagnostics_color.hint, 'hint'),
    }
  end

  -- Initialize variable to store last update so we can use it in insert
  -- mode for no update_in_insert
  self.last_diagnostics_count = {}

  -- Error out no source
  if #self.options.sources < 1 then
    modules.utils_notices.add_notice(
      '### diagnostics.sources\n\nno sources for diagnostics configured.\nPlease specify which diagnostics source you want lualine to use with `sources` option.\n'
    )
  end
end

function M:update_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics_count
  local result = {}
  if self.options.update_in_insert or vim.api.nvim_get_mode().mode:sub(1, 1) ~= 'i' then
    local error_count, warning_count, info_count, hint_count = 0, 0, 0, 0
    local diagnostic_data = modules.sources.get_diagnostics(self.options.sources)
    -- sum all the counts
    for _, data in pairs(diagnostic_data) do
      error_count = error_count + data.error
      warning_count = warning_count + data.warn
      info_count = info_count + data.info
      hint_count = hint_count + data.hint
    end
    diagnostics_count = {
      error = error_count,
      warn = warning_count,
      info = info_count,
      hint = hint_count,
    }
    -- Save count for insert mode
    self.last_diagnostics_count[bufnr] = diagnostics_count
  else -- Use cached count in insert mode with update_in_insert disabled
    diagnostics_count = self.last_diagnostics_count[bufnr] or { error = 0, warn = 0, info = 0, hint = 0 }
  end

  local always_visible = false
  if type(self.options.always_visible) == 'boolean' then
    always_visible = self.options.always_visible
  elseif type(self.options.always_visible) == 'function' then
    always_visible = self.options.always_visible()
  end

  -- format the counts with symbols and highlights
  if self.options.colored then
    local colors, bgs = {}, {}
    for name, hl in pairs(self.highlight_groups) do
      colors[name] = self:format_hl(hl)
      bgs[name] = modules.utils.extract_highlight_colors(colors[name]:match('%%#(.-)#'), 'bg')
    end
    local previous_section, padding
    for _, section in ipairs(self.options.sections) do
      if diagnostics_count[section] ~= nil and (always_visible or diagnostics_count[section] > 0) then
        padding = previous_section and (bgs[previous_section] ~= bgs[section]) and ' ' or ''
        previous_section = section
        table.insert(result, colors[section] .. padding .. self.symbols[section] .. diagnostics_count[section])
      end
    end
  else
    for _, section in ipairs(self.options.sections) do
      if diagnostics_count[section] ~= nil and (always_visible or diagnostics_count[section] > 0) then
        table.insert(result, self.symbols[section] .. diagnostics_count[section])
      end
    end
  end
  return table.concat(result, ' ')
end

return M
