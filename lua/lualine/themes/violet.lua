------
-- Violet theme inspired by the airline theme and a bugged display of it.
------

local colors = {
  lightblue     = '#cacfd2',
  gray_0        = '#c6c6c6',
  gray_1        = '#bcbcbc',
  gray_2        = '#4e4e4e',
  gray_3        = '#3a3a3a',
  gray_4        = '#282828',
  rose          = '#ce537a',
  pink          = '#ff5faf',
  purple        = '#d75fd7',
  darkpurple    = '#875faf',
  aqua          = '#009966',
  yellow        = '#f0f571',
}

return {
  normal = {
    a = {bg = colors.darkpurple, fg = colors.gray_1, gui = 'bold'},
    b = {bg = colors.gray_4, fg = colors.purple},
    c = {bg = colors.purple, fg = colors.gray_0}
  },
  insert = {
    a = {bg = colors.yellow, fg = colors.darkpurple, gui = 'bold'},
    b = {bg = colors.gray_4, fg = colors.purple},
    c = {bg = colors.purple, fg = colors.gray_0}
  },
  visual = {
    a = {bg = colors.pink, fg = colors.gray_3, gui = 'bold'},
  },
  replace = {
    a = {bg = colors.rose, fg = colors.gray_0, gui = 'bold'},
  },
  command = {
    a = {bg = colors.gray_4, fg = colors.aqua, gui = 'bold'},
  },
  inactive = {
    a = {bg = colors.gray_3, fg = colors.rose, gui = 'bold'},
  }
}
