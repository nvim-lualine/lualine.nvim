-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit itchyny, jackno (lightline)
-- stylua: ignore
local colors = {
  black   = '#000000',
  maroon  = '#800000',
  green   = '#008000',
  olive   = '#808000',
  navy    = '#000080',
  purple  = '#800080',
  teal    = '#008080',
  silver  = '#c0c0c0',
  gray    = '#808080',
  red     = '#ff0000',
  lime    = '#00ff00',
  yellow  = '#ffff00',
  blue    = '#0000ff',
  fuchsia = '#ff00ff',
  aqua    = '#00ffff',
  white   = '#ffffff',
}

return {
  normal = {
    a = { fg = colors.white, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.white, bg = colors.gray },
    c = { fg = colors.silver, bg = colors.black },
  },
  insert = { a = { fg = colors.white, bg = colors.green, gui = 'bold' } },
  visual = { a = { fg = colors.white, bg = colors.purple, gui = 'bold' } },
  replace = { a = { fg = colors.white, bg = colors.red, gui = 'bold' } },
  inactive = {
    a = { fg = colors.silver, bg = colors.gray, gui = 'bold' },
    b = { fg = colors.gray, bg = colors.black },
    c = { fg = colors.silver, bg = colors.black },
  },
}
