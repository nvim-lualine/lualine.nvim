-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require'lualine_require'
local modules = lualine_require.lazy_require{
  highlight = 'lualine.highlight',
  utils     = 'lualine.utils.utils',
}
local FileType = lualine_require.require('lualine.component'):new()

function FileType:new(options, child)
  local new_instance = self._parent:new(options, child or FileType)
  if new_instance.options.colored == nil then
    new_instance.options.colored = true
  end
  if new_instance.options.disable_text == nil then
    new_instance.options.disable_text = false
  end
  return new_instance
end

function FileType.update_status() return vim.bo.filetype or '' end

function FileType:apply_icon()
  if not self.options.icons_enabled then return end

  local icon, icon_highlight_group
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    local f_name, f_extension = vim.fn.expand('%:t'), vim.fn.expand('%:e')
    icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)

    if icon and self.options.colored then
      local highlight_color = modules.utils.extract_highlight_colors(
                                  icon_highlight_group, 'fg')
      local is_focused = modules.utils.is_focused()
      local default_highlight = modules.highlight.format_highlight(is_focused,
                                                           self.options.self
                                                               .section)
      local icon_highlight = self.options.self.section .. '_' ..
                                 icon_highlight_group
      if not modules.utils.highlight_exists(icon_highlight .. '_normal') then
        icon_highlight = modules.highlight.create_component_highlight_group(
                             {fg = highlight_color}, icon_highlight_group,
                             self.options)
      end

      icon = modules.highlight.component_format_highlight(icon_highlight) .. icon ..
                 default_highlight
    end
  else
    ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
    if ok ~= 0 then icon = vim.fn.WebDevIconsGetFileTypeSymbol() end
  end

  if not icon then return end

  if self.options.disable_text then
    self.status = icon
  else
    self.status = icon .. ' ' .. self.status
  end
end

return FileType
