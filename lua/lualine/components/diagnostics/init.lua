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
  self.options = vim.tbl_deep_extend('keep', self.options or {}, modules.default_config.options)
  -- apply default sources
  if not self.options.sources then
    self.options.sources = { vim.fn.has('nvim-0.6') == 1 and 'nvim_diagnostic' or 'nvim_lsp', 'coc' }
  end
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
    local colors = {}
    for name, hl in pairs(self.highlight_groups) do
      colors[name] = modules.highlight.component_format_highlight(hl)
    end
    for _, section in ipairs(self.options.sections) do
      if diagnostics_count[section] ~= nil and (always_visible or diagnostics_count[section] > 0) then
        table.insert(result, colors[section] .. self.symbols[section] .. diagnostics_count[section])
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
