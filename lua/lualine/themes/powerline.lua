local powerline = {  }

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

powerline.normal = {
  a = { Colors.darkestgreen, Colors.brightgreen, 'bold', },
  b = { Colors.gray10,Colors.gray5, },
  c = { Colors.gray7, Colors.gray2, },
}

powerline.insert = {
  a = { Colors.darkestcyan, Colors.white, 'bold', },
  b = { Colors.darkestcyan,Colors.mediumcyan, },
  c = { Colors.mediumcyan, Colors.darkestblue, },
}


powerline.visual = {
  a = { Colors.darkred, Colors.brightorange, 'bold', },
}

powerline.replace = {
  a = { Colors.white, Colors.brightred, 'bold', },
}

powerline.inactive = {
  a = { Colors.gray1, Colors.gray5, 'bold', },
  b = { Colors.gray1,Colors.gray5, },
  c = { Colors.gray1, Colors.gray5, },
}

return powerline
