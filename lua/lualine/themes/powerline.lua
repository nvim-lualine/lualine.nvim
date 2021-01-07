local M = {  }

local Colors = {
  white          = {'#ffffff', 231},
  darkestgreen   = {'#005f00', 22 },
  brightgreen    = {'#afdf00', 148},
  darkestcyan    = {'#005f5f', 23 },
  mediumcyan     = {'#87dfff', 117},
  darkestblue    = {'#005f87', 24 },
  darkred        = {'#870000', 88 },
  brightred      = {'#df0000', 160},
  brightorange   = {'#ff8700', 214},
  gray1          = {'#262626', 235},
  gray2          = {'#303030', 236},
  gray4          = {'#585858', 240},
  gray5          = {'#606060', 241},
  gray7          = {'#9e9e9e', 245},
  gray10         = {'#f0f0f0', 252},
}

M.normal = {
  a = {
    fg = Colors.darkestgreen,
    bg = Colors.brightgreen,
    gui = 'bold',
  },
  b = {
    fg = Colors.gray10,
    bg = Colors.gray5,
  },
  c = {
    fg = Colors.gray7,
    bg = Colors.gray2,
  },
}

M.insert = {
  a = {
    fg = Colors.darkestcyan,
    bg = Colors.white,
    gui = 'bold',
  },
  b = {
    fg = Colors.darkestcyan,
    bg = Colors.mediumcyan,
  },
  c = {
    fg = Colors.mediumcyan,
    bg = Colors.darkestblue,
  },
}


M.visual = {
  a = {
    fg = Colors.darkred,
    bg = Colors.brightorange,
    gui = 'bold',
  },
}

M.replace = {
  a = {
    fg = Colors.white,
    bg = Colors.brightred,
    gui = 'bold',
  },
}

M.inactive = {
  a = {
    fg = Colors.gray1,
    bg = Colors.gray5,
    gui = 'bold',
  },
  b = {
    fg = Colors.gray1,
    bg = Colors.gray5,
  },
  c = {
    bg = Colors.gray1,
    fg = Colors.gray5,
  },
}

return M
