-- Copyright (c) 2020-2021 Shatur95
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  gray     = '#3C3C3C',
  lightred = '#D16969',
  blue     = '#569CD6',
  pink     = '#C586C0',
  black    = '#262626',
  white    = '#D4D4D4',
  green    = '#608B4E',
}

return {
  normal = {
    b = { fg = colors.green, bg = colors.black },
    a = { fg = colors.black, bg = colors.green, gui = 'bold' },
    c = { fg = colors.white, bg = colors.black },
  },
  visual = {
    b = { fg = colors.pink, bg = colors.black },
    a = { fg = colors.black, bg = colors.pink, gui = 'bold' },
  },
  inactive = {
    b = { fg = colors.black, bg = colors.blue },
    a = { fg = colors.white, bg = colors.gray, gui = 'bold' },
  },
  replace = {
    b = { fg = colors.lightred, bg = colors.black },
    a = { fg = colors.black, bg = colors.lightred, gui = 'bold' },
    c = { fg = colors.white, bg = colors.black },
  },
  insert = {
    b = { fg = colors.blue, bg = colors.black },
    a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
    c = { fg = colors.white, bg = colors.black },
  },
}
