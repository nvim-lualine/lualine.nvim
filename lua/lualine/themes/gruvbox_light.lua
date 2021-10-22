-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  black        = '#3c3836',
  white        = '#f9f5d7',
  orange       = '#af3a03',
  green        = '#427b58',
  blue         = '#076678',
  gray         = '#d5c4a1',
  darkgray     = '#7c6f64',
  lightgray    = '#ebdbb2',
  inactivegray = '#a89984'
}

return {
  normal = {
    a = { bg = colors.darkgray, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.darkgray },
    c = { bg = colors.lightgray, fg = colors.darkgray },
  },
  insert = {
    a = { bg = colors.blue, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.darkgray },
    c = { bg = colors.gray, fg = colors.black },
  },
  visual = {
    a = { bg = colors.orange, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.darkgray },
    c = { bg = colors.darkgray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.green, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.darkgray },
    c = { bg = colors.gray, fg = colors.black },
  },
  command = {
    a = { bg = colors.darkgray, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.darkgray },
    c = { bg = colors.lightgray, fg = colors.darkgray },
  },
  inactive = {
    a = { bg = colors.lightgray, fg = colors.inactivegray },
    b = { bg = colors.lightgray, fg = colors.inactivegray },
    c = { bg = colors.lightgray, fg = colors.inactivegray },
  },
}
