-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  color3   = '#2c3043',
  color6   = '#a1aab8',
  color7   = '#82aaff',
  color8   = '#ae81ff',
  color0   = '#092236',
  color1   = '#ff5874',
  color2   = '#c3ccdc',
}

return {
  replace = {
    a = { fg = colors.color0, bg = colors.color1, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  inactive = {
    a = { fg = colors.color6, bg = colors.color3, gui = 'bold' },
    b = { fg = colors.color6, bg = colors.color3 },
    c = { fg = colors.color6, bg = colors.color3 },
  },
  normal = {
    a = { fg = colors.color0, bg = colors.color7, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color2, bg = colors.color3 },
  },
  visual = {
    a = { fg = colors.color0, bg = colors.color8, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  insert = {
    a = { fg = colors.color0, bg = colors.color2, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
}
