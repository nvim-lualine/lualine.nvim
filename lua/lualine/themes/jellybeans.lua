-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Genarated by lightline to lualine theme converter
-- https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9
-- LuaFormatter off
local colors = {
  color2   = '#30302c',
  color3   = '#f0a0c0',
  color4   = '#e8e8d3',
  color5   = '#4e4e43',
  color8   = '#cf6a4c',
  color9   = '#666656',
  color10  = '#808070',
  color11  = '#8197bf',
  color14  = '#99ad6a',
}
-- LuaFormatter on

local jellybeans = {
  visual = {
    a = {fg = colors.color2, bg = colors.color3, 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  replace = {
    a = {fg = colors.color2, bg = colors.color8, 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  inactive = {
    c = {fg = colors.color9, bg = colors.color2},
    a = {fg = colors.color10, bg = colors.color2, 'bold'},
    b = {fg = colors.color9, bg = colors.color2}
  },
  normal = {
    c = {fg = colors.color10, bg = colors.color2},
    a = {fg = colors.color2, bg = colors.color11, 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  insert = {
    a = {fg = colors.color2, bg = colors.color14, 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  }
}

return jellybeans
