-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: Zoltan Dalmadi(lightline)
-- stylua: ignore
local colors = {
  blue   = '#61afef',
  green  = '#98c379',
  purple = '#c678dd',
  red1   = '#e06c75',
  red2   = '#be5046',
  yellow = '#e5c07b',
  fg     = '#494b53',
  bg     = '#fafafa',
  gray1  = '#494b53',
  gray2  = '#f0f0f0',
  gray3  = '#d0d0d0',
}

return {
  normal = {
    a = {fg = colors.bg, bg = colors.green, gui = 'bold'},
    b = {fg = colors.fg, bg = colors.gray3},
    c = {fg = colors.fg, bg = colors.gray2}
  },
  insert = {a = {fg = colors.bg, bg = colors.blue, gui = 'bold'}},
  visual = {a = {fg = colors.bg, bg = colors.purple, gui = 'bold'}},
  replace = {a = {fg = colors.bg, bg = colors.red1, gui = 'bold'}},
  inactive = {
    a = {fg = colors.bg, bg = colors.gray3, gui = 'bold'},
    b = {fg = colors.bg, bg = colors.gray3},
    c = {fg = colors.gray3, bg = colors.gray2}
  }

}
