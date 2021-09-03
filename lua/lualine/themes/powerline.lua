-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local Colors = {
  white          = '#ffffff',
  darkestgreen   = '#005f00',
  brightgreen    = '#afdf00',
  darkestcyan    = '#005f5f',
  mediumcyan     = '#87dfff',
  darkestblue    = '#005f87',
  darkred        = '#870000',
  brightred      = '#df0000',
  brightorange   = '#ff8700',
  gray1          = '#262626',
  gray2          = '#303030',
  gray4          = '#585858',
  gray5          = '#606060',
  gray7          = '#9e9e9e',
  gray10         = '#f0f0f0',
}

return {
  normal = {
    a = { fg = Colors.darkestgreen, bg = Colors.brightgreen, gui = 'bold' },
    b = { fg = Colors.gray10, bg = Colors.gray5 },
    c = { fg = Colors.gray7, bg = Colors.gray2 },
  },
  insert = {
    a = { fg = Colors.darkestcyan, bg = Colors.white, gui = 'bold' },
    b = { fg = Colors.darkestcyan, bg = Colors.mediumcyan },
    c = { fg = Colors.mediumcyan, bg = Colors.darkestblue },
  },
  visual = { a = { fg = Colors.darkred, bg = Colors.brightorange, gui = 'bold' } },
  replace = { a = { fg = Colors.white, bg = Colors.brightred, gui = 'bold' } },
  inactive = {
    a = { fg = Colors.gray1, bg = Colors.gray5, gui = 'bold' },
    b = { fg = Colors.gray1, bg = Colors.gray5 },
    c = { bg = Colors.gray1, fg = Colors.gray5 },
  },
}
