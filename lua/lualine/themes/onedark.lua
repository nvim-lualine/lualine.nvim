-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: Zoltan Dalmadi(lightline)
-- stylua: ignore
local colors = {
  blue   = '#61afef',
  green  = '#98c379',
  purple = '#c678dd',
  cyan   = '#56b6c2',
  red1   = '#e06c75',
  red2   = '#be5046',
  yellow = '#e5c07b',
  fg     = '#abb2bf',
  bg     = '#282c34',
  gray1  = '#828997',
  gray2  = '#2c323c',
  gray3  = '#3e4452',
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
  terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = 'bold' } },
  replace = { a = { fg = colors.bg, bg = colors.red1, gui = 'bold' } },
  inactive = {
    a = { fg = colors.gray1, bg = colors.bg, gui = 'bold' },
    b = { fg = colors.gray1, bg = colors.bg },
    c = { fg = colors.gray1, bg = colors.gray2 },
  },
}
