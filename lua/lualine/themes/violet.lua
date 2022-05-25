------
-- Violet theme inspired by the airline theme and a bugged display of it.
------

local colors = {
  lightblue     = '#cacfd2',
  white         = '#ffffff',
  gray_0        = '#c6c6c6',
  gray_1        = '#bcbcbc',
  gray_2        = '#4e4e4e',
  gray_3        = '#3a3a3a',
  gray_4        = '#282828',
  rose          = '#ce537a',
  pink          = '#ff5faf',
  purple        = '#d75fff',
  darkpurple    = '#875faf',
  aqua          = '#009966',
  yellow        = '#f0f571',
  accent        = '#52736D',
}

return {
  normal = {
    a = {bg = colors.darkpurple, fg = colors.white, gui = 'bold'},
    b = {bg = colors.gray_3, fg = colors.lightblue},
    c = {bg = colors.gray_4, fg = colors.lightblue},
    y = {bg = colors.gray_3, fg = colors.pink},
  },
  insert = {
    a = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_4},
    c = {bg = colors.purple, fg = colors.white},
    x = {bg = colors.purple, fg = colors.aqua},
    y = {bg = colors.gray_4, fg = colors.white},
    z = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
  },
  visual = {
    a = {bg = colors.yellow, fg = colors.white, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_4},
    c = {bg = colors.purple, fg = colors.white}
  },
  replace = {
    a = {bg = colors.rose, fg = colors.white, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_4},
    c = {bg = colors.purple, fg = colors.white},
  },
  command = {
    a = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
    b = {bg = colors.darkpurple, fg = colors.gray_4},
    c = {bg = colors.gray_4, fg = colors.lightblue},
    x = {bg = colors.gray_4, fg = colors.pink}, y = {bg = colors.gray_4, fg = colors.white},
    z = {bg = colors.aqua, fg = colors.white, gui = 'bold'},
  },
  inactive = {
    a = {bg = colors.accent, fg = colors.lightblue, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_4},
    c = {bg = colors.purple, fg = colors.white},
  }
}
