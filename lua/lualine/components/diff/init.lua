-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  git_diff = 'lualine.components.diff.git_diff',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
  highlight = 'lualine.highlight',
}
local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  colored = true,
  show_all_if_any = false,
  symbols = { added = '+', modified = '~', removed = '-' },
}

local function apply_default_colors(opts)
  local default_diff_color = {
    added = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'GitSignsAdd', 'GitGutterAdd', 'DiffAdded', 'DiffAdd' },
        '#90ee90'
      ),
    },
    modified = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'GitSignsChange', 'GitGutterChange', 'DiffChanged', 'DiffChange' },
        '#f0e130'
      ),
    },
    removed = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'GitSignsDelete', 'GitGutterDelete', 'DiffRemoved', 'DiffDelete' },
        '#ff0038'
      ),
    },
  }
  opts.diff_color = vim.tbl_deep_extend('keep', opts.diff_color or {}, default_diff_color)
end

-- Initializer
function M:init(options)
  M.super.init(self, options)
  apply_default_colors(self.options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  -- create highlights and save highlight_name in highlights table
  if self.options.colored then
    self.highlights = {
      added = self:create_hl(self.options.diff_color.added, 'added'),
      modified = self:create_hl(self.options.diff_color.modified, 'modified'),
      removed = self:create_hl(self.options.diff_color.removed, 'removed'),
    }
  end
  modules.git_diff.init(self.options)
end

-- Function that runs everytime statusline is updated
function M:update_status(is_focused)
  local git_diff = modules.git_diff.get_sign_count((not is_focused and vim.api.nvim_get_current_buf()))
  if git_diff == nil then
    return ''
  end

  local colors = {}
  if self.options.colored then
    -- load the highlights and store them in colors table
    for name, highlight_name in pairs(self.highlights) do
      colors[name] = self:format_hl(highlight_name)
    end
  end

  local result = {}
  local has_any = false
  -- loop though data and load available sections in result table
  for _, name in ipairs { 'added', 'modified', 'removed' } do
    local val = git_diff[name]
    if val and (val > 0 or self.options.show_all_if_any) then
      local color = self.options.colored and colors[name] or ''
      table.insert(result, color .. self.options.symbols[name] .. val)
      if val > 0 then has_any = true end
    end
  end
  if has_any then
    return table.concat(result, ' ')
  else
    return ''
  end
end

return M
