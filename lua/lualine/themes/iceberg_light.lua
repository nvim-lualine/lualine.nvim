-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Genarated by lightline to lualine theme converter
-- https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9
-- LuaFormatter off
local colors = {
  color5   = '#668e3d',
  color8   = '#757ca3',
  color9   = '#8b98b6',
  color10  = '#cad0de',
  color11  = '#2d539e',
  color0   = '#e8e9ec',
  color1   = '#9fa6c0',
  color2   = '#c57339',
}
-- LuaFormatter on

local iceberg = {
  replace = {
    b = {fg = colors.color0, bg = colors.color1},
    a = {fg = colors.color0, bg = colors.color2, 'bold'}
  },
  visual = {
    b = {fg = colors.color0, bg = colors.color1},
    a = {fg = colors.color0, bg = colors.color5, 'bold'}
  },
  normal = {
    b = {fg = colors.color0, bg = colors.color1},
    a = {fg = colors.color0, bg = colors.color8, 'bold'},
    c = {fg = colors.color9, bg = colors.color10}
  },
  inactive = {
    b = {fg = colors.color9, bg = colors.color10},
    a = {fg = colors.color9, bg = colors.color10, 'bold'},
    c = {fg = colors.color9, bg = colors.color10}
  },
  insert = {
    b = {fg = colors.color0, bg = colors.color1},
    a = {fg = colors.color0, bg = colors.color11, 'bold'}
  }
}

return iceberg
