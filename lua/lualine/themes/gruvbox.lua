local M = {  }

local Colors = {
  black = "#282828",
  white = '#ebdbb2',
  red = '#fb4934',
  green = '#b8bb26',
  blue = '#83a598',
  yellow = '#fe8019',

  gray = '#a89984',
  darkgray = '#3c3836',

  lightgray = '#504945',
  inactivegray = '#7c6f64',
}

M.normal = {
  a = {
    bg = Colors.gray,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightgray,
    fg  = Colors.white,
  },
  c = {
    bg = Colors.darkgray,
    fg = Colors.gray
  }
}

M.insert = {
  a = {
    bg = Colors.blue,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightgray,
    fg = Colors.white,
  },
  c = {
    bg = Colors.lightgray,
    fg = Colors.white
  }
}


M.visual = {
  a = {
    bg = Colors.yellow,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightgray,
    fg = Colors.white,
  },
  c = {
    bg = Colors.inactivegray,
    fg = Colors.black
  },
}

M.replace = {
  a = {
    bg = Colors.red,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightgray,
    fg = Colors.white,
  },
  c = {
    bg = Colors.black,
    fg = Colors.white
  },
}

M.command = {
  a = {
    bg = Colors.green,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightgray,
    fg = Colors.white,
  },
  c = {
    bg = Colors.inactivegray,
    fg = Colors.black
  },
}

M.terminal = M.normal

M.inactive = {
  a = {
    bg = Colors.darkgray,
    fg = Colors.gray,
  },
  b = {
    bg = Colors.darkgray,
    fg = Colors.gray,
  },
  c = {
    bg = Colors.darkgray,
    fg = Colors.gray
  },
}

return M
