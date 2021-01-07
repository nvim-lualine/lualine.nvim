local forest_night = {}

local colors = {
  bg0    = {"#323d43", 237},
  bg1    = {"#3c474d", 238},
  bg3    = {"#505a60", 240},
  fg     = {"#d8caac", 187},
  aqua   = {"#87c095", 108},
  green  = {"#a7c080", 144},
  orange = {"#e39b7b", 180},
  purple = {"#d39bb6", 181},
  red    = {"#e68183", 174},
  grey1  = {"#868d80", 102},
}

forest_night.normal = {
  a = {
    bg = colors.green,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.insert = {
  a = {
    bg = colors.fg,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.visual = {
  a = {
    bg = colors.red,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.replace = {
  a = {
    bg = colors.orange,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.command = {
  a = {
    bg = colors.aqua,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.terminal = {
  a = {
    bg = colors.purple,
    fg = colors.bg0,
    gui = 'bold',
  },
  b = {
    bg = colors.bg3,
    fg = colors.fg,
  },
  c = {
    bg = colors.bg1,
    fg = colors.fg,
  },
}

forest_night.inactive = {
  a = {
    bg = colors.bg1,
    fg = colors.grey1,
    gui = 'bold',
  },
  b = {
    bg = colors.bg1,
    fg = colors.grey1,
  },
  c = {
    bg = colors.bg1,
    fg = colors.grey1,
  },
}

return forest_night
