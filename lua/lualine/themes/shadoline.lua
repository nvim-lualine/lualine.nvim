-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Genarated by lightline to lualine theme converter
-- https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9
-- LuaFormatter off
local colors = {
  color2   = '#282525',
  color3   = '#E9608F',
  color4   = '#282525',
  color5   = '#EE90DD',
  color8   = '#CC74ED',
  color9   = '#282525',
  color10  = '#AA74ED',
  color11  = '#282525',
  color12  = '#F82E74',
  color15  = '#922A6C',
}
-- LuaFormatter on
return {
  visual = {
    a = {fg = colors.color2, bg = colors.color3, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  replace = {
    a = {fg = colors.color2, bg = colors.color8, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  inactive = {
    c = {fg = colors.color9, bg = colors.color10},
    a = {fg = colors.color9, bg = colors.color10, gui = 'bold'},
    b = {fg = colors.color9, bg = colors.color10}
  },
  normal = {
    c = {fg = colors.color9, bg = colors.color10},
    a = {fg = colors.color11, bg = colors.color12, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  insert = {
    a = {fg = colors.color2, bg = colors.color15, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  }
}
