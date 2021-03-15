-- Copyright (c) 2020-2021 Shatur95
-- MIT license, see LICENSE for more details.
local codedark = {}
-- LuaFormatter off
local colors = {
  gray     = '#3C3C3C',
  lightred = '#D16969',
  blue     = '#569CD6',
  pink     = '#C586C0',
  black    = '#262626',
  white    = '#D4D4D4',
  green    = '#608B4E',
}
-- LuaFormatter on

codedark.normal = {
  b = {fg = colors.green, bg = colors.black},
  a = {fg = colors.black, bg = colors.green, 'bold'},
  c = {fg = colors.white, bg = colors.black}
}

codedark.visual = {
  b = {fg = colors.pink, bg = colors.black},
  a = {fg = colors.black, bg = colors.pink, 'bold'}
}

codedark.inactive = {
  b = {fg = colors.black, bg = colors.blue},
  a = {fg = colors.white, bg = colors.gray, 'bold'}
}

codedark.replace = {
  b = {fg = colors.lightred, bg = colors.black},
  a = {fg = colors.black, bg = colors.lightred, 'bold'},
  c = {fg = colors.white, bg = colors.black}
}

codedark.insert = {
  b = {fg = colors.blue, bg = colors.black},
  a = {fg = colors.black, bg = colors.blue, 'bold'},
  c = {fg = colors.white, bg = colors.black}
}

return codedark
