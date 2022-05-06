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
  self.icon_hl_cache = {}
end

function M.update_status()
  local ft = vim.bo.filetype or ''
  return modules.utils.stl_escape(ft)
end

function M:apply_icon()
  if not self.options.icons_enabled then
    return
  end

  local icon_char, icon, icon_highlight_group
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    icon_char, icon_highlight_group = self:extract_icons(devicons)

    if icon_char and self.options.colored then
      local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
      if highlight_color then
        local default_highlight = self:get_default_hl()
        local icon_highlight = self:icon_hl_for(highlight_color)
        if not icon_highlight or not modules.highlight.highlight_exists(icon_highlight.name .. '_' .. self:mode()) then
          icon_highlight = self:create_hl({ fg = highlight_color }, icon_highlight_group)
          self:save_icon_hl_for(highlight_color, icon_highlight)
        end

        icon = self:format_hl(icon_highlight, self:is_focused()) .. icon_char .. default_highlight
      end
    end
  else
    ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
    if ok ~= 0 then
      icon_char = vim.fn.WebDevIconsGetFileTypeSymbol()
      icon = icon_char
    end
  end

  if not icon then
    return
  end

  if self.options.icon_only then
    self.status = icon
    self.len = self.len and vim.fn.strdisplaywidth(icon_char)
  else
    self.len = self.len and self.len + vim.fn.strdisplaywidth(icon_char) + 1
    if type(self.options.icon) == 'table' and self.options.icon.align == 'right' then
      self.status = self.status .. ' ' .. icon
    else
      self.status = icon .. ' ' .. self.status
    end
  end
end

function M:extract_icons(devicons)
  local f_name = self.f_name or vim.fn.expand('%:t')
  local f_extension = self.f_extension or vim.fn.expand('%:e')
  local filetype = self.filetype or vim.bo.filetype
  local buftype = self.buftype or vim.bo.buftype

  local icon_char, icon_highlight_group = devicons.get_icon(f_name, f_extension)
  if not icon_char then
    icon_char, icon_highlight_group = devicons.get_icon_by_filetype(filetype)
  end
  if not icon_char then
    icon_char, icon_highlight_group = devicons.get_icon_by_filetype(buftype)
  end
  if not icon_char and type(self.options.icon) == 'table' and self.options.icon.use_default then
    icon_char, icon_highlight_group = devicons.get_icon('', '', { default = true })
  end

  return icon_char, icon_highlight_group
end

function M:icon_hl_for(highlight_color)
  return self.icon_hl_cache[highlight_color]
end

function M:save_icon_hl_for(highlight_color, highlight)
  self.icon_hl_cache[highlight_color] = highlight
end

function M:is_focused()
  return false
end

function M:mode()
  return self:is_focused() and 'normal' or 'inactive'
end

return M
