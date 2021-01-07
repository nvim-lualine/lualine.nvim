local M = {  }

local colors = {
  black        = {"#282828", 235},
  white        = {'#ebdbb2', 223},
  red          = {'#fb4934', 203},
  green        = {'#b8bb26', 143},
  blue         = {'#83a598', 108},
  yellow       = {'#fe8019', 209},

  gray         = {'#a89984', 144},
  darkgray     = {'#3c3836', 237},

  lightgray    = {'#504945', 239},
  inactivegray = {'#7c6f64', 242},
}

M.normal = {
  a = {
    bg = colors.gray,
    fg = colors.black,
    gui = 'bold',
  },
  b = {
    bg = colors.lightgray,
    fg  = colors.white,
  },
  c = {
    bg = colors.darkgray,
    fg = colors.gray
  }
}

M.insert = {
  a = {
    bg = colors.blue,
    fg = colors.black,
    gui = 'bold',
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.lightgray,
    fg = colors.white
  }
}


M.visual = {
  a = {
    bg = colors.yellow,
    fg = colors.black,
    gui = 'bold',
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.inactivegray,
    fg = colors.black
  },
}

M.replace = {
  a = {
    bg = colors.red,
    fg = colors.black,
    gui = 'bold',
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.black,
    fg = colors.white
  },
}

M.command = {
  a = {
    bg = colors.green,
    fg = colors.black,
    gui = 'bold',
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.inactivegray,
    fg = colors.black
  },
}

M.inactive = {
  a = {
    bg = colors.darkgray,
    fg = colors.gray,
    gui = 'bold',
  },
  b = {
    bg = colors.darkgray,
    fg = colors.gray,
  },
  c = {
    bg = colors.darkgray,
    fg = colors.gray
  },
}

return M
