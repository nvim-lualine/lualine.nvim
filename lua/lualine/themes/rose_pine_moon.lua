local colors = {
  gray       = '#2a273f',
  lightgray  = '#393552',
  orange     = '#ea9a97',
  red        = '#eb6f92',
  yellow     = '#f6c177',
  green      = '#9ccfd8',
  white      = '#e0def4',
  black      = '#232136',
}

return {
  normal = {
    a = { bg = colors.black, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.white },
    c = { bg = colors.lightgray, fg = colors.white },
  },
  insert = {
    a = { bg = colors.green, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  visual = {
    a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.red, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  command = {
    a = { bg = colors.orange, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  inactive = {
    a = { bg = colors.gray, fg = colors.white, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
}
