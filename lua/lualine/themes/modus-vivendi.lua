-- Copyright (c) 2020-2021 ronniedroid
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
    black     = '#000000',
    white     = '#eeeeee',
    red       = '#ffa0a0',
    green     = '#88cf88',
    blue      = '#92baff',
    magenta   = '#feacd0',
    cyan      = '#a0bfdf',
    gray      = '#2f2f2f',
    darkgray  = '#202020',
    lightgray = '#434343'
}

return {
  normal = {
    a = { bg = colors.blue, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.blue },
    c = { bg = colors.gray, fg = colors.white },
  },
  insert = {
    a = { bg = colors.cyan, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.cyan },
    c = { bg = colors.gray, fg = colors.white },
  },
  visual = {
    a = { bg = colors.magenta, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.magenta },
    c = { bg = colors.gray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.red, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.red },
    c = { bg = colors.gray, fg = colors.white },
  },
  command = {
    a = { bg = colors.green, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.green },
    c = { bg = colors.gray, fg = colors.white },
  },
  inactive = {
    a = { bg = colors.darkgray, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.lightgray },
    c = { bg = colors.darkgray, fg = colors.lightgray },
  },
}
