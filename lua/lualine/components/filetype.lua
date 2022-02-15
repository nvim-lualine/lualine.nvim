-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}
local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  colored = true,
  icon_only = false,
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

function M.update_status()
  local ft = vim.bo.filetype or ''
  return modules.utils.stl_escape(ft)
end

function M:apply_icon()
  if not self.options.icons_enabled then
    return
  end

  local icon, icon_highlight_group
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
    f_extension = f_extension ~= '' and f_extension or vim.bo.filetype
    icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)

    if icon and self.options.colored then
      local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
      local default_highlight = modules.highlight.format_highlight(self.options.self.section)
      local icon_highlight = self.options.self.section .. '_' .. icon_highlight_group
      if not modules.highlight.highlight_exists(icon_highlight .. '_normal') then
        icon_highlight = modules.highlight.create_component_highlight_group(
          { fg = highlight_color },
          icon_highlight_group,
          self.options
        )
      end

      icon = modules.highlight.component_format_highlight(icon_highlight) .. icon .. default_highlight
    end
  else
    ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
    if ok ~= 0 then
      icon = vim.fn.WebDevIconsGetFileTypeSymbol()
    end
  end

  if not icon then
    return
  end

  if self.options.icon_only then
    self.status = icon
  else
    self.status = icon .. ' ' .. self.status
  end
end

return M
