-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Genarated by lightline to lualine theme converter
-- https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9
-- LuaFormatter off
local colors = {
  color0   = '#ffffff',
  color1   = '#99c794',
  color2   = '#65737e',
  color3   = '#343d46',
  color4   = '#6699cc',
  color5   = '#d8dee9',
  color6   = '#f99157',
  color7   = '#ec5f67',
}
-- LuaFormatter on

local oceanicnext = {
  insert = {
    a = {fg = colors.color0, bg = colors.color1, 'bold'},
    b = {fg = colors.color0, bg = colors.color2},
    c = {fg = colors.color0, bg = colors.color3}
  },
  normal = {
    a = {fg = colors.color0, bg = colors.color4, 'bold'},
    b = {fg = colors.color0, bg = colors.color2},
    c = {fg = colors.color0, bg = colors.color3}
  },
  inactive = {
    a = {fg = colors.color5, bg = colors.color2, 'bold'},
    b = {fg = colors.color5, bg = colors.color3},
    c = {fg = colors.color2, bg = colors.color3}
  },
  visual = {
    a = {fg = colors.color0, bg = colors.color6, 'bold'},
    b = {fg = colors.color0, bg = colors.color2},
    c = {fg = colors.color0, bg = colors.color3}
  },
  replace = {
    a = {fg = colors.color0, bg = colors.color7, 'bold'},
    b = {fg = colors.color0, bg = colors.color2},
    c = {fg = colors.color0, bg = colors.color3}
  }
}

return oceanicnext
