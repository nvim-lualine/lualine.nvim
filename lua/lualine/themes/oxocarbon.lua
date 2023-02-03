-- Copyright (c) 2023 charleszheng44
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  black        = '#161616',
  white        = '#fafafa',
  red          = '#ee5396',
  green        = '#08bdba',
  blue         = '#78a9ff',
  yellow       = '#ffab91',
  gray         = '#37474F',
  darkgray     = '#1A1C23',
  lightgray    = '#2e303e',
  inactivegray = '#1C1E26',
  purple       = '#673ab7',
  lightpurple  = '#be95ff',
}

return {
  normal = {
    a = { bg = colors.blue, fg = colors.inactivegray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  insert = {
    a = { bg = colors.red, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  visual = {
    a = { bg = colors.lightpurple, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  command = {
    a = { bg = colors.green, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  inactive = {
    c = { bg = colors.darkgray, fg = colors.lightgray },
  },
}
