-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: itchyny(lightline)
-- stylua: ignore
local colors = {
  base03  = '#242424',
  base023 = '#353535',
  base02  = '#444444',
  base01  = '#585858',
  base00  = '#666666',
  base0   = '#808080',
  base1   = '#969696',
  base2   = '#a8a8a8',
  base3   = '#d0d0d0',
  yellow  = '#cae682',
  orange  = '#e5786d',
  red     = '#e5786d',
  magenta = '#f2c68a',
  blue    = '#8ac6f2',
  cyan    = '#8ac6f2',
  green   = '#95e454',
}

return {
  normal = {
    a = { fg = colors.base02, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.base02, bg = colors.base0 },
    c = { fg = colors.base2, bg = colors.base02 },
  },
  insert = { a = { fg = colors.base02, bg = colors.green, gui = 'bold' } },
  visual = { a = { fg = colors.base02, bg = colors.magenta, gui = 'bold' } },
  replace = { a = { fg = colors.base023, bg = colors.red, gui = 'bold' } },
  inactive = {
    a = { fg = colors.base1, bg = colors.base02, gui = 'bold' },
    b = { fg = colors.base023, bg = colors.base01 },
    c = { fg = colors.base1, bg = colors.base023 },
  },
}
