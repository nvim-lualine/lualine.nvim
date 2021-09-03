-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: Lokesh Krishna(lightline)
-- stylua: ignore
local colors = {
  fg     = '#eeffff',
  bg     = '#263238',
  blue   = '#82aaff',
  green  = '#c3e88d',
  purple = '#c792ea',
  red1   = '#f07178',
  red2   = '#ff5370',
  yellow = '#ffcb6b',
  gray1  = '#314549',
  gray2  = '#2E3C43',
  gray3  = '#515559',
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.gray3 },
    c = { fg = colors.fg, bg = colors.gray2 },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.gray3 },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.purple, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.gray3 },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.red1, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.gray3 },
  },
  inactive = {
    a = { fg = colors.fg, bg = colors.bg, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.gray2 },
  },
}
