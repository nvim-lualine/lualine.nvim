-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: Zoltan Dalmadi(lightline)
-- stylua: ignore
local colors = {
  blue   = '#4078f2',
  green  = '#50a14f',
  purple = '#a626a4',
  red1   = '#e45649',
  red2   = '#ca1243',
  yellow = '#c18401',
  fg     = '#494b53',
  bg     = '#fafafa',
  gray1  = '#696c77',
  gray2  = '#f0f0f0',
  gray3  = '#d0d0d0',
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.gray3 },
    c = { fg = colors.fg, bg = colors.gray2 },
  },
  command = { a = { fg = colors.bg, bg = colors.yellow, gui = 'bold' } },
  insert = { a = { fg = colors.bg, bg = colors.blue, gui = 'bold' } },
  visual = { a = { fg = colors.bg, bg = colors.purple, gui = 'bold' } },
  replace = { a = { fg = colors.bg, bg = colors.red1, gui = 'bold' } },
  inactive = {
    a = { fg = colors.bg, bg = colors.gray3, gui = 'bold' },
    b = { fg = colors.bg, bg = colors.gray3 },
    c = { fg = colors.gray3, bg = colors.gray2 },
  },
}
