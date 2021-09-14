-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}
local FileType = lualine_require.require('lualine.component'):new()

local function check_deprecated_options(options)
  local function rename_notice(before, now)
    if options[before] then
      require('lualine.utils.notices').add_notice(string.format(
        [[
### option.%s
%s option has been renamed to `%s`. Please use `%s` instead in your config
for filetype component.
]],
        before,
        before,
        now,
        now
      ))
      options[now] = options[before]
      options[before] = nil
    end
  end
  rename_notice('disable_text', 'icon_only')
end

local default_options = {
  colored = true,
  icon_only = false,
}

function FileType:new(options, child)
  local new_instance = self._parent:new(options, child or FileType)
  new_instance.options = vim.tbl_deep_extend('keep', new_instance.options or {}, default_options)
  check_deprecated_options(new_instance.options)
  return new_instance
end

function FileType.update_status()
  return vim.bo.filetype or ''
end

function FileType:apply_icon()
  if not self.options.icons_enabled then
    return
  end

  local icon, icon_highlight_group
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    local f_name, f_extension = vim.fn.expand '%:t', vim.fn.expand '%:e'
    icon, icon_highlight_group = devicons.get_icon(f_name, f_extension)

    if icon and self.options.colored then
      local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, 'fg')
      local is_focused = modules.utils.is_focused()
      local default_highlight = modules.highlight.format_highlight(is_focused, self.options.self.section)
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
    ok = vim.fn.exists '*WebDevIconsGetFileTypeSymbol'
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

return FileType
