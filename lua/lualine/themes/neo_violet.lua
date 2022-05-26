local colors = {
  lightblue     = '#cacfd2',
  gray_0        = '#c6c6c6',
  gray_1        = '#bcbcbc',
  gray_2        = '#4e4e4e',
  gray_3        = '#3a3a3a',
  accent        = '#5f0000',
  rose          = '#ce537a',
  pink          = '#ff5faf',
  purple        = '#d75fd7',
  darkpurple    = '#875faf',
  aqua          = '#009966',
}

return {
  normal = {
    a = {bg = colors.gray_1, fg = colors.darkpurple, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  },
  insert = {
    a = {bg = colors.lightblue, fg = colors.aqua, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  },
  visual = {
    a = {bg = colors.accent, fg = colors.pink, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  },
  replace = {
    a = {bg = colors.gray_0, fg = colors.rose, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  },
  command = {
    a = {bg = colors.aqua, fg = colors.gray_3, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  },
  inactive = {
    a = {bg = colors.gray_3, fg = colors.rose, gui = 'bold'},
    b = {bg = colors.purple, fg = colors.gray_2},
    c = {bg = colors.gray_0, fg = colors.gray_3}
  }
}
