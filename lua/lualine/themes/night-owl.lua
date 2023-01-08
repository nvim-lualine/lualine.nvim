local colors = {
  dark = '#010d18',
  light = '#d6deeb',
  magenta = '#c792ea',
  green = '#c5e478',
  yellow = '#e2b93d',
  orange = '#f78c6c',
  cyan = '#6ae9f0',
  dark_blue = '#0e293f',
  light_blue = '#5f7e97',
}

return {
  normal = {
    a = { bg = colors.magenta, fg = colors.dark, gui = 'bold' },
    b = { bg = colors.dark, fg = colors.light },
    c = { bg = colors.dark, fg = colors.light },
  },
  insert = {
    a = { bg = colors.green, fg = colors.dark, gui = 'bold' },
    b = { bg = colors.dark, fg = colors.light },
    c = { bg = colors.dark, fg = colors.light },
  },
  visual = {
    a = { bg = colors.yellow, fg = colors.dark, gui = 'bold' },
    b = { bg = colors.dark, fg = colors.light },
    c = { bg = colors.dark, fg = colors.light },
  },
  replace = {
    a = { bg = colors.orange, fg = colors.dark, gui = 'bold' },
    b = { bg = colors.dark, fg = colors.light },
    c = { bg = colors.dark, fg = colors.light },
  },
  command = {
    a = { bg = colors.cyan, fg = colors.dark, gui = 'bold' },
    b = { bg = colors.dark, fg = colors.light },
    c = { bg = colors.dark, fg = colors.light },
  },
  inactive = {
    a = { bg = colors.dark_blue, fg = colors.light_blue, gui = 'bold' },
    b = { bg = colors.dark_blue, fg = colors.light_blue },
    c = { bg = colors.dark_blue, fg = colors.light_blue },
  },
}
