-- Copyright (c) 2020-2021 arturgoms
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  black  = '#0A0E14',
  gray   = '#504945',
  white  = '#f9f5d7',
  cyan   = '#83a598',
  green  = '#b8bb26',
  orange = '#fe8019',
  yellow = '#fabd2f',
  blue   = '#458588',
}

return {
  visual = {
    a = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
    b = { fg = colors.white, bg = colors.black },
  },
  replace = {
    a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.white, bg = colors.black },
  },
  inactive = {
    c = { fg = colors.white, bg = colors.black },
    a = { fg = colors.white, bg = colors.gray, gui = 'bold' },
    b = { fg = colors.white, bg = colors.gray },
  },
  normal = {
    a = { fg = colors.black, bg = colors.yellow, gui = 'bold' },
    b = { fg = colors.white, bg = colors.gray },
  },
  insert = {
    a = { fg = colors.black, bg = colors.green, gui = 'bold' },
    b = { fg = colors.white, bg = colors.gray },
  },
}
