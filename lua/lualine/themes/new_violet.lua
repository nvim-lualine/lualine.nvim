------
-- Violet theme inspired by the 'violet' airline theme, that was even nicer with a bug.
------

local colors = {
  lightblue     = '#cacfd2',
  white         = '#ffffff',
  gray_0        = '#3a3a3a',
  gray_1        = '#282828',
  rose          = '#ce537a',
  pink          = '#ff5faf',
  purple        = '#d75fff',
  darkpurple    = '#875faf',
  aqua          = '#009966',
  yellow        = '#f0f571',
}

return {
  normal = {
    a = {bg = colors.darkpurple, fg = colors.white, gui = 'bold'},
    b = {bg = colors.gray_0, fg = colors.lightblue},
    c = {bg = colors.gray_1, fg = colors.lightblue},
    y = {bg = colors.gray_0, fg = colors.pink},
  },
  insert = {
    a = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.white},
    c = {bg = colors.purple, fg = colors.white},
    x = {bg = colors.purple, fg = colors.white},
    y = {bg = colors.darkpurple, fg = colors.white},
    z = {bg = colors.rose, fg = colors.white, gui = 'bold'},
  },
  visual = {
    a = {bg = colors.yellow, fg = colors.gray_1, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.white},
    c = {bg = colors.purple, fg = colors.white},
    y = {bg = colors.darkpurple, fg = colors.white},
  },
  replace = {
    a = {bg = colors.gray_1, fg = colors.white, gui = 'bold'},
    b = {bg = colors.aqua, fg = colors.white},
    c = {bg = colors.aqua, fg = colors.white},
    z = {bg = colors.rose, fg = colors.gray_1},
  },
  command = {
    a = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
    b = {bg = colors.darkpurple, fg = colors.white},
    c = {bg = colors.gray_1, fg = colors.white},
    x = {bg = colors.gray_1, fg = colors.white},
    y = {bg = colors.gray_1, fg = colors.white},
    z = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
  },
  inactive = {
    a = {bg = colors.gray_1, fg = colors.white, gui = 'bold'},
    b = {bg = colors.gray_0, fg = colors.lightblue},
    c = {bg = colors.gray_0, fg = colors.lightblue},
    z = {bg = colors.aqua, fg = colors.pink},
  }
}
