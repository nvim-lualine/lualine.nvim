-- Copyright (c) 2022 Hugosxm
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  black        = '#091833',
  white        = '#0ABDC6',
  red          = '#FF0000',
  green        = '#00FF00',
  blue         = '#EA00D9',
  yellow       = '#f57800',
  gray         = '#0ABDC6',
  darkgray     = '#091833',
  lightgray    = '#133E7C',
  inactivegray = '#091833',
}

return {
  normal = {
    a = { bg = colors.gray, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  insert = {
    a = { bg = colors.blue, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  visual = {
    a = { bg = colors.green, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.red, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  command = {
    a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  inactive = {
    a = { bg = colors.inactivegray, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.inactivegray, fg = colors.lightgray },
    c = { bg = colors.inactivegray, fg = colors.lightgray },
  },
}

