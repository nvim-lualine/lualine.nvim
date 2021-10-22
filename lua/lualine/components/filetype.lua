-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local utils = require('lualine.utils.utils')

local FileType = require('lualine.component'):new()

FileType.update_status = function(self)
  local data = vim.bo.filetype
  if #data > 0 then
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
      local icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)
      self.options.icon = icon

      if self.options.icon and
          (self.options.colored or self.options.colored == nil) then
        self.options.colored = true

        local highlight_color = utils.extract_highlight_colors(icon_highlight_group, 'fg')
        local is_focused = vim.g.statusline_winid == vim.fn.win_getid()
        local default_highlight = highlight.format_highlight(is_focused,
                                                             self.options.self
                                                                 .section)
        local icon_highlight = self.options.self.section .. '_' ..
                                   icon_highlight_group
        if not utils.highlight_exists(icon_highlight .. '_normal') then
          icon_highlight = highlight.create_component_highlight_group(
                               {fg = highlight_color}, icon_highlight_group,
                               self.options)
        end

        self.options.icon =
            highlight.component_format_highlight(icon_highlight) ..
                self.options.icon .. default_highlight
      end
    else
      ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
      if ok ~= 0 then
        self.options.icon = vim.fn.WebDevIconsGetFileTypeSymbol()
      end
    end
    return data
  end
  return ''
end

return FileType
