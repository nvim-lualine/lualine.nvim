local colors = {
  gray_1        = '#bcbcbc',
  darkpurple  = '#875faf',
  purple      = '#d75fd7',
  gray_0   = '#c6c6c6',
  gray_3    = '#3a3a3a',
  lightblue   = '#cacfd2',
  aqua        = '#009966',
  accent      = '#5f0000',
  pink   = '#ff5faf',
  rose        = '#ce537a',
  gray_2       = '#4e4e4e'
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
require('lualine').setup {options = {theme = violet}}
